package QVD::Admin4::CLI::Command::Login;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use Term::ReadKey;

sub run 
{
    my ($self, $opts, @args) = @_;

    ReadMode 'normal';
    my $login = ReadLine 0; 
    chomp $login;

    $self->cache->set( login => $login );
}

1;
