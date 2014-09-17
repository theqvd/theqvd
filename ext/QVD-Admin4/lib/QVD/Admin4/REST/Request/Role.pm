package QVD::Admin4::REST::Request::Role;
use strict;
use warnings;
use Moose;

extends 'QVD::Admin4::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;

    push @{$self->modifiers->{join}}, qw(acls roles);

    $self->_check;
    $self->_map;
}

1;

__DATA__

id = me.id
name = me.name
all_acls = me.get_nested_acls
positive_acls = me.get_positive_acls_columns
negative_acls = me.get_negative_acls_columns
all_roles = me.get_nested_roles
roles = me.get_roles
acl_id = acls.acl_id

