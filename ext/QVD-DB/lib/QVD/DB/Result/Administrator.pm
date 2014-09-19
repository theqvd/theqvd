package QVD::DB::Result::Administrator;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('administrators');
__PACKAGE__->add_columns( tenant_id  => { data_type         => 'integer' },
                          id         => { data_type         => 'integer',
					  is_auto_increment => 1 },
			  name      => { data_type         => 'varchar(64)' },
			  # FIXME: get passwords out of this table!
                          # FIXME: omg encrypt passwords!!
			  password   => { data_type         => 'varchar(64)',
					  is_nullable       => 1 } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(name tenant_id)]);
__PACKAGE__->has_many(roles => 'QVD::DB::Result::Role_Assignment_Relation', 'administrator_id');
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });

sub is_superadmin
{
    my $self = shift;
    $self->tenant_id eq 0 ? return 1 : return 0;
}

sub tenant_name
{
    my $self = shift;
    $self->tenant->name;
}

sub get_roles
{
    my $self = shift;
    $out = {};

    for my $role (map { $_->role } $self->roles)
    {
	$out->{$role->id} = { name => $role->name, inherited => $role->kk };
    }
    $out;
}

sub get_acls
{
    my $self = shift;
    my %acls;

    for my $role (map { $_->role } $self->roles)
    {
	for my $acl ($role->_get_inherited_acls(return_value => 'object'))
	{
	    my @roles = grep { $_->is_allowed_to($acl->name) } 
	    $role->_get_inherited_roles(return_value => 'object');
	    $acls{$acl->name}->{roles} //= []; 
	    my %roles = map { $_ => 1 } @{$acls{$acl->name}->{roles}},
	    map { $_->name => 1 } @roles;
	    $acls{$acl->name}->{roles} = [keys %roles];
	}
    }
    \%acls;
}

sub is_allowed_to
{
    my ($self,$acl_name) = @_;

    for my $role (map {$_->role} $self->roles)
    {
	$role->is_allowed_to($acl_name) && return 1;
    }
    return 0;
}

1;

