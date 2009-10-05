package QVD::DB::Result::Farm;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('farm');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	name => {
	    data_type => 'varchar(64)'
	}
	);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'farm_id');
__PACKAGE__->has_many(hosts => 'QVD::DB::Result::Host', 'farm_id');

1;
