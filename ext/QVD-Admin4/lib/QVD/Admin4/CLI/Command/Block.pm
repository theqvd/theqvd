package QVD::Admin4::CLI::Command::Block;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;


sub usage_text { 
"======================================================================================================
                                             BLOCK COMMAND USAGE
======================================================================================================

  block (Starts a form intended to change the current QVD administrator pagination block)

"
}

sub run 
{
    my ($self, $opts, @args) = @_;

    my $app = $self->get_app;
    my $block = $self->_read("Pagination block");
    $app->cache->set( block => $block );
}

1;

