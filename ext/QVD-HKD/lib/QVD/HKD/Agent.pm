package QVD::HKD::Agent;

#BEGIN { *debug = \$QVD::HKD::debug }

use 5.010;
use strict;
use warnings;

use AnyEvent::Util ();
use AnyEvent::HTTP;
use QVD::HKD::Helpers;
use Pg::PQ qw(:pgres);
use QVD::Log;
use JSON;

use parent qw(Class::StateMachine);

our $debug = 1;

sub new {
    my ($class, %opts) = @_;
    my $config = delete $opts{config};
    my $db = delete $opts{db};
    my $node_id = delete $opts{node_id};
    my $on_stopped = delete $opts{on_stopped};

    croak_invalid_opts %opts;

    my $self = { config => $config,
                 db => $db,
                 node_id => $node_id,
                 on_stopped => $on_stopped };

    Class::StateMachine::bless($self, $class);
}

sub _main_state {
    my $state = shift->state;
    $state =~ s|/.*$||;
    $state;
}

sub _cfg { shift->{config}->_cfg(@_) }

sub _maybe_callback {
    my $self = shift;
    my $cb = shift;
    my $sub = $self->{$cb};
    if (defined $sub) {
        if ($debug) {
            local ($@, $ENV{__DIE__});
            my $name = eval {
                require Devel::Peek;
                Devel::Peek::CvGV($sub)
                } // 'unknown';
            $self->_debug("calling $cb as $sub ($name) with args @_");
        }
        $sub->($self, @_);
    }
    else {
        $debug and $self->_debug("no callback for $cb");
    }
}

sub _debug {
    my $self = shift;
    my $state = $self->state;
    my $method = (caller 1)[3];
    $method =~ s/.*:://;
    warn "[$self state: $state]\@$method> @_\n";
}

sub _query_callbacks {
    my $name = shift;
    $name =~ s/.*::_?//;
    [ "_on_${name}_result",
      "_on_${name}_error",
      "_on_${name}_done",
      "_on_${name}_bad_result"]
}

my %query_callbacks;

sub _query_n {
    my ($self, $n, $sql, @args) = @_;
    my $method = (caller 1)[3];
    my ($on_result, $on_error, $on_done, $on_bad_result) = @{$query_callbacks{$method} //= _query_callbacks($method)};

    if ($debug) {
        $self->can($_) or $self->_debug("warning: callback method $_ not found!")
            for ($on_result, $on_error, $on_done, $on_bad_result);

        my $line = $sql;
        $line =~ s/\s+/ /gms;
        $self->_debug("sql: >$line<, args: >@args<");
    }


    my $db = $self->_db // die "internal error: database handler not available";
    my $seq = $db->push_query(query     => $sql,
                              args      => \@args,
                              on_result => sub {
                                  $debug and $self->_debug("calling method $on_result");
                                  my $res = $_[1];
                                  given ($res->status) {
                                      when (PGRES_TUPLES_OK) {
                                          return $self->$on_result($res)
                                              if (!defined $n or $res->rows == $n);
                                      }
                                      when (PGRES_COMMAND_OK) {
                                          return $self->$on_result($res)
                                              if (!defined $n or $res->cmdRows == $n);
                                      }
                                  }
                                  $debug and $self->_debug("actually calling method $on_bad_result");
                                  $self->$on_bad_result($res);
                              },
                              on_error  => sub {
                                  delete $self->{current_query_seq};
                                  $debug and $self->_debug("calling method $on_error");
                                  $self->$on_error
                              },
                              on_done   => sub {
                                  delete $self->{current_query_seq};
                                  my $m = $self->can($on_done);
                                  if ($m) {
                                      $debug and $self->_debug("calling method $on_done");
                                      $m->($self);
                                  }
                                  else {
                                      $debug and $self->_debug("there is not method $on_done");
                                  }
                              },
                             );
    $self->{current_query_seq} = $seq;
}

sub _query {
    my $self = shift;
    unshift @_, ($self, undef);
    goto &_query_n;
}

sub _query_1 {
    my $self = shift;
    unshift @_, ($self, 1);
    goto &_query_n;
}

sub _cancel_current_query {
    my $self = shift;
    if (my $seq = $self->{current_query_seq}) {
        $self->db->cancel_query($seq);
    }
}

sub _db {
    my $self = shift;
    $self->{db} = shift if @_;
    $self->{db};
}

sub _run_cmd {
    my $self = shift;
    my $cmd = shift;
    my $method = (caller 1)[3];
    my (undef, $on_error, $on_done) = @{$query_callbacks{$method} //= _query_callbacks($method)};

    if ($debug) {
        $self->can($_) or $self->_debug("warning: callback method $_ not found!")
            for ($on_error, $on_done);
        $self->_debug("running command @$cmd");
    }

    my $w = $self->{cmd_watcher} = AnyEvent::Util::run_cmd($cmd,
                                                           '$$' => \$self->{cmd_pid},
                                                           @_);
    $w->cb( sub {
                my $rc = shift->recv;
                if ($rc) {
                    delete $self->{cmd_watcher};
                    delete $self->{cmd_pid};
                    $cmd = [$cmd] unless ref $cmd;
                    $debug and $self->_debug("command failed: @$cmd => $rc");
                    ERROR "command @$cmd failed: $rc";
                    $self->$on_error($rc);
                }
                else {
                    delete $self->{cmd_watcher};
                    delete $self->{cmd_pid};
                    $self->$on_done
                }
            });
}

sub _kill_cmd {
    my ($self, $signal) = @_;
    my $pid = $self->{cmd_pid} or return undef;
    $signal //= 'TERM';
    $debug and $self->_debug("killing $pid with signal $signal");
    kill $signal => $pid;
}

my $json;
sub _json { $json //= JSON->new->ascii->pretty->allow_nonref }

sub _rpc {
    my $self = shift;
    $self->{rpc_last_query} = [@_];

    my $method = shift;
    my $url = "$self->{rpc_service}/$method";

    $self->{rpc_retry_count} //= $self->_cfg('internal.hkd.agent.rpc.retry.count');
    $self->{rpc_retry_delay} //= $self->_cfg('internal.hkd.agent.rpc.retry.delay');

    my @query;
    while (@_) {
        my $key = shift;
        my $value = shift;
        push @query, uri_escape($key) . '=' . uri_escape($value);
    }
    $url .= '?' . join('&', @query) if @query;

    my ($on_result, $on_error, $on_done) = @{$query_callbacks{"rpc_$method"} //= _query_callbacks("rpc_$method")};

    if ($debug) {
        $self->can($_) or $self->_debug("warning: callback method $_ not found!")
            for ($on_result, $on_error, $on_done);
    }

    my $w = http_get($url, persistent => 0,
                     timeout => $self->_cfg('internal.hkd.agent.rpc.timeout'),
                     cb => sub {
                         $debug and $self->_debug("on http_get callback");
                         my $headers = $_[1];
                         my $status = $headers->{Status};
                         my ($result, $error);
                         if ($status =~ /^2\d\d$/) {
                             my $data = _json->decode("[$_[0]]");
                             if (defined $data) {
                                 ($result, $error) = @$data;
                                 if (defined $error) {
                                     $self->$on_error($error);
                                 }
                                 else {
                                     $self->$on_result($result);
                                 }
                             }
                             else {
                                 $debug and $self->_debug("bad JSON response: $_[0]");
                                 $self->$on_error("bad JSON response");
                             }
                         }
                         else {
                             $debug and $self->_debug("bad response status: $status");
                             return $self->_rpc_retry if $self->{rpc_retry_count};

                             $self->$on_error("HTTP response status: $status");
                         }
                         $self->$on_done if $self->{rpc_watcher}; # may be unset on a previous callback
                     });

    delete $self->{rpc_retry_count};
    delete $self->{rpc_retry_delay};

    $self->{rpc_watcher} = $w;
}

sub _rpc_retry {
    my $self = shift;
    $self->{rpc_retry_count}--;
    $self->{rpc_watcher} = AnyEvent->timer(after => $self->{rpc_retry_count},
                                           cb => sub {
                                               $debug and $self->_debug("retrying rpc query");
                                               $self->rpc(@{$self->{rpc_last_query}})
                                           });
}

sub _abort_rpc {
    my $self = shift;
    $debug and $self->_debug("_abort_rpc called");
    undef $self->{rpc_watcher}
}

sub _call_after {
    my ($self, $delay, $method) = @_;
    $self->{call_after_timer} = AnyEvent->timer(after => $delay,
                                                cb => sub {
                                                    $debug and $self->_debug("call after timeout, method: $method");
                                                    $self->$method
                                                });
}

use Data::Dumper;

sub _abort_call_after {
    my $self = shift;
    $debug and $self->_debug("_abort_call_after called");
    undef $self->{call_after_timer}
}

sub DESTROY {
    local $!;
    my $self = shift;
    $debug and $self->_debug("$self->DESTROY called");
    $self->_kill_cmd('KILL');
}

sub _abort_all {
    my $self = shift;
    $self->_abort_call_after;
    $self->_abort_rpc;
    $self->_cancel_current_query;
}

1;
