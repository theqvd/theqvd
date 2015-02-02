package QVD::Admin4::CLI::Command;
use strict;
use warnings;
use Text::SimpleTable::AutoWidth;
use Term::ReadKey;
use Exporter qw(import);
our @EXPORT = qw(parse_string read_password print_table ask_api
                 related_qvd_object default_fields action fields nested_queryx);

my $NESTED_QUERIES =
{
    vm =>  {  assign => { property => sub { my $prop = shift; 
					    return { __property_changes__ => { set => $prop }}}},
	      unassign => { property => sub { my $prop = shift; 
					      return { __property_changes__ => { delete => $prop }}}}
    },
};

my $RELATED_QVD_OBJECTS =
{
    vm =>  {  tenant => 'tenant_id',
	      di_tag => 'di_tag',
	      user => 'user_id',
	      host => 'host_id',
	      osf => 'osf_id',
	      di => 'di_id' },
};

my $CLI_RESPONSE_TO_API_REQUEST =
{
    vm => {  ids => 'vm_all_ids',
	     get => 'vm_get_list',
	     update => 'vm_update',
	     create => 'vm_create',
	     delete => 'vm_delete',
	     start => 'vm_start',
	     stop => 'vm_stop',
	     disconnect => 'vm_user_disconnect',
	     block => 'vm_update',
	     unblock => 'vm_update',
	     assign => 'vm_update',
	     unassign => 'vm_update'},

    tenant => {  ids => 'tenant_all_ids',
		 get => 'tenant_get_list' },
    di_tag => {  ids => 'tag_all_ids',
		 get => 'tag_get_list' },
    user => {  ids => 'user_all_ids',
	       get => 'user_get_list' },
    host => {  ids => 'host_all_ids',
	       get => 'host_get_list' },
    osf => {  ids => 'osf_all_ids',
	    get => 'osf_get_list' },
    di => {  ids => 'di_all_ids',
	     get => 'di_get_list' },
};

my $API_RESPONSE_TO_CLI_RESPONSE =
{
    default => sub { my ($res,$field) = @_; return $res->{$field}},

    vm => { id => sub { my $res = shift; return $res->{id}; },
	    tenant => sub { my $res = shift; return $res->{tenant_name}; },
	    name => sub { my $res = shift; return $res->{name}; },
	    blocked => sub { my $res = shift; return $res->{blocked}; },
	    user => sub { my $res = shift; return $res->{user_name}; },
	    host => sub { my $res = shift; return $res->{host_name}; },
	    di => sub { my $res = shift; return $res->{di_name}; },
	    ip => sub { my $res = shift; return $res->{ip}; },
	    "ip in use" => sub { my $res = shift; return $res->{ip_in_use}; },
	    "di in use" => sub { my $res = shift; return $res->{di_name_in_use}; },
	    state => sub { my $res = shift; return $res->{state}; },
	    "user state" => sub { my $res = shift; return $res->{user_state}; }
    },
};


my $DEFAULT_FIELDS = 
{
    vm => [ qw( id tenant name blocked user host di ip ),  "ip in use", "di in use", "state", "user state" ]
};

#####################
## VARS MANAGEMENT ##
#####################

sub related_qvd_object
{
    my ($obj1,$obj2) = @_;
    my $link_filter = eval { $RELATED_QVD_OBJECTS->{$obj1}->{$obj2} } 
    // undef;
}

sub default_fields
{
    my ($obj) = @_;
    my $fields = eval { $DEFAULT_FIELDS->{$obj} } // []; 
    @$fields;
}

sub action
{
    my ($obj,$cmd) = @_;
    my $action = eval { $CLI_RESPONSE_TO_API_REQUEST->{$obj}->{$cmd} } 
    // undef; 
}

sub fields
{
    my ($res,$obj,@fields) = @_;

    for my $field (@fields)
    {
	my $cb =  eval { $API_RESPONSE_TO_CLI_RESPONSE->{$obj}->{$field} } //
	    $API_RESPONSE_TO_CLI_RESPONSE->{default};
	$field = eval { $cb->($res,$field) } // '';
    }
    @fields;
}

sub nested_query
{
    my ($obj1,$cmd,$obj2,$value) = @_;
    my $cb = eval { $NESTED_QUERIES->{$obj1}->{$cmd}->{$obj2} } // return undef;
    my $nq = eval { $cb->($value) } // undef;
} 

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

sub print_table
{
    my $res = shift;
    my $obj = shift;
    my $time = shift;
    my @keys = @_;

    my $n = 0;
    my $status     = $res->json('/status') // '';
    my $message    = $res->json('/message') // '';
    my $properties = $res->json("/rows/$n");
    
    my $tb = Text::SimpleTable::AutoWidth->new();
    $tb->max_width(500);
    $tb->captions(\@keys);
    use Data::Dumper; print Dumper \@keys;
    my $rows;
    while ($properties = $res->json("/rows/$n")) 
    {	
	$tb->row(fields($properties,$obj,@keys));
	$n++;
    }
    
    print  $tb->draw . "Total: ".$res->json('/total') . "\n$time\n";
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
