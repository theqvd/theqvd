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

sub option_spec {
        [ 'login|l=s'      => 'Administrator name' ],
        [ 'password|psw'   => 'Administrator\'s password' ],
        [ 'host|h=s'   => 'API host' ],
        [ 'port|p=s'   => 'API port' ],
    }

sub command_map {

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

    my ($host,$port,$login,$password) = 
	(($opts->host || '172.20.126.16'), ($opts->port || 3000), 
	 ($opts->login || 'superadmin'), ($opts->password || 'superadmin' ));

    $password = read_password($self)
	if $opts->password;

    my $api = Mojo::URL->new(); $api->scheme('http'); $api->host($host); $api->port($port); 
    my $ws = Mojo::URL->new(); $ws->scheme('ws'); $ws->host($host); $ws->port($port); $ws->path('/staging');
    my $ua = Mojo::UserAgent->new;

    my $unificator = QVD::Admin4::CLI::Grammar::Unificator->new();
    my $grammar = QVD::Admin4::CLI::Grammar->new();
    my $parser = QVD::Admin4::CLI::Parser->new( grammar => $grammar, unificator => $unificator);
    my $tokenizer = QVD::Admin4::CLI::Tokenizer->new();
    
    $self->cache->set( ua => $ua ); 
    $self->cache->set( parser => $parser);
    $self->cache->set( tokenizer => $tokenizer );
    $self->cache->set( api => $api ); 
    $self->cache->set( ws => $ws ); 
    $self->cache->set( login => $login ); 
    $self->cache->set( password => $password ); 

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

#FIXME-TODO-CMDLINE_COMPLETION:
#        # Arrange for command-line completion...
#        my $attribs = $term->Attribs;
#        $attribs->{completion_function} = $app->_cmd_request_completions();
    }
    # Prompt for the name of a command and read input from STDIN.
    # Store the individual tokens that are read in @ARGV.
    my $command_request = $term->readline('> ');


    if(! defined $command_request ) {
        # Interpret CTRL-D (EOF) as a quit signal...
        @ARGV = $app->quit_signals();
        print "\n"; # since EOF character is rendered as ''
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
