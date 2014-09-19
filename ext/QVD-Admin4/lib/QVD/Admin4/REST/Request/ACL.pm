package QVD::Admin4::REST::Request::ACL;
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
    push @{$self->modifiers->{join}}, { roles => { role => { administrators => 'administrator' }}};
    $self->_check;
    $self->_map;
}

1;

__DATA__

id = me.id
name = me.name
role_id = role.id
admin_id = administrator.id
roles = me.get_roles_with_this_acl
