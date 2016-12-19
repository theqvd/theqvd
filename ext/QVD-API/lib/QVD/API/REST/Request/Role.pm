package QVD::API::REST::Request::Role;
use strict;
use warnings;
use Moose;

extends 'QVD::API::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;
    push @{$self->modifiers->{join}}, qw(tenant);
    push @{$self->modifiers->{join}}, {roles => 'inherited', 
				       acls => 'acl'};

    $self->_check;
    $self->_map;
}

1;

__DATA__

id = me.id
name = me.name
description = me.description
own_acls = me.get_own_acls
inherited_acls = me.get_inherited_acls_kk
own_roles = me.get_own_roles
inherited_roles = me.get_inherited_roles_kk
tenant = me.tenant_id
tenant_name  = tenant.name
acl_id = acl.id
acl_name = acl.name
nested_role_id = inherited.id
nested_role_name = inherited.name
