package QVD::Admin4::CLI::Command;
use strict;
use warnings;
use Text::SimpleTable::AutoWidth;
use Term::ReadKey;
use Exporter qw(import);
our @EXPORT = qw(parse_string read_password print_table ask_api
                 related_qvd_object default_fields action fields nested_queryx);


###############
## UTILITIES ##
###############

sub read_password
{
    my $app = shift;
    ReadMode 'noecho'; 
    my $pass = ReadLine 0; 
    chomp $pass;
    ReadMode 'normal';
    $pass;
}

sub run_cmd 
{
    my ($self, $opts, @args) = @_;

    my $parsing = parse_string($self,@args);

    my $query = 
    { action => $parsing->action,
      filters => $parsing->filters, 
      order_by => $parsing->order, 
      arguments => $parsing->arguments};

    if ($parsing->has_indirect_object)
    {
	my $related_query = 
	{ action => $parsing->action_to_get_indirect_object,
	  filters => $parsing->indirect_object->filters };

	my $related_res = ask_api($self,$related_query);
	my $ids = $related_res->json('/rows');
	$query->{filters}->{$self->link_to_indirect_object} = $ids;
    }

    my $res = ask_api($self,$query);
  
    $parsing->fields && $res->json('/total') ?
	print_table($res,$parsing) : print_count($res);
}

sub print_count
{
    my $res = shift;
    print  "Total: ".$res->json('/total')."\n";
}

sub print_table
{
    my ($res,$parsing) = @_;
    my $n = 0;    
    my @fields = $parsing->fields;
    my @cbs = map { $parsing->cb_to_get_field_value($_) } @fields;

    my $tb = Text::SimpleTable::AutoWidth->new();
    $tb->max_width(500);
    $tb->captions(@fields);
    
    my $rows;
    while ($properties = $res->json("/rows/$n")) 
    {	
	$tb->row( map { $_->($properties) } @cbs );
	$n++;
    }

    print  $tb->draw . "Total: ".$res->json('/total')."\n";
}

sub parse_string
{
    my ($app,@args) = @_;

    for my $arg (@args)
    {
	next unless $arg =~ /\s/;
	$arg = "'".$arg."'";
    }

    my $req = join(' ',@args);
    my ($tokenizer,$parser) = 
	($app->cache->get('tokenizer'), 
	 $app->cache->get('parser'));

    my $tokenization = $tokenizer->parse($req);

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
    my ($app,$query) = @_;

    my %args = (
	login => $app->cache->get('login'), 
	password => $app->cache->get('password'),
	sid => $app->cache->get('sid'),
	url => $app->cache->get('api'),
	ua =>  $app->cache->get('ua'));

    my ($sid,$login,$password,$url,$ua) = 
	@args{qw(sid login password url ua)};

    my %credentials = defined $sid ? (sid => $sid) : 
	( login => $login, password => $password );

    my $json = {%$query,%credentials};

    my $res = $ua->post($url, json => $json)->res;

    die 'API returns bad status' 
	unless $res->code;

    die $res->json('/message') 
	if $res->json('/status');
    return $res;
}
