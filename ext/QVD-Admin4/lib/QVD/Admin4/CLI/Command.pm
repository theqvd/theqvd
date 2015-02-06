package QVD::Admin4::CLI::Command;
use strict;
use warnings;
use base qw( CLI::Framework::Command::Meta );
use Text::SimpleTable::AutoWidth;
use Term::ReadKey;
use Mojo::JSON qw(encode_json decode_json j);
use Mojo::IOLoop;
use Mojo::Message::Response;

my $FILTERS =
{
    vm => { storage => 'storage',
	    id => 'id',
	    name => 'name',
	    user => 'user_name',
	    osf => 'osf_name',
	    tag => 'di_tag',
	    blocked => 'blocked', 
	    expiration_soft => 'expiration_soft',
	    expiration_hard => 'expiration_hard',
	    state => 'state',
	    host =>  'host_name',
	    di => 'di_name', 
	    user_state => 'user_state',
	    ip => 'ip',
	    ssh_port => 'ssh_port',
	    vnc_port => 'vnv_port',
	    serial_port => 'serial_port',
	    tenant =>  'tenant_name',
	    creation_admin => 'creation_admin',
	    creation_date => 'creation_date',
	    ip_in_use => 'ip_in_use',
	    di_in_use => 'di_name_in_use' }
};

my $ORDER =
{
    vm => { storage => 'storage',
	    id => 'id',
	    name => 'name',
	    user => 'user_name',
	    osf => 'osf_name',
	    tag => 'di_tag',
	    blocked => 'blocked', 
	    expiration_soft => 'expiration_soft',
	    expiration_hard => 'expiration_hard',
	    state => 'state',
	    host =>  'host_name',
	    di => 'di_name', 
	    user_state => 'user_state',
	    ip => 'ip',
	    ssh_port => 'ssh_port',
	    vnc_port => 'vnv_port',
	    serial_port => 'serial_port',
	    tenant =>  'tenant_name',
	    creation_admin => 'creation_admin',
	    creation_date => 'creation_date',
	    ip_in_use => 'ip_in_use',
	    di_in_use => 'di_name_in_use'},

};

my $FIELDS =
{
    vm => { storage => 'storage',
	    id => 'id',
	    name => 'name',
	    user => 'user_name',
	    osf => 'osf_name',
	    tag => 'di_tag',
	    blocked => 'blocked', 
	    expiration_soft => 'expiration_soft',
	    expiration_hard => 'expiration_hard',
	    state => 'state',
	    host =>  'host_name',
	    di => 'di_name', 
	    user_state => 'user_state',
	    ip => 'ip',
	    mac => 'mac',
	    ssh_port => 'ssh_port',
	    vnc_port => 'vnv_port',
	    serial_port => 'serial_port',
	    tenant =>  'tenant_name',
	    creation_admin => 'creation_admin',
	    creation_date => 'creation_date',
	    ip_in_use => 'ip_in_use',
	    di_in_use => 'di_name_in_use' },
};

my $ARGUMENTS =
{
    vm => { name => 'name',
	    ip => 'ip',
	    blocked => 'blocked',
	    expiration_soft => 'expiration_soft',
	    expiration_hard => 'expiration_hard',
	    storage => 'storage',
	    tag => 'di_tag',
	    user => 'user_id',
	    osf => 'osf_id' }
};

my $CBS_TO_GET_RELATED_OBJECTS_IDS =
{
    vm => { tenant => sub { my ($self,$name) = @_; 
			    $self->ask_api(
				{ action => 'tenant_all_ids', 
				  filters =>  { name => $name }}
				)->json('/rows');}, 
	    user => sub { my ($self,$name,$tenant_id) = @_; 
			  $self->ask_api(
			      { action => 'user_all_ids', 
				filters =>  { name => $name, 
					      tenant_id => $tenant_id }}
			      )->json('/rows');},
	    host => sub { my ($self,$name) = @_; 
			  $self->ask_api(
			      { action => 'host_all_ids', 
				filters =>  { name => $name }}
			      )->json('/rows');},
	    osf => sub { my ($self,$name,$tenant_id) = @_; 
			 $self->ask_api(
			     { action => 'osf_all_ids', 
			       filters =>  { name => $name, 
					     tenant_id => $tenant_id }}
			     )->json('/rows');},
	    di => sub { my ($self,$disk_image,$tenant_id) = @_; 
			$self->ask_api(
			    { action => 'di_all_ids', 
			      filters =>  { disk_image => $disk_image, 
					    tenant_id => $tenant_id }}
			    )->json('/rows');}},
};

my $CLI_CMD2API_ACTION =
{
    vm => { ids => 'vm_all_ids', 
	    get => 'vm_get_list', 
	    update => 'vm_update', 
	    create => 'vm_create', 
	    delete => 'vm_delete', 
	    start => 'vm_start', 
	    stop => 'vm_stop',
	    disconnect => 'vm_user_disconnect' },
};


my $DEFAULT_FIELDS = 
{ 
    vm => [ qw( id tenant name blocked user host di ip ip_in_use di_in_use state user_state) ],
};

###############
## UTILITIES ##
###############

sub run 
{
    my ($self, $opts, @args) = @_;

    my $parsing = parse_string($self,@args);

    my $query = 
    { action => $self->get_action($parsing),
      filters => $self->get_filters($parsing), 
      order_by => $self->get_order($parsing), 
      arguments => $self->get_arguments($parsing)};

    my $res = $query->{action} eq 'di_create' ? 
	$self->ask_api_ws($query) : $self->ask_api($query);
  
    $self->get_fields($parsing) && $res->json('/total') ?
	$self->print_table($res,$parsing) : $self->print_count($res);
}

sub print_count
{
    my ($self,$res) = @_;
    print  "Total: ".$res->json('/total')."\n";
}

sub print_table
{
    my ($self,$res,$parsing) = @_;
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
    my ($self,@args) = @_;
    my $req = join(' ',@args);
    my $app = $self->get_app;
    my ($tokenizer,$parser) = 
	($app->cache->get('tokenizer'), 
	 $app->cache->get('parser'));

    my $tokenization = $tokenizer->parse($req);

    $self->unrecognized($tokenization) &&
	die 'Unable to tokenize request';

    my $parsing = $parser->parse( shift @$tokenization );

    $self->unrecognized($parsing) &&
	die 'Unable to parse request';
    $self->ambiguous($parsing) &&
	die 'Ambiguos request';
    
    shift @$parsing;
}

sub unrecognized
{
    my ($self,$response) = @_;
    scalar @$response < 1 ? return 1 : 0; 
}

sub ambiguous
{
    my ($self,$response) = @_;
    scalar @$response > 1 ? return 1 : 0; 
}

sub ask_api
{
    my ($self,$query) = @_;
    my $app = $self->get_app;
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
    my ($self,$query) = @_;

    my $app = $self->get_app;
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

sub print_filters
{
    my ($self,$parsing) = @_;
    my @f = sort keys %{$FILTERS->{$parsing->qvd_object}};
    print join "\n", @f;
}

sub print_arguments
{
    my ($self,$parsing) = @_;
    my @a = sort keys %{$ARGUMENTS->{$parsing->qvd_object}};
    print join "\n", @a;
}

sub print_order
{
    my ($self,$parsing) = @_;
    my $o = sort keys %{$ORDER->{$parsing->qvd_object}};
    print join "\n", @o;
}

sub print_fields
{
    my ($self,$parsing) = @_;
    my @f = sort @{$DEFAULT_FIELDS->{$parsing->qvd_object}};
   print join "\n",@f; 
}

sub get_action
{
    my ($self,$parsing) = @_;
    return eval { 
	$CLI_CMD2API_ACTION->{$parsing->qvd_object}->{$parsing->command} 
    } // die "No API action available"; 
}

sub get_filters
{
    my ($self,$parsing) = @_;
    my $filters = $filters->filters // {};
    my $out = {};
    my $tenant_id = 1;

    while (my ($k,$v) = each %filters)
    {
	$k = $FILTERS->{$parsing->qvd_object}->{$k} // die 'Unknown filter';
	$v = $self->get_value($parsing,$k,$v);
	$out->{$k} = $v;
    }
    $out;
}

sub get_arguments
{
    my ($self,$parsing) = @_;
    my $arguments = $arguments->filters // {};
    my $out = {};
    my $tenant_id = 1;

    while (my ($k,$v) = each %arguments)
    {
	$k = $ARGUMENTS->{$parsing->qvd_object}->{$k} // die 'Unknown argument';
	$v = $self->get_value($parsing,$k,$v);
	$out->{$k} = $v;
    }
    $out;
}

sub get_order
{
    my ($self,$parsing) = @_;

    my $order = $parsing->order // {};
    my $out = [];
    my $criteria = $order->{field} // []; 

    for my $criteria (@$criteria)
    {
	$criteria = eval { $ORDER->{$parsing->qvd_object}->{$_} } 
	// die 'Unknown order criteria';
	push @$out, $criteria;
    }
    my $direction = $order->{order} // '-asc';
    { order => $direction, field => $out };
}

sub get_fields
{
    my ($self,$parsing) = @_;

    return qw(id) if $parsing->command eq 'create';
    return qw() unless $parsing->command eq 'get';

    my @fields = @{$parsing->fields} // 
	@{$DEFAULT_FIELDS->{$parsing->qvd_object}}; 
}

sub get_value
{
    my ($self,$parsing,$key,$value) = @;
    if ( my $cb = eval { 
	$CBS_TO_GET_RELATED_OBJECTS_IDS->
	{$parsing->qvd_object}->{$parsing->qvd_object}->{$key}})
	{
	    my $ids = $cb->($self,$value,$tenant_id);
	    $value = shift @$ids // 
		die 'Unknown related object in filters';	    
	    die 'Amgiguous reference to object in filters'
		if @$ids;	    
	}
    $value;
}

