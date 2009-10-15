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
	    is_nullable => 1,
	    is_enum => 1,
            extra => {
                list => [qw/stopped assigned starting running stopping zombie failed/]
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
	real_user_id => {
	    data_type => 'integer',
	    is_nullable => 1
	});
	
__PACKAGE__->set_primary_key('vm_id');
__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id');
__PACKAGE__->has_one('vm_id' => 'QVD::DB::Result::VM');

__PACKAGE__->belongs_to('x_state' => 'QVD::DB::Result::X_state');
__PACKAGE__->belongs_to('vm_state' => 'QVD::DB::Result::VM_state');
__PACKAGE__->belongs_to('user_state' => 'QVD::DB::Result::User_state');

__PACKAGE__->belongs_to('x_cmd' => 'QVD::DB::Result::X_cmd');
__PACKAGE__->belongs_to('vm_cmd' => 'QVD::DB::Result::VM_cmd');
__PACKAGE__->belongs_to('user_cmd' => 'QVD::DB::Result::User_cmd');

