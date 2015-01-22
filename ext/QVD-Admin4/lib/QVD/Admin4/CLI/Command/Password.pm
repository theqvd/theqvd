package QVD::Admin4::CLI::Command::Password;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use Term::ReadKey;

sub run 
{
    my ($self, $opts, @args) = @_;

    ReadMode 'noecho';
    my $pass = ReadLine 0;
    chomp $pass;
    ReadMode 'normal';

    $self->cache->set( password => $pass );
    print '';
}

1;
