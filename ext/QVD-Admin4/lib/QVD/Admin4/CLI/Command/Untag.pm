package QVD::Admin4::CLI::Command::Untag;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub run 
{
    my ($self, $opts, @args) = @_;
    run_command($self,'untag',@args);
}



1;

