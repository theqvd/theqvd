package QVD::Admin4::CLI::Command::OSF;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;


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

  Adding custom properties:

  osf <FILTERS> set property key=value  
  osf <FILTERS> set property key=value, key=value, ...  

  For example: 
  osf set property mykey=myvalue (Sets property mykey in all OSFs)
  osf name=myosf set property mykey=myvalue, yourkey=yourvalue (Sets properties mykey and yourkey in OSF with name myosf)

  Deleting custom properties:

  osf <FILTERS> del property key
  osf <FILTERS> del property key, key, ...

  For example: 
  osf del property mykey (Deletes property mykey in all OSFs)
  osf name=myosf del property mykey, yourkey (Deletes properties mykey and yourkey in OSF with name myosf)

== REMOVING OSFs
  
  osf del
  osf <FILTERS> del

  For example: 
  osf del (Removes all OSFs) 
  osf name=myosf del (Removes OSF with name myosf)

$QVD::Admin4::CLI::Command::COMMON_USAGE_TEXT
"

}


sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'osf',@args);
}


1;


