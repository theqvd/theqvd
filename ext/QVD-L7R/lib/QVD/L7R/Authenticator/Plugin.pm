package QVD::L7R::Authenticator::Plugin;

use strict;
use warnings;

sub init {}

sub authenticate_basic {}

sub before_connect_to_vm {}

sub before_list_of_vms {}

sub allow_access_to_vm { 1 }

sub normalize_login { $_[1] }

1;

