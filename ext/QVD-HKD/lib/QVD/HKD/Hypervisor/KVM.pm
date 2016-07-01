package QVD::HKD::Hypervisor::KVM;

use strict;
use warnings;

use QVD::HKD::VMHandler::KVM;

use parent qw(QVD::HKD::Hypervisor);

sub new_vm_handler {
    my $self = shift;
    QVD::HKD::VMHandler::KVM->new(@_, hypervisor => $self);
}

1;
