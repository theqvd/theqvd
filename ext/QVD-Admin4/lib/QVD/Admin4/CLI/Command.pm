package QVD::Admin4::CLI::Command;
use strict;
use warnings;
use Text::SimpleTable::AutoWidth;
use Term::ReadKey;
use Data::Dumper;
use Exporter qw(import);
our @EXPORT = qw(run_command read_password);

sub read_password
{
    my $app = shift;
    ReadMode 'noecho'; 
    my $pass = ReadLine 0; 
    chomp $pass;
    ReadMode 'normal';
    $pass;
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
	my @values = map {  defined $_ ? $_ : '' } 
	map { ref($_) ? 'ref' : $_ } @{$properties}{@keys};
	
	$tb->row(@values);
	$n++;
    }
    
    my $output = $rows ? $tb->draw : "$message\n";
    print  $output;
}

sub parse_string
{
    my ($string,%args) = @_;
    my ($tokenizer,$parser) = @args{qw(tokenizer parser)};
    my $tokenization = $tokenizer->parse($string);

    unrecognized($tokenization) &&
	die 'Unable to tokenize request';

    my $parsing = $parser->parse( shift @$tokenization );

    unrecognized($parsing) &&
	die 'Unable to parse request';
    ambiguous($parsing) &&
	die 'Ambiguos request';
    
    shift @$parsing;
}

sub unrecognized
{
    my $response = shift;
    scalar @$response < 1 ? return 1 : 0; 
}

sub ambiguous
{
    my $response = shift;
    scalar @$response > 1 ? return 1 : 0; 
}


sub ask_api
{
    my ($query,%args) = @_;

    my ($sid,$login,$password,$url,$ua) = @args{qw(sid login password url ua)};
    my %credentials = defined $sid ? (sid => $sid) : 
	( login => $login, password => $password );
    my %parameters = (parameters => {__client__ => 'CLI'});

    my $json = {%$query,%parameters,%credentials};
    my $res = $ua->post($url, json => $json)->res;

    die 'API returns bad status' 
	unless $res->code;

    die $res->json('/message') 
	if $res->json('/status');

    return $res;
}

sub run_command 
{
    my ($app,@args) = @_;
    my $req = join(' ',@args);

    my %parsing_args = (
	tokenizer => $app->cache->get('tokenizer'), 
	parser => $app->cache->get('parser'));
    my $query = parse_string($req,%parsing_args);
    print Dumper $query;
}

#
#sub run_command 
#{
#    my ($app,@args) = @_;
#    my $req = join(' ',@args);
#
#    my %parsing_args = (
#	tokenizer => $app->cache->get('tokenizer'), 
#	parser => $app->cache->get('parser'));
#
#    my %api_req_args = (
#	login => $app->cache->get('login'), 
#	password => $app->cache->get('password'),
#	sid => $app->cache->get('sid'),
#	url => $app->cache->get('api'),
#	ua =>  $app->cache->get('ua'));
#
#    my $query = parse_string($req,%parsing_args);
#    my $res = ask_api($query,%api_req_args);
#    my $sid = $res->json('/sid');
#    $app->cache->set(sid => $sid);
#    print_table($res);
#}
#
