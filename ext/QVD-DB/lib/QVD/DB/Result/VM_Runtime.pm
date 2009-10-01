package QVD::DB::Result::VM_Runtime;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_runtime');
__PACKAGE__->add_columns(
	vm_id => {
	},
	state => {
	    is_nullable => 1
	},
	host_id  => {
	    is_nullable => 1
	},
	state_x => {
            is_nullable => 1
        },
	state_user  => {
            is_nullable => 1
        },
	user_ip  => {
            is_nullable => 1
        },
	real_user_id => {
	    is_nullable => 1
	});
__PACKAGE__->set_primary_key('vm_id');
__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id');
#__PACKAGE__->has_one(vm => 'QVD::DB::Result::VM', 'vm_id');
__PACKAGE__->has_one('vm_id' => 'QVD::DB::Result::VM');

