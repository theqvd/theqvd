package QVD::Admin4::CLI::Command::Config;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub usage_text { "Wrong syntax my friend!\n" }

sub run 
{
    my ($self, $opts, @args) = @_;
	if (my $s = $self->object->{filters}->{key_re})
	{
	    $s =~ s/%/.*/g;
	    $self->object->{filters}->{key_re} = qr/^$s$/;
	} 

    run_cmd($self,'config',@args);
}



1;

