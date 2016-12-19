package QVD::API::REST::Request::DI_Tag;
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
    push @{$self->modifiers->{join}}, qw(di);
    $self->_check;
    $self->_map;
}

1;

__DATA__


osf_id = di.osf_id
name = me.tag
id = me.id
