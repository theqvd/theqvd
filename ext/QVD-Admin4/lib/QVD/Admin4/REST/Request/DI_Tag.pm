package QVD::Admin4::REST::Request::DI_Tag;
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
    $self->modifiers->{join} //= [];
    push @{$self->modifiers->{join}}, qw(di);

    $self->order_by;
}

1;

__DATA__


osf_id = di.osf_id
name = me.tag
