package QVD::Admin4::CLI;
use base qw( CLI::Framework );
use strict;
use warnings;
use QVD::Admin4::CLI::Grammar;
use QVD::Admin4::CLI::Grammar::Unificator;
use QVD::Admin4::CLI::Parser;
use QVD::Admin4::CLI::Tokenizer;
use Mojo::UserAgent;
use Mojo::URL;
use Term::ReadKey;

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
        [ 'host|h=s'   => 'API host' ],
        [ 'port|p=s'   => 'API port' ],
    }

sub command_map {

    log      => 'QVD::Admin4::CLI::Command::Log',
    usage    => 'QVD::Admin4::CLI::Command::Usage',
    version  => 'QVD::Admin4::CLI::Command::Version',
    config   => 'QVD::Admin4::CLI::Command::Config',
    tenant   => 'QVD::Admin4::CLI::Command::Tenant',
    role     => 'QVD::Admin4::CLI::Command::Role',
    acl      => 'QVD::Admin4::CLI::Command::ACL',
    admin    => 'QVD::Admin4::CLI::Command::Admin',
    tag      => 'QVD::Admin4::CLI::Command::Tag',
    property => 'QVD::Admin4::CLI::Command::Property',
    vm       => 'QVD::Admin4::CLI::Command::VM',
    user     => 'QVD::Admin4::CLI::Command::User',
    host     => 'QVD::Admin4::CLI::Command::Host',
    osf      => 'QVD::Admin4::CLI::Command::OSF',
    di       => 'QVD::Admin4::CLI::Command::DI',
    login    => 'QVD::Admin4::CLI::Command::Login',
    logout   => 'QVD::Admin4::CLI::Command::Logout',
    password => 'QVD::Admin4::CLI::Command::Password',
    block    => 'QVD::Admin4::CLI::Command::Block',
    menu     => 'QVD::Admin4::CLI::Command::Menu',
    }

# This is executen when the app is run.
# It initalizes all objects and sets all parameters

sub init {
    my ($self, $opts) = @_;

    my ($host,$port) =  # It gets the API address
	(($opts->host || 'localhost'), 
	 ($opts->port || 3000)); 

# Created as objects all addresses in API

    my $api_url = Mojo::URL->new(); 
    $api_url->scheme('http'); 
    $api_url->host($host); 
    $api_url->port($port); 
    
    my $api_info_url = Mojo::URL->new(); 
    $api_info_url->scheme('http'); 
    $api_info_url->host($host); 
    $api_info_url->port($port); 
    $api_info_url->path('/info');
    
    my $api_staging_url = Mojo::URL->new(); 
    $api_staging_url->scheme('ws'); 
    $api_staging_url->host($host); 
    $api_staging_url->port($port); 
    $api_staging_url->path('/staging');
    
    my $api_di_upload_url = Mojo::URL->new(); 
    $api_di_upload_url->scheme('http'); 
    $api_di_upload_url->host($host); 
    $api_di_upload_url->port($port); 
    $api_di_upload_url->path('/di/upload');
    
# Created a web client

    my $user_agent = Mojo::UserAgent->new;

# Created objects to parse the input string

    my $unificator = QVD::Admin4::CLI::Grammar::Unificator->new();
    my $grammar = QVD::Admin4::CLI::Grammar->new();
    my $parser = QVD::Admin4::CLI::Parser->new( 
	grammar => $grammar, unificator => $unificator);
    my $tokenizer = QVD::Admin4::CLI::Tokenizer->new();

# Set parameters available from the whole app.

    $self->cache->set( user_agent => $user_agent ); 
    $self->cache->set( parser => $parser);
    $self->cache->set( tokenizer => $tokenizer );
    $self->cache->set( api_url => $api_url ); # url '/' in API
    $self->cache->set( api_info_url => $api_info_url ); # url '/info' in API
    $self->cache->set( api_di_upload_url => $api_di_upload_url ); # url '/di/upload' in API
    $self->cache->set( api_staging_url => $api_staging_url ); # ws url '/staging' in API
    $self->cache->set( login => undef ); # No default credentials provided
    $self->cache->set( tenant_name => undef ); 
    $self->cache->set( password => undef ); 
    $self->cache->set( block => 25 ); # FIX ME. Default block value should be taken from a config file or sth.
}


sub quit_signals { qw( q quit exit ) }

sub render {
    my ($self,$output) = @_;
    print $output unless $output =~ /[01]/;
}

sub handle_exception
{
    my ($self,$e) = @_;

    ReadMode(0); # This is important. It guarantees that,
                 # after an exception is thrown, the CLI console is in the
                 # right mode (i.e. this is needed when the CLI thrown an exception while it
                 # is in pagination mode; it forces the return to the non-pagination mode)
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

1;
