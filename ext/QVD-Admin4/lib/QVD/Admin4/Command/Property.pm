package QVD::Admin4::Command::Property;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;
use QVD::Admin4::Command;

sub usage_text { 

"======================================================================================================
                                             ADMIN COMMAND USAGE
======================================================================================================

== CREATING A NEW PROPERTY

  property new <ARGUMENTS>
  
  For example: 
  property new key=myprop, description=mydescription (Creates a PROPERTY with key name 'myprop' and description 'mydescription')

== GETTING PROPERTYs

  property get
  property <FILTERS> get
  property <FILTERS> get <FIELDS TO RETRIEVE>

  For example:
  property get (retrieves default fields of all PROPERTYs)
  property key=myprop get (retrieves default fields of all PROPERTYs with name 'myprop')
  property key=myprop get key, id (retrieves 'key', 'id' of PROPERTYs with name 'myprop')

== ASSIGNING PROPERTYs

  property <FILTERS> assign <QVD_OBJECT>

  For example:
  property key=myprop assign user
  property key=myprop assign vm

== UNASSIGNING PROPERTYs

  property <FILTERS> unassign <QVD_OBJECT>

  For example:
  property key=myprop unassign user
  property key=myprop unassign vm

== UPDATING PROPERTYs

  property <FILTERS> set <ARGUMENTS>

  For example:
  property key=myprop set description=newdescription

== UPDATING PROPERTYs in OBJECTS

  <QVD_OBJECT> set <ARGUMENTS>
  <QVD_OBJECT> <FILTERS> set <ARGUMENTS>

  For example: 
  user set addess=myaddress (Sets property address in all USERs)
  user name=myuser set addess=myaddress (Sets property address in the USER with name myuser)
  vm name=myvm set location=mylocation (Sets property location in the VM with name myvm)

== REMOVING PROPERTYs
  
  property <FILTERS> del

  For example: 
  property id=1000 del (Removes PROPERTY with id 1000 that includes any of the established values for that property)

== AVAILABLE PARAMETERS

  The following parameters can be used as <FILTERS>, <ARGUMENTS>, <FIELDS TO RETRIEVE> or <ORDER CRITERIA>,
  although some combinations may not be allowed and an error will be prompted:

  key           (Key name of the Property)
  id            (ID of the Property)
  tenant_name   (Name of tenant the Property belongs to)
  tenant_id     (ID of tenant the Property belongs to)
  description   (Describes what the Property is intended)
  in_user       (Relation ID with a USER if any)
  in_vm         (Relation ID with a VM if any)
  in_host       (Relation ID with a HOST if any)
  in_osf        (Relation ID with a OSF if any)
  in_di         (Relation ID with a DI if any)

  The properties can be assigned to differents elements of the system. The following parameters represents
  these elements and can be used as <QVD_OBJECT>:

  user
  host
  osf
  di
  vm

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'property',@args);
}

1;


