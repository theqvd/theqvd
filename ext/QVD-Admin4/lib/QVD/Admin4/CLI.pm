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

sub option_spec {
        [ 'login|l=s'      => 'Administrator name' ],
        [ 'password|p'   => 'Administrator\'s password' ],
        [ 'api|a=s'   => 'API address' ],
    }

sub command_map {

    config => 'QVD::Admin4::CLI::Command::Config',
    tenant => 'QVD::Admin4::CLI::Command::Tenant',
    role => 'QVD::Admin4::CLI::Command::Role',
    acl => 'QVD::Admin4::CLI::Command::Acl',
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

    my ($address,$login,$password) = 
	(($opts->api || 'http://172.20.126.16:3000/'),$opts->login);

    $password = read_password($self)
	if $opts->password;

    my $ua = Mojo::UserAgent->new;

    my $unificator = QVD::Admin4::CLI::Grammar::Unificator->new();
    my $grammar = QVD::Admin4::CLI::Grammar->new();
    my $parser = QVD::Admin4::CLI::Parser->new( grammar => $grammar, unificator => $unificator);
    my $tokenizer = QVD::Admin4::CLI::Tokenizer->new();
    
    $self->cache->set( ua => $ua ); 
    $self->cache->set( parser => $parser);
    $self->cache->set( tokenizer => $tokenizer );
    $self->cache->set( api => $address ); 
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

1;
