package QVD::Admin4::Command::VM;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;

sub option_spec {
    }

sub usage_text { 

"======================================================================================================
                                             VM COMMAND USAGE
======================================================================================================

== CREATING A NEW VM

  vm new <ARGUMENTS>
  
  For example: 
  vm new name=myvm, user=myuser, osf=myosf (Creates a VM with user 'myuser', osf 'myosf' and name 'myvm') 

== GETTING VMs

  vm get
  vm <FILTERS> get
  vm <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  vm get (retrieves default fields of all VMs)
  vm name=myvm get (retrieves default fields of all VMs with name 'myvm')
  vm name=myvm get name, id, ip (retrieves 'name', 'id' and 'ip' of VMs with name 'myvm') 

  Ordering:

  vm ... order <ORDER CRITERIA>
  vm ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  vm get order name (Ordering by 'name' in default ascendent order)
  vm get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  vm get order desc name, id (Ordering by 'name' and 'id' in descendent order)

== UPDATING VMs

  vm set <ARGUMENTS>
  vm <FILTERS> set <ARGUMENTS>

  For example: 
  vm set di_tag=default (Sets new value for di_tag in all VMs)
  vm name=myvm set name=yourvm, di_tag=default (Sets new values for name and di_tag in VM with name myvm)

  Adding custom properties:

  vm <FILTERS> set property key=value  
  vm <FILTERS> set property key=value, key=value, ...  

  For example: 
  vm set property mykey=myvalue (Sets property mykey in all VMs)
  vm name=myvm set property mykey=myvalue, yourkey=yourvalue (Sets properties mykey and yourkey in VM with name myvm)

  Deleting custom properties:

  vm <FILTERS> del property key
  vm <FILTERS> del property key, key, ...

  For example: 
  vm del property mykey (Deletes property mykey in all VMs)
  vm name=myvm del property mykey, yourkey (Deletes properties mykey and yourkey in VM with name myvm)

  Blocking/Unblocking VMs

  vm <FILTERS> block
  vm <FILTERS> unblock

  For example: 
  vm block (Blocks all VMs)
  vm name=myvm block (Blocks VM with name myvm)

== REMOVING VMs
  
  vm del
  vm <FILTERS> del

  For example: 
  vm del (Removes all VMs) 
  vm name=myvm del (Removes VM with name myvm)

== EXECUTING VMs

  vm <FILTERS> start
  vm <FILTERS> stop
  vm <FILTERS> disconnect

  For example: 
  vm start (Starts all VMs)
  vm name=myvm stop (Stop VM with name myvm)

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'vm',@args);
}


1;
