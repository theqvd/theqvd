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

  Adding custom properties:

  user <FILTERS> set property key=value  
  user <FILTERS> set property key=value, key=value, ...  

  For example: 
  user set property mykey=myvalue (Sets property mykey in all USERs)
  user name=myuser set property mykey=myvalue, yourkey=yourvalue (Sets properties mykey and yourkey in USER with name myuser)

  Deleting custom properties:

  user <FILTERS> del property key
  user <FILTERS> del property key, key, ...

  For example: 
  user del property mykey (Deletes property mykey in all USERs)
  user name=myuser del property mykey, yourkey (Deletes properties mykey and yourkey in USER with name myuser)

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

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'user',@args);
}


1;


