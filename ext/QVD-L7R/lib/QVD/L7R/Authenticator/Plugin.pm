package QVD::L7R::Authenticator::Plugin;

use strict;
use warnings;

sub init {}

sub authenticate_basic {}

sub authenticate_bearer {}

sub after_authenticate_basic {}

sub before_connect_to_vm {}

sub before_list_of_vms {}

sub allow_access_to_vm {
    my ($self, $auth, $vm) = @_;
    return $auth->user_id == $vm->user_id;
}

sub normalize_tenant { $_[2] }

sub normalize_login { $_[2] }

sub find_tenant {}

1;

