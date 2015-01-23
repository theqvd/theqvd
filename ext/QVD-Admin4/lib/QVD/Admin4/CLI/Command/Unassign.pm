package QVD::Admin4::CLI::Command::Unassign;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub run 
{
    my ($self, $opts, @args) = @_;
    run_command($self,'unassign',@args);
}



1;

