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
  config get <CONFIG TOKEN NAME>

  For example: 
  config get (retrieves all configuration tokens in the system)
  config get wat.multitenant (retrieves the 'wat.multitenant' configuration token)

== SETTING CONFIG TOKENS

  config set <CONFIG TOKEN NAME> = <CONFIG TOKEN VALUE>
  For example: 
  config set wat.multitenant=1 (Sets the 'wat.multitenant' configuration token to 1)

== REMOVING CONFIG TOKENS

  config del <CONFIG TOKEN NAME>
  (Only for custom config tokens: default tokens in the system, or tokens codified in
   configuration files cannot be removed)
 
  For example: 
  config del myconfig (Deletes the 'myconfig' configuration token)

"

}


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
    my $res = $self->ask_api($query);
    $self->print_table($res,$parsing);
}

1;

