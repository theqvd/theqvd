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
use Time::HiRes ();
use URI::Escape qw(uri_escape);

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

sub run { shift->_on_run }

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
        return $sub->($self, @_);
    }
    else {
        $debug and $self->_debug("no callback for $cb");
        return ();
    }
}

sub _debug {
    my $self = shift;
    my $state = $self->state;
    my $method = (caller 1)[3];
    $method =~ s/.*:://;
    my $ts = sprintf "%08.3f", (Time::HiRes::time() - $^T);
    warn "$ts> [$self state: $state]\@$method> @_\n";
}

my @query_callbacks = qw(result error done bad_result);
my %query_callbacks;

sub _query_callbacks ($;\%) {
    my ($name, $opts) = @_;
    my @cb = @{ $query_callbacks{$name} //=
                    do {
                        $name =~ /([a-zA-Z]\w*)$/ or die "internal error: bad method name: $name";
                        [ map "_on_$1_$_", @query_callbacks ];
                    }
                };
    if ($opts and %$opts) {
        for (0..$#query_callbacks) {
            my $over = delete $opts->{"on_$query_callbacks[$_]"};
            $cb[$_] = $over if defined $over;
        }
    }
    @cb
}

my %retry_on_sqlstate = map { $_ => 1 } ( '40001', # serialization_failure
                                        );

sub _query_n {
    my ($self, $n, $sql, @args) = @_;
    my $method = (caller 1)[3];
    my ($on_result, $on_error, $on_done, $on_bad_result) = _query_callbacks($method);

    if ($debug) {
        for ($on_result, $on_error, $on_done, $on_bad_result) {
            $self->_debug("callback $_ is " . (ref $_ ? $_ : $self->can($_)));
        }
        ref $_ or $self->can($_) or $self->_debug("warning: callback method $_ not found!")
            for ($on_result, $on_error, $on_done, $on_bad_result);

        my $line = $sql;
        $line =~ s/\s+/ /gms;
        $self->_debug("sql: >$line<, args: >@args<");
    }

    my $db = $self->_db // die "internal error: database handler not available";
    my $watcher = $db->push_query(query       => $sql,
                                  args        => \@args,
                                  max_retries => $self->{query_retry_count} // 1000, # FIXME!!!
                                  retry_on_sqlstate => \%retry_on_sqlstate,
                                  on_result   => sub {
                                      my $res = $_[2];
                                      my $or = $self->can($on_result);
                                      $debug and $self->_debug("calling method $on_result: " . ($or // '<undef>'));
                                      given ($res->status) {
                                          when (PGRES_TUPLES_OK) {
                                              if (!defined $n or $res->rows == $n) {
                                                  $or->($self, $res) if $or;
                                                  return;
                                              }
                                          }
                                          when (PGRES_COMMAND_OK) {
                                              if (!defined $n or $res->cmdRows == $n) {
                                                  $or->($self, $res) if $or;
                                                  return;
                                              }
                                          }
                                      }
                                      $debug and $self->_debug("actually calling method $on_bad_result");
                                      my $m = $self->can($on_bad_result);
                                      if ($m) {
                                          $m->($self, $res);
                                      }
                                      else {
                                          $debug and $self->_debug("there is no such method, marking the query"
                                                                   . " as erroneus for later");
                                          $self->{current_query_bad_result} = 1;
                                      }
                                  },
                                  on_error    => sub {
                                      delete $self->{current_query_watcher};
                                      delete $self->{current_query_bad_result};
                                      $debug and $self->_debug("calling method $on_error");
                                      $self->$on_error
                                  },
                                  on_done     => sub {
                                      delete $self->{current_query_watcher};
                                      if ($self->{current_query_bad_result}) {
                                          delete $self->{current_query_bad_result};
                                          $debug and $self->_debug("bad result seen, calling on_error callback $on_error");
                                          $self->$on_error
                                      }
                                      else {
                                          my $m = $self->can($on_done);
                                          if ($m) {
                                              $debug and $self->_debug("calling method $on_done");
                                              $m->($self);
                                          }
                                          else {
                                              $debug and $self->_debug("there is not method $on_done");
                                          }
                                      }
                                  },
                                 );
    $self->{current_query_bad_result} = 0;
    $self->{current_query_watcher} = $watcher;
}

sub _listen {
    my ($self, $channel) = @_;
    my $method = "_on_${channel}_notify";
    my $cb = sub { $self->$method };
    my $w = $self->_db->listen($channel,
                               on_notify           => $cb,
                               on_listener_started => $cb);
    $self->{listener_watcher}{$channel} = $w;
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

sub _cancel_current_query { undef shift->{current_query_watcher} }

sub _db {
    my $self = shift;
    $self->{db} = shift if @_;
    $self->{db};
}

sub _run_cmd {
    my ($self, $cmd, %opts) = @_;
    my $method = (caller 1)[3];
    my $kill_after = delete $opts{kill_after};
    my $ignore_errors = delete $opts{ignore_errors};

    my (undef, $on_error, $on_done) = _query_callbacks($method, %opts);

    if ($debug) {
        ref $_ or $self->can($_) or $self->_debug("warning: callback method $_ not found!")
            for ($on_error, $on_done);
        $self->_debug("running command @$cmd");
    }
    INFO "Running command '@$cmd'";
    my $pid;
    if (my $w = eval { AnyEvent::Util::run_cmd($cmd, '$$' => \$pid, %opts) }) {
        $debug and $self->_debug("process $pid forked");
        $self->{cmd_watcher}{$pid} = $w;
        $w->cb( sub {
                    $debug and $self->_debug("slave process $pid terminated");
                    my $rc = shift->recv;
                    $debug and $self->_debug("rc: $rc");
                    delete $self->{cmd_timer}{$pid};
                    delete $self->{cmd_watcher}{$pid};
                    if ($rc) {
                        $cmd = [$cmd] unless ref $cmd;
                        $debug and $self->_debug("command failed: @$cmd => " . ($rc >> 8) . " ($rc)");
                        ERROR "Command '@$cmd' failed: $rc";
                        unless ($ignore_errors) {
                            $debug and $self->_debug("calling on_error callback $on_error");
                            $self->$on_error($rc);
                            return
                        }
                        $debug and $self->_debug("ignore_errors set, so...");
                    }
                    $debug and $self->_debug("calling on_done callback $on_done");
                    $self->$on_done
                });
        if (defined $kill_after) {
            $self->{cmd_timer}{$pid} = AnyEvent->timer(after => $kill_after,
                                                       cb => sub { $self->_do_kill_after(TERM => $pid) });
            $debug and $self->_debug("process $pid will be killed after $kill_after seconds");
            DEBUG "Process '$pid' will be killed after '$kill_after' seconds";
        }
        return $pid;
    }
    else {
        AE::postpone {
            $debug and $self->_debug("faked slave process termination");
            if ($ignore_errors) {
                $debug and $self->_debug("ignore_errors set, calling  $on_done");
                $self->$on_done;
            }
            else {
                $debug and $self->_debug("calling on_error callback $on_error");
                $self->$on_error(-1);
            }
        };
        return -1
    }
}

sub _do_kill_after {
    my ($self, $signal, $pid) = @_;
    $debug and $self->_debug("command timed out");
    DEBUG 'Command timed out';
    $self->_kill_cmd($signal);
    $self->{cmd_timer}{$pid} = AnyEvent->timer(after => 2,
                                               cb => sub { $self->_do_kill_after(KILL => $pid) });
}

sub _kill_cmd {
    my ($self, $signal, $pid) = @_;
    unless (defined $pid) {
        ($pid) = my(@pids) = keys %{$self->{cmd_watcher}};
        @pids > 1 and die "internal error: more than one slave command is running, pids: @pids";
        if (!@pids) {
            $debug and $self->_debug("no slave command is running");
            WARN 'No slave command is running';
            return 1;
        }
    }
    $signal //= 'TERM';
    $debug and $self->_debug("killing $pid with signal $signal");
    my $ok = kill $signal => $pid;
    unless ($ok) {
        $debug and $self->_debug("unable to kill process $pid with signal $signal");
        WARN "Unable to kill process '$pid' with signal '$signal'";
    }
    $ok;
}

my $json;
sub _json { $json //= JSON->new->ascii->pretty->allow_nonref }

sub _rpc {
    my ($self, $method, @args) = @_;
    $self->{rpc_last_query} = [$method, @args];

    my $url = "$self->{rpc_service}/$method";

    $debug and $self->_debug("calling RPC service $url");

    $self->{rpc_retry_count} //= $self->_cfg('internal.hkd.agent.rpc.retry.count');
    $self->{rpc_retry_delay} //= $self->_cfg('internal.hkd.agent.rpc.retry.delay');

    my @query;
    while (@args) {
        my $key = shift @args;
        my $value = shift @args;
        push @query, uri_escape($key) . '=' . uri_escape($value);
    }
    $url .= '?' . join('&', @query) if @query;

    my ($on_result, $on_error, $on_done) = _query_callbacks("rpc_$method");

    if ($debug) {
        ref $_ or $self->can($_) or $self->_debug("warning: callback method $_ not found!")
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
                                               $self->_rpc(@{$self->{rpc_last_query}})
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

sub _on_stopped {
    my $self = shift;
    $self->_maybe_callback('on_stopped');
}

sub _abort_call_after {
    my $self = shift;
    $debug and $self->_debug("_abort_call_after called");
    undef $self->{call_after_timer}
}

sub _abort_cmd {
    my ($self, $pid) = @_;
    if (defined $pid) {
        delete $self->{cmd_watcher}{$pid};
        delete $self->{cmd_timer}{$pid};
    }
}

sub DESTROY {
    local $!;
    my $self = shift;
    $debug and $self->_debug("$self->DESTROY called");
    # $self->_kill_cmd('KILL');
}

sub _abort_all {
    my $self = shift;
    $self->_abort_call_after;
    $self->_abort_rpc;
    $self->_cancel_current_query;
}

1;
