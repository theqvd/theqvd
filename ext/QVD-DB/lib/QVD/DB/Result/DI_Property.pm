package QVD::DB::Result::DI_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('di_properties');
__PACKAGE__->add_columns( di_id => { data_type => 'integer' },
                          property_id  => { data_type => 'integer' },
                          value => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('di_id', 'property_id');
__PACKAGE__->belongs_to(di => 'QVD::DB::Result::DI', 'di_id');
__PACKAGE__->belongs_to(di_properties_list => 'QVD::DB::Result::DI_Property_List', 'property_id');

sub key
{
	my $self = shift;
	return $self->di_properties_list->properties_list->key;
}

1;
