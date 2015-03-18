package QVD::Admin4::CLI::Command;
use strict;
use warnings;
use base qw( CLI::Framework::Command::Meta );
use Text::SimpleTable::AutoWidth;
use Text::UnicodeTable::Simple;
use Mojo::JSON qw(encode_json decode_json j);
use Mojo::IOLoop;
use Mojo::Message::Response;
use Encode;
use File::Basename qw(basename dirname);
use Term::ReadKey;
use CLI::Framework::Exceptions;
use utf8::all;

our $COMMON_USAGE_TEXT =
"
======================================================================================================
                                             DEFAULT FILTERS
======================================================================================================

  The filter key 'name', and the operator '=' are consirered as defaults. So the following is a right 
  syntax: 
  
  <QVD OBJECT COMMAND> <QVD OBJECT NAME> <ACTION COMMAND>

  For example:
  vm myVM get (Equal to vm name=myVM get)  
  vm myVM set name=yourVM (Equal to vm name=myVM set name=yourVM)   

======================================================================================================
                                             COMPLEX FILTERS
======================================================================================================

  A filter is a key/value pair. Key and value can be related by means of different kinds of 
  IDENTITY OPERATORS (=, >, <, etc.). Different operators allow different kinds of values 
  (numeric, alphanumeric, arrays, ranges...). Morover, two or more filters can be joined by means 
  of LOGICAL OPERATORS (coordination, disjunction and negation operators).

  DIFFERENT IDENTITY OPERATORS:
  Supported operators:

  =  (equal)
  <  (less than)
  >  (greater that)
  <= (less or equal than)
  >= (greater or equal than)
  ~  (matches with a commodins expression: the SQL LIKE operator)

  For example:
  key1 = 1, 
  key1 < 3, 
  key1 > 3, 
  key1 <= 3, 
  key1 >= 3
  key1 = [1,2,3] (key1 must be in (1, 2, 3))
  key1 = [1:3] (key1 must be between 1 and 3)
  key1 = This_is_a_chain
  key1 = 'This is a chain' (A value with blanks must be quoted)
  key1 = \"This is a chain\" (A value with blanks must be quoted)
  key1 ~ %s_is_a_ch% (key1 must match the SQL commodins expression %s_is_a_ch%)
  key1 ~ '%s is a ch%' (key1 must match the SQL commodins expression %s_is_a_ch%)
  key1 ~ \"%s is a ch%\" (key1 must match the SQL commodins expression %s_is_a_ch%)

  LOGICAL OPERATORS
  Supported operators

  , (the AND operator)
  ; (the OR operator)
  ! (the NOT operator)

  (These operators have left precedence. In order to override this behaviour you must 
   grup filters with '(' and ')')

  For example:
  key1=value, key2=value, key3=value (key1 AND key2 AND key3)
  (key1=value; key2=value), key3=value ((key1 OR key2) AND key3))
  !key1=value (This expresion means: NOT key1)
  !key1=value, key2=value, key3=value (NOT ( key1 AND key2 AND key3))
  (! key1=value), key2=value, key3=value ((NOT key1) AND key2 AND key3))

======================================================================================================
";

my $FILTERS =
{
    vm => { storage => 'storage', id => 'id', name => 'name', user => 'user_name', osf => 'osf_name', tag => 'di_tag', blocked => 'blocked', 
	    expiration_soft => 'expiration_soft', expiration_hard => 'expiration_hard', state => 'state', host =>  'host_name', di => 'di_name', 
	    user_state => 'user_state', ip => 'ip', ssh_port => 'ssh_port', vnc_port => 'vnv_port', serial_port => 'serial_port',
	    tenant =>  'tenant_name', ip_in_use => 'ip_in_use', di_in_use => 'di_name_in_use' },

    user => { id => 'id', name => 'name', blocked => 'blocked', tenant => 'tenant_name'},

    host => { id => 'id', name => 'name', address => 'address', blocked => 'blocked', frontend => 'frontend', backend => 'backend', state => 'state'},

    osf => { id => 'id', name => 'name', overlay => 'overlay', user_storage => 'user_storage', memory => 'memory', tenant =>  'tenant_name' },

    di => { id => 'id', name => 'disk_image', version => 'version', osf => 'osf_name', tenant => 'tenant_name', blocked => 'blocked', tag => 'tag' },

    tenant => { id => 'id', name => 'name', language => 'language', block => 'block' },

    config => { key_re => 'key_re' },

    admin => { id => 'id', name => 'name', tenant => 'tenant_name', language => 'language', block => 'block' },

    role => { id => 'id', name => 'name', fixed => 'fixed', internal => 'internal' },

    acl => { id => 'id', name => 'name', role => 'role_id', admin => 'admin_id', operative => 'operative'},

    log => { id => 'id', admin_id => 'admin_id', admin_name => 'admin_name', tenant_id => 'tenant_id', action => 'action',  arguments => 'arguments',  object_id => 'object_id', 
	     object_name => 'object_name', time => 'time', status => 'status', source => 'source', ip => 'ip', type_of_action => 'type_of_action', qvd_object => 'qvd_object' },

};


my $ORDER =
{
    vm => { storage => 'storage', id => 'id', name => 'name', user => 'user_name', osf => 'osf_name', tag => 'di_tag', blocked => 'blocked', 
	    expiration_soft => 'expiration_soft', expiration_hard => 'expiration_hard', state => 'state', host =>  'host_name', di => 'di_name', 
	    user_state => 'user_state', ip => 'ip', ssh_port => 'ssh_port', vnc_port => 'vnv_port', serial_port => 'serial_port',
	    tenant =>  'tenant_name', ip_in_use => 'ip_in_use'},

    user => { id => 'id', name => 'name', blocked => 'blocked', tenant => 'tenant_name'},

    host => { id => 'id', name => 'name', address => 'address', blocked => 'blocked', frontend => 'frontend', backend => 'backend',state => 'state'},

    osf => { id => 'id', name => 'name', overlay => 'overlay', user_storage => 'user_storage', memory => 'memory', tenant =>  'tenant_name' },

    di => { id => 'id', name => 'disk_image', version => 'version', osf => 'osf_name', tenant => ' tenant_name', blocked => 'blocked', tag => 'tag' },

    tenant => { id => 'id', name => 'name', language => 'language', block => 'block' },

    admin => { id => 'id', name => 'name', tenant => 'tenant_name', language => 'language', block => 'block' },

    role => { id => 'id', name => 'name', fixed => 'fixed', internal => 'internal' },

    acl => { id => 'id', name => 'name' },

    log => { id => 'id', admin_id => 'admin_id', admin_id => 'admin_name', tenant_id => 'tenant_id', action => 'action',  arguments => 'arguments',  object_id => 'object_id', 
	     object_name => 'object_name', time => 'time', status => 'status', source => 'source', ip => 'ip', type_of_action => 'type_of_action', qvd_object => 'qvd_object' },

};

my $FIELDS =
{
    vm => { storage => 'storage', id => 'id', name => 'name', user => 'user_name', osf => 'osf_name', tag => 'di_tag', blocked => 'blocked', 
	    expiration_soft => 'expiration_soft', expiration_hard => 'expiration_hard', state => 'state', host =>  'host_name', di => 'di_name', 
	    user_state => 'user_state', ip => 'ip', mac => 'mac', ssh_port => 'ssh_port', vnc_port => 'vnv_port', serial_port => 'serial_port', 
	    tenant =>  'tenant_name', ip_in_use => 'ip_in_use', di_in_use => 'di_name_in_use' },

    user => { id => 'id', name => 'name', tenant => 'tenant_name', blocked => 'blocked', number_of_vms => 'number_of_vms', number_of_vms_connected => 'number_of_vms_connected'},

    host => { id => 'id', name => 'name', address => 'address', blocked => 'blocked', frontend => 'frontend', backend => 'backend', state => 'state', number_of_vms_connected => 'number_of_vms_connected'},

    osf => { id => 'id', name => 'name', overlay => 'overlay', user_storage => 'user_storage', memory => 'memory', tenant =>  'tenant_name', number_of_vms => 'number_of_vms', number_of_dis => 'number_of_dis'},

    di => { id => 'id', name => 'disk_image', tenant => 'tenant_name', version => 'version', osf => 'osf_name', blocked => 'blocked', tags => 'tags'},

    tenant => { id => 'id', name => 'name', language => 'language', block => 'block' },

    config => { key => 'key', value => 'operative_value', default => 'default_value'  },

    admin => { id => 'id', name => 'name', roles => 'roles', tenant => 'tenant_name', language => 'language', block => 'block' },

    role => { id => 'id', name => 'name', fixed => 'fixed', internal => 'internal', roles => 'roles', acls => 'acls'},

    acl => { id => 'id', name => 'name' },

    log => { id => 'id', admin_id => 'admin_id', admin_id => 'admin_name', tenant_id => 'tenant_id', action => 'action',  arguments => 'arguments',  object_id => 'object_id', 
	     object_name => 'object_name', time => 'time', status => 'status', source => 'source', ip => 'ip', type_of_action => 'type_of_action', qvd_object => 'qvd_object' },

};

my $FIELDS_CBS =
{
    di => { tags => sub { my $tags = shift; my @tags = map { $_->{tag} } @$tags; return join ', ', @tags; }},

    admin => { roles => sub { my $roles = shift; my @roles =  values %$roles; return join "\n", @roles }},

    role => { roles => sub { my $roles = shift; my @roles = map { $_->{name} } values %$roles; return join "\n", @roles},
	      acls =>  sub { my $acls = shift; my @acls = sort ( (map { "$_ (+)" } @{$acls->{positive}}), (map { "$_ (-)" } @{$acls->{negative}})); return join "\n", @acls}},

};

my $ARGUMENTS =
{
    vm => { name => 'name', ip => 'ip', tenant => 'tenant_id', blocked => 'blocked', expiration_soft => 'expiration_soft',
	    expiration_hard => 'expiration_hard', storage => 'storage', tag => 'di_tag', user => 'user_id', osf => 'osf_id', 
	    __properties_changes__ => '__properties_changes__' },

    user => { name => 'name', password => 'password', blocked => 'blocked', tenant => 'tenant_id',
	      __properties_changes__ => '__properties_changes__' },

    host => { name => 'name', address => 'address', frontend => 'frontend', backend => 'backend', blocked => 'blocked',
	      __properties_changes__ => '__properties_changes__' },

    osf => { name => 'name', memory => 'memory', user_storage => 'user_storage', overlay => 'overlay', tenant => 'tenant_id',
	     __properties_changes__ => '__properties_changes__' },

    di => { blocked => 'blocked',  name => 'disk_image',  version => 'version', osf => 'osf_id',
	    __properties_changes__ => '__properties_changes__', __tags_changes__ => '__tags_changes__'},

    tenant => { name => 'name', language => 'language', block => 'block' },

    config => { key => 'key', value => 'value' },

    admin => { name => 'name', password => 'password', tenant => 'tenant_id', language => 'language', block => 'block',
	       __roles_changes__ => '__roles_changes__' },

    role => { name => 'name', fixed => 'fixed', internal => 'internal',
	      __roles_changes__ => '__roles_changes__', __acls_changes__ => '__acls_changes__' },
};

my $related_tenant_cb = sub { 
    my ($self,$name) = @_; 
    $self->ask_api({ action => 'tenant_all_ids', 
		     filters =>  { name => $name }})->json('/rows');
};

my $related_user_cb = sub { 
    my ($self,$name,$tenant_id) = @_; 
    my $filters = { name => $name };
    $filters->{tenant_id} = $tenant_id if $tenant_id;
    $self->ask_api( { action => 'user_all_ids', 
		      filters =>  $filters })->json('/rows');
};

my $related_host_cb = sub { 
    my ($self,$name) = @_; 
    $self->ask_api({ action => 'host_all_ids', 
		     filters =>  { name => $name }})->json('/rows');
};

my $related_osf_cb = sub { 
    my ($self,$name,$tenant_id) = @_; 
    my $filters = { name => $name };
    $filters->{tenant_id} = $tenant_id if $tenant_id;
    $self->ask_api( { action => 'osf_all_ids', 
		      filters =>  $filters })->json('/rows');
};

my $related_di_cb = sub { 
    my ($self,$name,$tenant_id) = @_; 
    my $filters = { name => $name };
    $filters->{tenant_id} = $tenant_id if $tenant_id;
    $self->ask_api( { action => 'di_all_ids', 
		      filters =>  $filters })->json('/rows');
};

my $related_admin_cb = sub { 
    my ($self,$name,$tenant_id) = @_; 
    my $filters = { name => $name };
    $filters->{tenant_id} = $tenant_id if $tenant_id;
    $self->ask_api( { action => 'admin_all_ids', 
		      filters =>  $filters })->json('/rows');
};

my $related_role_cb = sub { 
    my ($self,$name) = @_; 
    $self->ask_api({ action => 'role_all_ids', 
		     filters =>  { name => $name }})->json('/rows');
};

my $CBS_TO_GET_RELATED_OBJECTS_IDS =
{
    vm => { argument =>  { user => $related_user_cb,host => $related_host_cb,
			   osf => $related_osf_cb, di => $related_di_cb }},

    di => { argument => {osf => $related_osf_cb }}
};

my $CLI_CMD2API_ACTION =
{
    vm => { ids => 'vm_all_ids',  get => 'vm_get_list', update => 'vm_update', create => 'vm_create', delete => 'vm_delete', 
	    start => 'vm_start', stop => 'vm_stop', disconnect => 'vm_user_disconnect' },

    user => { ids => 'user_all_ids', get => 'user_get_list', update => 'user_update', create => 'user_create', delete => 'user_delete' },

    host => { ids => 'host_all_ids', get => 'host_get_list', update => 'host_update', create => 'host_create', delete => 'host_delete'},

    osf => { ids => 'osf_all_ids', get => 'osf_get_list', update => 'osf_update', create => 'osf_create', delete => 'osf_delete'},

    di => { ids => 'di_all_ids', get => 'di_get_list', update => 'di_update', create => 'di_create', delete => 'di_delete'},

    tenant => { ids => 'tenant_all_ids', get => 'tenant_get_list', update => 'tenant_update', create => 'tenant_create', delete => 'tenant_delete' },

    config => { get => 'config_get', update => 'config_set', delete => 'config_delete', default => 'config_default' },

    admin => { ids => 'admin_all_ids', get => 'admin_get_list', update => 'admin_update', create => 'admin_create', delete => 'admin_delete' },

    role => { ids => 'role_all_ids', get => 'role_get_list', update => 'role_update', create => 'role_create', delete => 'role_delete' },

    acl => { get => 'acl_get_list' }, 

    log => { get => 'log_get_list' },

};


my $DEFAULT_FIELDS = 
{ 
    vm => [ qw( id tenant name blocked user host di ip ip_in_use di_in_use state user_state ) ],

    user => [ qw( id tenant name blocked number_of_vms number_of_vms_connected ) ],

    host => [ qw( id name blocked address frontend backend state number_of_vms_connected ) ],

    osf => [ qw( id name overlay user_storage memory tenant number_of_vms number_of_dis ) ],

    di => [ qw( id tenant name version osf blocked tags ) ],

    tenant => [ qw( id name language block ) ],

    config => [ qw( key value default) ],

    admin => [ qw(id tenant name language block) ],

    role => [ qw(id name fixed internal) ],

    acl => [ qw(id name) ],

    log => [qw(time admin_name type_of_action qvd_object object_name arguments status)]
};

###############
## UTILITIES ##
###############

sub _get 
{
    my ($self,$parsing) = @_;
    my $query = $self->make_api_query($parsing);
    my $res = $self->ask_api($query);
    $self->print_table($res,$parsing);
}

sub _create 
{
    my ($self,$parsing) = @_;

    if (my $tenant_name = $parsing->arguments->{tenant})
    {
	my $tenant_ids = $related_tenant_cb->($self,$tenant_name);
	my $tenant_id = shift @$tenant_ids //
	    CLI::Framework::Exception->throw("Unknown related object tenant in filters");
	$self->tenant_scoop($tenant_id);
	$parsing->arguments->{tenant} = $self->tenant_scoop; 
    }
  
    my $query = $self->make_api_query($parsing);
    my $res = $self->ask_api($query);
    $self->print_table($res,$parsing);
}

sub _can
{
    my ($self,$parsing) = @_;

    my $ids = $self->ask_api({ action => $self->get_all_ids_action($parsing),
			       filters => $self->get_filters($parsing) })->json('/rows');

    my $acl_name = $parsing->parameters->{acl_name}; 
    my $id_key = $parsing->qvd_object eq 'admin' ? 'admin_id' : 'role_id';
    my $filters = { $id_key => $ids, operative => 1 }; 
    $filters->{acl_name} = { 'LIKE' => $acl_name } if defined $acl_name;
    my $action = $parsing->qvd_object eq 'admin' ? 'get_acls_in_admins' : 'get_acls_in_roles';

    my $res = $self->ask_api({ action => $action,filters => $filters,order_by => $self->get_order($parsing)});
    $self->print_table($res,QVD::Admin4::CLI::Grammar::Response->new(
			   response => { command => 'get', obj1 => { qvd_object => 'acl' }}));
}

sub _cmd
{
    my ($self,$parsing) = @_;

    my $ids = $self->ask_api(
	{ action => $self->get_all_ids_action($parsing),
	  filters => $self->get_filters($parsing) })->json('/rows');
    
    my $res = $self->ask_api(
	{ action => $self->get_action($parsing),
	  filters => { id => { '=' => $ids }}, 
	  order_by => $self->get_order($parsing), 
	  arguments => $self->get_arguments($parsing)});

    $self->print_table($res,$parsing);
}

sub run 
{
    my ($self, $opts, @args) = @_;

    my $parsing = $self->parse_string(@args);

    if ($parsing->command eq 'get')
    {
	$self->_get($parsing);
    }
    elsif ($parsing->command eq 'create')
    {
	$self->_create($parsing);
    }
    elsif ($parsing->command eq 'can')
    {
	$self->_can($parsing);
    }
    else
    {
	$self->_cmd($parsing);
    }
}

sub make_api_query
{
    my ($self,$parsing) = @_;

    return { action => $self->get_action($parsing),
	     filters => $self->get_filters($parsing), 
	     fields => $self->get_fields_for_api($parsing), 
	     order_by => $self->get_order($parsing), 
	     arguments => $self->get_arguments($parsing)};
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

    my @fields = $self->get_fields($parsing,$res);

    unless (@fields) { $self->print_count($res); return; }

    my $tb = Text::UnicodeTable::Simple->new();
    $tb->set_header(@fields);

    my $rows;

    while (my $properties = $res->json("/rows/$n")) 
    { 
	$tb->add_row( map {  $self->get_field_value($parsing,$properties,$_) // '' } @fields );
	$n++;
    }

    print STDOUT "$tb" . "Total: ".$res->json('/total')."\n";
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
	CLI::Framework::Exception->throw('Unable to tokenize request');

    my $parsing = $parser->parse( shift @$tokenization );

    $self->unrecognized($parsing) &&
	CLI::Framework::Exception->throw('Unable to parse request');
    $self->ambiguous($parsing) &&
	CLI::Framework::Exception->throw('Ambiguos request');
    
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

    return $self->ask_api_di_upload($query)
	if $query->{action} eq 'di_create';

    my $app = $self->get_app;
    my %args = (
	login => $app->cache->get('login'), 
	password => $app->cache->get('password'),
	tenant => $app->cache->get('tenant_name'),
	sid => $app->cache->get('sid'),
	url => $app->cache->get('api_url'),
	ua =>  $app->cache->get('user_agent'));

    my ($sid,$login,$password,$tenant,$url,$ua) = 
	@args{qw(sid login password tenant url ua)};

    my %credentials = defined $sid ? (sid => $sid) : 
	( login => $login, password => $password);
    $credentials{tenant} = $tenant if 
	defined $tenant && defined $credentials{login};
 
    my $res = $ua->post("$url", json => {%$query,%credentials,parameters => { source => 'CLI'}} )->res;

    CLI::Framework::Exception->throw('API returns bad status')
	unless $res->code;

    $self->check_api_result($res);

    return $res;
}

sub check_api_result
{
    my ($self,$res) = @_;

    return 1 unless $res->json('/status');

    my $API_INTERNAL_PROBLEMS_MSG = 'Internal problems in API';
    my %SERVER_INTERNAL_ERRORS = qw(1100 1 4100 1 4110 1 6100 1);

    CLI::Framework::Exception->throw($API_INTERNAL_PROBLEMS_MSG) if 
	$SERVER_INTERNAL_ERRORS{$res->json('/status')};

    CLI::Framework::Exception->throw($res->json('/message')) unless 
	$res->json('/status') eq 1200;

    my ($message,$failures) = ($res->json('/message') . ":\n",$res->json('/failures'));

    my %seen_msgs;

    while (my ($id,$failure) = each %$failures)
    {
	my $msg = $SERVER_INTERNAL_ERRORS{$failure->{status}} ? 
	    $API_INTERNAL_PROBLEMS_MSG : 
	    $failure->{message};
	next if exists $seen_msgs{$msg};
	$seen_msgs{$msg} = 1;
	$message .= "$msg\n"; 
    } 

    $message =~ s/\n$//;
    CLI::Framework::Exception->throw($message);
}


sub ask_api_staging
{
    my ($self,$query) = @_;

    my $app = $self->get_app;
    my %args = (
	login => $app->cache->get('login'), 
	password => $app->cache->get('password'),
	sid => $app->cache->get('sid'),
	url => $app->cache->get('api_staging_url'),
	ua =>  $app->cache->get('user_agent'));

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
		 print STDERR "\r";
		 printf STDERR '%.2f%%', $percentage;
		 $tx->send('Ale');
	     }
	     else
	     {
		 print STDERR "\r";
		 $tx->finish;
	     }};

    $ua->websocket("$url" =>  sub { my ($ua, $tx) = @_;
				    $tx->on(message => $on_message_cb); $tx->send('Ale');} );

    Mojo::IOLoop->start;

    CLI::Framework::Exception->throw('API returns bad status') 
	unless $res->code;

    $self->check_api_result($res);

    Mojo::Message::Response->new(json => $res);
}

sub ask_api_di_upload
{
    my ($self,$query) = @_;

    my $app = $self->get_app;
    my %args = (
	login => $app->cache->get('login'), 
	password => $app->cache->get('password'),
	sid => $app->cache->get('sid'),
	url => $app->cache->get('api_di_upload_url'),
	ua =>  $app->cache->get('user_agent'));

    my ($sid,$login,$password,$url,$ua) = 
	@args{qw(sid login password url ua)};

    my %credentials = defined $sid ? (sid => $sid) : 
	( login => $login, password => $password );

    my $file = $query->{arguments}->{disk_image};
    $query->{arguments}->{disk_image} = basename($file);
    $query->{arguments} = encode_json($query->{arguments});
    delete $query->{filters};
    delete $query->{fields};
    delete $query->{order_by};
    
    my $res; 
    Mojo::IOLoop->delay(
	sub { my $delay = shift;
	      $ua->post("$url", form => { %credentials,%$query, file => { file => $file }}, $delay->begin); },
	
	sub { my ($delay,$tx) = @_; $res = $tx->res; })->wait;
    
    return $res;
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
    my @o = sort keys %{$ORDER->{$parsing->qvd_object}};
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

sub get_all_ids_action
{
    my ($self,$parsing) = @_;
    return eval { 
	$CLI_CMD2API_ACTION->{$parsing->qvd_object}->{'ids'} 
    } // die "No API action available"; 
}

sub get_filters
{
    my ($self,$parsing) = @_;
    my $filters = $parsing->filters // {};

    for my $k ($parsing->filters->list_filters)
    {
	my $normalized_k = $FILTERS->{$parsing->qvd_object}->{$k} // $k;

	for my $ref_v ($parsing->filters->get_filter_ref_value($k))
	{
	    my $op = $parsing->filters->get_operator($ref_v);
	    my $v = $parsing->filters->get_value($ref_v);
	    $v = $self->get_value($parsing,$k,$v,'filter');

	    $parsing->filters->set_filter($ref_v,$normalized_k, {$op => $v});
	}
    }
    $parsing->filters->hash;
}

sub get_arguments
{
    my ($self,$parsing) = @_;
    my $arguments = $parsing->arguments // {};
    my $out = {};

    while (my ($k,$v) = each %$arguments)
    {
	my $normalized_k = $ARGUMENTS->{$parsing->qvd_object}->{$k} // $k;
	$v = $self->get_value($parsing,$k,$v,'argument');
	$out->{$normalized_k} = $v;
    }

    $out;
}

sub superadmin
{
    my $self = shift;
    my $app = $self->get_app;
    $app->cache->get('tenant_id') ? return 1 : return 0;
}

sub get_order
{
    my ($self,$parsing) = @_;

    my $order = $parsing->order // {};
    my $out = [];
    my $criteria = $order->{field} // []; 

    for my $criteria (@$criteria)
    {
	$criteria = eval { $ORDER->{$parsing->qvd_object}->{$criteria} } // $criteria;
	push @$out, $criteria;
    }
    my $direction = $order->{order} // '-asc';
    { order => $direction, field => $out };
}

sub get_fields
{
    my ($self,$parsing,$api_res) = @_;

    my $rows = $api_res->json('/rows') // return ();
    my $first = $$rows[0] // return ();
    return qw(id) if $parsing->command eq 'create';
    return qw() unless $parsing->command eq 'get';

    my @asked_fields = @{$parsing->fields} ? 
	@{$parsing->fields}  : @{$DEFAULT_FIELDS->{$parsing->qvd_object}};

    my @retrieved_fields;
    for my $asked_field (@asked_fields)
    {
	my $api_field = eval {
	    $FIELDS->{$parsing->qvd_object}->{$asked_field} 
	} // $asked_field;

	push @retrieved_fields, $asked_field
	    if exists $first->{$api_field};
    } 
    @retrieved_fields;
}


sub get_fields_for_api
{
    my ($self,$parsing,$api_res) = @_;

    my @asked_fields = @{$parsing->fields};
    for my $asked_field (@asked_fields)
    {
	$asked_field = eval {
	    $FIELDS->{$parsing->qvd_object}->{$asked_field} 
	} // $asked_field;
    } 
    \@asked_fields;
}

sub get_field_value
{
    my ($self,$parsing,$api_res_obj,$cli_field) = @_;

    my $api_field = eval { $FIELDS->{$parsing->qvd_object}->{$cli_field} } // $cli_field;
    my $v = $api_res_obj->{$api_field};

    if (ref($v)) 
    {
	my $cb = eval { $FIELDS_CBS->{$parsing->qvd_object}->{$cli_field} }
	// die "No method available to parse complex field in API output";
	$v = $cb->($v);
    }
    return $v;
}

sub get_value
{
    my ($self,$parsing,$key,$value,$filter_or_argument) = @_;

    if ( my $cb = eval { $CBS_TO_GET_RELATED_OBJECTS_IDS->{$parsing->qvd_object}->{$filter_or_argument}->{$key}})
    {
	$value = $cb->($self,$value,$self->tenant_scoop);
	CLI::Framework::Exception->throw("Unknown related object $key in filters") unless defined $$value[0];

	if ($filter_or_argument eq 'argument')
	{ 
	    CLI::Framework::Exception->throw('Amgiguous reference to object in filters') if 
		defined $$value[1];	    
	    $value = shift @$value;
	}
    }
    $value;
}

sub tenant_scoop
{
    my ($self,$tenant_scoop) = @_;

    $self->{tenant_scoop} = $tenant_scoop
	if $tenant_scoop;

    unless ($self->{tenant_scoop})
    {
	my $app = $self->get_app;
	$self->{tenant_scoop} = $app->cache->get('tenant_id');
    }

    $self->{tenant_scoop};
}


sub read_password
{
    my $self = shift;
    print STDERR "Password: ";
    ReadMode 'noecho'; 
    my $pass = ReadLine 0; 
    chomp $pass;
    ReadMode 'normal';
    print STDERR "\n";
    $pass;
}


sub _read
{
    my ($self,$msg) = @_;
    print STDERR "$msg: ";
    my $read = <>; 
    chomp $read;
    print STDERR "\r";
    $read;
}

1;
