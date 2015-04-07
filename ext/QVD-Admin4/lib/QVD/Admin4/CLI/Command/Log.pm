package QVD::Admin4::CLI::Command::Log;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;

sub option_spec {
    }

sub usage_text { 

"======================================================================================================
                                             LOG COMMAND USAGE
======================================================================================================

== GETTING LOG entries

  log get
  log <FILTERS> get
  log <FILTERS> get <FIELDS TO RETRIEVE>

  For example: 
  log get (retrieves default fields of all LOG entries)
  log action=login get (retrieves default fields of all LOG entries regarding login actions)
  log action=login get action, time, status (retrieves 'action', 'time', and 'status fields)

  Ordering:

  log ... order <ORDER CRITERIA>
  log ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  log get order time (Ordering by 'time' in default ascendent order)
  log get order asc time, action (Ordering by 'time' and 'action' in ascendent order)
  log get order desc time, action (Ordering by 'time' and 'action' in descendent order)

$QVD::Admin4::CLI::Command::COMMON_USAGE_TEXT
"

}

sub run 
{
    my ($self, $opts, @args) = @_;
    $self->SUPER::run($opts,'log',@args);
}


1;

