package QVD::DB::Result::Host_State;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('host_states');
__PACKAGE__->add_columns( name => { data_type => 'varchar(20)' } );
__PACKAGE__->set_primary_key('name');
__PACKAGE__->has_many(runtime => 'QVD::DB::Result::Host_Runtime', 'state');



1;
