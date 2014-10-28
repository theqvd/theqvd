package QVD::Admin4::REST;
use strict;
use warnings;
use Moo;
use QVD::Admin4;
use QVD::Admin4::REST::Request;
use QVD::Admin4::REST::Model;
use QVD::Admin4::REST::JSON;
use QVD::Admin4::Exception;

has 'administrator', is => 'ro', isa => sub { die "Invalid type for attribute administrator" 
						  unless ref(+shift) eq 'QVD::DB::Result::Administrator'; };
my $QVD_ADMIN;
my $ACTIONS =
{

current_admin_setup => {type_of_action => 'admin_config_provider',
		       admin4method => 'current_admin_setup'},

user_get_list => {type_of_action => 'list',
		  admin4method => 'select',
		  acls => [qr/^user\.see-main\.$/],
		  qvd_object => 'User'},

user_tiny_list => {type_of_action => 'tiny',
		  admin4method => 'select',
		   acls => [qr/^user\.see-main\.$/],
		   qvd_object => 'User'},

user_all_ids => { type_of_action => 'all_ids',
		  admin4method => 'select',
		  acls => [qr/^user\.see-main\.$/],
		  qvd_object => 'User'},

user_get_details => { type_of_action => 'details',
		      admin4method => 'select',
		      acls => [qr/^user\.see-details\.$/],
		      qvd_object => 'User' },

user_get_state => { type_of_action => 'state',
		    admin4method => 'select',
		    acls => [qr/^user\.see-vm-list-state\.$/],
		    qvd_object => 'User' },

user_update => { type_of_action => 'update',
		 admin4method => 'update',
		 acls => [qr/^user\.update\./],
		 qvd_object => 'User' },

user_create => { type_of_action => 'create',
		 admin4method => 'create',
		 acls => [qr/^user\.create\.$/],
		 qvd_object => 'User'},

user_delete => { type_of_action => 'delete',
		 admin4method => 'delete',
		 acls => [qr/^user\.delete\.$/],
		 qvd_object => 'User'},

vm_get_list => { type_of_action => 'list',
		 admin4method => 'select',
		 qvd_object => 'VM'},

vm_all_ids => { type_of_action => 'all_ids',
		admin4method => 'select',
		qvd_object => 'VM'},

vm_tiny_list => { type_of_action => 'tiny',
		  admin4method => 'select',
		  qvd_object => 'VM'},

vm_get_details => { type_of_action => 'details',
		    admin4method => 'select',
		    qvd_object => 'VM'},

vm_get_state => { type_of_action => 'state',
		  admin4method => 'select',
		  qvd_object => 'VM'},

vm_update => { type_of_action => 'update',
	       admin4method => 'update',
	       qvd_object => 'VM'},

vm_user_disconnect => { type_of_action => 'exec',
			admin4method => 'vm_user_disconnect',
			qvd_object => 'VM'},

vm_start => { type_of_action => 'exec',
	      admin4method => 'vm_start',
	      qvd_object => 'VM'},

vm_stop => { type_of_action => 'exec',
	     admin4method => 'vm_stop',
	     qvd_object => 'VM' },

vm_create => { type_of_action => 'create',
	       admin4method => 'create',
	       qvd_object => 'VM'},

vm_delete => { type_of_action => 'delete',
	       admin4method => 'vm_delete',
	       qvd_object => 'VM'},

host_get_list => { type_of_action => 'list',
		   admin4method => 'select',
		   qvd_object => 'Host'},

host_all_ids => { type_of_action => 'all_ids',
		  admin4method => 'select',
		  qvd_object => 'Host'},

host_tiny_list => { type_of_action => 'tiny',
		    admin4method => 'select',
		    qvd_object => 'Host'},

host_get_details => { type_of_action => 'details',
		      admin4method => 'select',
		      qvd_object => 'Host'},

host_get_state => { type_of_action => 'state',
		    admin4method => 'select',
		    qvd_object => 'Host'},

host_update => { type_of_action => 'update', 
		 admin4method => 'update',
		 qvd_object => 'Host' },

host_create => { type_of_action => 'create',
		 admin4method => 'create',
		 qvd_object => 'Host'},

host_delete => { type_of_action => 'delete',
		 admin4method => 'delete',
		 qvd_object => 'Host'},

osf_get_list => { type_of_action => 'list',
		  admin4method => 'select',
		  qvd_object => 'OSF'},

osf_all_ids => { type_of_action => 'all_ids',
		 admin4method => 'select',
		 qvd_object => 'OSF'},

osf_tiny_list => { type_of_action => 'tiny',
		   admin4method => 'select',
		   qvd_object => 'OSF'},

osf_get_details => { type_of_action => 'details',
		     admin4method => 'select',
		     qvd_object => 'OSF'},

osf_update => {  type_of_action => 'update',
		 admin4method => 'update',
		 qvd_object => 'OSF' },

osf_create => { type_of_action => 'create',
		admin4method => 'create',
		qvd_object => 'OSF'},

osf_delete => { type_of_action => 'delete',
		admin4method => 'delete',
		qvd_object => 'OSF'},

di_get_list => { type_of_action => 'list',
		 admin4method => 'select',
		 qvd_object => 'DI'},

di_all_ids => { type_of_action => 'all_ids',
		admin4method => 'select',
		qvd_object => 'DI'},

di_tiny_list => { type_of_action => 'tiny',
		  admin4method => 'select',
		  qvd_object => 'DI'},

di_get_details => { type_of_action => 'details',
		 admin4method => 'select',
		 qvd_object => 'DI'},

di_update => { type_of_action => 'update',
	       admin4method => 'update',
	       qvd_object => 'DI'},

di_create => { type_of_action => 'create',
	       admin4method => 'di_create',
	       qvd_object => 'DI'},

di_delete => { type_of_action => 'delete',
	       admin4method => 'di_delete',
	       qvd_object => 'DI'},

tag_tiny_list => { type_of_action => 'tiny',
		   admin4method => 'select',
		   qvd_object => 'DI_Tag'},

tag_get_list => { type_of_action => 'list',
		   admin4method => 'select',
		   qvd_object => 'DI_Tag'},

tag_get_details => { type_of_action => 'details',
		   admin4method => 'select',
		   qvd_object => 'DI_Tag'},

tag_all_ids => { type_of_action => 'all_ids',
		 admin4method => 'select',
		 qvd_object => 'DI_Tag'},

admin_tiny_list => { type_of_action => 'tiny',
		     admin4method => 'select',
		     qvd_object => 'Administrator'},

admin_get_list => { type_of_action => 'list',
		    admin4method => 'select',
		    qvd_object => 'Administrator' },

admin_get_details => { type_of_action => 'details',
		       admin4method => 'select',
		       qvd_object => 'Administrator'},

admin_all_ids => { type_of_action => 'all_ids',
		       admin4method => 'select',
		       qvd_object => 'Administrator'},

admin_create => { type_of_action => 'create',
		  admin4method => 'create',
		  qvd_object => 'Administrator'},

admin_update => { type_of_action => 'update',
		  admin4method => 'update',
		  qvd_object => 'Administrator'},

admin_delete => { type_of_action => 'delete',
		  admin4method => 'delete',
		  qvd_object => 'Administrator'},

tenant_tiny_list => { type_of_action => 'tiny',
		      admin4method => 'select',
		      qvd_object => 'Tenant'},

tenant_get_list => { type_of_action => 'list',
		     admin4method => 'select',
		     qvd_object => 'Tenant'},

tenant_get_details => { type_of_action => 'details',
			admin4method => 'select',
			qvd_object => 'Tenant'},

tenant_all_ids => { type_of_action => 'all_ids',
			admin4method => 'select',
			qvd_object => 'Tenant'},

tenant_update => { type_of_action => 'update',
		   admin4method => 'update',
		   qvd_object => 'Tenant'},

tenant_create => { type_of_action => 'create',
		   admin4method => 'create',
		   qvd_object => 'Tenant'},

tenant_delete => { type_of_action => 'delete',
		   admin4method => 'delete',
		   qvd_object => 'Tenant'},

role_tiny_list => { type_of_action => 'tiny',
		    admin4method => 'select',
		    qvd_object => 'Role'},

role_get_list => { type_of_action => 'list',
		   admin4method => 'select',
		   qvd_object => 'Role'},

role_get_details => { type_of_action => 'details',
		      admin4method => 'select',
		      qvd_object => 'Role'},

role_all_ids => { type_of_action => 'all_ids',
		      admin4method => 'select',
		      qvd_object => 'Role'},

acl_tiny_list => { type_of_action => 'tiny',
		   admin4method => 'select',
		   qvd_object => 'ACL'},

acl_get_list => { type_of_action => 'list',
		  admin4method => 'select',
		  qvd_object => 'ACL'},

get_acls_in_roles => { type_of_action => 'general',
		      admin4method => 'get_acls_in_roles'},

get_acls_in_admins => { type_of_action => 'general',
		      admin4method => 'get_acls_in_admins'},

acl_all_ids => { type_of_action => 'all_ids',
		  admin4method => 'select',
		  qvd_object => 'ACL'},

acl_get_details => { type_of_action => 'details',
		  admin4method => 'select',
		  qvd_object => 'ACL'},

role_update => { type_of_action => 'update',
		 admin4method => 'update',
		 qvd_object => 'Role'},

role_create => { type_of_action => 'create',
		 admin4method => 'create',
		 qvd_object => 'Role'},

role_delete => { type_of_action => 'delete',
		 admin4method => 'delete',
		 qvd_object => 'Role'},


tenant_view_tiny_list => { type_of_action => 'tiny',
			   admin4method => 'select',
			   qvd_object => 'Tenant_Views_Setup'},

tenant_view_get_list => { type_of_action => 'list',
			  admin4method => 'select',
			  qvd_object => 'Tenant_Views_Setup'},

tenant_view_get_details => { type_of_action => 'details',
			     admin4method => 'select',
			     qvd_object => 'Tenant_Views_Setup'},

tenant_view_all_ids => { type_of_action => 'all_ids',
			 admin4method => 'select',
			 qvd_object => 'Tenant_Views_Setup'},

tenant_view_update => { type_of_action => 'update',
			admin4method => 'update',
			qvd_object => 'Tenant_Views_Setup'},

tenant_view_create => { type_of_action => 'create',
			admin4method => 'create',
			qvd_object => 'Tenant_Views_Setup'},

tenant_view_delete => { type_of_action => 'delete',
			admin4method => 'delete',
			qvd_object => 'Tenant_Views_Setup'},



admin_view_tiny_list => { type_of_action => 'tiny',
			   admin4method => 'select',
			   qvd_object => 'Administrator_Views_Setup'},

admin_view_get_list => { type_of_action => 'list',
			  admin4method => 'select',
			  qvd_object => 'Administrator_Views_Setup'},

admin_view_get_details => { type_of_action => 'details',
			     admin4method => 'select',
			     qvd_object => 'Administrator_Views_Setup'},

admin_view_all_ids => { type_of_action => 'all_ids',
			 admin4method => 'select',
			 qvd_object => 'Administrator_Views_Setup'},

admin_view_update => { type_of_action => 'update',
			admin4method => 'update',
			qvd_object => 'Administrator_Views_Setup'},

admin_view_create => { type_of_action => 'create',
			admin4method => 'create',
			qvd_object => 'Administrator_Views_Setup'},

admin_view_delete => { type_of_action => 'delete',
			admin4method => 'delete',
			qvd_object => 'Administrator_Views_Setup'},


qvd_objects_statistics => { type_of_action =>  'general',
			    admin4method => 'qvd_objects_statistics'},

number_of_acls_in_role => { type_of_action =>  'general',
			    admin4method => 'get_number_of_acls_in_role'},

number_of_acls_in_admin => { type_of_action =>  'general',
			    admin4method => 'get_number_of_acls_in_admin'},

properties_by_qvd_object => { type_of_action =>  'general',
			      admin4method => 'get_properties_by_qvd_object'},

};

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

   my $json_wrapper = QVD::Admin4::REST::JSON->new(json => $json);

   my $action = $ACTIONS->{$json_wrapper->action} // 
       return QVD::Admin4::REST::Response->new(status => 5)->json;

   $self->available_action_for_current_admin($action) || 
       return QVD::Admin4::REST::Response->new(status => 8)->json;

   return $self->process_admin_config_provider_query($action,$json_wrapper)
       if $action->{type_of_action} eq 'admin_config_provider';

   return $self->process_query_without_qvd_object_model($action,$json_wrapper)
       if $action->{type_of_action} eq 'general';

   my $qvd_object_model = QVD::Admin4::REST::Model->new(current_qvd_administrator => $self->administrator,
							qvd_object => $action->{qvd_object},
							type_of_action => $action->{type_of_action});

   my $admin4method = $action->{admin4method};
   my $result = eval { $QVD_ADMIN->$admin4method($self->get_request($json_wrapper,$qvd_object_model)) } // {};

   print $@ if $@;
   my $general_status = ($@ && (( $@->can('code') && $@->code) || 1)) || 0;
   my $individual_failures = ($@ && $@->can('failures')) ? $@->failures  : {};

   my $response = eval {QVD::Admin4::REST::Response->new(qvd_object_model => $qvd_object_model,
							  status   => $general_status,
							  result   => $result,
							  failures => $individual_failures) };

   return $response->json;
}

sub process_admin_config_provider_query
{ 
    my ($self,$action,$json_wrapper) = @_;

    my $admin4method = $action->{admin4method};
    my $result = eval { $QVD_ADMIN->$admin4method($self->administrator,$json_wrapper) } // {};
    print $@ if $@;
    my $general_status = ($@ && (( $@->can('code') && $@->code) || 1)) || 0;
    my $individual_failures = ($@ && $@->can('failures')) ? $@->failures  : {};
    my $response = eval { QVD::Admin4::REST::Response->new(status   => $general_status,
							   result   => $result,
							   failures => $individual_failures) };
    return $response->json;

}

sub process_query_without_qvd_object_model
{
    my ($self,$action,$json_wrapper) = @_;

    my $admin4method = $action->{admin4method};
    my $result = eval { $QVD_ADMIN->$admin4method($json_wrapper) } // {};
    print $@ if $@;
    my $general_status = ($@ && (( $@->can('code') && $@->code) || 1)) || 0;
    my $individual_failures = ($@ && $@->can('failures')) ? $@->failures  : {};
    my $response = eval { QVD::Admin4::REST::Response->new(status   => $general_status,
							   result   => $result,
							   failures => $individual_failures) };
    return $response->json;
}

sub available_action_for_current_admin
{
    my ($self,$action) = @_;

    $self->administrator->re_is_allowed_to(@{$action->{acls}});
}

sub get_request 
{ 
    my ($self, $json_wrapper,$qvd_object_model) = @_;

    QVD::Admin4::REST::Request->new(qvd_object_model => $qvd_object_model, 
				    json_wrapper => $json_wrapper);
}


1;

