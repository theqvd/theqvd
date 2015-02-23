package QVD::Admin4::CLI::Command::Usage;
use base qw( CLI::Framework::Command::Meta );
use strict;
use warnings;


sub run 
{
    my ($self, $opts, @args) = @_;

    my $app = $self->get_app;
    my $usage = $app->usage(@args);

    system("more <<DELIM
$usage
DELIM");
}

1;

