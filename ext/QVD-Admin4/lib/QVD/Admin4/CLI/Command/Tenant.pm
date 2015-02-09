package QVD::Admin4::CLI::Command::Tenant;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub usage_text { 

"
tenant get
tenant filter1=value1, filter2=value2 (, filter3=value3, ...) get
tenant (filters) get field1, field2(, field3, ...)
tenant ... get ... order (asc|desc) criteria1, criteria2(, criteria 3, ...)
tenant (filters) set argument1=value1, argument2=value2(, argument3=value3, ...)
tenant new argument1=value1, argument2=value2(, argument3=value3, ...)
tenant (filters) block|unblock
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'tenant',@args);
}


1;


