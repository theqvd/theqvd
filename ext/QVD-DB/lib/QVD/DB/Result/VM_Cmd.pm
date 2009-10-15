package QVD::DB::Result::VM_cmd;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_cmds');
__PACKAGE__->add_columns(
	name => {
	    data_type => 'varchar(20)'
	}
	);
__PACKAGE__->set_primary_key('name');
__PACKAGE__->has_many(runtime => 'QVD::DB::Result::VM_Runtime', 'vm_cmd');

1;
