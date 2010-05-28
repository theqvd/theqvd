package QVD::DB::Result::OSI_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('osi_properties');
__PACKAGE__->add_columns( osi_id => { data_type => 'integer' },
                          key   => { data_type => 'varchar(1024)' },
                          value => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('osi_id', 'key');
__PACKAGE__->belongs_to(osi => 'QVD::DB::Result::OSI', 'osi_id');

1;
