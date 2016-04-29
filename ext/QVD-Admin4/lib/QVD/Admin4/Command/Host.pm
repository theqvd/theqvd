package QVD::Admin4::Command::Host;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;

sub usage_text { 

"======================================================================================================
                                             HOST COMMAND USAGE
======================================================================================================

== CREATING A NEW HOST

  host new <ARGUMENTS>
  
  For example: 
  host name=myhost, address=10.3.15.1 (Creates a HOST with name 'myhost', address '10.3.15.1') 

== GETTING HOSTs

  host get
  host <FILTERS> get
  host <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  host get (retrieves default fields of all HOSTs)
  host name=myhost get (retrieves default fields of all HOSTs with name 'myhost')
  host name=myhost get name, id (retrieves 'name', 'id' of HOSTs with name 'myhost') 

  Ordering:

  host ... order <ORDER CRITERIA>
  host ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  host get order name (Ordering by 'name' in default ascendent order)
  host get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  host get order desc name, id (Ordering by 'name' and 'id' in descendent order)

== UPDATING HOSTs

  host set <ARGUMENTS>
  host <FILTERS> set <ARGUMENTS>

  For example: 
  host name=myhost set name=yourhost, address=10.3.15.1 (Sets new values for name and address in HOST with name myhost)

  Adding custom properties:

  host <FILTERS> set property key=value  
  host <FILTERS> set property key=value, key=value, ...  

  For example: 
  host set property mykey=myvalue (Sets property mykey in all HOSTs)
  host name=myhost set property mykey=myvalue, yourkey=yourvalue (Sets properties mykey and yourkey in HOST with name myhost)

  Deleting custom properties:

  host <FILTERS> del property key
  host <FILTERS> del property key, key, ...

  For example: 
  host del property mykey (Deletes property mykey in all HOSTs)
  host name=myhost del property mykey, yourkey (Deletes properties mykey and yourkey in HOST with name myhost)

  Blocking/Unblocking HOSTs

  host <FILTERS> block
  host <FILTERS> unblock

  For example: 
  host block (Blocks all HOSTs)
  host name=myhost block (Blocks HOST with name myhost)

== REMOVING HOSTs
  
  host del
  host <FILTERS> del

  For example: 
  host del (Removes all HOSTs) 
  host name=myhost del (Removes HOST with name myhost)

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}


sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'host',@args);
}


1;

