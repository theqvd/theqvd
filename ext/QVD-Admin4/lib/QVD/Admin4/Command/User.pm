package QVD::Admin4::Command::User;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;
use QVD::Admin4::Command;


sub usage_text { 

"======================================================================================================
                                             USER COMMAND USAGE
======================================================================================================

== CREATING A NEW USER

  user new <ARGUMENTS>
  
  For example: 
  user name=myuser, password=mypassword (Creates a USER with name 'myuser', password 'mypassword') 

== GETTING USERs

  user get
  user <FILTERS> get
  user <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  user get (retrieves default fields of all USERs)
  user name=myuser get (retrieves default fields of all USERs with name 'myuser')
  user name=myuser get name, id (retrieves 'name', 'id' of USERs with name 'myuser') 

  Ordering:

  user ... order <ORDER CRITERIA>
  user ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  user get order name (Ordering by 'name' in default ascendent order)
  user get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  user get order desc name, id (Ordering by 'name' and 'id' in descendent order)

== UPDATING USERs

  user set <ARGUMENTS>
  user <FILTERS> set <ARGUMENTS>

  For example: 
  user set password=samepassword (Sets new value for password in all USERs)
  user name=myuser set name=youruser, password=mypassword (Sets new values for name and password in USER with name myuser)

  Blocking/Unblocking USERs

  user <FILTERS> block
  user <FILTERS> unblock

  For example: 
  user block (Blocks all USERs)
  user name=myuser block (Blocks USER with name myuser)

== REMOVING USERs
  
  user del
  user <FILTERS> del

  For example: 
  user del (Removes all USERs) 
  user name=myuser del (Removes USER with name myuser)

== AVAILABLE PARAMETERS

  The following parameters can be used as <FILTERS>, <ARGUMENTS>, <FIELDS TO RETRIEVE> or <ORDER CRITERIA>,
  although some combinations may not be allowed and an error will be prompted:
  
  id                        (ID of the User)
  tenant_name               (Name of the tenant the User belongs to)
  tenant_id                 (ID of the tenant the User belongs to)
  name                      (Name of the User)
  number_of_vms             (Number of VMs associated to the User)
  number_of_vms_connected   (Number of VMs the User is connected to)

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'user',@args);
}


1;


