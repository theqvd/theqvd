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

has 'administrator', is => 'ro', isa => sub { die "Invalid type for attribute administrator" 
						  unless ref(+shift) eq 'QVD::DB::Result::Administrator'; };
my $QVD_ADMIN;

sub BUILD
{
    my $self = shift;
    $QVD_ADMIN = QVD::Admin4->new();
}

sub validate_user
{
    my ($self,%params) = @_;

    $params{name} = delete $params{login}; # FIX ME IN DB!!!
    my $admin = eval { $QVD_ADMIN->_db->resultset('Administrator')->find(\%params) };
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
   my $response;

   try {
       my $json_wrapper = QVD::Admin4::REST::JSON->new(json => $json);

       my $action = QVD::Admin4::Action->new(name => $json_wrapper->action );

       QVD::Admin4::Exception->throw(code => 26) 
	   unless $action->available;

       QVD::Admin4::Exception->throw(code => 27) 
	   unless $action->available_for_admin($self->administrator);

       my $qvd_object_model = $self->get_qvd_object_model($action) 
	   if $action->qvd_object;

       my $restmethod = $action->restmethod;
       my $result = $self->$restmethod($action,$json_wrapper,$qvd_object_model);

       my %args = (status => 0, result => $result);
       $args{qvd_object_model} = $qvd_object_model
	   if $qvd_object_model;

       $response = QVD::Admin4::REST::Response->new(%args);

   } catch ( QVD::Admin4::Exception $err ) {
       $response = $err;
   } catch ($err) {
       print $err;
       $response = QVD::Admin4::Exception->new(code => 11);
   }

   return $response->json;
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



1;

