package QVD::L7R::LoadBalancer::Plugin;

use strict;
use warnings;

sub new {
    my ($class, %params) = @_;
    my $self = { params => \%params };
    bless $self, $class;
}

sub get_free_host {
    die "unimplemented method called";
}

sub params {
    my $self = shift;
    %{$self->{params}};
}

1;

