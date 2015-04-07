package QVD::DB::Result::Administrator;
use base qw/DBIx::Class/;
use QVD::DB;
use QVD::Admin4::AclsOverwriteList;

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
__PACKAGE__->has_many(views => 'QVD::DB::Result::Administrator_Views_Setup', 'administrator_id');
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });
__PACKAGE__->has_one (wat_setups   => 'QVD::DB::Result::Wat_Setups_By_Administrator',  'administrator_id');

######### Log info

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Wat_Log', 
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

##################

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
 
    my $acls_overwrite_list = QVD::Admin4::AclsOverwriteList->new(admin => $self,admin_id => $self->id);
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

1;

