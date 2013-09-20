#!/var/lib/qvd/bin/perl

use strict;
use warnings;

use QVD::DB::Simple;

my ($host_id) = @ARGV;
defined $host_id or die <<EOU;
Usage:
  $0 <node_id>

EOU

print STDERR "This command may corrupt the QVD database.\n".
             "Are you sure you want to unassign any ".
             "virtual machines running on host $host_id [y/N]? ";
my $res = <STDIN>;
unless ($res =~ /^y(es)?$/i) {
    warn "Aborted!\n";
    exit(1);
}

my ($vm_count, $l7r_count);
txn_eval {
    my @l7r = rs(VM_Runtime)->search({l7r_host => $host_id});
    $l7r_count = @l7r;
    $_->clear_l7r_all for @l7r;

    my @vms = rs(VM_Runtime)->search({host_id => $host_id});
    $vm_count = @vms;

    print STDERR "This command may corrupt the QVD database.\n".
                 "Are you sure you want to unassign ".
                 "$c virtual machines from host $host_id [y/N]? ";

    my $res = <STDIN>;
    $res =~ /^y(es)?$/i or die "Aborted!\n";

    $_->unassign for @vms;
    my $host = rs(Host_Runtime)->find({host_id => $host_id});
    $host->set_state('lost);

};

if ($@) {
    print $@;
    exit 1;
}
else {
    print "$vm_count virtual machines and $l7r_count L7R processes have been unassigned from host $host_id\n";
}
