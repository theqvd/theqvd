package QVD::DB::Result::User;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	login =>  {
	    data_type => 'varchar(64)'
	},
#	uid => {
#	    data_type => 'integer'
#	}
	);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['login']);
#__PACKAGE__->add_unique_constraint(['uid']);
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'user_id');

1;
