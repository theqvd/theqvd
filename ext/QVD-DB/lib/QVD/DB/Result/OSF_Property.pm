package QVD::DB::Result::OSF_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('osf_properties');
__PACKAGE__->add_columns( osf_id => { data_type => 'integer' },
                          key   => { data_type => 'varchar(1024)' },
                          value => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('osf_id', 'key');
__PACKAGE__->belongs_to(osf => 'QVD::DB::Result::OSF', 'osf_id');

sub get_has_many { qw(); }
sub get_has_one { qw(); }
sub get_belongs_to { qw(osf); }

1;
