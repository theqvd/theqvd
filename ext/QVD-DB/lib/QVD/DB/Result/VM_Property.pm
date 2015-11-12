package QVD::DB::Result::VM_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_properties');
__PACKAGE__->add_columns( vm_id => { data_type => 'integer' },
                          property_id   => { data_type => 'integer' },
                          value => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('vm_id', 'property_id');
__PACKAGE__->belongs_to(vm => 'QVD::DB::Result::VM', 'vm_id');
__PACKAGE__->belongs_to(vm_properties_list => 'QVD::DB::Result::VM_Property_List', 'property_id');

sub key
{
	my $self = shift;
	return $self->vm_properties_list->properties_list->key;
}

1;
