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
__PACKAGE__->has_many(views => 'QVD::DB::Result::Administrator_View', 'administrator_id');
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });

sub roles
{
    my $self = shift;
    my @roles = map { $_->role } $self->role_rels;
}

sub acls
{
    my $self = shift;
    return $self->{acls_cache} if 
	defined $self->{acls_cache};
    my %acls;

    for my $role ($self->roles)
    {
	$acls{$_} = 1 for $role->get_acls_fast;
    }
    $self->{acls_cache} = [keys %acls];

    keys %acls;
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

    my $out = {};
    $out->{$_->id} = $_->name for $self->roles;
    $out; 
}

sub get_acls_info
{
    my $self = shift;
    my $acls_info;

    for my $role ($self->roles)
    {
	my $role_acls_info = $role->get_acls_info;
	for my $acl_id (keys %$role_acls_info)
	{
	    my $acl_info = $role_acls_info->{$acl_id}; 
	    $acls_info->{$acl_id}->{name} = $acl_info->{name};   
	    $acls_info->{$acl_id}->{roles}->{$role->id} = $role->name;
	}
    }
    $acls_info;
}

sub is_allowed_to
{
    my ($self,$acl_name) = @_;
    my %acls = map { $_ => 1 } $self->acls;
    defined $acls{$acl_name} ? return 1 : return 0;
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

