
package QVD::DB::Result::User;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('users');
__PACKAGE__->add_columns( blocked      => { data_type         => 'boolean' },
			  tenant_id      => { data_type         => 'integer' },
                          role_id        => { data_type         => 'integer' },
			  id         => { data_type         => 'integer',
					  is_auto_increment => 1 },
			  login      => { data_type         => 'varchar(64)' },
			  # FIXME: get passwords out of this table!
                          # FIXME: omg encrypt passwords!!
			  password   => { data_type         => 'varchar(64)',
					  is_nullable       => 1 } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['login']);
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });
__PACKAGE__->belongs_to(role => 'QVD::DB::Result::Role', 'role_id', { cascade_delete => 0 });
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM', 'user_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(properties => 'QVD::DB::Result::User_Property', \&custom_join_condition, 
		      {join_type => 'LEFT', order_by => {'-asc' => 'key'}});


sub get_has_many { qw(vms properties); }
sub get_has_one { qw(); }
sub get_belongs_to { qw(); }

sub custom_join_condition
{ 
    my $args = shift; 
    my $key = $ENV{QVD_ADMIN4_CUSTOM_JOIN_CONDITION};

    { "$args->{foreign_alias}.user_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.key"     => ($key ? { '=' => $key } : { -ident => "$args->{foreign_alias}.key"}) };
}


1;
