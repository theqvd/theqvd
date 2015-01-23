package QVD::Admin4::CLI::Command::Tag;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub run 
{
    my ($self, $opts, @args) = @_;
    run_command($self,'tag',@args);
}



1;

