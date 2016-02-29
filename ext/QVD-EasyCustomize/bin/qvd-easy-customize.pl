#!/usr/lib/qvd/bin/perl

use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use Log::Log4perl qw/get_logger/;
use Term::ReadKey;
use QVD::Admin;
use QVD::EasyCustomize qw/:all/;

BEGIN {
Log::Log4perl->init ({
    'log4perl.rootLogger'                                => 'DEBUG, LOGFILE',
    'log4perl.appender.LOGFILE'                          => 'Log::Log4perl::Appender::File',
    'log4perl.appender.LOGFILE.filename'                 => '/var/log/qvd/easy-customize.log',
    'log4perl.appender.LOGFILE.utf8'                     => 1,
    'log4perl.appender.LOGFILE.layout'                   => 'Log::Log4perl::Layout::PatternLayout',
    'log4perl.appender.LOGFILE.layout.ConversionPattern' => '[%d{yyyy-MM-dd HH:mm:ss.SSS Z}] %H %p - %M{3} - %m%n',
});
}
my $qa = QVD::Admin->new;

sub ask {
    my ($q, $def) = @_;
    print "$q [$def]: ";
    my $r = <>;
    chomp $r;
    return length $r ? $r : $def;
}

sub ask_pass {
    my ($prompt) = @_;

    my $logger = get_logger;
    ReadMode 'noecho';
    print "$prompt: ";        my $pw1 = <>; $pw1 //= ''; chomp $pw1; print "\n";
    if (!length $pw1) {
        ReadMode 'restore';
        return;
    }
    print "Enter it again: "; my $pw2 = <>; $pw2 //= ''; chomp $pw2; print "\n";
    ReadMode 'restore';

    if ($pw1 eq $pw2) {
        return $pw1;
    } else {
        $logger->logwarn ('given passwords do not match');
        return;
    }
}
END { ReadMode 'restore'; }

sub reconfig_network {
    my ($firstnode) = @_;
    my $logger = get_logger;
    my %data = gather_net_data;
    my $val;

    do {
        $val = ask 'Enter management IP', $data{'mgmt_ip'}{'value'};
    } while !validate_quaddot $val;
    if ($val ne $data{'mgmt_ip'}{'value'}) {
        $data{'mgmt_ip'}{'value'} = $val;
        $data{'mgmt_ip'}{'_changed'} = 1;
    }

    do {
        $val = ask 'Enter management network mask', $data{'mgmt_netmask'}{'value'};
    } while !validate_quaddot $val;
    if ($val ne $data{'mgmt_netmask'}{'value'}) {
        $data{'mgmt_netmask'}{'value'} = $val;
        $data{'mgmt_netmask'}{'_changed'} = 1;
    }

    do {
        $val = ask 'Enter service IP', $data{'svc_ip'}{'value'};
    } while !validate_quaddot $val;
    if ($val ne $data{'svc_ip'}{'value'}) {
        $data{'svc_ip'}{'value'} = $val;
        $data{'svc_ip'}{'_changed'} = 1;
    }

    do {
        $val = ask 'Enter service network mask', $data{'svc_netmask'}{'value'};
    } while !validate_quaddot $val;
    if ($val ne $data{'svc_netmask'}{'value'}) {
        $data{'svc_netmask'}{'value'} = $val;
        $data{'svc_netmask'}{'_changed'} = 1;
    }

    do {
        $val = ask 'Enter gateway', $data{'gateway'}{'value'};
    } while !validate_quaddot $val;
    if ($val ne $data{'gateway'}{'value'}) {
        $data{'gateway'}{'value'} = $val;
        $data{'gateway'}{'_changed'} = 1;
    }

    do {
        $val = ask 'Enter DNS server', $data{'dns_server'}{'value'};
    } while !validate_quaddot $val;
    if ($val ne $data{'dns_server'}{'value'}) {
        $data{'dns_server'}{'value'} = $val;
        $data{'dns_server'}{'_changed'} = 1;
    }

    if (!grep { $data{$_}{'_changed'} } keys %data) {
        $logger->debug ('no new network information provided, skipping network reconfiguration');
        return;
    }
    $logger->debug ('new network information provided, performing network reconfiguration');

    ## this has to be done before touching the network - otherwise the db may not be reachable afterwards
    if ($firstnode) {
        $qa->cmd_config_set ('vm.network.gateway' => $data{'gateway'}{'value'});
        $qa->cmd_config_set ('vm.network.netmask' => $data{'mgmt_netmask'}{'value'});
    }

    system 'ifdown qvdnet0; ifdown eth0';
    edit_interfaces
        mgmt_ip      => $data{'mgmt_ip'}{'value'},
        mgmt_netmask => $data{'mgmt_netmask'}{'value'},
        svc_ip       => $data{'svc_ip'}{'value'},
        svc_netmask  => $data{'svc_netmask'}{'value'},
        gateway      => $data{'gateway'}{'value'},
        dns_server   => $data{'dns_server'}{'value'};
    system 'ifup eth0; ifup qvdnet0';

    if ($data{'mgmt_ip'}{'_changed'} or $data{'mgmt_netmask'}{'_changed'}) {
        my $bits = mask2bits $data{'mgmt_netmask'}{'value'};
        system "sed -i -e 's:.*qvddb.*:host qvddb qvd $data{'mgmt_ip'}{'value'}/$bits md5:' /etc/postgresql/*/main/pg_hba.conf";
        system "/etc/init.d/postgresql reload";
    }
}

sub reconfig_db {
    my ($firstnode) = @_;
    my $logger = get_logger;
    my %data = gather_nodeconf_data;
    my $val;

    $val = ask 'Enter the name of the database node', $data{'nodename'}{'value'};
    if ($val ne $data{'nodename'}{'value'}) {
        $data{'nodename'}{'value'} = $val;
        $data{'nodename'}{'_changed'} = 1;
    }

    $val = ask 'Enter database host', $data{'database.host'}{'value'};
    if ($val ne $data{'database.host'}{'value'}) {
        $data{'database.host'}{'value'} = $val;
        $data{'database.host'}{'_changed'} = 1;
    }

    $val = ask 'Enter database name', $data{'database.name'}{'value'};
    if ($val ne $data{'database.name'}{'value'}) {
        $data{'database.name'}{'value'} = $val;
        $data{'database.name'}{'_changed'} = 1;
    }

    $val = ask 'Enter database user', $data{'database.user'}{'value'};
    if ($val ne $data{'database.user'}{'value'}) {
        $data{'database.user'}{'value'} = $val;
        $data{'database.user'}{'_changed'} = 1;
    }

    $val = ask_pass 'Enter database password';
    if (defined $val and $val ne $data{'database.password'}{'value'}) {
        $data{'database.password'}{'value'} = $val;
        $data{'database.password'}{'_changed'} = 1;
    }

    if (!grep { $data{$_}{'_changed'} } keys %data) {
        $logger->debug ('no new database information provided, skipping database reconfiguration');
        return;
    }
    $logger->debug ('new database information provided, performing database reconfiguration');

    edit_node_conf
        'nodename'      => $data{'nodename'}{'value'},
        'database.host' => $data{'database.host'}{'value'},
        'database.user' => $data{'database.user'}{'value'},
        'database.name' => $data{'database.name'}{'value'},
        'database.pass' => $data{'database.password'}{'value'};
    set_db_pass $data{'database.password'}{'value'} if $data{'database.password'}{'_changed'};
}

sub reconfig_qvd {
    my ($firstnode) = @_;
    my %data = gather_qvd_data;
    my $val;

    if ($firstnode) {
        $val = ask 'Enter highest IP for VM range', $data{'ip_start'}{'value'};
        $qa->cmd_config_set ('vm.network.ip.start' => $val);
    }

    $val = ask_pass 'Enter password for the QVD user in the VMs';
    if (defined $val) {
        set_qvd_pass $val;
    }
    $val = ask_pass 'Enter password for the WAT admin user';
    if (defined $val) {
        set_wat_pass $val;
    }
}

GetOptions \my %opts, '--help' or pod2usage -verbose => 0;
$opts{'help'} and pod2usage -verbose => 2;

my $logger = get_logger '';
$logger->info ("$0 starting");

my $firstnode = ask "Is this the first node you're setting up?", 'Y';
if ($firstnode =~ /^y(?:es)?/i) {
    $firstnode = 1;
} elsif ($firstnode =~ /^no?/i) {
    $firstnode = 0;
} else {
    die "Error: one of 'y', 'n', 'yes' or 'no' is expected.\n";
}
reconfig_db $firstnode;
reconfig_qvd $firstnode;
reconfig_network $firstnode;





=head1 NAME

qvd-easy-customize.pl - Easily customize a QVD installation.

=head1 SYNOPSIS

  qvd-easy-customize.pl

=head1 DESCRIPTION

This program is useful to easily change some details of a QVD box, namely the
IP related ones (address, network mask, gateway and DNS server), database
connection details and some passwords. It will interactively ask for the
required data, suggesting a default value. In all cases, accepting the default
means that no changes will be done. In the case of passwords no default is
suggested, of course, and providing an empty password means that the existing
passwords won't be changed.

=head1 AUTHOR

David Serrano <david.serrano@qindel.com>

=head1 LICENSE

Copyright 2014 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU GPL version 3 as published by the Free Software
Foundation.

=cut
