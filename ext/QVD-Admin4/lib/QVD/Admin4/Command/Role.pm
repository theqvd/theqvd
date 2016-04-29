package QVD::Admin4::Command::Role;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;
use QVD::Admin4::Command;

sub usage_text { 

"======================================================================================================
                                             ROLE COMMAND USAGE
======================================================================================================

== CREATING A NEW ROLE

  role new <ARGUMENTS>
  
  For example: 
  role name=myrole (Creates a ROLE with name 'myrole') 

== GETTING ROLEs

  role get
  role <FILTERS> get
  role <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  role get (retrieves default fields of all ROLEs)
  role name=myrole get (retrieves default fields of all ROLEs with name 'myrole')
  role name=myrole get name, id (retrieves 'name', 'id' of ROLEs with name 'myrole') 

  Ordering:

  role ... order <ORDER CRITERIA>
  role ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  role get order name (Ordering by 'name' in default ascendent order)
  role get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  role get order desc name, id (Ordering by 'name' and 'id' in descendent order)

  Getting role permissions:

  role <ROLE NAME> can
  role <ROLE NAME> can <ACL>

  For example:
  role myrole can (Retrieves all acls operative for role 'myrole')
  role myrole can user.update. (Retrieves acl user.update. if role 'myrole' has been assigned that acl)
  role myrole can user% (Retrieves all acls assigned to role 'myrole' that matches SQL commodin expression user%)

== UPDATING ROLEs

  role set <ARGUMENTS>
  role <FILTERS> set <ARGUMENTS>

  For example: 
  role name=myrole set name=yourrole (Sets new values for name in ROLE with name myrole)

  Assign roles and acls:

  role <FILTERS> assign role <ROLE NAME>
  role <FILTERS> assign role <ROLE NAME1>, <ROLE NAME2>, ...
  role <FILTERS> assign acl <ACL NAME>
  role <FILTERS> assign acl <ACL NAME1>, <ACL NAME2>, ...

  For example:
  role name=myrole assign role myrole
  role name=myrole assign role myrole, yourrole
  role name=myrole assign acl myacl
  role name=myrole assign acl myacl, youracl

  Unassign roles and acls:

  role <FILTERS> unassign role <ROLE NAME>
  role <FILTERS> unassign role <ROLE NAME1>, <ROLE NAME2>, ...
  role <FILTERS> unassign acl <ACL NAME>
  role <FILTERS> unassign acl <ACL NAME1>, <ACL NAME2>, ...

  For example:
  role name=myrole unassign role myrole
  role name=myrole unassign role myrole, yourrole
  role name=myrole unassign acl myacl
  role name=myrole unassign acl myacl, youracl

== REMOVING ROLEs
  
  role del
  role <FILTERS> del

  For example: 
  role del (Removes all ROLEs) 
  role name=myrole del (Removes ROLE with name myrole)

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'role',@args);
}


1;


