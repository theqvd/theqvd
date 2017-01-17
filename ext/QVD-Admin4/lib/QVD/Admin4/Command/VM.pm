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

== AVAILABLE PARAMETERS

  The following parameters can be used as <FILTERS>, <ARGUMENTS>, <FIELDS TO RETRIEVE> or <ORDER CRITERIA>,
  although some combinations may not be allowed and an error will be prompted:
  
  id            (ID of the VM)
  tenant_name   (Name of the VM the OSF belongs to)
  tenant_id     (ID of the VM the OSF belongs to)
  name          (Name of the VM)
  blocked       (Flag that indicates whether the VM is blocked for users to access)
  user_name     (Name of the User associated to the VM)
  user_id       (ID of the User associated to the VM)
  user_state    (State of the User respect to the VM)
  host_name     (Name of Host the VM is running in)
  host_id       (ID of Host the VM is running in)
  di_id         (ID of the Disk Image associated to the VM)
  di_name       (Name of the Disk Image associated to the VM)
  di_id_in_use  (ID of the Disk Image the VM is using while in running state)
  ip            (IP address of the VM)
  ip_in_use     (IP address the VM is using while in running state)
  state         (Current state of the VM)

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'vm',@args);
}


1;
