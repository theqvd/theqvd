package QVD::Admin4::CLI::App;
use base qw( CLI::Framework );
use strict;
use warnings;
use QVD::Admin4::CLI;
use QVD::Admin4::CLI::Grammar;
use QVD::Admin4::CLI::Parser;
use QVD::Admin4::CLI::Parser::Unificator;
use QVD::Admin4::CLI::Tokenizer;
use Mojo::UserAgent;
use Term::ReadLine;

sub usage_text { };

sub menu { print "Hola"; };

sub option_spec {
        [ 'login|l=s'      => 'QVD administrator name' ],
        [ 'password|p=s'   => 'QVD Administrator password' ],
        [ 'api|a=s'        => 'QVD administrator tool address' ],
    }

sub command_map {
        qa    => 'QVD::Admin4::CLI::Command::Qa',
        login    => 'QVD::Admin4::CLI::Command::Login',
        password    => 'QVD::Admin4::CLI::Command::Password',
        logout   => 'QVD::Admin4::CLI::Command::Logout',
        menu    => 'QVD::Admin4::CLI::Command::Menu',
    }


sub read_cmd {
    my $self = shift;

    my $term = Term::ReadLine->new('CLI Admin Tool For QVD');

    while ( defined ($_ = $term->readline($prompt)) ) {

    my $req = $_;
    my $res = $CLI->query($req);

    ref($res) && ref($res) eq 'HASH' ?
	say $OUT $res->{status} . ": ".$res->{message} :
	print_table($res);

    $term->addhistory($_) if /\S/;
}


}

sub init {
    my ($self, $opts) = @_;
    
    my ($address,$login,$password) = 
	('http://172.20.126.16:3000/','','');

    my $ua = Mojo::UserAgent->new;
    my $unificator = QVD::Admin4::CLI::Parser::Unificator->new();
    my $grammar = QVD::Admin4::CLI::Grammar->new();
    my $parser = QVD::Admin4::CLI::Parser->new( grammar => $grammar, unificator => $unificator);
    my $tokenizer = QVD::Admin4::CLI::Tokenizer->new();
    
    $self->cache->set( ua => $ua ); 
    $self->cache->set( parser => $parser);
    $self->cache->set( tokenizer => $tokenizer );
    $self->cache->set( api => $address ); 

}

sub quit_signals { qw( q quit exit ) }


1;
