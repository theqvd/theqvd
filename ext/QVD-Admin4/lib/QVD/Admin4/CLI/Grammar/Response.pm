package QVD::Admin4::CLI::Grammar::Response;
use strict;
use warnings;
use Moo;
use QVD::Admin4::REST::Filter;
use Clone qw(clone);

has 'json', is => 'ro', isa => sub { die "Invalid type for attribute json" unless ref(+shift) eq 'HASH'; };
has 'response', is => 'ro', isa => sub { die "Invalid type for attribute response" unless ref(+shift) eq 'HASH'; };
has 'command', is => 'ro';
has 'qvd_object', is => 'ro';
has 'filters', is => 'ro';
has 'arguments', is => 'ro';
has 'parameters', is => 'ro';
has 'fields', is => 'ro';
has 'order', is => 'ro';

sub BUILD
{
    my $self = shift;
    die 'Either json or response argument required' 
	unless $self->json || $self->response;

    die 'Incompatible arguments json and response' 
	if $self->json && $self->response;

    my $json = $self->json // $self->response;
    $json = clone $json;

    $self->{command} = $json->{command};
    $self->{qvd_object} = eval { $json->{obj1}->{qvd_object} };

    $self->{filters} = QVD::Admin4::REST::Filter->new(hash => eval { $json->{obj1}->{filters} } // {});
    $self->{arguments} = $json->{arguments} // {};
    $self->{parameters} = $json->{parameters} // {};
    $self->{fields} = $json->{fields} // [];
    $self->{order} = $json->{order_by} // {};
}



1;

