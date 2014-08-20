package QVD::DB::Result::Config_Field;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('config_fields');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer'
	},
	name => {
	    data_type => 'varchar(64)'
	},
	qvd_obj => {
	    data_type => 'varchar(64)'
	},
	argument => {
	    data_type => 'boolean',
	    is_nullable => 1
	},
	get_list => {
	    data_type => 'boolean',
	    is_nullable => 1
	},
	get_details => {
	    data_type => 'boolean',
	    is_nullable => 1
	},
	filter_list => {
	    data_type => 'boolean',
	    is_nullable => 1
	},
	filter_details => {
	    data_type => 'boolean',
	    is_nullable => 1
	}
	);
__PACKAGE__->set_primary_key('id');

1;
