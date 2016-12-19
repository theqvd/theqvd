package QVD::Admin4::Grammar::Substitution;
use strict;
use warnings;
use Moo;

sub BUILD
{
    my $self = shift;
    $self->{items} = {};
}

sub subst
{
    my ($self, $k) = @_;
    exists $self->{items}->{$k} ? 
	return $self->{items}->{$k} : $k ;
} 

sub _set
{
    my ($self, $k, $v) = @_;
    $self->{items}->{$k} = $v;
} 

sub _get
{
    my ($self, $k) = @_;
    $self->{items}->{$k};
} 

sub _list
{
    my $self = shift;
    keys %{$self->{items}};
}

1;
