package QVD::DB::Result::User_Cmd;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_cmds');
__PACKAGE__->add_columns(
	name => {
	    data_type => 'varchar(20)'
	}
	);
__PACKAGE__->set_primary_key('name');
__PACKAGE__->has_many(runtime => 'QVD::DB::Result::VM_Runtime', 'user_cmd');

1;
