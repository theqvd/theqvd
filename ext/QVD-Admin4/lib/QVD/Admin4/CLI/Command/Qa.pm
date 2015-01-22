package QVD::Admin4::CLI::Command::Qa;
use base qw( CLI::Framework::Command );
use strict;
use warnings;
use lib::glob '/home/benjamin/wat/*/lib/';
use Text::SimpleTable::AutoWidth;
use QVD::Admin4::CLI;

sub run 
{
    my ($self, $opts, @args) = @_;
    my $req = join(' ',@args);

    my $CLI = QVD::Admin4::CLI->new( 
	ua => $self->cache->get('ua'), 
	url => $self->cache->get('api'), 
	parser => $self->cache->get('parser'), 
	tokenizer => $self->cache->get('tokenizer'));

    my %credentials = $self->get_api_credentials;
    my $res = $CLI->query($req,%credentials);
    my $sid = $res->json('/sid');
    $self->cache->set(sid => $sid) if defined $sid;

    ref($res) && ref($res) eq 'HASH' ?
	say $res->{status} . ": ".$res->{message} :
	print_table($res);
}

sub get_api_credentials
{
    my $self = shift;
    my $sid = $self->cache->get('sid');
    return (sid => $sid) if defined $sid;
    my $login = $self->cache->get('login');
    my $pass = $self->cache->get('password');
    return (login => $login, password => $pass);
}

sub print_table
{
    my $res = shift;
    my $n = 0;
    my $status     = $res->json('/status') // '';
    my $message    = $res->json('/message') // '';
    my $properties = $res->json("/rows/$n");
    
    my $tb = Text::SimpleTable::AutoWidth->new();
    $tb->max_width(500);
    my $first = $res->json("/rows/0") // {};
    my @keys = sort keys %$first;
    $tb->captions(\@keys);
    
    my $rows;
    while ($properties = $res->json("/rows/$n")) 
    {
	$rows //= 1;
	my @values = map {  defined $_ ? $_ : 'undef' } 
	map { ref($_) ? 'ref' : $_ } @{$properties}{@keys};
	
	$tb->row(@values);
	$n++;
    }
    
    my $output = $rows ? $tb->draw : "$message\n";
    print  $output;
}

1;
