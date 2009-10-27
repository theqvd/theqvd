package QVD::DB::Result::Host;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('hosts');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	name => {
	    data_type => 'varchar(127)',
	},
	address => {
	    data_type => 'varchar(127)',
	}
	);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(runtime => 'QVD::DB::Result::VM_Runtime', 'host_id');

1;
