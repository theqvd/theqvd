package QVD::DB::Result::VM_Runtime;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_runtimes');
__PACKAGE__->add_columns(
	vm_id => {
	    data_type => 'integer'
	},
	host_id  => {
	    data_type => 'integer',
	    is_nullable => 1
	},
	user_ip  => {
	    data_type => 'varchar(15)',
            is_nullable => 1
        },
	vm_state => {
	    data_type => 'varchar(12)',
	    is_nullable => 1
	},
	vm_state_ts => {
	    data_type => 'timestamp',
	    is_nullable => 1
	},
	vm_cmd => {
	    data_type => 'varchar(12)',
	    is_nullable => 1
	},	
	vm_failures => {
	    data_type => 'integer',
	    is_nullable => 1
	},	
	x_state => {
	    data_type => 'varchar(12)',
            is_nullable => 1
        },
	x_state_ts => {
	    data_type => 'timestamp',
	    is_nullable => 1
	},
	x_cmd => {
	    data_type => 'varchar(12)',
	    is_nullable => 1
	},
	x_failures => {
	    data_type => 'integer',
	    is_nullable => 1
	},
	user_state => {
	    data_type => 'varchar(12)',
            is_nullable => 1
        },
	user_state_ts => {
	    data_type => 'timestamp',
	    is_nullable => 1
	},
	user_cmd => {
	    data_type => 'varchar(12)',
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

__PACKAGE__->has_one('x_state' => 'QVD::DB::Result::X_state');
__PACKAGE__->has_one('vm_state' => 'QVD::DB::Result::VM_state');
__PACKAGE__->has_one('user_state' => 'QVD::DB::Result::User_state');

__PACKAGE__->has_one('x_cmd' => 'QVD::DB::Result::X_cmd');
__PACKAGE__->has_one('vm_cmd' => 'QVD::DB::Result::VM_cmd');
__PACKAGE__->has_one('user_cmd' => 'QVD::DB::Result::User_cmd');

