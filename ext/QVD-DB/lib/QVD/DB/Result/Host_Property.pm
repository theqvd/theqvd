package QVD::DB::Result::Host_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('host_properties');
__PACKAGE__->add_columns(
#	id => {
#	    data_type => 'integer',
#	    is_auto_increment => 1,
#	},
	host_id => {
	    data_type => 'integer',
	},
	key => {
	    data_type => 'varchar(20)',
	},
	value => {
	    data_type => 'varchar(255)',
	},
	);
__PACKAGE__->set_primary_key('host_id', 'key');
__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id');

1;
