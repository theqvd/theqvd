package QVD::DB::Result::VM;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm');
__PACKAGE__->add_columns(
	id => {
	    data_type => 'integer',
	    is_auto_increment => 1
	},
	qw/name farm_id user_id osi_id ip storage/ );
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'user_id');
__PACKAGE__->belongs_to(osi => 'QVD::DB::Result::OSI', 'osi_id');
__PACKAGE__->has_one(vm_runtime => 'QVD::DB::Result::VM_Runtime', 'vm_id');

1;
