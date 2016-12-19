package QVD::Admin4::Tokenizer::Token;
use strict;
use warnings;
use Moo;

has 'string', is => 'ro', isa => sub { die "Invalid type for attribute string" if ref(+shift); }, required => 1;
has 'from', is => 'ro', isa => sub { die "Invalid type for attribute from" if ref(+shift); }, required => 1;
has 'to', is => 'ro', isa => sub { die "Invalid type for attribute to" if ref(+shift); };

sub BUILD
{
    my $self = shift;
    $self->set_to;
}

sub set_to
{
    my $self = shift;
    $self->{to} = $self->from + length($self->string);
}


1;
