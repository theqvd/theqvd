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
__PACKAGE__->has_many(role_rels => 'QVD::DB::Result::Role_Administrator_Relation', 'administrator_id');
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });

sub roles
{
    my $self = shift;
    my @roles = map { $_->role } $self->role_rels;
}

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

sub get_roles_info
{
    my $self = shift;
    $out = {};

    for my $role ($self->roles)
    {
	$out->{$role->id} = { name => $role->name, inherited => $role->kk };
    }
    $out;
}

sub get_acls_info
{
    my $self = shift;
    my %acls;

    for my $role ($self->roles)
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

    for my $role ($self->roles)
    {
	$role->is_allowed_to($acl_name) && return 1;
    }
    return 0;
}

sub set_tenants_scoop
{
    my $self = shift;
    my $tenants_ids = shift;
    $self->{tenants_scoop} = $tenants_ids;
}

sub tenants_scoop
{
    my $self = shift;
    my $tenants_ids = shift;
    return [$self->tenant_id]
	unless $self->is_superadmin;

    die "No tenants scoop assigned to superadmin"
	unless defined $self->{tenants_scoop};

    return $self->{tenants_scoop};
}

1;

