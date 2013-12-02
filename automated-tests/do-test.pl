#!/usr/bin/perl

use warnings;
use strict;
use Getopt::Long;

sub setup_env {
    my ($is_local) = @_;
    @ENV{qw/NOVA_VERSION OS_PASSWORD OS_AUTH_URL OS_USERNAME OS_TENANT_NAME COMPUTE_API_VERSION OS_CACERT OS_NO_CACHE/} = qw{
        1.1 nomoresecrete http://172.20.64.23:5000/v2.0 demo demo 1.1 /opt/stack/data/CA/int-ca/ca-chain.pem 1
    };
    $ENV{'TEST_IS_LOCAL'} = 1 if $is_local;
}

sub run_pybot {
    my %args = @_;
    my @vars;

    my $test_file = $args{'test_file'};
    die "No test file given\n" unless length $test_file;
    die "Test file '$test_file' isn't readable\n" unless -r $test_file;

    foreach my $var (keys %{ $args{'variables'} }) {
        defined $args{'variables'}{$var} or next;
        push @vars, '--variable', sprintf '%s:%s', uc $var,   $args{'variables'}{$var};
    }

    printf "system %s %s %s\n", 'pybot', (join ' ', @vars), $test_file;
    system 'pybot', @vars, $test_file;
}

sub upload_test_output {
    system q[tar -cf - log.html report.html output.xml |ssh root@qvdci 'B=/var/www/automated-tests; D=$B/$(date +%Y%m%d-%H%M%S%z); echo $D; mkdir $D && tar -xC $D && ln -nsf $D $B/LATEST']
}

GetOptions \my %args,
    '--local',
    '--os-full-reset=s',
    '--os-image=s',
    '--os-image-name=s',
    '--os-vm-name=s',
    '--sources-list=s',
    '--qvd-host-name=s',
    '--qvd-host-ip=s',
    '--qvd-user-name=s',
    '--qvd-user-pass=s',
    '--qvd-osf-name=s',
    '--qvd-di-path=s',
    '--qvd-vm-name=s',
    '--qvd-hypervisor=s',           #kvm, lxc
    '--qvd-unionfs-type=s',         #aufs, overlayfs, unionfs-fuse, btrfs
    '--qvd-use-dhcp=s' or
    die "getopt failed\n";
my ($test_file) = @ARGV;

setup_env $args{'local'};
run_pybot
    test_file => $test_file,
    variables => {
        os_full_reset    => $args{'os-full-reset'},
        os_image         => $args{'os-image'},
        os_image_name    => $args{'os-image-name'},
        os_vm_name       => $args{'os-vm-name'},
        sources_list     => $args{'sources-list'},
        qvd_host_name    => $args{'qvd-host-name'},
        qvd_host_ip      => $args{'qvd-host-ip'},
        qvd_user_name    => $args{'qvd-user-name'},
        qvd_user_pass    => $args{'qvd-user-pass'},
        qvd_osf_name     => $args{'qvd-osf-name'},
        qvd_di_path      => $args{'qvd-di-path'},
        qvd_vm_name      => $args{'qvd-vm-name'},
        qvd_hypervisor   => $args{'qvd-hypervisor'},
        qvd_unionfs_type => $args{'qvd-unionfs-type'},
        qvd_use_dhcp     => $args{'qvd-use-dhcp'},
    };
#upload_test_output;
