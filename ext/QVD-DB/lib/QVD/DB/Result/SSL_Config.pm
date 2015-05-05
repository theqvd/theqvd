package QVD::DB::Result::SSL_Config;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('ssl_configs');
__PACKAGE__->add_columns( key   => { data_type => 'varchar(64)'    },
			  value => { data_type => 'varchar(32768)' } );
__PACKAGE__->set_primary_key('key');



1;
