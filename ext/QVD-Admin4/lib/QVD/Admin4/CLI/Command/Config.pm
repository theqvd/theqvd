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

  config get <CONFIG TOKEN NAME>

== SETTING CONFIG TOKENS

  Ordering:

  acl ... order <ORDER CRITERIA>
  acl ... order <ORDER DIRECTION> <ORDER CRITERIA>

  For example: 
  acl get order name (Ordering by 'name' in default ascendent order)
  acl get order asc name, id (Ordering by 'name' and 'id' in ascendent order)
  acl get order desc name, id (Ordering by 'name' and 'id' in descendent order)

$QVD::Admin4::CLI::Command::COMMON_USAGE_TEXT
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

