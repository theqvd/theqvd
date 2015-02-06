package QVD::Admin4::CLI::Command::VM;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;

sub usage_text { 

"
vm get
vm filter1=value1, filter2=value2 (, filter3=value3, ...) get
vm (filters) get field1, field2(, field3, ...)
vm ... get ... order (asc|desc) criteria1, criteria2(, criteria 3, ...)
vm (filters) set argument1=value1, argument2=value2(, argument3=value3, ...)
vm new argument1=value1, argument2=value2(, argument3=value3, ...)
vm (filters) block|unblock|start|stop|disconnect
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'vm',@args);
}


1;

