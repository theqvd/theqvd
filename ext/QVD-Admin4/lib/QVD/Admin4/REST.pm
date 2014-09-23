package QVD::Admin4::REST;
use strict;
use warnings;
use Moose;
use QVD::Admin4;
use QVD::Admin4::DBConfigProvider;
use QVD::Admin4::REST::Request;
use QVD::Admin4::REST::Model;
use QVD::Admin4::REST::JSON;
use QVD::Admin4::Exception;

my $QVD_ADMIN;
my $ACTIONS =
{

user_get_list => {type_of_action => 'list',
		  admin4method => 'select',
		  acls => ['see_user'],
		  qvd_object => 'User'},

user_tiny_list => {type_of_action => 'tiny',
		  admin4method => 'select',
		   acls => ['see_user'],
		   qvd_object => 'User'},

user_all_ids => { type_of_action => 'all_ids',
		  admin4method => 'select',
		  acls => ['see_user'],
		  qvd_object => 'User'},

user_get_details => { type_of_action => 'details',
		      admin4method => 'select',
		      acls => ['see_user'],
		      qvd_object => 'User' },

user_get_state => { type_of_action => 'state',
		    admin4method => 'select',
		    acls => ['see_user'],
		    qvd_object => 'User' },

user_update => { type_of_action => 'update',
		 admin4method => 'update',
		 acls => ['update_user'],
		 qvd_object => 'User' },

user_update_custom => { type_of_action => 'update_custom',
			admin4method => 'update',
			acls => ['update_user'],
			qvd_object => 'User' },

user_create => { type_of_action => 'create',
		 admin4method => 'create',
		 acls => ['create_user'],
		 qvd_object => 'User'},

user_delete => { type_of_action => 'delete',
		 admin4method => 'delete',
		 acls => ['delete_user'],
		 qvd_object => 'User'},

vm_get_list => { type_of_action => 'list',
		 admin4method => 'select',
		 qvd_object => 'VM'},

vm_all_ids => { type_of_action => 'all_ids',
		admin4method => 'select',
		qvd_object => 'VM'},

vm_tiny_list => { type_of_action => 'tiny',
		  admin4method => 'select',
		  qvd_object => 'VM'}

vm_get_details => { type_of_action => 'details',
		    admin4method => 'select',
		    qvd_object => 'VM'}

vm_get_state => { type_of_action => 'state',
		  admin4method => 'select',
		  qvd_object => 'VM'}

vm_update => { type_of_action => 'update',
	       admin4method => 'update',
	       qvd_object => 'VM'},

vm_update_custom => { type_of_action => 'update_custom',
		      admin4method => 'update',
		      qvd_object => 'VM'},

vm_user_disconnect => { type_of_action => 'exec',
			admin4method => 'vm_user_disconnect',
			qvd_object => 'VM'},

vm_start => { type_of_action => 'exec',
	      admin4method => 'vm_start',
	      qvd_object => 'VM'}

vm_stop => { type_of_action => 'exec',
	     admin4method => 'vm_stop',
	     qvd_object => 'VM' },

vm_create => { type_of_action => 'create',
	       admin4method => 'vm_create',
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
		 qvd_object => 'Host' }

host_update_custom => { type_of_action => 'update_custom', 
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

osf_update_custom => { type_of_action => 'update_custom',
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

di_get_list => { type_of_action => 'list',
		 admin4method => 'select',
		 qvd_object => 'DI'},

di_update => { type_of_action => 'update',
	       admin4method => 'update',
	       qvd_object => 'DI'},

di_update_custom => { type_of_action => 'update_custom',
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

admin_create => { type_of_action => 'create',
		  admin4method => 'admin_create',
		  qvd_object => 'Administrator'},

admin_update => { type_of_action => 'update',
		  admin4method => 'update',
		  qvd_object => 'Administrator'},

admin_delete => { type_of_action => 'delete',
		  admin4method => 'delete',
		  qvd_object => 'Administrator'},

tenant_tiny_list => { type_of_action = 'tiny',
		      admin4method => 'select',
		      qvd_object => 'Tenant'},

tenant_get_list => { type_of_action => 'list',
		     admin4method => 'select',
		     qvd_object => 'Tenant'},

tenant_get_details => { type_of_action => 'details',
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

acl_tiny_list => { type_of_action => 'tiny',
		   admin4method => 'select',
		   qvd_object => 'ACL'},

acl_get_list => { type_of_action => 'list',
		  admin4method => 'select',
		  qvd_object => 'ACL'},

acl_create => { type_of_action => 'create',
		admin4method => 'create',
		qvd_object => 'ACL'},

role_update => { type_of_action => 'update_custom',
		 admin4method => 'update',
		 qvd_object => 'Role'},

role_create => { type_of_action => 'create',
		 admin4method => 'create',
		 qvd_object => 'Role'},

role_delete => { type_of_action => 'delete',
		 admin4method => 'delete',
		 qvd_object => 'Role'},

qvd_objects_statistics { type_of_action =>  'general',
			 admin4method => 'qvd_objects_statistics'},
};

sub BUILD
{
    my $self = shift;
    $QVD_ADMIN = QVD::Admin4->new();
}

sub load_user
{
    my ($self,%params) = @_;

    return undef unless 
	defined $params{tenant} && 
	defined $params{login};

    $params{name} = delete $params{login};
    $params{tenant_id} = delete $params{tenant};

    my $uid = 
	eval { $QVD_ADMIN->get_credentials(%params) } // undef;
}

sub validate_user
{
    my ($self,%params) = @_;

    return undef unless 
	defined $params{password} && 
	defined $params{login};

    $params{name} = delete $params{login};

    my $uid = 
	eval { $QVD_ADMIN->get_credentials(%params) } // undef;
}

sub _admin
{
   my ($self,$json) = @_;

   my $json_wrapper = QVD::Admin4::REST::JSON->new(json => $json);
   my $action = $ACTIONS->{$qvd_json->action} // 
       QVD::Admin4::Exception->throw(code => 5);

   $self->available_action_for_current_admin($action) // 
       QVD::Admin4::Exception->throw(code => 8);

   $self->exec_action_without_qvd_object_model($action)
       if $action->{type_of_action} eq 'general';

   my $qvd_object_model = QVD::Admin4::REST::Model(current_qvd_administrator => $QVD_ADMIN->administrator,
						   qvd_object => $action->{qvd_object},
						   type_of_action => $action->{type_of_action});

   my $admin4method = $action->{admin4method};
   my $result = eval { $QVD_ADMIN->$admin4method($self->get_request($json_wrapper,$qvd_object_model)) } // {};
   print $@ if $@;
   my $general_status = ($@ && (( $@->can('code') && $@->code) || 1)) || 0;
   my $individual_failures = ($@ && $@->can('failures')) ? $@->failures  : {};
   
   my $response = QVD::Admin4::REST::Response->new(qvd_object_model => $qvd_object_model,
						   status   => $general_status,
                                                   result   => $result,
                                                   failures => $individual_failures);
   $response->json;
}

sub exec_action_without_qvd_object_model
{
    my ($self,$action) = @_;

    my $admin4method = $action->{admin4method};
    my $result = eval { $QVD_ADMIN->$admin4method($self->get_request($json_wrapper,$qvd_object_model)) } // {};
    print $@ if $@;
    my $general_status = ($@ && (( $@->can('code') && $@->code) || 1)) || 0;
    my $individual_failures = ($@ && $@->can('failures')) ? $@->failures  : {};
   
    my $response = QVD::Admin4::REST::Response->new(status   => $general_status,
						    result   => $result,
						    failures => $individual_failures);
    $response->json;
}

sub available_action_for_current_admin
{
    my ($self,$action) = @_;

    $QVD_ADMIN->administrator->is_allowed_to($_) || return 0
	for @{$action->{acls}};
    return 1;
}


sub get_request 
{ 
    my ($self, $json_wrapper,$qvd_object_model) = @_;

    QVD::Admin4::REST::Request->new(qvd_object_model => $qvd_object_model, 
				    json_wrapper => $json_wrapper, 
				    db_qvd_config_provider => QVD::Admin4::DBConfigProvider->new());
}


1;

