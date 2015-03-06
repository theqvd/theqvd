package QVD::Admin4::CLI;
use base qw( CLI::Framework );
use strict;
use warnings;
use QVD::Admin4::CLI;
use QVD::Admin4::CLI::Command;
use QVD::Admin4::CLI::Grammar;
use QVD::Admin4::CLI::Grammar::Unificator;
use QVD::Admin4::CLI::Parser;
use QVD::Admin4::CLI::Tokenizer;
use Mojo::UserAgent;
use Mojo::URL;

sub usage_text { 
"=======================================================================================================================
                                                      CLI COMMANDS USAGE
=======================================================================================================================

  vm|user|osf|host|di|tenant|admin|role|acl get
  vm|user|osf|host|di|tenant|admin|role|acl <FILTERS> get
  vm|user|osf|host|di|tenant|admin|role|acl <FILTERS> get <FIELDS TO RETRIEVE>
  vm|user|osf|host|di|tenant|admin|role|acl <FILTERS> get <FIELDS TO RETRIEVE> order <ORDER CRITERIA>
  vm|user|osf|host|di|tenant|admin|role|acl <FILTERS> get <FIELDS TO RETRIEVE> order <ORDER DIRECTION> <ORDER CRITERIA>

  vm|user|osf|host|di|tenant|admin|role set <ARGUMENTS>
  
  vm|user|osf|host|di|tenant|admin|role new <ARGUMENTS>
  
  vm|user|osf|host|di|tenant|admin|role del
  vm|user|osf|host|di|tenant|admin|role <FILTERS> del

  vm|user|osf|host|di <FILTERS> block
  vm|user|osf|host|di <FILTERS> unblock

  vm <FILTERS> start
  vm <FILTERS> stop
  vm <FILTERS> disconnect

";
}


sub option_spec {
        [ 'host|h=s'   => 'API host' ],
        [ 'port|p=s'   => 'API port' ],
    }

sub command_map {

    usage => 'QVD::Admin4::CLI::Command::Usage',
    version => 'QVD::Admin4::CLI::Command::Version',
    config => 'QVD::Admin4::CLI::Command::Config',
    tenant => 'QVD::Admin4::CLI::Command::Tenant',
    role => 'QVD::Admin4::CLI::Command::Role',
    acl => 'QVD::Admin4::CLI::Command::ACL',
    admin => 'QVD::Admin4::CLI::Command::Admin',
    tag => 'QVD::Admin4::CLI::Command::Tag',
    property => 'QVD::Admin4::CLI::Command::Property',
    vm => 'QVD::Admin4::CLI::Command::VM',
    user => 'QVD::Admin4::CLI::Command::User',
    host => 'QVD::Admin4::CLI::Command::Host',
    osf => 'QVD::Admin4::CLI::Command::OSF',
    di => 'QVD::Admin4::CLI::Command::DI',
    login    => 'QVD::Admin4::CLI::Command::Login',
    logout   => 'QVD::Admin4::CLI::Command::Logout',
    menu    => 'QVD::Admin4::CLI::Command::Menu',
    }

sub init {
    my ($self, $opts) = @_;

    my ($host,$port) = (($opts->host || 'localhost'), ($opts->port || 3000)); 

    my $api_url = Mojo::URL->new(); $api_url->scheme('http'); $api_url->host($host); $api_url->port($port); 
    my $api_info_url = Mojo::URL->new(); $api_info_url->scheme('http'); $api_info_url->host($host); $api_info_url->port($port); $api_info_url->path('/info');
    my $api_staging_url = Mojo::URL->new(); $api_staging_url->scheme('ws'); $api_staging_url->host($host); $api_staging_url->port($port); 
    $api_staging_url->path('/staging');
    my $api_di_upload_url = Mojo::URL->new(); $api_di_upload_url->scheme('http'); $api_di_upload_url->host($host); $api_di_upload_url->port($port); 
    $api_di_upload_url->path('/di/upload');
    my $user_agent = Mojo::UserAgent->new;

    my $unificator = QVD::Admin4::CLI::Grammar::Unificator->new();
    my $grammar = QVD::Admin4::CLI::Grammar->new();
    my $parser = QVD::Admin4::CLI::Parser->new( grammar => $grammar, unificator => $unificator);
    my $tokenizer = QVD::Admin4::CLI::Tokenizer->new();
    
    $self->cache->set( user_agent => $user_agent ); 
    $self->cache->set( parser => $parser);
    $self->cache->set( tokenizer => $tokenizer );
    $self->cache->set( api_url => $api_url ); 
    $self->cache->set( api_info_url => $api_info_url ); 
    $self->cache->set( api_di_upload_url => $api_di_upload_url ); 
    $self->cache->set( api_staging_url => $api_staging_url ); 
    $self->cache->set( login => undef ); 
    $self->cache->set( tenant_name => undef ); 
    $self->cache->set( password => undef ); 
}


sub quit_signals { qw( q quit exit ) }

sub render {
    my ($self,$output) = @_;
    print $output unless $output =~ /[01]/;
}

sub handle_exception
{
    my ($self,$e) = @_;

    my $m = $e->message;
    print $m;
#    print $self->register_command($self->get_current_command)->usage_text
#	if ($e->isa('CLI::Framework::Exception::CmdRunException'));
}

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
	$command_request =~ s/'/\\'/g;
	$command_request =~ s/"/\\"/g;
        @ARGV = Text::ParseWords::shellwords( $command_request );
        $term->addhistory($command_request)
            if $command_request =~ /\S/ and !$term->Features->{autohistory};
    }
    return 1;
}

1;
