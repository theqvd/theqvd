package QVD::Admin4::CLI;
use base qw( CLI::Framework );
use strict;
use warnings;
use QVD::Admin4::CLI;
use QVD::Admin4::CLI::Command;
use QVD::Admin4::CLI::Grammar;
use QVD::Admin4::CLI::Parser;
use QVD::Admin4::CLI::Parser::Unificator;
use QVD::Admin4::CLI::Tokenizer;
use Mojo::UserAgent;

sub option_spec {
        [ 'login|l=s'      => 'Administrator name' ],
        [ 'password|p'   => 'Administrator\'s password' ],
        [ 'api|a=s'   => 'API address' ],
    }

sub command_map {

        get    => 'QVD::Admin4::CLI::Command::Get',
        set    => 'QVD::Admin4::CLI::Command::Set',
        new    => 'QVD::Admin4::CLI::Command::New',
        del    => 'QVD::Admin4::CLI::Command::Del',
        block    => 'QVD::Admin4::CLI::Command::Block',
        unblock    => 'QVD::Admin4::CLI::Command::Unblock',
        start    => 'QVD::Admin4::CLI::Command::Start',
        stop    => 'QVD::Admin4::CLI::Command::Stop',
        disconnect    => 'QVD::Admin4::CLI::Command::Disconnect',
        assign    => 'QVD::Admin4::CLI::Command::Assign',
        unassign    => 'QVD::Admin4::CLI::Command::Unassign',
        tag    => 'QVD::Admin4::CLI::Command::Tag',
        untag    => 'QVD::Admin4::CLI::Command::Untag',
        login    => 'QVD::Admin4::CLI::Command::Login',
        password    => 'QVD::Admin4::CLI::Command::Password',
        logout   => 'QVD::Admin4::CLI::Command::Logout',
        menu    => 'QVD::Admin4::CLI::Command::Menu',
    }

sub init {
    my ($self, $opts) = @_;

    my ($address,$login,$password) = 
	('http://172.20.126.16:3000/',$opts->login);

    $password = read_password($self)
	if $opts->password;

    $self->render("\rHi, What's up!\n");

    my $ua = Mojo::UserAgent->new;
    my $unificator = QVD::Admin4::CLI::Parser::Unificator->new();
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
    print $self->register_command($self->get_current_command)->usage_text
	if ($e->isa('CLI::Framework::Exception::CmdRunException'));
}

1;
