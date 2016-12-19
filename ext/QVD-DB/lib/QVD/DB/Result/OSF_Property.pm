package QVD::DB::Result::OSF_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('osf_properties');
__PACKAGE__->add_columns( osf_id => { data_type => 'integer' },
                          property_id   => { data_type => 'integer' },
                          value => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('osf_id', 'property_id');
__PACKAGE__->belongs_to(osf => 'QVD::DB::Result::OSF', 'osf_id');
__PACKAGE__->belongs_to(qvd_properties_list => 'QVD::DB::Result::QVD_Object_Property_List', 'property_id');

sub key
{
	my $self = shift;
	return $self->qvd_properties_list->properties_list->key;
}

1;
