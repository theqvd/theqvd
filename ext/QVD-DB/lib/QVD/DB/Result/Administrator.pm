package QVD::DB::Result::Administrator;
use base qw/DBIx::Class/;
use QVD::DB;
use QVD::API::AclsOverwriteList;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('administrators');
__PACKAGE__->add_columns(
	tenant_id   => { data_type => 'integer' },
	id          => { data_type => 'integer', is_auto_increment => 1 },
			  name      => { data_type         => 'varchar(64)' },
	description => { data_type => 'varchar(32768)', is_nullable => 1 },
			  # FIXME: get passwords out of this table!
                          # FIXME: omg encrypt passwords!!
	password    => { data_type => 'varchar(64)', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(name tenant_id)]);
__PACKAGE__->has_many(role_rels => 'QVD::DB::Result::Role_Administrator_Relation', 'administrator_id');
__PACKAGE__->has_many(views => 'QVD::DB::Result::Views_Setup_Attributes_Administrator', 'administrator_id');
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });
__PACKAGE__->has_one (wat_setups   => 'QVD::DB::Result::Wat_Setups_By_Administrator',  'administrator_id'); # Setups for the WAT client (language, block)

######### FOR LOG ##########################################################################################

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});

sub creation_log_entry_join_condition
{ 
    my $args = shift; 

    { "$args->{foreign_alias}.object_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.qvd_object"     => { '=' => 'administrator' },
      "$args->{foreign_alias}.type_of_action"     => { '=' => 'create' } };
}

sub update_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='administrator' and type_of_action='update' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}

sub login_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   action='login' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}

###########################################################################################################

my $DB;

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

    $DB //= QVD::DB->new();
 
    my $acls_overwrite_list = QVD::API::AclsOverwriteList->new(admin => $self,admin_id => $self->id);
    my $bind = [$acls_overwrite_list->acls_to_close_re,
		$acls_overwrite_list->acls_to_open_re,
		$acls_overwrite_list->acls_to_hide_re];

   my $rs = $DB->resultset('Operative_Acls_In_Administrator')->search({},{ bind => $bind })->search(
	{'me.admin_id' => $self->id, 'me.operative' => 1});

    my @operative_acls = map { $_->acl_name } $rs->all; 

    $self->{acls_cache} = \@operative_acls;
    @operative_acls;
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

sub re_is_allowed_to
{
    my ($self,@acl_res) = @_;
    
    return 1 unless @acl_res;

    for my $acl_re (@acl_res)
    {
	for my $acl_name ($self->acls)
	{
	    if ($acl_name =~ /$acl_re/) { return 1; }
	}
    }
    return 0;
}

# Tenants where the admin can operate

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
    use constant COMMON_TENANT_ID => -1;

    # Common tenant is always included in the admin scoop
    return [$self->tenant_id, COMMON_TENANT_ID]
	unless $self->is_superadmin;

    die "No tenants scoop assigned to superadmin"
	unless defined $self->{tenants_scoop};

    return $self->{tenants_scoop};
}

sub is_blocked
{
	my $self = shift;
	return $self->tenant->is_blocked;
}

1;

