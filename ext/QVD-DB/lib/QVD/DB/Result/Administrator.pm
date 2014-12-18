package QVD::DB::Result::Administrator;
use base qw/DBIx::Class/;
use QVD::Admin4::AclsOverwriteList;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('administrators');
__PACKAGE__->add_columns( tenant_id  => { data_type         => 'integer' },
                          id         => { data_type         => 'integer',
					  is_auto_increment => 1 },
			  name      => { data_type         => 'varchar(64)' },
			  language      => { data_type         => 'varchar(64)' },
			  block      => { data_type         => 'integer' },
			  # FIXME: get passwords out of this table!
                          # FIXME: omg encrypt passwords!!
			  password   => { data_type         => 'varchar(64)',
					  is_nullable       => 1 } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(name tenant_id)]);
__PACKAGE__->has_many(role_rels => 'QVD::DB::Result::Role_Administrator_Relation', 'administrator_id');
__PACKAGE__->has_many(views => 'QVD::DB::Result::Administrator_Views_Setup', 'administrator_id');
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });

sub roles
{
    my $self = shift;
    my @roles = map { $_->role } $self->role_rels;
}

sub acls
{
    my $self = shift;
    return @{$self->{acls_cache}} if 
	defined $self->{acls_cache};
    my $acls = {};

    for my $role ($self->roles)
    {
	$acls->{$_} = 1 for $role->get_all_acl_names;
    }

    $self->adjust_acls_with_overwrite_lists($acls);

    $self->{acls_cache} = [keys %$acls];

    keys %$acls;
}

sub adjust_acls_with_overwrite_lists
{
    my ($self,$acls) = @_;
    my @lists_names;
    push @lists_names,'tenant_admin_acls_restrictions'
	unless $self->is_superadmin;

    push @lists_names,'recovery_admin_acls'
	if $self->is_recovery_admin;

    my @lists; push @lists,QVD::Admin4::AclsOverwriteList->new(name => $_)
	for @lists_names;

    for my $list (@lists)
    {
	$acls->{$_} = 1 for $list->get_positive_acls_list;
    }

    for my $list (@lists)
    {
       delete $acls->{$_} for $list->get_negative_acls_list;
    }
}

sub is_recovery_admin
{
    my $self = shift;
    $self->id eq 0 ? return 1 : return 0;
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

sub is_allowed_to
{
    my ($self,@acl_names) = @_;
    my %acls = map { $_ => 1 } $self->acls;

    for my $acl_name (@acl_names)
    {
	return 0 unless defined $acls{$acl_name};
    }

    return 1;
}


sub re_is_allowed_to
{
    my ($self,@acl_res) = @_;

    for my $acl_re (@acl_res)
    {
	my $flag = 0;
	for my $acl_name ($self->acls)
	{
	    if ($acl_name =~ /$acl_re/) { $flag = 1; last; }
	}
	return 0 unless $flag;
    }
    return 1;
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

sub required_language
{
    my $self = shift;

    $self->language eq 'default' ? 
	return $self->tenant->language : 
	return $self->language; 
}

sub tenant_language
{
    my $self = shift;
    $self->tenant->language;
}

sub tenant_block
{
    my $self = shift;
    $self->tenant->block;
}

1;

