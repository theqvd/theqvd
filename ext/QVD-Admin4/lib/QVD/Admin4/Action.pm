package QVD::Admin4::Action;
use strict;
use warnings;
use Moo;
use QVD::Admin4::Exception;

has 'name', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute name" if ref($name) || (not defined $name) || $name eq ''; }, required => 1;

my $AVAILABLE_ACTION_SIZES = { default => 'normal', normal => 'normal', heavy => 'heavy' };

my $ACTIONS =
{

dis_in_staging => { type_of_action =>  'general',
		    acls => [qr/^di\.create\./],
		    admin4method => 'dis_in_staging'},

config_ssl => { type_of_action =>  'general',
		acls => [qr/^config\.update\./],
		admin4method => 'config_ssl'},

config_get => { type_of_action =>  'general',
		acls => [qr/^config\.see-main\./],
		admin4method => 'config_get'},

config_preffix_get => { type_of_action =>  'general',
			acls => [qr/^config\.see-main\./],
			admin4method => 'config_preffix_get'},

config_set => { type_of_action =>  'create',
		qvd_object => 'Config',
		acls => [qr/^config\.update\./],
		admin4method => 'config_set'},

config_default => { type_of_action =>  'delete',
		   qvd_object => 'Config',
		   acls => [qr/^config\.update\./],
		   admin4method => 'config_default'},

config_delete => { type_of_action =>  'delete',
		   qvd_object => 'Config',
		   acls => [qr/^config\.update\./],
		   admin4method => 'config_delete'},

user_get_list => {type_of_action => 'list',
		  admin4method => 'select',
		  acls => [qr/^user\.see-main\./],
		  qvd_object => 'User'},

user_tiny_list => {type_of_action => 'tiny',
		   admin4method => 'select',
		   acls => [qr/^vm\.(create\.|filter\.user)$/],
		   qvd_object => 'User'},

user_all_ids => { type_of_action => 'all_ids',
		  admin4method => 'select',
		  acls => [qr/^user\.[^.]+-massive\./],
		  qvd_object => 'User'},

user_get_details => { type_of_action => 'details',
		      admin4method => 'select',
		      channels => [qw(user_state_changed vm_state_changed user_state_changed)],
		      acls => [qr/^user\.see-details\./],
		      qvd_object => 'User' },

user_get_state => { type_of_action => 'state',
		    admin4method => 'select',
		    acls => [qr/^user\.see\.vm-list-state$/],
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
		 acls => [qr/^user\.delete\./],
		 qvd_object => 'User'},

vm_get_list => { type_of_action => 'list',
		 admin4method => 'select',
		 acls => [qr/^(vm\.see-main\.|[^.]+\.see\.vm-list)$/],
		 qvd_object => 'VM'},

vm_all_ids => { type_of_action => 'all_ids',
		admin4method => 'select',
		acls => [qr/^vm\.[^.]+-massive\./],
		qvd_object => 'VM'},

vm_tiny_list => { type_of_action => 'tiny',
		  admin4method => 'select',
		   acls => [qr/^(host|osf)\.filter\.vm$/],
		  qvd_object => 'VM'},

vm_get_details => { type_of_action => 'details',
		    admin4method => 'select',
		    channels => [qw(vm_state_changed user_state_changed)],
		    acls => [qr/^vm\.see-details\./],
		    qvd_object => 'VM'},

vm_get_state => { type_of_action => 'state',
		  admin4method => 'select',
		  acls => [qr/^vm\.see\.state$/,qr/^vm\.see\.user-state$/],
		  qvd_object => 'VM'},

vm_update => { type_of_action => 'update',
	       admin4method => 'update',
	       acls => [qr/^vm\.update\./],
	       qvd_object => 'VM'},

vm_user_disconnect => { type_of_action => 'update',
			admin4method => 'vm_user_disconnect',
			acls => [qr/^vm\.update(-massive)?\.disconnect-user$/],
			qvd_object => 'VM'},

vm_start => { type_of_action => 'update',
	      admin4method => 'vm_start',
	     acls => [qr/^vm\.update(-massive)?\.state$/],
	      qvd_object => 'VM'},

vm_stop => { type_of_action => 'update',
	     admin4method => 'vm_stop',
	     acls => [qr/^(vm\.update(-massive)?\.state|host\.update(-massive)?\.stop-vms)$/],
	     qvd_object => 'VM' },

vm_create => { type_of_action => 'create',
	       admin4method => 'create',
	       acls => [qr/^vm\.create\./],
	       qvd_object => 'VM'},

vm_delete => { type_of_action => 'delete',
	       admin4method => 'vm_delete',
	       acls => [qr/^vm\.delete\./],
	       qvd_object => 'VM'},

host_get_list => { type_of_action => 'list',
		   admin4method => 'select',
		   acls => [qr/^host\.see-main\./],
		   qvd_object => 'Host'},

host_all_ids => { type_of_action => 'all_ids',
		  admin4method => 'select',
		  acls => [qr/^host\.[^.]+-massive\./],
		  qvd_object => 'Host'},

host_tiny_list => { type_of_action => 'tiny',
		    admin4method => 'select',
		    acls => [qr/^vm\.filter\.host$/],
		    qvd_object => 'Host'},

host_get_details => { type_of_action => 'details',
		      admin4method => 'select',
		      channels => [qw(host_state_changed vm_state_changed)],
		      acls => [qr/^host\.see-details\./],
		      qvd_object => 'Host'},

host_get_state => { type_of_action => 'state',
		    admin4method => 'select',
		   acls => [qr/^host\.see\.vm-list-state$/],
		    qvd_object => 'Host'},

host_update => { type_of_action => 'update', 
		 admin4method => 'update',
		   acls => [qr/^host\.update\./],
		 qvd_object => 'Host' },

host_create => { type_of_action => 'create',
		 admin4method => 'create',
		   acls => [qr/^host\.create\./],
		 qvd_object => 'Host'},

host_delete => { type_of_action => 'delete',
		 admin4method => 'delete',
		 acls => [qr/^host\.delete\./],
		 qvd_object => 'Host'},

osf_get_list => { type_of_action => 'list',
		  admin4method => 'select',
		  acls => [qr/^osf\.see-main\./],
		  qvd_object => 'OSF'},

osf_all_ids => { type_of_action => 'all_ids',
		 admin4method => 'select',
		 acls => [qr/^osf\.[^.]+-massive\./],
		 qvd_object => 'OSF'},

osf_tiny_list => { type_of_action => 'tiny',
		   admin4method => 'select',
		   acls => [qr/^(di|vm)\.(create\.|filter\.(di|vm))$/],
		   qvd_object => 'OSF'},

osf_get_details => { type_of_action => 'details',
		     admin4method => 'select',
		     channels => [qw(vm_created_or_deleted di_created_or_delated)],
		     acls => [qr/^osf\.see-details\./],
		     qvd_object => 'OSF'},

osf_update => {  type_of_action => 'update',
		 admin4method => 'update',
		 acls => [qr/^osf\.update\./],
		 qvd_object => 'OSF' },

osf_create => { type_of_action => 'create',
		admin4method => 'create',
		acls => [qr/^osf\.create\./],
		qvd_object => 'OSF'},

osf_delete => { type_of_action => 'delete',
		admin4method => 'delete',
		acls => [qr/^osf\.delete\./],
		qvd_object => 'OSF'},

di_get_list => { type_of_action => 'list',
		 admin4method => 'select',
		 acls => [qr/^(di\.see-main\.|[^.]+\.see\.di-list)$/],
		 qvd_object => 'DI'},

di_all_ids => { type_of_action => 'all_ids',
		admin4method => 'select',
		acls => [qr/^di\.[^.]+-massive\./],
		qvd_object => 'DI'},

di_tiny_list => { type_of_action => 'tiny',
		  admin4method => 'select',
		  acls => [qr/^osf\.filter\.di$/],
		  qvd_object => 'DI'},

di_get_details => { type_of_action => 'details',
		    admin4method => 'select',
		     channels => [qw(vm_created_or_deleted)],
		    acls => [qr/^di\.see-details\./],
		    qvd_object => 'DI'},

di_update => { type_of_action => 'update',
	       admin4method => 'update',
	       acls => [qr/^di\.update\./],
	       qvd_object => 'DI'},

di_create => { type_of_action => 'create',
	       admin4method => 'di_create',
	       size => $AVAILABLE_ACTION_SIZES->{heavy},
	       acls => [qr/^di\.create\./],
	       qvd_object => 'DI'},

di_delete => { type_of_action => 'delete',
	       admin4method => 'di_delete',
	       acls => [qr/^di\.delete\./],
	       qvd_object => 'DI'},

tag_tiny_list => { type_of_action => 'tiny',
		   admin4method => 'select',
		   qvd_object => 'DI_Tag'},

admin_get_list => { type_of_action => 'list',
		    admin4method => 'select',
		    acls => [qr/^administrator\.see-main\./],
		    qvd_object => 'Administrator' },

admin_get_details => { type_of_action => 'details',
		       admin4method => 'select',
		       acls => [qr/^administrator\.see-details\./],
		       qvd_object => 'Administrator'},

admin_all_ids => { type_of_action => 'all_ids',
		   admin4method => 'select',
		   acls => [qr/^administrator\.[^.]+-massive\./],
		   qvd_object => 'Administrator'},

admin_create => { type_of_action => 'create',
		  admin4method => 'create',
		  acls => [qr/^administrator\.create\./],
		  qvd_object => 'Administrator'},

admin_update => { type_of_action => 'update',
		  admin4method => 'update',
		  acls => [qr/^administrator\.update\./],
		  qvd_object => 'Administrator'},

admin_delete => { type_of_action => 'delete',
		  admin4method => 'delete',
		  acls => [qr/^administrator\.delete\./],
		  qvd_object => 'Administrator'},

tenant_tiny_list => { type_of_action => 'tiny',
		      admin4method => 'select',
		      qvd_object => 'Tenant'},

tenant_get_list => { type_of_action => 'list',
		     admin4method => 'select',
		     acls => [qr/^tenant\.see-main\./],
		     qvd_object => 'Tenant'},

tenant_get_details => { type_of_action => 'details',
			admin4method => 'select',
			acls => [qr/^tenant\.see-details\./],
			qvd_object => 'Tenant'},

tenant_all_ids => { type_of_action => 'all_ids',
		    admin4method => 'select',
		    acls => [qr/^tenant\.[^.]+-massive\./],
		    qvd_object => 'Tenant'},

tenant_update => { type_of_action => 'update',
		   admin4method => 'update',
		   acls => [qr/^tenant\.update\./],
		   qvd_object => 'Tenant'},

tenant_create => { type_of_action => 'create',
		   admin4method => 'create',
		   acls => [qr/^tenant\.create\./],
		   qvd_object => 'Tenant'},

tenant_delete => { type_of_action => 'delete',
		   admin4method => 'delete',
		   acls => [qr/^tenant\.delete\./],
		   qvd_object => 'Tenant'},

role_tiny_list => { type_of_action => 'tiny',
		    admin4method => 'select',
		   acls => [qr/^(administrator\.see|role\.see\.inherited)\.roles$/],
		    qvd_object => 'Role'},

role_get_list => { type_of_action => 'list',
		   admin4method => 'select',
		   acls => [qr/^role\.see-main\./],
		   qvd_object => 'Role'},

role_get_details => { type_of_action => 'details',
		      admin4method => 'select',
		   acls => [qr/^role\.see-details\./],
		      qvd_object => 'Role'},

role_all_ids => { type_of_action => 'all_ids',
		  admin4method => 'select',
		  acls => [qr/^role\.[^.]+-massive\./],
		  qvd_object => 'Role'},

acl_tiny_list => { type_of_action => 'tiny',
		   admin4method => 'select',
		   acls => [qr/^(role|administrator)\.see\.acl-list$/],
		   qvd_object => 'ACL'},

get_acls_in_roles => { type_of_action => 'general',
		       acls => [qr/^administrator\.see\.acl-list$/],
		       admin4method => 'get_acls_in_roles'},

get_acls_in_admins => { type_of_action => 'general',
			acls => [qr/^administrator\.see\.acl-list$/],
		      admin4method => 'get_acls_in_admins'},


number_of_acls_in_role => { type_of_action =>  'general',
			    acls => [qr/^administrator\.see\.acl-list$/],
			    admin4method => 'get_number_of_acls_in_role'},

number_of_acls_in_admin => { type_of_action =>  'general',
			     acls => [qr/^administrator\.see\.acl-list$/],
			     admin4method => 'get_number_of_acls_in_admin'},

role_update => { type_of_action => 'update',
		 admin4method => 'update',
		 acls => [qr/^role\.update\./],
		 qvd_object => 'Role'},

role_create => { type_of_action => 'create',
		 admin4method => 'create',
		 acls => [qr/^role\.create\./],
		 qvd_object => 'Role'},

role_delete => { type_of_action => 'delete',
		 admin4method => 'delete',
		 acls => [qr/^role\.delete\./],
		 qvd_object => 'Role'},

tenant_view_get_list => { type_of_action => 'list',
			  admin4method => 'select',
			  acls => [qr/^views\.see-main\./],
			  qvd_object => 'Tenant_Views_Setup'},

tenant_view_set => { type_of_action => 'create',
		     admin4method => 'create_or_update',
		     acls => [qr/^views\.update\./],
		     qvd_object => 'Tenant_Views_Setup'},

tenant_view_delete => { type_of_action => 'delete',
			admin4method => 'delete',
			acls => [qr/^views\.update\./],
		       qvd_object => 'Tenant_Views_Setup'},

admin_view_get_list => { type_of_action => 'list',
			 admin4method => 'select',
			 acls => [qr/^views\.see-main\./],
			 qvd_object => 'Administrator_Views_Setup'},

admin_view_set => { type_of_action => 'create',
		    admin4method => 'create_or_update',
		    acls => [],
		    qvd_object => 'Administrator_Views_Setup'},

admin_view_delete => { type_of_action => 'delete',
		       admin4method => 'delete',
		       acls => [qr/^views\.update\./],
		       qvd_object => 'Administrator_Views_Setup'},

current_admin_setup => {type_of_action => 'general',
		       admin4method => 'current_admin_setup'},


properties_by_qvd_object => { type_of_action =>  'general',
			      acls => [qr/^views\.see-main\./],
			      admin4method => 'get_properties_by_qvd_object'},


qvd_objects_statistics => { type_of_action =>  'multiple',
			    channels => [qw(vm_created_or_removed vm_blocked_or_unblocked vm_state_changed vm_expiration_date_changed
                                            host_created_or_removed host_blocked_or_unblocked host_state_changed
                                            user_created_or_removed user_blocked_or_unblocked user_state_changed
                                            osf_created_or_removed osf_blocked_or_unblocked
                                            di_created_or_removed di_blocked_or_unblocked)],
			    admin4methods => { users_count => { acls => [qr/^user\.stats/] },
					       blocked_users_count => { acls => [qr/^user\.stats\.blocked$/]},
					       vms_count => { acls => [qr/^vm\.stats/] },
					       blocked_vms_count => { acls => [qr/^vm\.stats\.blocked$/] },
					       running_vms_count => { acls => [qr/^vm\.stats\.running-vms$/] },
					       hosts_count => { acls => [qr/^host\.stats/] },
					       blocked_hosts_count => { acls => [qr/^host\.stats\.blocked$/] },
					       running_hosts_count => { acls => [qr/^host\.stats\.running-hosts$/] },
					       osfs_count => { acls => [qr/^osf\.stats/] },
					       dis_count => { acls => [qr/^di\.stats/] },
					       blocked_dis_count => { acls => [qr/^di\.stats\.blocked$/] },
					       vms_with_expiration_date => { acls => [qr/^vm\.stats\.close-to-expire$/] },
					       top_populated_hosts => { acls => [qr/^host\.stats\.top-hosts-most-vms$/] } },
			    acls => [qr/^[^.]+\.stats\./]},
};


sub available
{
    my $self = shift;

    defined 
    exists $ACTIONS->{$self->name} ? 
	return 1 : 
	return 0;
}


sub channels
{
    my $self = shift;
    $ACTIONS->{$self->name}->{'channels'} || [];
}

sub size
{
    my $self = shift;
    $ACTIONS->{$self->name}->{'size'} || 
	$AVAILABLE_ACTION_SIZES->{default};
}

sub type
{
    my $self = shift;
    $ACTIONS->{$self->name}->{type_of_action};
}

sub qvd_object
{
    my $self = shift;
    $ACTIONS->{$self->name}->{qvd_object};
}

sub admin4method
{
    my $self = shift;
    $ACTIONS->{$self->name}->{admin4method};
}

sub admin4methods
{
    my $self = shift;
    my $methods = $ACTIONS->{$self->name}->{admin4methods} // {};
    return keys %$methods;
}

sub acls
{
    my $self = shift;
    my $acls = eval { $ACTIONS->{$self->name}->{acls} } // [];
    @$acls;
}

sub acls_for_nested_action
{
    my ($self,$na) = @_;
    my $acls = eval { $ACTIONS->{$self->name}->{admin4methods}->{$na}->{acls} } // [];
    @$acls;
}

sub restmethod
{
    my $self = shift;

    return 'process_multiple_query' if 
	$ACTIONS->{$self->name}->{type_of_action} eq 'multiple';
    return 'process_general_query' if 
	$ACTIONS->{$self->name}->{type_of_action} eq 'general';
    return 'process_standard_query';
}

sub available_for_admin
{
    my ($self,$admin) = @_;
    $admin->re_is_allowed_to($self->acls);
}

sub available_nested_action_for_admin
{
    my ($self,$admin,$na) = @_;
    $admin->re_is_allowed_to($self->acls_for_nested_action($na));
}

1;
