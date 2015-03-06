package QVD::Admin4::CLI::Command::Admin;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;
use QVD::Admin4::CLI::Grammar::Response;

sub usage_text { 

"======================================================================================================
                                             ADMIN COMMAND USAGE
======================================================================================================

== CREATING A NEW ADMIN

  admin new <ARGUMENTS>
  
  For example: 
  admin name=myadmin, password=mypassword (Creates a ADMIN with name 'myadmin' and password 'mypassword') 

== GETTING ADMINs

  admin get
  admin <FILTERS> get
  admin <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  admin get (retrieves default fields of all ADMINs)
  admin name=myadmin get (retrieves default fields of all ADMINs with name 'myadmin')
  admin name=myadmin get name, id (retrieves 'name', 'id' of ADMINs with name 'myadmin') 

  Ordering:

  admin ... order <ORDER CRITERIA>
  admin ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  admin get order name (Ordering by 'name' in default ascendent order)
  admin get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  admin get order desc name, id (Ordering by 'name' and 'id' in descendent order)

  Getting admin permissions:

  admin <ADMIN NAME> can
  admin <ADMIN NAME> can <ACL>

  For example:
  admin myadmin can (Retrieves all acls operative for admin 'myadmin')
  admin myadmin can user.update. (Retrieves acl user.update. if admin 'myadmin' has been assigned that acl)
  admin myadmin can user% (Retrieves all acls assigned to admin 'myadmin' that matches SQL commodin expression user%)

== UPDATING ADMINs

  admin set <ARGUMENTS>
  admin <FILTERS> set <ARGUMENTS>

  For example: 
  admin set language=en (Sets new value for language in all ADMINs)
  admin name=myadmin set language=en, block=10 (Sets new values for language and block in ADMIN with name myadmin)

  Assign roles:

  admin <FILTERS> assign role <ROLE NAME>
  admin <FILTERS> assign role <ROLE NAME1>, <ROLE NAME2>, ...

  For example:
  admin name=myadmin assign role myrole
  admin name=myadmin assign role myrole, yourrole

  Unassign roles:

  admin <FILTERS> unassign role <ROLE NAME>
  admin <FILTERS> unassign role <ROLE NAME1>, <ROLE NAME2>, ...

  For example:
  admin name=myadmin unassign role myrole
  admin name=myadmin unassign role myrole, yourrole

== REMOVING ADMINs
  
  admin del
  admin <FILTERS> del

  For example: 
  admin del (Removes all ADMINs) 
  admin name=myadmin del (Removes ADMIN with name myadmin)

$QVD::Admin4::CLI::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'admin',@args);
}


1;


