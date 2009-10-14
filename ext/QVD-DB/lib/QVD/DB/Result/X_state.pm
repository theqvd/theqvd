package QVD::DB::Result::X_state;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('x_state');
__PACKAGE__->add_columns(
	name => {
	    data_type => 'varchar(12)'
	}
	);
__PACKAGE__->set_primary_key('name');
__PACKAGE__->has_many(runtime => 'QVD::DB::Result::VM_Runtime', 'x_state');

1;
