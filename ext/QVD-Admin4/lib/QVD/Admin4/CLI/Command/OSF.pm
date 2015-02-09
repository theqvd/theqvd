package QVD::Admin4::CLI::Command::OSF;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub usage_text { 

"
osf get
osf filter1=value1, filter2=value2 (, filter3=value3, ...) get
osf (filters) get field1, field2(, field3, ...)
osf ... get ... order (asc|desc) criteria1, criteria2(, criteria 3, ...)
osf (filters) set argument1=value1, argument2=value2(, argument3=value3, ...)
osf new argument1=value1, argument2=value2(, argument3=value3, ...)
osf (filters) block|unblock
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'osf',@args);
}


1;


