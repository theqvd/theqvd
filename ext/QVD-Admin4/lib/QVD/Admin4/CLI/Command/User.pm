package QVD::Admin4::CLI::Command::User;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;

sub usage_text { 

"
user get
user filter1=value1, filter2=value2 (, filter3=value3, ...) get
user (filters) get field1, field2(, field3, ...)
user ... get ... order (asc|desc) criteria1, criteria2(, criteria 3, ...)
user (filters) set argument1=value1, argument2=value2(, argument3=value3, ...)
user new argument1=value1, argument2=value2(, argument3=value3, ...)
user (filters) block|unblock
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'user',@args);
}


1;


