package QVD::Admin4::CLI::Command::Tenant;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;


sub usage_text { 

"======================================================================================================
                                             TENANT COMMAND USAGE
======================================================================================================

== CREATING A NEW TENANT

  tenant new <ARGUMENTS>
  
  For example: 
  tenant name=mytenant (Creates a TENANT with name 'mytenant') 

== GETTING TENANTs

  tenant get
  tenant <FILTERS> get
  tenant <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  tenant get (retrieves default fields of all TENANTs)
  tenant name=mytenant get (retrieves default fields of all TENANTs with name 'mytenant')
  tenant name=mytenant get name, id (retrieves 'name', 'id' of TENANTs with name 'mytenant') 

  Ordering:

  tenant ... order <ORDER CRITERIA>
  tenant ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  tenant get order name (Ordering by 'name' in default ascendent order)
  tenant get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  tenant get order desc name, id (Ordering by 'name' and 'id' in descendent order)

== UPDATING TENANTs

  tenant set <ARGUMENTS>
  tenant <FILTERS> set <ARGUMENTS>

  For example: 
  tenant set language=en (Sets new value for language in all TENANTs)
  tenant name=mytenant set language=en, block=10 (Sets new values for language and block in TENANT with name mytenant)

== REMOVING TENANTs
  
  tenant del
  tenant <FILTERS> del

  For example: 
  tenant del (Removes all TENANTs) 
  tenant name=mytenant del (Removes TENANT with name mytenant)

$QVD::Admin4::CLI::Command::COMMON_USAGE_TEXT
"

}



sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'tenant',@args);
}


1;


