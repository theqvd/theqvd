package QVD::DB::Result::User;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('users');
__PACKAGE__->add_columns( id         => { data_type         => 'integer',
					  is_auto_increment => 1 },
			  login      => { data_type         => 'varchar(64)' },
			  # FIXME: get passwords out of this table!
			  password   => { data_type         => 'varchar(64)' } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['login']);
__PACKAGE__->has_one(extra => 'QVD::DB::Result::User_Extra', 'id');
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'user_id');
__PACKAGE__->has_many(properties => 'QVD::DB::Result::User_Property',
		      'user_id', {join_type => 'INNER'});

1;
