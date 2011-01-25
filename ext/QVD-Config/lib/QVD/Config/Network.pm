package QVD::Config::Network;

use strict;
use warnings;
use 5.010;

use QVD::Config;

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

my $network_n;
my $netmask_n;
my $netstart_n;
my $nettop_n;

sub netmask_n {
    $netmask_n //= do {
        my $a = cfg('vm.network.netmask');
        $a =~ /^\d+$/ ? lenton($a) : net_aton($a)
    }
}

sub netstart_n {
    $netstart_n //= do {
        my $a = cfg('vm.network.start');
        net_aton($a);
    }
}

sub network_n {
    $network_n //= do {
        my $nm = netmask_n;
        my $ns = netstart_n;
        $ns & $nm;
    }
}

sub nettop_n {
    $nettop_n //= do {
        my $ns = netstart_n;
        my $nm = netmask_n;
        $ns | (0xffffffff & ~$nm);
    }
}

sub netnodes { sprintf("%s-%s", net_ntoa(network_n + 1), net_ntoa(netstart_n - 1)) }
sub netvms   { sprintf("%s-%s", net_ntoa(netstart_n), net_ntoa(nettop_n - 1)) }

1;
