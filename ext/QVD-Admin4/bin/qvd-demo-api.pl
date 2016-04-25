#!/usr/lib/qvd/bin/perl
use strict;
use warnings;
use Mojolicious::Lite;
use Mojo::JSON qw(decode_json);
use Deep::Encode;
use Capture::Tiny ':all';

my $perl_path = "$^X";
my $create_tenant_script_path = "./QVD-Admin4/bin/demo_tenant_creator.pl";

# Set port
app->config(hypnotoad => {listen => ['http://*:3001']});

sub get_input_json {
	my $c = shift;
	my $json = $c->req->json // $c->req->params->to_hash;

	foreach my $key (keys %{$json}){
		eval {
			$json->{$key} = decode_json($json->{$key});
		}
	}

	deep_utf8_decode($json);

	return $json;
}

# Routes
any [qw(POST GET)] => '/create_tenant' => sub {
	my $c = shift;
	$c->inactivity_timeout(300);

	my $exit_code = 0;
	my $message = "OK";
	my $tenant_name = "";

	# Get parameters from url
	my $input_json = get_input_json($c);
	my @args = ();
	while(my ($key, $value) = each(%$input_json)){
		if(ref($value) eq "ARRAY") {
			foreach my $subvalue (@$value){
		push @args, "-$key";
				push @args, "$subvalue";
			}
		} else {
			push @args, "-$key";
			push @args, "$value";
		}
	}

	# Call create tenant script
	my ($stdout, $stderr);
	eval {
		if(-e $create_tenant_script_path){
			($stdout, $stderr, $exit_code) = capture {
				system($perl_path, $create_tenant_script_path, @args);
			};
			$exit_code >>= 8;
		} else {
			die "Tenant creator script does not exist";
		}
	};
	if ($@) {
		$message = $@;
		$exit_code = 1;
	} else {
		chomp($stdout);
		chomp($stderr);
		$stderr =~ s/\n/, /g;
        
		my $OK_code = 0;
		if($OK_code == $exit_code){
			$tenant_name = $stdout;
		} else {
			$tenant_name = "";
			$message = "${stdout}: ${stderr}";
		}
	}

	# Return state
	my $json = {
		status => $exit_code,
		message => $message,
		tenant => $tenant_name,
	};

	$c->render(json => $json);
};

get '/status' => sub{
	my $c = shift;
	$c->inactivity_timeout(300);

	$c->render(json => { status => 0 , message => 'I am alive' });
};

app->start;
