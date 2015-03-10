package QVD::DB::Result::Config;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('configs');
__PACKAGE__->add_columns( tenant_id => { data_type => 'integer' },
                          key => { data_type => 'varchar(64)' },
                          value => { data_type => 'varchar(4096)' } );
__PACKAGE__->set_primary_key(qw(tenant_id key));
__PACKAGE__->add_unique_constraint([qw(key)]);
1;
