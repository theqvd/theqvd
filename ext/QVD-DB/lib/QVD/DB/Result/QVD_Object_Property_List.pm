package QVD::DB::Result::QVD_Object_Property_List;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('qvd_object_properties_list');
__PACKAGE__->add_columns( id   => { data_type => 'integer', is_auto_increment => 1 } );
__PACKAGE__->add_columns( property_id   => { data_type => 'integer' } );
__PACKAGE__->add_columns( qvd_object  => { data_type => 'administrator_and_tenant_views_setups_qvd_object_enum'} );


__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(property_id qvd_object)]);
__PACKAGE__->has_many(tenant_prop_setups => 'QVD::DB::Result::Views_Setup_Properties_Tenant', {'foreign.qvd_obj_prop_id' => 'self.id'});
__PACKAGE__->has_many(admin_prop_setups => 'QVD::DB::Result::Views_Setup_Properties_Administrator', {'foreign.qvd_obj_prop_id' => 'self.id'});
__PACKAGE__->belongs_to(properties_list => 'QVD::DB::Result::Property_List', 'property_id');

__PACKAGE__->might_have(vm_property => 'QVD::DB::Result::VM_Property', 'property_id');
__PACKAGE__->might_have(osf_property => 'QVD::DB::Result::OSF_Property', 'property_id');
__PACKAGE__->might_have(di_property => 'QVD::DB::Result::DI_Property', 'property_id');
__PACKAGE__->might_have(host_property => 'QVD::DB::Result::Host_Property', 'property_id');
__PACKAGE__->might_have(user_property => 'QVD::DB::Result::User_Property', 'property_id');

sub tenant_id
{
	my $self = shift;
	$self->properties_list->tenant->id;
}

sub tenant_name
{
	my $self = shift;
	$self->properties_list->tenant->name;
}

sub description
{
	my $self = shift;
	$self->properties_list->description;
}

sub key {
	my $self = shift;
	$self->properties_list->key;
}

sub is_user_property{
	my $self = shift;
	return ($self->qvd_object eq 'user');
}

sub is_host_property{
	my $self = shift;
	return ($self->qvd_object eq 'host');
}

sub is_osf_property{
	my $self = shift;
	return ($self->qvd_object eq 'osf');
}

sub is_vm_property{
	my $self = shift;
	return ($self->qvd_object eq 'vm');
}

sub is_di_property{
	my $self = shift;
	return ($self->qvd_object eq 'di');
}

1;