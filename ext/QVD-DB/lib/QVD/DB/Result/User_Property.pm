package QVD::DB::Result::User_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_properties');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1,
	},
	user_id => {
	    data_type => 'integer',
	},
	key => {
	    data_type => 'varchar(20)',
	},
	value => {
	    data_type => 'varchar(255)',
	},
	);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'user_id');

1;
