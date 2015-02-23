package QVD::Admin4::CLI::Command::VM;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;

sub option_spec {
        [ 'host|h=s'   => 'API host' ],
        [ 'port|p=s'   => 'API port' ],
    }

sub usage_text { 
"==================================================================================
                                  VM COMMAND USAGE
==================================================================================

  (<FILTERS> are optional. See also 'usage filters', usage fields', 'usage order' 
   and 'usage arguments')

== CREATING A NEW VM

  vm new <ARGUMENTS>

== GETTING VMs

  vm <FILTERS> get
  vm <FILTERS> get <FIELDS TO RETRIEVE>
  vm <FILTERS> get <FIELDS TO RETRIEVE> order <ORDER CRITERIA>
  vm <FILTERS> get <FIELDS TO RETRIEVE> order <ORDER DIRECTION> <ORDER CRITERIA>

== UPDATING VMs

  vm <FILTERS> set <ARGUMENTS>

  Adding custom properties:

  vm <FILTERS> set property key=value  
  vm <FILTERS> set property key=value, key=value, ...  

  Deleting custom properties:

  vm <FILTERS> del property key
  vm <FILTERS> del property key, key, ...

== REMOVING VMs
  
  vm <FILTERS> del

  vm <FILTERS> block
  vm <FILTERS> unblock

  vm <FILTERS> start
  vm <FILTERS> stop
  vm <FILTERS> disconnect

===================================================================================
"

}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'vm',@args);
}


1;

