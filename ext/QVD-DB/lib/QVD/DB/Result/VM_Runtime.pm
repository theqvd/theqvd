package QVD::DB::Result::VM_Runtime;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_runtime');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	qw/vm_id state host_id state_x state_user user_ip real_user_id/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id');
__PACKAGE__->belongs_to(vm => 'QVD::DB::Result::VM', 'vm_id');

1;
