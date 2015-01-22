package QVD::Admin4::CLI::Command::Logout;
use base qw( CLI::Framework::Command );
use strict;
use warnings;

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->cache->set( login => undef );
    $self->cache->set( password => undef );
    $self->cache->set( sid => undef );
}
1;
