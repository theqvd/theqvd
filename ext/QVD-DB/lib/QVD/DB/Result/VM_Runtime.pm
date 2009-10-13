package QVD::DB::Result::VM_Runtime;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_runtimes');
__PACKAGE__->add_columns(
	vm_id => {
	    data_type => 'integer'
	},
	state => {
	    data_type => 'varchar(16)',
	    is_nullable => 1
	},
	host_id  => {
	    data_type => 'integer',
	    is_nullable => 1
	},
	state_x => {
	    data_type => 'varchar(16)',
            is_nullable => 1
        },
	state_user  => {
	    data_type => 'varchar(16)',
            is_nullable => 1
        },
	user_ip  => {
	    data_type => 'varchar(15)',
            is_nullable => 1
        },
	real_user_id => {
	    data_type => 'integer',
	    is_nullable => 1
	});
__PACKAGE__->set_primary_key('vm_id');
__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id');
#__PACKAGE__->has_one(vm => 'QVD::DB::Result::VM', 'vm_id');
__PACKAGE__->has_one('vm_id' => 'QVD::DB::Result::VM');

