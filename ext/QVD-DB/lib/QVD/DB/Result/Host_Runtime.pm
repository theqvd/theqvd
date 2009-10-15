package QVD::DB::Result::Host_Runtime;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('host_runtimes');
__PACKAGE__->add_columns(
	host_id => {
	    data_type => 'integer'
	},
	hkd  => {
	    data_type => 'integer',
	    is_nullable => 1
	},
	hkd_ok_ts => {
	    data_type => 'timestamp',
	    is_nullable => 1
	}
	);
	
__PACKAGE__->set_primary_key('host_id');

__PACKAGE__->belongs_to('rel_host_id' => 'QVD::DB::Result::Host', 'host_id');

