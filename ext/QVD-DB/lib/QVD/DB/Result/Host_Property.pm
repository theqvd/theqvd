package QVD::DB::Result::Host_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('host_properties');
__PACKAGE__->add_columns( host_id => { data_type => 'integer' },
                          key     => { data_type => 'varchar(1024)' },
                          value   => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('host_id', 'key');
__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id');


sub get_has_many { qw(); }
sub get_has_one { qw(); }
sub get_belongs_to { qw(host); }

1;
