package QVD::HKD::DHCPDHandler;

use strict;
use warnings;

use AnyEvent;
use AnyEvent::Util;

use QVD::Log;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__  => {},

    new      => { transitions => { _on_run      => 'running'  } },

    running  => { substates => [ run   => { enter => '_start_dhcpd',
                                            transitions => { _on_done    => 'delay',
                                                             on_hkd_stop => 'stopping' } },

                                 delay => { enter => '_set_timer',
                                            transitions => { _on_timeout => 'run',
                                                             on_hkd_stop => 'stopped' } } ] },

    stopping => { enter => '_kill_cmd',
                  transitions => { _on_done => 'stopped' },
                  ignore => [qw(on_hkd_stop)] },

    stopped  => { enter => '_on_stopped' };

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    $self->{dhcpd_pid} = undef;
    $self->{mac} = {};
    $self->{ip} = {};
    $self;
}

sub register_mac_and_ip {
    # TODO: pass extra info as vm name
    my ($self, $vm_id, $mac, $ip) = @_;
    INFO "Registering mac '$mac', ip '$ip' for VM $vm_id in DHCP";
    $self->{mac}{$vm_id} = $mac;
    $self->{ip}{$vm_id} = $ip;
    $self->_reload_config;
}

sub unregister_mac_and_ip {
    my ($self, $vm_id) = @_;
    INFO "Unregistering mac '" . $self->{mac}{$vm_id}. "', ip '" . $self->{ip}{$vm_id} . "' for VM $vm_id in DHCP";
    delete $self->{mac}{$vm_id};
    delete $self->{ip}{$vm_id};
    $self->_reload_config;
}

sub _make_config {
    my $self = shift;
    my $dhcp_hostsfile = $self->_cfg('internal.vm.network.dhcp-hostsfile');
    DEBUG "Writing DHCP hosts file '$dhcp_hostsfile'";
    open my $fh, ">", $dhcp_hostsfile or die "unable to open $dhcp_hostsfile: $!";
    for my $vm (sort { $self->{mac}{$a} cmp $self->{mac}{$b} } keys %{$self->{mac}}) {
        print $fh "$self->{mac}{$vm},$self->{ip}{$vm}\n";
    }
    close $fh;
}

sub _reload_config {
    my $self = shift;
    $self->_make_config;
    DEBUG 'Sending HUP signal to dhcpd';
    $self->_kill_cmd('HUP') or
        ERROR "Unable to signal dnsmasq process";
}

sub _start_dhcpd {
    my $self = shift;

    my $dhcpd_cmd          = $self->_cfg('command.dhcpd');
    my $network_bridge     = $self->_cfg('vm.network.bridge');
    my $dhcp_start         = $self->_cfg('vm.network.ip.start');
    my $dhcp_default_route = $self->_cfg('vm.network.gateway');
    my $dhcp_domain        = $self->_cfg('vm.network.domain');
    my $dhcp_hostsfile     = $self->_cfg('internal.vm.network.dhcp-hostsfile');
    DEBUG "About to run dhcpd: network bridge '$network_bridge', IP start '$dhcp_start', gateway '$dhcp_default_route', domain '$dhcp_domain'";
    $self->_make_config;
    my @dhcpd_cmd = ( 'dhcpd',
                      '-k', '--log-dhcp', '--bind-interfaces',
                      '--interface'        => $network_bridge,
                      '--except-interface' => 'lo',
                      '--dhcp-range'       => "interface:$network_bridge,$dhcp_start,static",
                      '--dhcp-option'      => "option:router,$dhcp_default_route",
                      '--dhcp-hostsfile'   => $dhcp_hostsfile,
                      '-X'                 => 50000,  # set the limit to the number of
                                                      # leases served big enough to
                                                      # ensure it will not be reached
                                                      # ever
                    );
    push @dhcpd_cmd, "--domain=$dhcp_domain" if length $dhcp_domain;
    push @dhcpd_cmd, "-d" if $debug;

    $self->_run_cmd( { ignore_errors => 1,
                       outlives_state => 1 },
                     @dhcpd_cmd);
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.dhcpdhandler.delay' ), '_on_timeout');
}

1;
