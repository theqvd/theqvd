package QVD::Admin4::Command::OSF;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;
use QVD::Admin4::Command;


sub usage_text { 

"======================================================================================================
                                             OSF COMMAND USAGE
======================================================================================================

== CREATING A NEW OSF

  osf new <ARGUMENTS>
  
  For example: 
  osf name=myosf (Creates a OSF with name 'myosf') 

== GETTING OSFs

  osf get
  osf <FILTERS> get
  osf <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  osf get (retrieves default fields of all OSFs)
  osf name=myosf get (retrieves default fields of all OSFs with name 'myosf')
  osf name=myosf get name, id (retrieves 'name', 'id' of OSFs with name 'myosf') 

  Ordering:

  osf ... order <ORDER CRITERIA>
  osf ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  osf get order name (Ordering by 'name' in default ascendent order)
  osf get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  osf get order desc name, id (Ordering by 'name' and 'id' in descendent order)

== UPDATING OSFs

  osf set <ARGUMENTS>
  osf <FILTERS> set <ARGUMENTS>

  For example: 
  osf set memory=256 (Sets new value for memory in all OSFs)
  osf name=myosf set memory=256, overlay=0 (Sets new values for memory and overlay in OSF with name myosf)

== REMOVING OSFs
  
  osf del
  osf <FILTERS> del

  For example: 
  osf del (Removes all OSFs) 
  osf name=myosf del (Removes OSF with name myosf)

== AVAILABLE PARAMETERS

  The following parameters can be used as <FILTERS>, <ARGUMENTS>, <FIELDS TO RETRIEVE> or <ORDER CRITERIA>,
  although some combinations may not be allowed and an error will be prompted:
  
  id            (ID of the OSF)
  tenant_name   (Name of the tenant the OSF belongs to)
  tenant_id     (ID of the tenant the OSF belongs to)
  name          (Name of the OSF)
  user_storage  (Disk allocated for this VMs associated with the OSF in MB)
  memory        (RAM allocated for this VMs associated with the OSF in MB)
  overlay       (Flag that indicate whether overlay is enabled)
  number_of_vms (Number of VMs associated to the OSF)
  number_of_dis (Number of DIs associated to the DI)

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}


sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'osf',@args);
}


1;


