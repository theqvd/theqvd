package QVD::HKD::Agent;

#BEGIN { *debug = \$QVD::HKD::debug }

use 5.010;
use strict;
use warnings;

use AnyEvent::Util ();
use AnyEvent::HTTP;
use Errno qw(EAGAIN);
use Fcntl ();
use Fcntl::Packer ();
use QVD::HKD::Helpers qw(croak_invalid_opts perl_quote);
use Pg::PQ qw(:pgres);
use QVD::Log;
use JSON;
use Time::HiRes ();
use URI::Escape ();
use Method::WeakCallback qw(weak_method_callback);
use parent qw(Class::StateMachine);

our $debug = 1;

sub __caller_method {
    my $method = (caller 2)[3];
    $method =~ s/.*::_?//;
    return $method;
}

sub __opts {
    my $self = shift;
    my %opts = (ref $_[0] eq 'HASH' ? %{shift(@_)} : ());
    return ($self, \%opts, @_);
}

sub _debug {
    my $self = shift;
    my $state = $self->state;
    my $method = $self->__caller_method;
    my $ts = sprintf "%08.3f", (Time::HiRes::time() - $^T);
    warn "$ts> [$self state: $state]\@$method> @_\n";
}

sub new {
    my ($class, %opts) = @_;
    my $config = delete $opts{config};
    my $db = delete $opts{db};
    my $node_id = delete $opts{node_id};
    my $on_stopped = delete $opts{on_stopped};
    my $heavy = delete $opts{heavy};
    croak_invalid_opts %opts;

    my $self = { config => $config,
                 db => $db,
                 node_id => $node_id,
                 on_stopped => $on_stopped,
                 heavy => $heavy };

    Class::StateMachine::bless($self, $class);
}

sub run { shift->_on_run }

sub _main_state {
    my $state = shift->state;
    $state =~ s|/.*$||;
    $state;
}

sub _cfg { shift->{config}->_cfg(@_) }

sub _cfg_optional { shift->{config}->_cfg_optional(@_) }

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
            $self->_debug("calling $cb as $sub ($name) with args (" .
                          join(", ", map { $_ // '<undef>' } @_) . ")");
        }
        return $sub->($self, @_);
    }
    $debug and $self->_debug("no callback for $cb");
    ();
}

my %retry_on_sqlstate = map { $_ => 1 } ( '40001' ); # serialization_failure

sub __call_on_done_or_error_callback {
    my ($self, $opts, $failed, @args) = @_;
    if ($opts->{run_and_forget}) {
        DEBUG "action is configured as run_and_forget";
    }
    else {
        my $cb;
        if ($failed and not $opts->{ignore_errors}) {
            $cb = $opts->{on_error} // '_on_error';
            if (defined(my $msg = $opts->{log_error})) {
		if (defined (my $level = $opts->{log_error_level})) {
		    no strict 'refs';
		    &{uc $level}($msg);
		}
		else {
		    ERROR $msg;
		}
            }
        }
        else {
            $cb = $opts->{on_done} // '_on_done';
        }
        DEBUG sprintf("invoking callback (failed: %s, ignore_errors: %s, cb: %s)",
                      map { defined $_ ? $_ : '<undef>' } $failed, $opts->{ignore_errors}, $cb);
	if (ref $cb) {
	    $cb->(@args);
	}
	else {
	    $self->$cb(@args);
	}
    }
}

sub _heavy_down {
    my ($self, $opts) = &__opts;
    if ($self->{heavy_watcher_down}) {
        $self->__call_on_done_or_error_callback($opts, 0)
    }
    else {
        $self->{heavy_watcher} = $self->{heavy}->down(weak_method_callback($self, '__heavy_down_callback', $opts))
    }
}

sub __heavy_down_callback {
    my ($self, $opts) = @_;
    $self->{heavy_watcher_down} = delete $self->{heavy_watcher};
    $self->__call_on_done_or_error_callback($opts, 0);
}

sub _heavy_up {
    my ($self, $opts) = @_;
    delete $self->{heavy_watcher_down};
    delete $self->{heavy_watcher};
    $self->__call_on_done_or_error_callback($opts, 0);
}

sub _query {
    my ($self, $opts, $sql, @args) = &__opts;
    my $db = $self->_db // die "internal error: database handler not available";
    $opts->{caller_method} = $self->__caller_method;

    $self->{query_watcher} =
        $db->push_query(query       => $sql,
                        args        => \@args,
                        max_retries => $self->{query_retry_count} // 1000, # FIXME!!!
                        priority    => $self->{query_priority},
                        retry_on_sqlstate => \%retry_on_sqlstate,
                        on_result   => weak_method_callback($self, __query_result_callback => $opts),
                        on_done     => weak_method_callback($self, __query_callback => $opts, 0),
                        on_error    => weak_method_callback($self, __query_callback => $opts, 1) );
}

sub __query_result_callback {
    my ($self, $opts, undef, undef, $res) = @_;
    my ($rows, $tuples_ok);
    my $status = $res->status;
    given ($status) {
        when (PGRES_TUPLES_OK) {
            $rows = $res->rows;
            $tuples_ok = 1;
        }
        when (PGRES_COMMAND_OK) {
            if ($opts->{save_to_self} or $opts->{save_to} or $opts->{save_pairs_to}) {
                ERROR "Internal error: query with save_to_self or save_to set returned PGRES_COMMAND_OK"
            }
            else {
                $rows = $res->cmdRows;
            }
        }
    }
    if (defined $rows) {
        my $n = $opts->{n};
        my $save_to_self = $opts->{save_to_self};
        $n ||= 1 if $save_to_self;
        if (not defined $n or $n == $rows) {
            if ($save_to_self) {
                $debug and $self->_debug("reply saved to self");
                my @names = (ref $save_to_self ? @$save_to_self : ());
                my $hash = $res->rowAsHash(0, @names);
                use Data::Dumper;
                $debug and $self->_debug("save_to_self --> \n" . Dumper($hash));
                @{$self}{keys %$hash} = values %$hash;
            }
            elsif (defined (my $save_to = $opts->{save_to})) {
                my ($to, @names) = (ref $save_to ? @$save_to : $save_to);
                $debug and $self->_debug("reply saved to $save_to");
                $self->{$to} = [$res->rowsAsHashes(@names)];
            }
            elsif (defined (my $save_pairs_to = $opts->{save_pairs_to})) {
                $debug and $self->_debug("reply saved as pairs to $save_pairs_to");
                my $columns = $res->columns;
                $columns == 2 or DEBUG "Internal error, too many columns ($columns)";
                my %res = map { @{$_}[0, 1] } $res->rows;
                $self->{$save_pairs_to} = \%res;
            }
            else {
                my $on_result = $opts->{on_result} // "_on_$opts->{caller_method}_result";
                my $method = (ref $on_result ? $on_result : $self->can($on_result));
                if ($method) {
                    $method->($self, $res);
                }
                else {
                    DEBUG "No action performed for on_result callback";
                }
            }
            return;
        }
        else {
            DEBUG "unexpected number of rows on query result, $n expected, $rows received";
        }
    }
    else {
        if (defined(my $to = $opts->{save_to} // $opts->{save_pairs_to})) {
            $to = $to->[0] if ref $to;
            delete $self->{$to};
        }
    }
    DEBUG "query set to failed";
    $opts->{query_got_bad_result} = 1;
};

sub __query_callback {
    my ($self, $opts, $failed) = @_;
    delete $self->{query_watcher};
    $failed ||= $opts->{query_got_bad_result};
    DEBUG "query from $opts->{caller_method} " . ($failed ? "failed" : "succeeded");
    $self->__call_on_done_or_error_callback($opts, $failed);
}

sub _listen {
    my ($self, $opts, $channel) = &__opts;
    DEBUG "Listening to channel '$channel'";
    my $cb = weak_method_callback($self, __listen_callback => $opts, $channel);
    $self->{listener_watcher}{$channel} =
        $self->_db->listen($channel,
                           on_notify           => $cb,
                           on_listener_started => $cb);
}

sub __listen_callback {
    my ($self, $opts, $channel) = @_;
    DEBUG "Notification for channel '$channel' received";
    my $cb = $opts->{on_notify} // "_on_${channel}_notify";
    $self->$cb($channel);
}

sub _notify {
    my ($self, $name) = @_;
    my $queue = $self->{notify_queue} ||= [];
    push @$queue, $name;
    $self->__queue_next_notify unless $self->{notify_watcher};
}

sub __queue_next_notify {
    my $self = shift;
    my $nq = $self->{notify_queue};
    if ($nq and @$nq) {
        my $channel = shift @$nq;
        my $cb = weak_method_callback($self, '__queue_next_notify');
        $self->{notify_watcher} = $self->_db->push_query(query       => "notify $channel",
                                                         max_retries => 0,
                                                         on_done     => $cb,
                                                         on_error    => $cb);
    }
    else {
        delete $self->{notify_watcher};
    }
}

sub _db {
    my $self = shift;

    $self->{db} = shift if @_;
    $self->{db};
}

sub _run_cmd {
    my ($self, $opts, $cmd, @args) = &__opts;
    my @cmd;
    if ($opts->{skip_cmd_lookup}) {
        @cmd = $cmd;
    }
    else {
        @cmd = $self->_cfg("command.$cmd");
        if (length(my $args = $self->_cfg("command.$cmd.args.extra", ''))) {
            push @cmd, < $args >;
        }
    }
    my @prefix = @{$opts->{prefix} // []};
    INFO "Running command " . perl_quote([@cmd, @args]);
    $opts->{outlives_state} //= $opts->{run_and_forget};
    my @extra = map { ( defined $opts->{$_}
                        ? ($_ => $opts->{$_})
                        : () ) }
                      ( qw(on_prepare), grep /^\d*[<>]$/, keys %$opts);

    my $pid;
    my $w = eval { AnyEvent::Util::run_cmd([@prefix, @cmd, @args], '$$' => \$pid, @extra) };
    if (defined(my $save_pid_to = $opts->{save_pid_to})) {
        $self->{$save_pid_to} = $pid;
    }
    if ($pid) {
        DEBUG "Process $pid forked";
        $self->{cmd_watcher}{$pid} = $w;
        $self->{last_cmd_pid} = $pid;
        $w->cb(weak_method_callback($self, __run_cmd_callback => $opts, $pid));
        if (defined(my $after = $opts->{kill_after})) {
            DEBUG "Process '$pid' will be killed after '$after' seconds";
            $opts->{kill_counter} = 0;
            $self->{cmd_timer_watcher}{$pid} =
                AE::timer($after, 2,
                          weak_method_callback($self, __run_cmd_kill_after_callback => $opts, $pid));
        }
        $self->on_leave_state(__run_cmd_on_leave_state => $opts, $pid);
    }
    else {
        &AE::postpone(weak_method_callback($self, __call_on_done_or_error_callback => $opts, 1));
    }
}

sub __run_cmd_callback {
    my ($self, $opts, $pid, $var) = @_;
    my $rc = $var->recv;
    if (($rc >> 8) == 126) {
        WARN "Process $pid returned rc: $rc, it probably means that the binary was not found";
    }
    else {
        DEBUG "Process $pid returned rc: $rc";
    }

    my $last = $self->{last_cmd_pid};
    delete $self->{last_cmd_pid} if $last and $last == $pid;
    delete $self->{cmd_timer_watcher}{$pid};
    delete $self->{cmd_watcher}{$pid};
    if (defined(my $as = $opts->{save_pid_to})) {
        delete $self->{$as};
    }
    my $failed = ($opts->{non_zero_rc_expected} ? $rc == 0 : $rc != 0);
    $self->__call_on_done_or_error_callback($opts, $failed, $rc);
}

sub __run_cmd_kill_after_callback {
    my ($self, $opts, $pid) = @_;
    my $signal = (++$opts->{kill_counter} > 3 ? 'KILL' : 'TERM');
    $self->_kill_cmd($signal, $pid);
}

sub __run_cmd_on_leave_state {
    my ($self, $opts, $pid) = @_;
    if ($self->{cmd_watcher}{$pid}) {
        DEBUG "process $pid keeps running on the background";
        unless ($opts->{outlives_state}) {
            $opts->{run_and_forget} = 1;
            $self->{cmd_timer_watcher}{$pid} =
                AE::timer(0, 2, weak_method_callback($self, __run_cmd_kill_after_callback => $opts, $pid));
        }
    }
}

sub _kill_cmd {
    my ($self, $signal, $pid) = @_;
    $pid = $self->{last_cmd_pid} if @_ < 3;
    if ($pid) {
        $signal //= 'TERM';
        DEBUG("killing $pid with signal $signal");
        kill $signal => $pid and return 1;
        WARN "Unable to send signal $signal to process $pid: $!";
    }
    else {
        WARN '_kill_cmd method invoked but last command has already finished or pid was undefined';
    }
    return;
}

my $json;
sub _json { $json //= JSON->new->ascii->pretty->allow_nonref }

sub __make_simplerpc_url {
    my ($self, $service, $method, @args) = @_;
    my @query;
    while (@args) {
        my $key = shift @args;
        my $value = shift @args;
        push @query, URI::Escape::uri_escape($key) . '=' . URI::Escape::uri_escape($value);
    }

    my $url = "$service/$method";
    $url .= '?' . join('&', @query) if @query;
    $url
}

sub _rpc {
    my ($self, $opts, $method, @args) = &__opts;
    $opts->{caller_method} = $self->__caller_method;
    $opts->{retry_count} //= $self->_cfg('internal.hkd.agent.rpc.retry.count');
    $opts->{retry_delay} //= $self->_cfg('internal.hkd.agent.rpc.retry.delay');
    my $service = $opts->{rpc_service} //= $self->{rpc_service};
    my $url = $opts->{url} //= $self->__make_simplerpc_url($service, $method, @args);
    my $timeout = $opts->{timeout} //= $self->_cfg('internal.hkd.agent.rpc.timeout');
    DEBUG "calling RPC service $url";
    $self->{rpc_watcher} = http_get($url,
                                    persistent => 0,
                                    timeout => $timeout,
                                    cb => weak_method_callback($self, _rpc_callback => $opts));
}

sub _rpc_callback {
    my ($self, $opts, undef, $headers) = @_;
    $debug and $self->_debug("on _rpc_result");
    delete $self->{rpc_watcher};
    my $status = $headers->{Status};
    my $error = 1;
    my $result;
    if ($status =~ /^2\d\d$/) {
        my $data = _json->decode("[$_[2]]");
        if (defined $data) {
            ($result, $error) = @$data;
            unless ($error) {
                if (defined (my $save_to = $opts->{save_to})) {
                    $self->{$save_to} = $result;
                }
                else {
                    my $on_result = $opts->{_on_result} // "_on_$opts->{caller_method}_result";
                    my $method = (ref $on_result ? $on_result : $self->can($on_result));
                    $self->$method($result) if $method;
                }
            }
        }
        else {
            DEBUG "bad JSON response: $_[2]";
        }
    }
    elsif ($opts->{retry_count} > 0) {
        DEBUG "bad response status: $status, retrying in $opts->{retry_delay} seconds";
        $opts->{retry_count}--;
        $self->{rpc_watcher} = AE::timer($opts->{retry_delay}, 0,
                                         weak_method_callback($self, _rpc => $opts));
        return;
    }
    else {
        DEBUG "bad response status: $status";
    }
    $self->__call_on_done_or_error_callback($opts, $error);
}

sub __call_after_callback {
    my ($self, $method, @args) = @_;
    delete $self->{call_after_watcher};
    $self->$method(@args);
}

sub _call_after {
    my ($self, $delay, @call) = @_;
    $self->{call_after_watcher} = AE::timer($delay, 0,
                                            weak_method_callback($self, __call_after_callback => @call));
}

sub _flock {
    my ($self, $opts, $file) = &__opts;
    my $cb = weak_method_callback($self, '__on_flock', $opts);

    DEBUG "locking $file";
    $opts->{filename} = $file; # save for error messages

    if (sysopen my $fh, $file, Fcntl::O_CREAT()|Fcntl::O_RDWR()) {
        my $save_to = ($opts->{save_to} //= 'flock_fh');
        $self->{$save_to} = $fh;
        DEBUG "flock file descriptor is " . fileno($self->{$save_to});
        $self->__acquire_flock($opts);
    }
    else {
        ERROR "Unable to open lock file $file: $!";
        $self->__call_on_done_or_error_callback($opts, 1);
    }
}

sub __acquire_flock {
    my ($self, $opts) = @_;
    my $save_to = $opts->{save_to};
    my $ok = flock($self->{$save_to}, Fcntl::LOCK_EX() | Fcntl::LOCK_NB());
    unless ($ok) {
        if ($! == Errno::EAGAIN()) {
            if (!defined($opts->{retries}) or --$opts->{retries} > 0) {
                DEBUG "delaying flock";
                my $delay = ($opts->{delay} // 10) * (0.8 + rand 0.4);
                if ($opts->{reheavy}) {
                    delete $opts->{heavy_watcher_down}
                        or die "internal error: __acquire_flock called with reheavy set but Agent is not heavy";
                    my $on_heavy = weak_method_callback($self, '__acquire_flock', $opts);
                    $self->_call_after($delay, _heavy_down => { on_done => $on_heavy });
                }
                else {
                    $self->_call_after($delay, '__acquire_flock', $opts);
                }
                return;
            }
            else {
                ERROR "flocking '$opts->{filename}' failed: too many retries";
            }
        }
        else {
            ERROR "flocking '$opts->{filename}' failed: $!";
        }
        delete $self->{$save_to};
    }
    $self->__call_on_done_or_error_callback($opts, !$ok);
}

sub leave_state {
    my $self = shift;
    delete $self->{call_after_watcher} and DEBUG "aborting/cleaning delayed method call";
    delete $self->{rpc_watcher}        and DEBUG "aborting RPC call";
    delete $self->{query_watcher}      and DEBUG "aborting database query";
    delete $self->{flock_watcher}      and DEBUG "aborting file locking";
    delete $self->{heavy_watcher}      and DEBUG "aborting heavy down";
}

sub _on_stopped {
    my $self = shift;
    $self->_maybe_callback('on_stopped');
}

sub DESTROY {
    local $!;
    my $self = shift;
    $debug and $self->_debug("$self->DESTROY called");
    # $self->_kill_cmd('KILL');
}


1;
