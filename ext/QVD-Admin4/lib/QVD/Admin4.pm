package QVD::Admin4;
use base qw( CLI::Framework );
use strict;
use warnings;
use QVD::Admin4::Grammar;
use QVD::Admin4::Grammar::Unificator;
use QVD::Admin4::Parser;
use QVD::Admin4::Tokenizer;
use Mojo::UserAgent;
use Mojo::URL;
use Term::ReadKey;
use QVD::Config qw(cfg);

sub usage_text {
	"
    ==============================================================================
                               AVAILABLE COMMANDS
    ==============================================================================
    
       For a specific explanation of the following commands run:
       usage <COMMAND>
       i.e. usage login
    
    == CLI GENERAL MANAGEMENT COMMANDS
    
       usage (retrieves instructions about the usage of the app) 
       
       login (Intended to log in as a QVD administrator)
       
       logout (Intended to log out)
       
       password (Intended to change current QVD administrator password)
    
       block (Intended to change current QVD administrator pagination block)
       
       version (Retrieves information about the QVD version the app is connected to)
          
       log (retrieves log entries about the QVD server activity) 
    
    == QVD OBJECTS COMMANDS
    
        vm (Intended to QVD virtual machines management)
    
        user (Intended to QVD users management)
    
        host (Intended to QVD hosts management)
    
        osf (Intended to QVD OSFs management)
    
        di (Intended to QVD disk images management)
    
        tenant (Intended to QVD tenants management)
    
        role (Intended to QVD roles management)
    
        acl (Intended to QVD acls management)
    
        admin (Intended to QVD administrators management)
    
        config (Intended to QVD configuration management)
    ";
}


sub option_spec {
	[ 'url|u=s'        => 'API url. Example: http://127.0.0.1:3000/api' ],
		[ 'tenant|t=s'     => 'API admin tenant name' ],
		[ 'login|l=s'      => 'API admin login' ],
		[ 'password|p=s'   => 'API admin password' ],
		[ 'format|f=s'     => 'Output format' ],
		[ 'insecure'       => 'Trust any certificate'],
		[ 'ca=s'           => 'CA certificate path'],
}

sub command_map {

	log      => 'QVD::Admin4::Command::Log',
		usage    => 'QVD::Admin4::Command::Usage',
		version  => 'QVD::Admin4::Command::Version',
		config   => 'QVD::Admin4::Command::Config',
		tenant   => 'QVD::Admin4::Command::Tenant',
		role     => 'QVD::Admin4::Command::Role',
		acl      => 'QVD::Admin4::Command::ACL',
		admin    => 'QVD::Admin4::Command::Admin',
		tag      => 'QVD::Admin4::Command::Tag',
		vm       => 'QVD::Admin4::Command::VM',
		user     => 'QVD::Admin4::Command::User',
		host     => 'QVD::Admin4::Command::Host',
		osf      => 'QVD::Admin4::Command::OSF',
		di       => 'QVD::Admin4::Command::DI',
		login    => 'QVD::Admin4::Command::Login',
		logout   => 'QVD::Admin4::Command::Logout',
		password => 'QVD::Admin4::Command::Password',
		block    => 'QVD::Admin4::Command::Block',
		menu     => 'QVD::Admin4::Command::Menu',
}

# This is executen when the app is run.
# It initalizes all objects and sets all parameters

sub init {
	my ($self, $opts) = @_;

	my ($url, $tenant_name, $login, $password, $insecure, $ca_cert_path, $output_format);
	$url = Mojo::URL->new($opts->url // cfg('qa.url'));
	$url->path->leading_slash(1)->trailing_slash(1)->canonicalize;
	$tenant_name = $opts->tenant // cfg('qa.tenant');
	$login = $opts->login // cfg('qa.login');
	$password = $opts->password // cfg('qa.password');
	$insecure = $opts->insecure // cfg('qa.insecure');
	$ca_cert_path = $opts->ca // cfg('qa.ca');
	my @output_formats = ('TABLE', 'CSV');
	$output_format = $opts->format //cfg('qa.format');
	if (not grep {$_ eq $output_format} @output_formats ) {
		print STDERR "[WARNING] Output format shall be one of:" . join(", ",@output_formats).
				". Using TABLE by default.\n";
		$output_format = 'TABLE';
	}

	# Created as objects all addresses in API

	my $api_url = Mojo::URL->new($url);
	my $ws_url = Mojo::URL->new($url);
	if ($ws_url->scheme() eq "http"){
		$ws_url->scheme('ws');
	} else {
		$ws_url->scheme('wss');
	}

	my $api_default_path = "api";
	my $api_info_path = "$api_default_path/info";
	my $api_di_upload_path = "$api_default_path/di/upload";
	my $api_staging_path = "$api_default_path/staging";
	
	# Created a web client
	my $user_agent = Mojo::UserAgent->new();
	unless($insecure){
		if (not -e $ca_cert_path){
			die "CA certificate \"$ca_cert_path\" does not exist";
		} else {
			$user_agent->ca($ca_cert_path);
		}
	}

	# Created objects to parse the input string

	my $unificator = QVD::Admin4::Grammar::Unificator->new();
	my $grammar = QVD::Admin4::Grammar->new();
	my $parser = QVD::Admin4::Parser->new(grammar => $grammar, unificator => $unificator);
	my $tokenizer = QVD::Admin4::Tokenizer->new();

	# Set parameters available from the whole app.

	$self->cache->set( user_agent => $user_agent );
	$self->cache->set( parser => $parser);
	$self->cache->set( tokenizer => $tokenizer );
	$self->cache->set( api_url => $api_url );
	$self->cache->set( ws_url => $ws_url );
	$self->cache->set( api_default_path => $api_default_path );
	$self->cache->set( api_info_path => $api_info_path );
	$self->cache->set( api_di_upload_path => $api_di_upload_path );
	$self->cache->set( api_staging_path => $api_staging_path );
	$self->cache->set( login => undef ); # No default credentials provided
	$self->cache->set( tenant_name => undef );
	$self->cache->set( password => undef );
	$self->cache->set( block => 25 ); # FIXME. Default block value should be taken from a config file or sth.
	$self->cache->set( display_mode => $output_format );
	$self->cache->set( exit_code => 0 );


	if (not $self->is_interactive_mode_enabled()){
		$self->cache->set( tenant_name => $tenant_name );
		$self->cache->set( login => $login );
		$self->cache->set( password => $password );
	}

}


sub quit_signals { qw( q quit exit ) }

sub render {
	my ($self,$output) = @_;
	print $output unless $output =~ /[01]/;
}

sub handle_exception
{
	my ($self,$e) = @_;

	# This is important. It guarantees that,
	# after an exception is thrown, the CLI console is in the
	# right mode (i.e. this is needed when the CLI thrown an exception while it
	# is in pagination mode; it forces the return to the non-pagination mode)
	ReadMode(0);

	$self->cache->set( exit_code => 1 );

	print $e->message, "\n";
}

# This method has been copy/pasted from CLI::Framework
# It overwrites the original one. It has been added here
# in order to escapa the quotes (',") introduced in the
# CLI console. We don't want them to be parsed in a Unix
# console regular way. Quotes have their own special meaning
# in CLI syntax

sub read_cmd {

	my ($app) = @_;

	require Text::ParseWords;

	my $term = $app->{_readline};

	unless( $term ) {
		require Term::ReadLine;
		$term = Term::ReadLine->new('CLIF Application');
		select $term->OUT;
		$app->{_readline} = $term;
	}
	my $command_request = $term->readline('> ');

	if(! defined $command_request ) {

		@ARGV = $app->quit_signals();
		print "\n";
	}
	else {
		$command_request =~ s/'/\\'/g; # These are the
		$command_request =~ s/"/\\"/g; # added lines
		@ARGV = Text::ParseWords::shellwords( $command_request );
		$term->addhistory($command_request)
			if $command_request =~ /\S/ and !$term->Features->{autohistory};
	}
	return 1;
}

sub is_interactive_mode_enabled {
	my $self = shift;
	return $self->get_interactivity_mode();
}

sub exit_status {
	my $self = shift;
	return $self->cache->get('exit_code');
}

sub set_help_message {
	my $self = shift;
	my $message = shift;
	$self->cache->set('help_message', $message);
}

sub help_message {
	my $self = shift;
	my $message = $self->cache->get('help_message') //
		"Insert any string: " . join(", ", map( {"\"$_\""} $self->quit_signals())) . " to exit from CLI";
	return $message;
}

1;
