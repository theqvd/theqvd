package QVD::Admin4::CLI::Command::Admin;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;
use QVD::Admin4::CLI::Grammar::Response;

sub usage_text { 

"
admin get
admin filter1=value1, filter2=value2 (, filter3=value3, ...) get
admin (filters) get field1, field2(, field3, ...)
admin ... get ... order (asc|desc) criteria1, criteria2(, criteria 3, ...)
admin (filters) set argument1=value1, argument2=value2(, argument3=value3, ...)
admin new argument1=value1, argument2=value2(, argument3=value3, ...)
" 
}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'admin',@args);
}


1;


