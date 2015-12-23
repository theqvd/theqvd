#!/usr/lib/qvd/bin/perl
use strict;
use warnings;
use Mojolicious::Lite;

my $perl_path = "$^X";
my $create_tenant_script_path = "./QVD-Admin4/bin/demo_tenant_creator.pl";

# Set port
app->config(hypnotoad => {listen => ['http://localhost:3001']});

# Routes
get '/create_tenant' => sub {
	my $c = shift;
	my $exit_code = 0;
	my $message = "OK";

	# Get parameters from url
	my $params_hash = $c->req->params->to_hash;
	my @args = ();
	while(my ($key, $value) = each(%$params_hash)){
		push @args, "-$key";
		push @args, $value;
	}

	# Call create tenant script
	eval {
		if(-e $create_tenant_script_path){
			system("$perl_path $create_tenant_script_path " . join (" ", @args));
		} else {
			die "Tenant creator script does not exist";
		}
	};
	if ($@) {
		$message = $@;
		$exit_code = 1;
	}

	# Return state
	my $json = {
		status => $exit_code,
		message => $message,
	};

	$c->render(json => $json);
};

app->start;
