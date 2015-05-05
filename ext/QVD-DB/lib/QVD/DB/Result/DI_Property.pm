package QVD::DB::Result::DI_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('di_properties');
__PACKAGE__->add_columns( di_id => { data_type => 'integer' },
                          key   => { data_type => 'varchar(1024)' },
                          value => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('di_id', 'key');
__PACKAGE__->belongs_to(di => 'QVD::DB::Result::DI', 'di_id');

1;
