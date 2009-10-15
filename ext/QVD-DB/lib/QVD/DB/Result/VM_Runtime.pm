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
	real_user_id => {
	    data_type => 'integer',
	    is_nullable => 1
	},
	vm_state => {
	    data_type => 'varchar(12)',
	    is_nullable => 1,
	    is_enum => 1,
            extra => {
                list => [qw/stopped starting running stopping zombie failed/]
            }
	},
	vm_state_ts => {
	    data_type => 'timestamp',
	    is_nullable => 1
	},
	vm_cmd => {
	    data_type => 'varchar(12)',
	    is_nullable => 1,
	    is_enum => 1,
            extra => {
                list => [qw/start stop/]
            }
	},	
	vm_failures => {
	    data_type => 'integer',
	    is_nullable => 1
	},	
	x_state => {
	    data_type => 'varchar(12)',
            is_nullable => 1,
	    extra => {
                list => [qw/stopped disconnected connecting connected/]
            }
        },
	x_state_ts => {
	    data_type => 'timestamp',
	    is_nullable => 1
	},
	x_cmd => {
	    data_type => 'varchar(12)',
	    is_nullable => 1,
	    extra => {
                list => [qw/start stop/]
            }
	},
	x_failures => {
	    data_type => 'integer',
	    is_nullable => 1
	},
	user_state => {
	    data_type => 'varchar(12)',
            is_nullable => 1,
	    extra => {
                list => [qw/disconnected connecting connected disconnecting aborting/]
            }
        },
	user_state_ts => {
	    data_type => 'timestamp',
	    is_nullable => 1
	},
	user_cmd => {
	    data_type => 'varchar(12)',
	    is_nullable => 1,
	    extra => {
                list => [qw/abort/]
            }
	},
	vma_ok_ts => {
	    data_type => 'timestamp',
	    is_nullable => 1
	},
	l7r_host  => {
	    data_type => 'varchar(15)',
            is_nullable => 1
        },
	l7r_pid => {
	    data_type => 'integer',
	    is_nullable => 1
	}
	);
	
__PACKAGE__->set_primary_key('vm_id');

__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id');
__PACKAGE__->belongs_to('rel_vm_id' => 'QVD::DB::Result::VM', 'vm_id');

__PACKAGE__->belongs_to('rel_x_state' => 'QVD::DB::Result::X_State', 'x_state');
__PACKAGE__->belongs_to('rel_vm_state' => 'QVD::DB::Result::VM_State', 'vm_state');
__PACKAGE__->belongs_to('rel_user_state' => 'QVD::DB::Result::User_State', 'user_state');

__PACKAGE__->belongs_to('rel_x_cmd' => 'QVD::DB::Result::X_Cmd', 'x_cmd');
__PACKAGE__->belongs_to('rel_vm_cmd' => 'QVD::DB::Result::VM_Cmd', 'vm_cmd');
__PACKAGE__->belongs_to('rel_user_cmd' => 'QVD::DB::Result::User_Cmd', 'user_cmd');

