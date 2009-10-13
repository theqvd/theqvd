package QVD::DB::Result::VM;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vms');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	name => {
	    data_type => 'varchar(64)'
	},
	user_id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	osi_id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	ip => {
	    data_type => 'varchar(15)'
	},
	storage  => {
	# Valor tomado de la variable PATH_MAX de /usr/src/linux-headers-2.6.28-15/include/linux/limits.h
	    data_type => 'varchar(4096)'
	}
	);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'user_id');
__PACKAGE__->belongs_to(osi => 'QVD::DB::Result::OSI', 'osi_id');
__PACKAGE__->has_one(vm_runtime => 'QVD::DB::Result::VM_Runtime', 'vm_id');

1;
