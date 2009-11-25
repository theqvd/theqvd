package QVD::DB::Result::OSI;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('osis');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	name => {
	    data_type => 'varchar(64)'
	},
	memory => {
	    data_type => 'integer',
	},
	user_storage_size => {
	    data_type => 'integer',
	    is_nullable => 1,
	},
	use_overlay => {
	    data_type => 'boolean'
	},
	disk_image => {
	# Valor tomado de la variable PATH_MAX de /usr/src/linux-headers-2.6.28-15/include/linux/limits.h
	    data_type => 'varchar(4096)'
	}
	);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'osi_id');

1;
