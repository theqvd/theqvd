package QVD::HKD::DHCPDHandler;

use strict;
use warnings;

use AnyEvent;
use AnyEvent::Util;

use QVD::Log;

use parent qw(QVD::HKD::Agent);

our $debug = 1;

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    $self->{dhcpd_pid} = undef;
    $self->{mac} = {};
    $self->{ip} = {};
    $self;
}

sub run { shift->_restart_server }

sub register_mac_and_ip {
    # TODO: pass extra info as vm name
    my ($self, $vm_id, $mac, $ip) = @_;
    $self->{mac}{$vm_id} = $mac;
    $self->{ip}{$vm_id} = $ip;
    $self->_restart_server;
}

sub _run_dhcpd {
    my $self = shift;

    my $dhcpd_cmd          = $self->_cfg('command.dhcpd');
    my $network_bridge     = $self->_cfg('vm.network.bridge');
    my $dhcp_start         = $self->_cfg('vm.network.ip.start');
    my $dhcp_default_route = $self->_cfg('vm.network.gateway');
    my $dhcp_hostsfile     = $self->_cfg('internal.vm.network.dhcp-hostsfile');

    open my $fh, ">", $dhcp_hostsfile or die "unable to open $dhcp_hostsfile: $!";
    for my $vm (sort { $self->{mac}{$a} cmp $self->{mac}{$b} } keys %{$self->{mac}}) {
        print $fh "$self->{mac}{$vm},$self->{ip}{$vm}\n";
    }
    close $fh;

    $self->_run_cmd([ $dhcpd_cmd,
                      '-k', '-log-dhcp',
                      '--dhcp-range'     => "interface:$network_bridge,$dhcp_start,static",
                      '--dhcp-option'    => "option:router,$dhcp_default_route",
                      '--interface'      => $network_bridge,
                      '--dhcp-hostsfile' => $dhcp_hostsfile,
                      ($debug ? ('-d') : ())
                    ]);
}

sub _on_run_dhcpd_done {
    my $self = shift;
    $self->{dhcpd_pid} = undef;
    $self->_run_dhcpd;
}

*_on_run_dhcpd_error = \&_on_run_dhcpd_done;

sub _restart_server {
    my $self = shift;
    $self->_kill_cmd or $self->_on_run_dhcpd_done;
}

1;
