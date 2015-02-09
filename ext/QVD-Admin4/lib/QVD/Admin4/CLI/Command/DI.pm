package QVD::Admin4::CLI::Command::DI;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub usage_text { 

"
di get
di filter1=value1, filter2=value2 (, filter3=value3, ...) get
di (filters) get field1, field2(, field3, ...)
di ... get ... order (asc|desc) criteria1, criteria2(, criteria 3, ...)
di (filters) set argument1=value1, argument2=value2(, argument3=value3, ...)
di new argument1=value1, argument2=value2(, argument3=value3, ...)
di (filters) block|unblock
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'di',@args);
}


1;


