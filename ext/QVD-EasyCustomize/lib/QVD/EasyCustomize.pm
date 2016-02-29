package QVD::EasyCustomize;

use warnings;
use strict;
use Exporter;
use Log::Log4perl qw/get_logger/;

our @ISA = qw/Exporter/;
our @EXPORT_OK = (qw/
    mask2bits validate_quaddot
    gather_net_data gather_qvd_data gather_nodeconf_data
    edit_interfaces edit_node_conf
    set_db_pass set_qvd_pass set_wat_pass
/);
our %EXPORT_TAGS = (all => [ @EXPORT_OK ]);

my $main_if = 'eth0';

## turns "24" into "255.255.255.0"
## pity, it goes unused :P
#sub bits2mask {
#    my ($bits) = @_;
#    my $logger = get_logger '';
#    if ($bits < 0 or $bits > 32) {
#        $logger->error ('invalid number of bits');
#        return;
#    }
#    my $mask = '1'x$bits . '0'x(32-$bits);
#    return join '.', map { ord pack 'B*', $_ } $mask =~ /.{8}/g;
#}

## turns "255.255.255.0" into "24"
sub mask2bits {
    my ($mask) = @_;
    my $logger = get_logger '';
    my $bits = join '', map { sprintf '%08b', $_ } split /\./, $mask;
    if (32 != length $bits or $bits !~ /^(1*)0*$/) {
        $logger->error ('invalid mask');
        return;
    }
    return length $1;
}

sub validate_quaddot {
    my ($val) = @_;
    return $val =~ /^\d+\.\d+\.\d+\.\d+$/;   ## quick n dirty
}

sub gather_net_data {
    my @ifconfig = split /\n/, qx/ifconfig/;
    my $if;
    my %ret;

    foreach my $line (@ifconfig) {
        if ($line =~ /^(\S+)\s+Link encap/) { $if = $1; next; }
        if ($line =~ /inet addr:(\S+).*Mask:(\S+)/) {
            if ('eth0' eq $if) {
                $ret{'mgmt_ip'}      = { value => $1 };
                $ret{'mgmt_netmask'} = { value => $2 };
            } elsif ('qvdnet0' eq $if) {
                $ret{'svc_ip'}       = { value => $1 };
                $ret{'svc_netmask'}  = { value => $2 };
            }
        }
    }

    my (undef, undef, @route) = split /\n/, qx/route -n/;
    foreach my $line (@route) {
        my ($dest, $gw, $mask, $flags, $metric, $ref, $use, $if) = split /\s+/, $line;
        if ('eth0' eq $if and '0.0.0.0' eq $dest) {
            $ret{'gateway'} = { value => $gw };
        }
    }

    ## since we're in a controlled environment we can simplify this
    open my $fd, '<', '/etc/network/interfaces' or die "open: $!";
    while (<$fd>) {
        next unless /dns-nameservers\s+(\S+)/;
        $ret{'dns_server'} = { value => $1 };
        last;
    }
    close $fd;

    return %ret;
}

sub gather_qvd_data {
    my ($ip_start) = map { (split /=/)[1] } qx{qa config get vm.network.ip.start}; chomp $ip_start;
    return
        ip_start => { value => $ip_start };
}

sub gather_nodeconf_data {
    my %ret;
    open my $fd, '<', '/etc/qvd/node.conf' or die "open: $!";
    while (<$fd>) {
        next if /^\s*$/;
        next if /^\s*#/;
        chomp;
        my ($k, $v) = split /\s*=\s*/, $_, 2;
        $ret{$k} = { value => $v };
    }
    close $fd;
    return %ret;
}

sub edit_interfaces {
    my (%opts) = @_;
    my ($mgmt_ip, $mgmt_netmask, $svc_ip, $svc_netmask, $gateway, $dns_server) = @opts{qw/mgmt_ip mgmt_netmask svc_ip svc_netmask gateway dns_server/};

    my $logger = get_logger '';
    my $file_current = '/etc/network/interfaces';
    my $file_new     = '/etc/network/interfaces.new';
    my $file_old     = '/etc/network/interfaces.old';

    $logger->debug (sprintf "mgmt IP '%s'",      $mgmt_ip      // '<undef>');
    $logger->debug (sprintf "mgmt netmask '%s'", $mgmt_netmask // '<undef>');
    $logger->debug (sprintf "svc IP '%s'",       $svc_ip       // '<undef>');
    $logger->debug (sprintf "svc netmask '%s'",  $svc_netmask  // '<undef>');
    $logger->debug (sprintf "gateway '%s'",      $gateway      // '<undef>');
    $logger->debug (sprintf "dns server '%s'",   $dns_server   // '<undef>');

    return unless grep defined, values %opts;

    open my $fd, '<', $file_current or $logger->logdie ("open: '$file_current': $!");
    local $/ = 'iface ';
    my @ifs = <$fd>;
    close $fd;

    for my $if (@ifs) {
        if (0 == index $if, 'qvdnet0') {
            defined $svc_ip       and $if =~ s/(\s)address\s+\S+/$1address $svc_ip/s;
            defined $svc_netmask  and $if =~ s/(\s)netmask\s+\S+/$1netmask $svc_netmask/s;
            defined $mgmt_ip      and $if =~ s/(\s)--to-source\s+\S+/$1--to-source $mgmt_ip/s;
            defined $mgmt_ip      and $if =~ s/(\s)-A PREROUTING\s+-d\s+\S+/$1-A PREROUTING -d $mgmt_ip/s;
            defined $svc_ip       and $if =~ s/(\s)--to-destination\s+\S+/$1--to-destination $svc_ip/s;
        } elsif (0 == index $if, $main_if) {
            defined $mgmt_ip      and $if =~ s/(\s)address\s+\S+/$1address $mgmt_ip/s;
            defined $mgmt_netmask and $if =~ s/(\s)netmask\s+\S+/$1netmask $mgmt_netmask/s;
            defined $gateway      and $if =~ s/(\s)gateway\s+\S+/$1gateway $gateway/s;
            defined $dns_server   and $if =~ s/(\s)dns-nameservers\s+\S+/$1dns-nameservers $dns_server/s;
        }
    }

    open $fd, '>', $file_new or $logger->logdie ("open: '$file_new': $!");
    print $fd @ifs;
    close $fd;

    unlink $file_old                or $logger->logwarn ("unlink: '$file_old': $!");
    rename $file_current, $file_old or $logger->logdie  ("rename '$file_current' to '$file_old': $!");
    rename $file_new, $file_current or $logger->logdie  ("rename '$file_new' to '$file_current': $!");
    #system "qa config set vm.network.dns_server=$dns_server";   ## oops, documented but absent from the QVD code
    system sprintf "qa config set vm.network.netmask=%d", mask2bits $svc_netmask if defined $svc_netmask;
}

sub edit_node_conf {
    my (%args) = @_;

    my $logger = get_logger '';
    my $file_current = '/etc/qvd/node.conf';
    my $file_new     = '/etc/qvd/node.conf.new';
    my $file_old     = '/etc/qvd/node.conf.old';

    $logger->debug (sprintf "'%s': '%s'", $_, $args{$_} // '<undef>') for keys %args;

    open my $fd, '<', $file_current or $logger->logdie ("open: '$file_current': $!");
    my @conf = <$fd>;
    close $fd;

    LINE: for my $line (@conf) {
        next if $line =~ /^\s*$/;
        next if $line =~ /^\s*#/;
        foreach my $k (keys %args) {
            if ($line =~ /^(\s*)$k(\s*)=(\s*)/) {
                $line = "$1$k$2=$3$args{$k}\n";
                next LINE;
            }
        }
    }

    open $fd, '>', $file_new or $logger->logdie ("open: '$file_new': $!");
    print $fd @conf;
    close $fd;

    unlink $file_old                or $logger->logwarn ("unlink: '$file_old': $!");
    rename $file_current, $file_old or $logger->logdie  ("rename '$file_current' to '$file_old': $!");
    rename $file_new, $file_current or $logger->logdie  ("rename '$file_new' to '$file_current': $!");
}

sub set_db_pass {
    my ($db_pass) = @_;
    system sprintf q{su - postgres -c 'psql -c "alter user qvd password '\''%s'\''"'}, $db_pass;
}

sub set_qvd_pass {
    my ($qvd_pass) = @_;
    system sprintf q{(echo %s; echo %s) |qa user passwd user=qvduser}, $qvd_pass, $qvd_pass;
}

sub set_wat_pass {
    my ($wat_pass) = @_;
    system sprintf q{qa config set wat.admin.password=%s}, $wat_pass;
}
