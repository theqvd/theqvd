package QVD::Admin4::Command::Usage;
use base qw( CLI::Framework::Command::Meta );
use strict;
use warnings;

sub usage_text { 
"======================================================================================================
                                             USAGE COMMAND USAGE
======================================================================================================

  usage (Retrieves general instructions about the app)
  usage <COMMAND> (Retrieves specific instructions about the <COMMAND> command)

"
}

sub run 
{
    my ($self, $opts, @args) = @_;

    my $app = $self->get_app;
    my $usage = $app->usage(@args);

    system("less <<DELIM
$usage
DELIM");
}

1;

