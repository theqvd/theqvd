package QVD::HKD;

our $VERSION = '3.00';

use 5.010;

our $debug = 1;

$Class::StateMachine::debug ||= -1;
$AnyEvent::Pg::debug ||= 2;

use strict;
use warnings;
no warnings 'redefine';

use Carp;
use File::Slurp qw(slurp);
use Pg::PQ qw(:pgres);
use AnyEvent;
use AnyEvent::Pg;

use QVD::HKD::Helpers;

use QVD::HKD::Config;
use QVD::HKD::Ticker;
use QVD::HKD::DHCPDHandler;
use QVD::HKD::CommandHandler;
use QVD::HKD::VMCommandHandler;
use QVD::HKD::VMHandler;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new                            => { transitions => { _on_run                    => 'starting/connecting_to_db'    } },

    'starting/connecting_to_db'    => { enter       => '_start_db',
                                        transitions => { _on_db_connected           => 'starting/loading_db_config'   } },

    'starting/loading_db_config'   => { enter       => '_start_config',
                                        transitions => { _on_config_reloaded        => 'starting/loading_host_row'    } },

    'starting/loading_host_row'    => { enter       => '_load_host_row',
                                        transitions => { _on_load_host_row_done     => 'starting/saving_loadbal_data' } },

    'starting/saving_loadbal_data' => { enter       => '_save_loadbal_data',
                                        transitions => { _on_save_loadbal_data_done => 'starting/ticking'             } },

    'starting/ticking'             => { enter       => '_start_ticking',
                                        transitions => { _on_ticked                 => 'starting/agents',
                                                         _on_ticker_error           => 'failed'                       } },

    'starting/agents'              => { enter       => '_start_agents',
                                        transitions => { _on_agents_started         => 'running'                      } },

    running                        => { transitions => { _on_cmd_stop               => 'stopping'                     },
                                        ignore      => ['_on_ticked']                                                 },
    failed                         => { enter       => '_on_failed'                                                   };


sub new {
    my ($class, %opts) = @_;
    # $opts{$_} //= $defaults{$_} for keys %defaults;
    my $config_file = delete $opts{config_file} // croak "configuration file missing";

    my $self = $class->SUPER::new(%opts);
    $self->{config} = QVD::HKD::Config->new(config_file => $config_file,
                                            on_reload_done => sub { $self->_on_config_reloaded },
                                            on_reload_error => sub { $self->_on_config_reload_error } );
    $self->{vm} = {};
    $self;
}

sub run {
    my $self = shift;
    $self->{exit} = AnyEvent->condvar;
    # exit cleanly:
    $self->{$_. "_watcher"} = AnyEvent->signal(signal => $_, cb => sub { $self->{exit}->send }) for (qw(TERM INT));
    if ($self->_cfg('internal.hkd.debugger.run')) {
        my $socket_path = $self->_cfg('internal.hkd.debugger.socket');
        require AnyEvent::Debug;
        require Data::Dumper;
        print STDERR "REPL debugger running at $socket_path\n";
        print STDERR "Connect as:\n    socat readline,history=/root/.hkd-debug unix:$socket_path\n\n";

        $self->{debug_shell} = AnyEvent::Debug::shell("unix/", $socket_path);
        no strict 'refs';
        *AnyEvent::Debug::shell::hkd = sub {
            $self
        };
        *AnyEvent::Debug::shell::x = sub {
            print Data::Dumper::Dumper(@_);
            ();
        };
        *AnyEvent::Debug::shell::set = sub {
            $self->{config}{props}->setProperty(@_);
            ()
        };
        *AnyEvent::Debug::shell::vm_cmd = sub {
            $self->_on_vm_cmd(@_);
            ()
        }
    }

    $self->_on_run;
    $self->{exit}->recv;
}

sub _start_db {
    my $self = shift;
    my $db = AnyEvent::Pg->new( {host     => $self->_cfg('database.host'),
                                 dbname   => $self->_cfg('database.name'),
                                 user     => $self->_cfg('database.user'),
                                 password => $self->_cfg('database.password') },
                                on_connect => sub { $self->_on_db_connected },
                                on_connect_error => sub { $self->_on_db_connect_failed } );
    $self->_db($db);
}

sub _start_config {
    my $self = shift;
    $self->{config}->set_db_and_reload($self->{db});
}

sub _load_host_row {
    my $self = shift;
    $self->_query_1('select id, name from hosts where name=$1', $self->_cfg('nodename'));
}

sub _on_load_host_row_bad_result {
    # FIXME
    exit(1);
}

sub _on_load_host_row_error {
    # FIXME
    exit(1);
}

sub _on_load_host_row_result {
    my ($self, $res) = @_;
    $self->{node_id} = $res->row;
}

sub _calc_load_balancing_data {   ## taken from was_QVD-HKD/lib/QVD/HKD.pm, _update_load_balancing_data
    my $bogomips;

    open my $fh, '<', '/proc/cpuinfo';
    (/^bogomips\s*: (\d*\.\d*)/ and $bogomips += $1) foreach <$fh>;
    close $fh;

    $bogomips *= 0.80; # 20% se reserva para el hipervisor

    # TODO: move this code into an external module!
    my $meminfo_lines = slurp('/proc/meminfo', array_ref => 1);
    my %meminfo = map { /^([^:]+):\s*(\d+)/; $1 => $2 } @$meminfo_lines;

    return $bogomips, $meminfo{MemTotal}/1000;
}

sub _save_loadbal_data {
    my $self = shift;
    my ($cpu, $ram) = _calc_load_balancing_data;
    $self->_query(q(update host_runtimes set usable_cpu=$1, usable_ram=$2 where host_id=$3),
                  $cpu, $ram, $self->{node_id});
}

sub _on_save_loadbal_data_bad_result {
    # FIXME
    exit(1);
}

sub _on_save_loadbal_data_error {
    # FIXME
    exit(1);
}

sub _on_save_loadbal_data_result {}

sub _start_ticking {
    my $self = shift;
    $self->{ticker} = QVD::HKD::Ticker->new( config => $self->{config},
                                             db => $self->{db},
                                             node_id => $self->{node_id},
                                             on_ticked => sub { $self->_on_ticked },
                                             on_error => sub { $self->_on_ticker_error } );
    $self->{ticker}->run;
}

sub _start_agents {
    my $self = shift;
    my %opts = ( config => $self->{config},
                 db => $self->{db},
                 node_id => $self->{node_id} );
    $self->{command_handler} = QVD::HKD::CommandHandler->new( %opts,
                                                              on_cmd => sub { $self->_on_cmd } );

    $self->{vm_command_handler} = QVD::HKD::VMCommandHandler->new( %opts,
                                                                   on_cmd => sub { $self->_on_vm_cmd($_[1], $_[2]) });
    $self->{dhcpd_handler} = QVD::HKD::DHCPDHandler->new( %opts );

    $self->{command_handler}->run;
    $self->{vm_command_handler}->run;
    $self->{dhcpd_handler}->run;

    $self->_on_agents_started;
}

sub _on_cmd {
    my ($self, $cmd) = @_;
    my $method = $self->can("_on_cmd_$cmd");
    if ($method) {
        $debug and $self->_debug("calling method _on_cmd_$cmd");
        $method->($self);
    }
    else {
        $debug and $self->_debug("no method _on_cmd_$cmd defined");
    }
}

sub _on_vm_cmd {
    my ($self, $vm_id, $cmd) = @_;
    my $vm = $self->{vm}{$vm_id};

    $debug and $self->_debug("command $cmd received for vm $vm_id");

    if ($cmd eq 'start') {
        if (defined $vm) {
            $debug and $self->_debug("start cmd received for live vm $vm_id");
            return;
        }
        $self->{vm}{$vm_id} = $vm = QVD::HKD::VMHandler->new(config => $self->{config},
                                                             vm_id =>  $vm_id,
                                                             node_id => $self->{node_id},
                                                             db => $self->{db},
                                                             dhcpd_handler => $self->{dhcpd_handler},
                                                             on_stopped => sub { $self->_on_vm_stopped($vm_id) });
    }
    unless (defined $vm) {
        $debug and $self->_debug("cmd $cmd received for unknown vm $vm_id");
        return;
    }
    $vm->on_cmd($cmd);
}

sub _on_vm_stopped {
    my ($self, $vm_id) = @_;
    delete $self->{vm}{$vm_id};
}

sub _on_failed { croak "something come completely wrong, aborting...\n" }

1;

__END__

# HKD tasks:
#
# * keep connection to the database open
# * (re)load config
# * periodically check for commands and launch/stop virtual machines
# * update Host_Runtimes table
# * monitor other HKDs
# * clean shutdown
# * run and monitor DHCP
# * run and monitor L7R
# * kill dangling L7R processes for disconnected VMs

# VM tasks:
#
# * start/stop
# * monitor processes
# * keep internal state
# * keep public info in VM_Runtimes table

# Concerns
#
# * DB may be a bottleneck, should we use some kind of priority system
# or whatever? add timeouts for push_query into AnyEvent::Pg?
#




1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

QVD::HKD - Perl extension for blah blah blah

=head1 SYNOPSIS

  use QVD::HKD;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for QVD::HKD, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Salvador Fandiño, E<lt>salva@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Salvador Fandiño

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
