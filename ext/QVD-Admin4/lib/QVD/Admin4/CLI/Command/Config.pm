package QVD::Admin4::CLI::Command::Config;
use base qw( QVD::Admin4::CLI::Command );
use strict;
use warnings;
use QVD::Admin4::CLI::Command;


sub usage_text { 

"======================================================================================================
                                             CONFIG COMMAND USAGE
======================================================================================================

== GETTING CONFIG TOKENS

  config get
  config key=<CONFIG TOKEN NAME>, tenant=<TENANT ID> get

  For example: 
  config get (retrieves all configuration tokens of the current administrator tenant)
  config key=wat.multitenant, tenant=-1 get (retrieves the global 'wat.multitenant' configuration token)
  config key=path.log, tenant=10000 get (retrieves the 'path.log' configuration token for tenant 10000)

== SETTING CONFIG TOKENS

  config set key=<CONFIG TOKEN NAME>, value=<CONFIG TOKEN VALUE>, tenant=<TENANT ID>
  For example: 
  config set key=wat.multitenant, value=1, tenant=1000
  (Sets the 'wat.multitenant' configuration token to 1 for tenant 10000)

== REMOVING CONFIG TOKENS

  config key=<CONFIG TOKEN NAME>, tenant=<TENANT ID> del
  (Only for custom config tokens: default tokens in the system, or tokens codified in
   configuration files cannot be removed)
 
  For example: 
  config key='myconfig', tenant=10000 del (Deletes the 'myconfig' configuration token for tenant 10000)

== SETTING CONFIG TOKENS TO DEFAULT

  config key=<CONFIG TOKEN NAME>, tenant=<TENANT ID> default

  For example:
  config key=path.log, tenant=10000 default
  (Sets the 'path.log' configuration token for tenant 10000 to the default value)

== SETTING SSL CONFIG

  config ssl key=<KEY FILE PATH>, cert=<CRT FILE PATH>

  For example:
  config ssl key=/var/run/qvd/l7r/ssl/key.pem, cert=/var/run/qvd/l7r/ssl/cert.pem
  (Stores the key and cert files content)
"

}



# Filters to identify config tokens are changed from
# the commodins syntax (%) that accepts the CLI to the
# REGEX syntax that supports the key_re filter in the API

# The rest is like any other display action

sub run 
{
    my ($self, $opts, @args) = @_;
    my $parsing = $self->parse_string('config',@args);

    for my $ref_v ($parsing->filters->get_filter_ref_value('key_re'))
    {
	my $v = $parsing->filters->get_value($ref_v);

	$v =~ s/\./[.]/g;
	$v =~ s/%/.*/g;
	$v = qr/^$v$/;
	$parsing->filters->set_filter($ref_v,'key_re', $v);
    }

    my $query = $self->make_api_query($parsing); 

	$self->execute_and_display_query($query,$parsing);
}

1;

