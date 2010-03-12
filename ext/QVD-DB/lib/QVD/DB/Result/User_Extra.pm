package QVD::DB::Result::User_Extra;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_extras');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	department => {
	    data_type => 'varchar(64)',
	    is_nullable => 1,
	},
	telephone => {
	    data_type => 'varchar(64)',
	    is_nullable => 1,
	},
	email => {
	    data_type => 'varchar(64)',
	    is_nullable => 1,
	},
	);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'id');

1;
