package QVD::DB::Result::Role;
use base qw/DBIx::Class/;
use strict;
use warnings;
use QVD::DB;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('roles');
__PACKAGE__->add_columns(id => { data_type => 'integer',
                                 is_auto_increment => 1 },
                          name => { data_type => 'varchar(64)' },
                          internal => { data_type => 'boolean' },
                          fixed => { data_type => 'boolean' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->has_many(admin_rels => 'QVD::DB::Result::Role_Administrator_Relation', 'role_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(acl_rels => 'QVD::DB::Result::ACL_Role_Relation', 'role_id');
__PACKAGE__->has_many(role_rels => 'QVD::DB::Result::Role_Role_Relation', 'inheritor_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(parent_role_rels => 'QVD::DB::Result::Role_Role_Relation', 'inherited_id', { cascade_delete => 0 } );


######### Log info

__PACKAGE__->has_one(creation_log_entry => 'QVD::DB::Result::Wat_Log', 
		     \&creation_log_entry_join_condition, {join_type => 'LEFT'});
__PACKAGE__->has_one(update_log_entry => 'QVD::DB::Result::Wat_Log', 
		     \&update_log_entry_join_condition, {join_type => 'LEFT'});

sub creation_log_entry_join_condition
{ 
    my $args = shift; 

    { "$args->{foreign_alias}.object_id" => { -ident => "$args->{self_alias}.id" },
      "$args->{foreign_alias}.qvd_object"     => { '=' => 'role' },
      "$args->{foreign_alias}.type_of_action"     => { '=' => 'create' } };
}

sub update_log_entry_join_condition
{ 
    my $args = shift; 

    my $sql = "IN (select id from wat_log where object_id=$args->{self_alias}.id and 
                   qvd_object='role' and type_of_action='update' order by id DESC LIMIT 1)";
    { "$args->{foreign_alias}.id"     => \$sql , };
}


##################

my $DB;

sub is_allowed_to
{
    my ($self,$acl_name) = @_;
    return $self->acls_info->{operative_acls}->{$acl_name};
}

sub has_inherited_acl
{
    my ($self,$acl_name) = @_;
    return exists $self->acls_info->{inherited_acls}->{$acl_name};
}

sub get_all_inherited_role_ids
{
    my $self = shift;
    return keys %{$self->acls_info->{all_inherited_role_ids}};
}

sub has_own_negative_acl
{
    my ($self,$acl_name) = @_;
    return exists $self->acls_info->{own_negative_acls}->{$acl_name};
}

sub has_own_positive_acl
{
    my ($self,$acl_name) = @_;
    return exists $self->acls_info->{own_positive_acls}->{$acl_name};
}

sub get_negative_own_acl_names
{
    my $self = shift;
    return keys %{$self->acls_info->{own_negative_acls}};
}

sub get_positive_own_acl_names
{
    my $self = shift;
    return keys %{$self->acls_info->{own_positive_acls}};
}

sub acls_info
{
    my $self = shift;
    $self->reload_acls_info unless defined $self->{acls_info};
    $self->{acls_info};
}

sub reload_acls_info
{
    my $self = shift;
    $DB //= QVD::DB->new();

    my @inherited_roles_ids = 
	 map { $_->inherited_id } $DB->resultset('Role_Role_Relation')->search(
	      {inheritor_id => $self->id})->all;

    my $rs = $DB->resultset('Operative_Acls_In_Role')->search(
	{},{bind => ['^$','^$']})->search({role_id => [$self->id,@inherited_roles_ids], operative => 1});

    my $all_inherited_roles_ids = { map { $_->inherited_id => 1 } 
				    $DB->resultset('All_Inherited_Roles_In_Role')->search(
					{inheritor_id => $self->id})->all };

    my @acls = $rs->all;    
    my $operative_acls = { map { $_->acl_name => 1 } grep { $_->role_id eq $self->id } @acls };
    my $inherited_acls = { map { $_->acl_name => 1 } grep { $_->role_id ne $self->id } @acls };
    my $own_positive_acls = { map { $_ => 1 } grep { not exists $inherited_acls->{$_} } keys %$operative_acls };
    my $own_negative_acls = { map { $_ => 1 } grep { not exists $operative_acls->{$_} } keys %$inherited_acls };

    $self->{acls_info} = 
    { all_inherited_role_ids => $all_inherited_roles_ids,operative_acls => $operative_acls, 
      inherited_acls => $inherited_acls,own_positive_acls => $own_positive_acls, 
      own_negative_acls => $own_negative_acls };

    return $self->{acls_info};
}

1;

