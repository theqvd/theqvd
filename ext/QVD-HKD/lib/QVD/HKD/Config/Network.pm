package QVD::HKD::Config::Network;

use strict;
use warnings;
use 5.010;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(netmask_n netstart_n nettop_n network_n netnodes
                    netvms net_aton net_ntoa);

sub net_aton { unpack('N', pack('C4', split /\./, shift)) }
sub net_ntoa { join '.', unpack('C4', pack('N', shift)) }

sub lenton {
    my $len = shift;
    my $zeros = 32 - $len;
    return ((0xffffffff >> $zeros) << $zeros);
}

sub netmask_n {
    my $agent = shift;
    my $a = $agent->_cfg('vm.network.netmask');
    return ($a =~ /^\d+$/ ? lenton($a) : net_aton($a));
}

sub netstart_n {
    my $agent = shift;
    net_aton($agent->_cfg('vm.network.ip.start'));
}

sub network_n {
    my $agent = shift;
    my $nm = netmask_n($agent);
    my $ns = netstart_n($agent);
    $ns & $nm;
}

sub nettop_n {
    my $agent = shift;
    my $ns = netstart_n($agent);
    my $nm = netmask_n($agent);
    $ns | (0xffffffff & ~$nm);
}

sub netnodes {
    my $agent = shift;
    sprintf("%s-%s", net_ntoa(network_n($agent) + 1), net_ntoa(netstart_n($agent) - 1))
}

sub netvms   {
    my $agent = shift;
    sprintf("%s-%s", net_ntoa(netstart_n($agent)), net_ntoa(nettop_n($agent) - 1))
}

