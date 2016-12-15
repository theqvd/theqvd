package QVD::Admin4::Command::ACL;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;

sub option_spec {
    }

sub usage_text { 

"======================================================================================================
                                             ACL COMMAND USAGE
======================================================================================================

== GETTING ACLs

  acl get
  acl <FILTERS> get
  acl <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  acl get (retrieves default fields of all ACLs)
  acl name=myacl get (retrieves default fields of all ACLs with name 'myacl')
  acl name=myacl get name (retrieves 'name' of ACLs with name 'myacl') 

  Ordering:

  acl ... order <ORDER CRITERIA>
  acl ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  acl get order name (Ordering by 'name' in default ascendent order)
  acl get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  acl get order desc name, id (Ordering by 'name' and 'id' in descendent order)


== AVAILABLE PARAMETERS

  The following parameters can be used as <FILTERS>, <FIELDS TO RETRIEVE> or <ORDER CRITERIA>,
  although some combinations may not be allowed and an error will be prompted:
  
  id    (Numeric ID of the ACL)
  name  (ACL name)

$QVD::Admin4::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'acl',@args);
}


1;
