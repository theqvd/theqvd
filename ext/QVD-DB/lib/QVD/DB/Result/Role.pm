package QVD::DB::Result::Role;
use base qw/DBIx::Class/;
use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('roles');
__PACKAGE__->add_columns(id => { data_type => 'integer',
                                 is_auto_increment => 1 },
                          name => { data_type => 'varchar(64)' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->has_many(admin_rels => 'QVD::DB::Result::Role_Administrator_Relation', 'role_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(acl_rels => 'QVD::DB::Result::ACL_Role_Relation', 'role_id');
__PACKAGE__->has_many(role_rels => 'QVD::DB::Result::Role_Role_Relation', 'inheritor_id', { cascade_delete => 0 } );


# FUNCTIONS TO GET DIRECT INFO FROM
# THE ROLE OBJECT ITSELF

sub get_acls
{
    my ($self) = @_;
    [map { $_->acl } $self->acl_rels];
}

sub get_positive_acls
{
    my $self = shift;

    [map { $_->acl }
     grep { $_->positive }
     $self->acl_rels];
}

sub get_negative_acls
{
    my $self = shift;

    [map { $_->acl }
     grep { not $_->positive }
     $self->acl_rels];
}

sub get_roles
{
    my $self = shift;
    [map { $_->inherited } $self->role_rels];
}

sub has_negative_acl
{
    my ($self,$acl_name) = @_;
    my @acls = $self->_get_own_acls(positive => 0, 
				    return_value => 'object');
    $_->name eq $acl_name && return $_ for @acls;
}

sub has_positive_acl
{
    my ($self,$acl_name) = @_;
    my @acls = $self->_get_own_acls(return_value => 'object');
    $_->name eq $acl_name && return $_ for @acls;
}


sub is_allowed_to
{
    my ($self,$acl_name) = @_;
    my @acls = $self->_get_inherited_acls;
    $_ eq $acl_name && return 1 for @acls;
}

sub get_master_roles_structure
{
    my $self = shift;
    my ($nested_str,$flat_str) = 
	$self->build_master_roles_structure;
    return $nested_str;
}

sub build_master_roles_structure
{
    my $self = shift;
    my $nested_str = shift // {};
    my $flat_str = shift // {};

    $nested_str->{$self->name}->{matrix} = $self;
    $nested_str->{$self->name}->{nested} = {};
    $nested_str->{$self->name}->{acls} = { map { $_->name => $_ }
					   @{$self->get_positive_acls}};
    $flat_str->{$self->name} = $self;

    for my $nested_role (@{$self->get_roles})
    {
	my ($ns,$fs) = 
	    $nested_role->build_master_roles_structure($nested_str->{$self->name}->{nested},
						       $flat_str);

	@{$nested_str->{$self->name}->{acls}}{keys %{$ns->{$nested_role->name}->{acls}}} = 
	    values %{$ns->{$nested_role->name}->{acls}}; 
	defined $nested_str->{$self->name}->{acls}->{$_->name} &&
	    delete $nested_str->{$self->name}->{acls}->{$_->name}
	for @{$self->get_negative_acls};
    }

    return ($nested_str,$flat_str);
}

sub _get_own_roles
{
    my ($self,%mods) = @_;

    $mods{return_value} //= 'name';

    return map { $_->inherited->name } $self->role_rels if $mods{return_value} eq 'name';
    return map { $_->inherited } $self->role_rels if $mods{return_value} eq 'object';
    return map { $_->inherited->id } $self->role_rels if $mods{return_value} eq 'id';
    return map { $_->inherited->get_columns } $self->role_rels if $mods{return_value} eq 'columns';
}

sub _get_inherited_roles
{
    my ($self,%mods) = @_;

    $mods{return_value} //= 'name';

    my ($nested_str,$flat_str) = 
	$self->build_master_roles_structure;

    return keys %$flat_str if $mods{return_value} eq 'name';
    return values %$flat_str if $mods{return_value} eq 'object';
    return map { $_->id } values %$flat_str if $mods{return_value} eq 'id';
    return map { $_->get_columns } values %$flat_str if $mods{return_value} eq 'columns';
}

sub _get_own_acls
{
    my ($self,%mods) = @_;

    $mods{positive} //= 1;
    $mods{return_value} //= 'name';

    my @acls = $mods{positive} ?
	map {$_->acl} grep { $_->positive } $self->acl_rels :
	map {$_->acl} grep { not $_->positive } $self->acl_rels ;

    return map { $_->name } @acls if $mods{return_value} eq 'name';
    return map { $_->id } @acls if $mods{return_value} eq 'id';
    return map { $_->get_columns } @acls if $mods{return_value} eq 'columns';
    return @acls if $mods{return_value} eq 'object';
}


sub _get_inherited_acls
{
    my ($self,%mods) = @_;

    $mods{return_value} //= 'name';

    my ($nested_str,$flat_str) = 
	$self->build_master_roles_structure;

    my $acls =  $nested_str->{$self->name}->{acls};

    return keys %$acls if $mods{return_value} eq 'name';
    return values %$acls if $mods{return_value} eq 'object';
    return map { $_->id } values %$acls if $mods{return_value} eq 'id';
    return map { $_->get_columns } values %$acls if $mods{return_value} eq 'columns';
}

sub _get_only_inherited_acls
{
    my ($self,%mods) = @_;

    $mods{return_value} //= 'name';
    my %acls;

    for my $role ($self->_get_own_acls(return_value => 'object'))
    {
	my ($nested_str,$flat_str) = 
	    $self->build_master_roles_structure;
	@acls{keys %{$nested_str->{$self->name}->{acls}}} =
	    values %{$nested_str->{$self->name}->{acls}};
    }

    return keys %acls if $mods{return_value} eq 'name';
    return values %acls if $mods{return_value} eq 'object';
    return map { $_->id } values %acls if $mods{return_value} eq 'id';
    return map { $_->get_columns } values %acls if $mods{return_value} eq 'columns';
}



sub assign_acl
{
    my ($self,$acl_id,$positive) = @_;

    $self->create_related('acl_rels', { acl_id => $acl_id,
			            positive => $positive });
}

sub unassign_acls
{
    my ($self,$acl_ids) = @_;

    $_->delete for 
	$self->search_related('acl_rels', { acl_id => $acl_ids })->all;
}

sub assign_role
{
    my ($self,$role_id) = @_;

    $self->create_related('role_rels', { inherited_id => $role_id });
}

sub unassign_roles
{
    my ($self,$role_ids) = @_;

    my $rs = $self->search_related('role_rels', { inherited_id => $role_ids });
    $_->delete for $rs->all;
}


#################

sub get_acls_info
{
    my $self = shift;
    my $acls_info = {};

    for my $acl ($self->_get_inherited_acls(return_value => 'object'))
    {
	my $acl_info = {};
	$acl_info->{name} = $acl->name;
	$acl_info->{roles} = {};

	$acl_info->{roles}->{$self->id} = $self->name
	    if $self->has_positive_acl($acl->name);

	for my $role (@{$self->get_roles})
	{
	    $acl_info->{roles}->{$role->id} = $role->name
		if $role->is_allowed_to($acl->name);
	}
	$acls_info->{$acl->id} = $acl_info;
    }
    $acls_info;
}

sub get_roles_info
{
    my $self = shift;
    
    my $out = {};
    $out->{$_->id} = $_->name for @{$self->get_roles};
    $out; 
}


sub get_roles_with_its_acls_info
{
    my $self = shift;
    
    my $out = {};

    for (@{$self->get_roles})
    {
	$out->{$_->id}->{name} = $_->name;
	$out->{$_->id}->{acls} = [$_->_get_inherited_acls];
    }

    $out; 
}

sub get_positive_and_negative_acls_info
{
    my $self = shift;
    my $out = { positive => {}, negative => {}};
    $out->{positive}->{$_->id} = $_->name for @{$self->get_positive_acls};
    $out->{negative}->{$_->id} = $_->name for @{$self->get_negative_acls};
    $out; 
}

sub get_positive_acls_info
{
    my $self = shift;
    my $out = {};
    $out->{$_->id} = $_->name for @{$self->get_positive_acls};
    $out; 
}


1;
