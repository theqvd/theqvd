package QVD::DB::Result::User_Extra;
use base qw/DBIx::Class/;

# FIXME: convert this table to a key/value form in order to make the slots customizable.
# ... or remove it completely and just use the User properties

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_extras');
__PACKAGE__->add_columns( id         => { data_type         => 'integer',
					  # FIXME: do we really need autoincrement for this?
					  # it should be set in accordance to the table User.
					  is_auto_increment => 1 },
			  department => { data_type         => 'varchar(64)',
					  is_nullable       => 1 },
			  telephone  => { data_type         => 'varchar(64)',
					 is_nullable        => 1 },
			  email      => { data_type         => 'varchar(64)',
					  is_nullable       => 1 } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User', 'id');

1;
