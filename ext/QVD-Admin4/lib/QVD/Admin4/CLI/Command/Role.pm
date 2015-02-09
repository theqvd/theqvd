package QVD::Admin4::CLI::Command::Role;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub usage_text { 

"
role get
role filter1=value1, filter2=value2 (, filter3=value3, ...) get
role (filters) get field1, field2(, field3, ...)
role ... get ... order (asc|desc) criteria1, criteria2(, criteria 3, ...)
role (filters) set argument1=value1, argument2=value2(, argument3=value3, ...)
role new argument1=value1, argument2=value2(, argument3=value3, ...)
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'role',@args);
}


1;


