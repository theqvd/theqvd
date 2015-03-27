package QVD::Admin4::REST;
use strict;
use warnings;
use Moo;
use QVD::Admin4;
use QVD::Admin4::REST::Request;
use QVD::Admin4::REST::Response;
use QVD::Admin4::REST::Model;
use QVD::Admin4::REST::JSON;
use QVD::Admin4::Exception;
use QVD::Admin4::Action;
use TryCatch;
use AnyEvent::Pg::Pool;
use QVD::Config;
use Mojo::JSON qw(encode_json);
use base qw(Mojolicious::Plugin);

has 'administrator', is => 'ro', isa => sub { die "Invalid type for attribute administrator" 
						  unless ref(+shift) eq 'QVD::DB::Result::Administrator'; };
my $QVD_ADMIN;

sub BUILD
{
    my $self = shift;
    $QVD_ADMIN = QVD::Admin4->new();
}

sub register
{ 
    my ($self,$app) = @_;
    $app->helper(qvd_admin4_api => sub { $self });
}

sub _db { $QVD_ADMIN->_db; };

sub validate_user
{
    my ($self,%params) = @_;
    my $multitenant = cfg('wat.multitenant');

    return undef if (not defined $params{id}) && 
	$multitenant && (not defined $params{tenant});

    $params{name} = delete $params{login} if defined $params{login};
    $params{tenant_id} = eval { $QVD_ADMIN->_db->resultset('Tenant')->search(
				    { name => delete $params{tenant} })->first->id } 
    if exists $params{tenant}; 

    my $rs = eval { $QVD_ADMIN->_db->resultset('Administrator')->search(\%params) };
    print $@ if $@;
    
    my @admins = grep { $multitenant || $_->is_recovery_admin || 
			    (not $_->is_superadmin) } $rs->all;
    return undef unless @admins;

    my $admin = shift @admins;
    die "More than one administrators found for these credentials" if @admins;
    return $admin;
}


sub load_user
{
    my ($self,$admin) = @_;

    $admin = $self->validate_user(id => $admin) 
	unless ref($admin);

    $self->{administrator} = $admin;
    $admin->set_tenants_scoop(
	[ map { $_->id } 
	  $QVD_ADMIN->_db->resultset('Tenant')->search()->all ])
	if $admin->is_superadmin;
}



sub process_query
{
   my ($self,$json) = @_;
   my ($response,$json_wrapper,$action,$qvd_object_model);

   try {

       $json_wrapper = QVD::Admin4::REST::JSON->new(json => $json);
       $action = QVD::Admin4::Action->new(name => $json_wrapper->action );
       QVD::Admin4::Exception->throw(code => 4210) 
	   unless $action->available_for_admin($self->administrator);

       $qvd_object_model = $self->get_qvd_object_model($action) 
	   if $action->qvd_object;

       my $restmethod = $action->restmethod;
	
       my $result = $self->$restmethod($action,$json_wrapper,$qvd_object_model);

       my %args = (status => 0, result => $result);
       $args{json_wrapper} = $json_wrapper;
       $args{qvd_object_model} = $qvd_object_model
	   if $qvd_object_model;

       $response = QVD::Admin4::REST::Response->new(%args);

   } catch ( QVD::Admin4::Exception $err ) {
       $response = $err;

   } catch ($err) {
       print $err;
       $response = QVD::Admin4::Exception->new(code => 1100);
   }

   $response->json;
}

sub get_channels
{
   my ($self,$action_name) = @_;
   QVD::Admin4::Action->new(name => $action_name )->channels;
}

sub get_size
{
   my ($self,$action_name) = @_;
   QVD::Admin4::Action->new(name => $action_name )->size;
}

sub process_standard_query
{
    my ($self,$action,$json_wrapper,$qvd_object_model) = @_;
    my $admin4method = $action->admin4method;
    my $result = $QVD_ADMIN->$admin4method($self->get_request($json_wrapper,$qvd_object_model));
}

sub process_general_query
{
    my ($self,$action,$json_wrapper) = @_;
    my $admin4method = $action->admin4method;
    my $result = $QVD_ADMIN->$admin4method($self->administrator,$json_wrapper);
}

sub process_multiple_query
{
    my ($self,$action,$json_wrapper) = @_;

    my @admin4methods = $action->admin4methods;
    my $result = {};

    for my $method (@admin4methods)
    {
	next unless $action->available_nested_action_for_admin($self->administrator,$method);
	$result->{$method} = $QVD_ADMIN->$method($self->administrator,$json_wrapper);
    }
    
    $result;
}

sub get_qvd_object_model 
{ 
    my ($self, $action) = @_;

    QVD::Admin4::REST::Model->new(current_qvd_administrator => $self->administrator,
				  qvd_object => $action->qvd_object,
				  type_of_action => $action->type);
}

sub get_request 
{ 
    my ($self, $json_wrapper,$qvd_object_model) = @_;

    QVD::Admin4::REST::Request->new(qvd_object_model => $qvd_object_model, 
				    json_wrapper => $json_wrapper);
}


sub _cfg
{
    my ($self,$key) = @_;

    return cfg($key);
}

sub _pool
{
    my $self = shift;
    $self->{pool} //=
	AnyEvent::Pg::Pool->new( {host     => cfg('database.host'),
				  dbname   => cfg('database.name'),
				  user     => cfg('database.user'),
				  password => cfg('database.password') },
				 timeout            => cfg('internal.database.pool.connection.timeout'),
				 global_timeout     => cfg('internal.database.pool.connection.global_timeout'),
				 connection_delay   => cfg('internal.database.pool.connection.delay'),
				 connection_retries => cfg('internal.database.pool.connection.retries'),
				 size               => cfg('internal.database.pool.size'),
				    on_connect_error   => sub {},
				 on_transient_error => sub {},
	);

    return $self->{pool};
}

sub database_version
{
    my $self = shift;
    my $version = eval { 
	$QVD_ADMIN->_db->resultset('Version')->search(
	    { component => 'schema' })->first->version
    } // undef;
}

1;

