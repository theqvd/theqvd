package QVD::Admin4::CLI::Command::Login;
use base qw( CLI::Framework::Command );
use strict;
use warnings;


sub run 
{
    my ($self, $opts, @args) = @_;
    my $login = shift @args;
    $self->cache->set( login => $login );
    print "$login\n";
}

1;
