package QVD::Admin4::CLI::Command::Usage;
use base qw( CLI::Framework::Command::Meta );
use strict;
use warnings;


sub run 
{
    my ($self, $opts, @args) = @_;

    my $app = $self->get_app;
    print $app->usage(@args);
}

1;

