package QVD::Admin4::CLI::Command::Host;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;

sub usage_text { 

"
host get
host filter1=value1, filter2=value2 (, filter3=value3, ...) get
host (filters) get field1, field2(, field3, ...)
host ... get ... order (asc|desc) criteria1, criteria2(, criteria 3, ...)
host (filters) set argument1=value1, argument2=value2(, argument3=value3, ...)
host new argument1=value1, argument2=value2(, argument3=value3, ...)
host (filters) block|unblock
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'host',@args);
}


1;

