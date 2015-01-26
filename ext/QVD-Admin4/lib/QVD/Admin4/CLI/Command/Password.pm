package QVD::Admin4::CLI::Command::Password;
use base qw( CLI::Framework::Command::Meta );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub run 
{
    my ($self, $opts, @args) = @_;
    my $app = $self->get_app;
    my $password = read_password($app);
    $self->cache->set( password => $password );
    print "\n";
}

1;
