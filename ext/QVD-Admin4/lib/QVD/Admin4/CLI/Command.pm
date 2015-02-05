package QVD::Admin4::CLI::Command;
use strict;
use warnings;
use Text::SimpleTable::AutoWidth;
use Term::ReadKey;
use Mojo::JSON qw(encode_json decode_json j);
use Mojo::IOLoop;
use Mojo::Message::Response;
use Exporter qw(import);
our @EXPORT = qw(read_password run_cmd);


###############
## UTILITIES ##
###############

sub read_password
{
    my $app = shift;
    print STDERR "Password: ";
    ReadMode 'noecho'; 
    my $pass = ReadLine 0; 
    chomp $pass;
    ReadMode 'normal';
    print STDERR "\r";
    $pass;
}

sub run_cmd 
{
    my ($self,@args) = @_;

    my $parsing = parse_string($self,@args);

    my $query = 
    { action => $parsing->action,
      filters => $parsing->filters, 
      order_by => $parsing->order, 
      arguments => $parsing->arguments};

    for my $io ($parsing->indirect_objects)
    {
	my $related_query = 
	{ action => $parsing->action_to_get_indirect_object($io->name),
	  filters => $io->filters };
	my $related_res = ask_api($self,$related_query);
	my $ids = $related_res->json('/rows');

	if ($parsing->command eq 'create')
	{ 
	    $query->{arguments}->{$parsing->id_link_to_indirect_object($io->name)} = shift @$ids;
#	    die "More than one ".$io->name." elements found" if @$ids;
	}
	else
	{
	    $query->{filters}->{$parsing->id_link_to_indirect_object($io->name)} = $ids;
	}
    }

    my $res = $parsing->action eq 'di_create' ? 
	ask_api_ws($self,$query) : ask_api($self,$query);
  
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
    $tb->captions(\@fields);
    
    my $rows;
    while (my $properties = $res->json("/rows/$n")) 
    {	
	$tb->row( map { $_->($properties) // '' } @cbs );
	$n++;
    }

    print  $tb->draw . "Total: ".$res->json('/total')."\n";
}

sub parse_string
{
    my ($app,@args) = @_;
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
    my ($app,$query,$ws_flag) = @_;

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

    my $res = $ua->post("$url", json => {%$query,%credentials})->res;

    die 'API returns bad status' 
	unless $res->code;


    die $res->json('/message') 
	if $res->json('/status');
    return $res;
}

sub ask_api_ws
{
    my ($app,$query,$ws_flag) = @_;

    my %args = (
	login => $app->cache->get('login'), 
	password => $app->cache->get('password'),
	sid => $app->cache->get('sid'),
	url => $app->cache->get('ws'),
	ua =>  $app->cache->get('ua'));

    my ($sid,$login,$password,$url,$ua) = 
	@args{qw(sid login password url ua)};

    my %credentials = defined $sid ? (sid => $sid) : 
	( login => $login, password => $password );

    for my $k (keys %$query)
    {
	my $v = $query->{$k};
	$query->{$k} = ref($v) ? 
	    encode_json($v) : $v;
    }

    $url->query(%$query,%credentials);

    my $res = {}; 
    my $on_message_cb =
	sub {my ($tx, $msg) = @_; 
	     $res = decode_json($msg);
	     if ($res->{status} eq 1000)
	     {  
		 my $total = $res->{total_size} // 0;
		 my $partial = $res->{copy_size} // 0;
		 my $percentage = ($partial * 100) / $total;
		 if ($percentage > 0)
		 {
		     print STDERR "\r";
		     printf STDERR '%.2f%%', $percentage;
		     $tx->send('Ale');
		 }
	     }
	     else
	     {
		 print STDERR "\r";
		 $tx->finish;
	     }};

    $ua->websocket("$url" =>  sub { my ($ua, $tx) = @_;
				    $tx->on(message => $on_message_cb); $tx->send('Ale');} );

    Mojo::IOLoop->start;
    Mojo::Message::Response->new(json => $res);
}
