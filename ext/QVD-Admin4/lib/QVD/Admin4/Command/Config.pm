package QVD::Admin4::Command::Config;
use base qw( QVD::Admin4::Command );
use strict;
use warnings;
use QVD::Admin4::Command;


sub usage_text { 

"======================================================================================================
                                             CONFIG COMMAND USAGE
======================================================================================================

== GETTING CONFIG TOKENS

  config get
  config key=<CONFIG TOKEN NAME>, tenant_id=<TENANT ID> get

  For example: 
  config get (retrieves all configuration tokens of the current administrator tenant)
  config key=wat.multitenant, tenant_id=-1 get (retrieves the global 'wat.multitenant' configuration token)
  config key=path.log, tenant_id=10000 get (retrieves the 'path.log' configuration token for tenant 10000)

== SETTING CONFIG TOKENS

  config set key=<CONFIG TOKEN NAME>, value=<CONFIG TOKEN VALUE>, tenant=<TENANT ID>
  For example: 
  config set key=wat.multitenant, value=1, tenant_id=10000
  (Sets the 'wat.multitenant' configuration token to 1 for tenant 10000)

== REMOVING CONFIG TOKENS

  config key=<CONFIG TOKEN NAME>, tenant_id=<TENANT ID> del
  (Only for custom config tokens: default tokens in the system, or tokens codified in
   configuration files cannot be removed)
 
  For example: 
  config key='myconfig', tenant_id=10000 del (Deletes the 'myconfig' configuration token for tenant 10000)

== SETTING CONFIG TOKENS TO DEFAULT

  config key=<CONFIG TOKEN NAME>, tenant_id=<TENANT ID> default

  For example:
  config key=path.log, tenant_id=10000 default
  (Sets the 'path.log' configuration token for tenant 10000 to the default value)

== SETTING SSL CONFIG

  config ssl key=<KEY FILE PATH>, cert=<CRT FILE PATH>

  For example:
  config ssl key=/var/run/qvd/l7r/ssl/key.pem, cert=/var/run/qvd/l7r/ssl/cert.pem
  (Registers the content of the key or cert local files)

== AVAILABLE PARAMETERS

  The following parameters can be used as <FILTERS>, <ARGUMENTS>, <FIELDS TO RETRIEVE> or <ORDER CRITERIA>,
  although some combinations may not be allowed and an error will be prompted:
  
  key           (Name of the configuration parameter)
  value         (Value of the configuration parameter)
  default_value (Default value of the configuration parameter)
  is_default    (Returns whether the parameter is set to default)
  tenant_id     (ID of the tenant the configuration parameter belongs to)
"

}



# Filters to identify config tokens are changed from
# the commodins syntax (%) that accepts the CLI to the
# REGEX syntax that supports the key_re filter in the API

# The rest is like any other display action

sub run 
{
    my ($self, $opts, @args) = @_;

    $self->SUPER::run($opts,'config',@args);
}

1;

