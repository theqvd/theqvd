package QVD::HKD::DHCPDHandler;

use strict;
use warnings;

use AnyEvent;
use AnyEvent::Util;

use QVD::Log;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new      => { transitions => { _on_run      => 'running'  } },

    running  => { enter => '_run_dhcpd',
                  transitions => { on_hkd_stop => 'stopping' } },

    stopping => { enter => '_kill_cmd',
                  transitions => { _on_run_dhcpd_done => 'stopped' },
                  ignore => [qw(on_hkd_stop)]                       },
    stopped  => { enter => '_on_stopped'                            };


sub _on_run_dhcpd_error {
    my $self = shift;
    ERROR 'Error running dhcpd';
    $self->_call_after ($self->_cfg('internal.hkd.dhcpdhandler.wait_on_run_error'), '_on_run_dhcpd_done');
}

sub _on_run_dhcpd_done :OnState('running') {
    my $self = shift;
    WARN 'dhcpd exited';
    $self->{dhcpd_pid} = undef;
    $self->_run_dhcpd;
}

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
    INFO "Registering mac '$mac', ip '$ip' in DHCP";
    $self->{mac}{$vm_id} = $mac;
    $self->{ip}{$vm_id} = $ip;
    $self->_reload_config;
    # $self->_restart_server;
}

sub _make_config {
    my $self = shift;
    my $dhcp_hostsfile     = $self->_cfg('internal.vm.network.dhcp-hostsfile');
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
    my $ok = $self->_kill_cmd('HUP');
    unless ($ok) {
        $debug and $self->_debug("unable to signal dnsmasq");
        ERROR "Unable to signal dnsmasq process";
    }
}

sub _restart_server {
    my $self = shift;
    $self->_kill_cmd or $self->_on_run_dhcpd_done;
}

sub _run_dhcpd {
    my $self = shift;

    my $dhcpd_cmd          = $self->_cfg('command.dhcpd');
    my $network_bridge     = $self->_cfg('vm.network.bridge');
    my $dhcp_start         = $self->_cfg('vm.network.ip.start');
    my $dhcp_default_route = $self->_cfg('vm.network.gateway');
    my $dhcp_domain        = $self->_cfg('vm.network.domain');
    my $dhcp_hostsfile     = $self->_cfg('internal.vm.network.dhcp-hostsfile');
    DEBUG "About to run dhcpd: network bridge '$network_bridge', IP start '$dhcp_start', gateway '$dhcp_default_route', domain '$dhcp_domain'";
    $self->_make_config;
    my @dhcpd_cmd = ( $dhcpd_cmd,
                      '-k', '--log-dhcp',
                      '--dhcp-range'     => "interface:$network_bridge,$dhcp_start,static",
                      '--dhcp-option'    => "option:router,$dhcp_default_route",
                      '--interface'      => $network_bridge,
                      '--dhcp-hostsfile' => $dhcp_hostsfile,
                      '-X'               => 50000,  # set the limit to the number of
                                                    # leases served big enough to
                                                    # ensure it will not be reached
                                                    # ever
                    );
    push @dhcpd_cmd, "--domain=$dhcp_domain" if length $dhcp_domain;
    push @dhcpd_cmd, "-d" if $debug;

    $self->_run_cmd(\@dhcpd_cmd);
}

1;
