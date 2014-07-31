
package QVD::DB::Result::User;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('users');
__PACKAGE__->add_columns( blocked      => { data_type         => 'boolean' },
			  id         => { data_type         => 'integer',
					  is_auto_increment => 1 },
			  login      => { data_type         => 'varchar(64)' },
			  # FIXME: get passwords out of this table!
                          # FIXME: omg encrypt passwords!!
			  password   => { data_type         => 'varchar(64)',
					  is_nullable       => 1 } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['login']);
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'user_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(properties => 'QVD::DB::Result::User_Property',
		      'user_id', {join_type => 'INNER'});


sub get_has_many { qw(vms properties); }
sub get_has_one { qw(); }
sub get_belongs_to { qw(); }

1;
