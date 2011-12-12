package QVD::DB::Result::VM_Counter;

use strict;
use warnings;

use parent qw(DBIx::Class);

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_counters');
__PACKAGE__->add_columns(
    vm_id         => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
    run_attempts  => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
    run_ok        => { data_type   => 'integer', is_numeric => 1, default_value => 0 },
);
__PACKAGE__->set_primary_key('vm_id');
__PACKAGE__->belongs_to(vm => 'QVD::DB::Result::VM', 'vm_id');

1;

#vms up
#vms blocked
