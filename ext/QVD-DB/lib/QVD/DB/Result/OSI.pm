package QVD::DB::Result::OSI;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('osi');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	qw/name disk_image /);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'osi_id');

1;
