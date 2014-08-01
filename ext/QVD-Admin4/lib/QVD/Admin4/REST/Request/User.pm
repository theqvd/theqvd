package QVD::Admin4::REST::Request::User;
use strict;
use warnings;
use Moose;
use Config::Properties;

extends 'QVD::Admin4::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;
    $self->get_customs('User_Property');
    $self->modifiers->{join} //= [];
    push @{$self->modifiers->{join}}, qw(tenant);

    $self->order_by;
}

1;

__DATA__

id             = me.id
login          = me.login
password       = me.password
blocked        = me.blocked
creation_admin = NULL
creation_date  = NULL
custom         = ALWAYS
vms            = AFTER
tenant         = me.tenant_id
