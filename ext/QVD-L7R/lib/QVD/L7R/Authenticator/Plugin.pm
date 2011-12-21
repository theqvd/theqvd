package QVD::L7R::Authenticator::Plugin;

use strict;
use warnings;

sub init {}

sub authenticate_basic {}

sub before_connect_to_vm {}

sub before_list_of_vms {}

sub filter_list_of_vms {
    my ($plugin, $auth, $vm_list) = @_;
    return $vm_list;
}

1;

