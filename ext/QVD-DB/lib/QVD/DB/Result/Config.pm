package QVD::DB::Result::Config;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('configs');
__PACKAGE__->add_columns(
	key => {
	    data_type => 'varchar(64)'
	},
	value => {
	    data_type => 'varchar(4096)'
	}
	);
__PACKAGE__->set_primary_key('key');

sub get_has_many { qw(); }
sub get_has_one { qw(); }
sub get_belongs_to { qw(); }

1;
