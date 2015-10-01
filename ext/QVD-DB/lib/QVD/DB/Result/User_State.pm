package QVD::DB::Result::User_State;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_states');

__PACKAGE__->add_columns(
	name => { data_type => 'varchar(20)' },
);

__PACKAGE__->set_primary_key('name');
__PACKAGE__->has_many(runtime => 'QVD::DB::Result::VM_Runtime', 'user_state');


1;
