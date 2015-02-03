package QVD::Admin4::CLI::Command::Admin;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub usage_text { "Wrong syntax my friend!\n" }

sub run 
{
    my ($self, $opts, @args) = @_;
    run_cmd($self,'admin',@args);
}


1;

