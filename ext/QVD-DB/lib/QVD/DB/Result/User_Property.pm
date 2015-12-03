package QVD::DB::Result::User_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_properties');
__PACKAGE__->add_columns( user_id => { data_type => 'integer' },
                          property_id     => { data_type => 'integer' },
                          value   => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('user_id', 'property_id');
__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'user_id');
__PACKAGE__->belongs_to(user_properties_list => 'QVD::DB::Result::QVD_Object_Property_List', 'property_id');

sub key
{
	my $self = shift;
	return $self->user_properties_list->properties_list->key;
}

1;
