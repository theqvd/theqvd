#!/var/lib/qvd/bin/perl

use strict;
use warnings;

use QVD::DB::Simple;

my ($host_id) = @ARGV;
defined $host_id or die <<EOU;
Usage:
  $0 <node_id>

EOU

my $c;
txn_eval {
    my @vms = rs(VM_Runtime)->search({host_id => $host_id});
    $c = @vms;
    $c or die "There isn't any virtual machine assigned to host $host_id\n";

    print STDERR "This command may corrupt the QVD database.\n".
                 "Are you sure you want to unassign ".
                 "$c virtual machines from host $host_id [y/N]? ";

    my $res = <STDIN>;
    $res =~ /^y(es)?$/i or die "Aborted!\n";

    for my $vm (@vms) {
        if ($vm->user_state != 'disconnected') {
            if ($vm->l7r_host eq $host_id) {
                $vm->clear_l7r_all;
            }
            else {
                $vm->send_user_abort;
            }
        }
        $vm->unassign;
    }
};

if ($@) {
    print $@;
    exit 1;
}
else {
    print "$c virtual machines have been unassigned from host $host_id\n";
}
