package QVD::DB::Result::VM_Property;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_properties');
__PACKAGE__->add_columns( vm_id => { data_type => 'integer' },
                          key   => { data_type => 'varchar(1024)' },
                          value => { data_type => 'varchar(32768)' } );

__PACKAGE__->set_primary_key('vm_id', 'key');
__PACKAGE__->belongs_to(vm => 'QVD::DB::Result::VM', 'vm_id');

1;
