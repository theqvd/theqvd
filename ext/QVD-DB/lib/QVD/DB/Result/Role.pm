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

sub get_positive_acls_columns
{
    my $self = shift;
    [ map {{$_->get_columns}} @{$self->get_positive_acls}];
}

sub get_negative_acls_columns
{
    my $self = shift;
    [ map {{$_->get_columns}} @{$self->get_negative_acls}];
}

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

sub get_roles_columns
{
    my $self = shift;
    [map {{$_->get_columns }} @{$self->get_roles}];
}

sub get_nested_acls
{
    my ($self,%mods) = @_;

    my %acls = $mods{no_myself} ? () :
	map { $_->id => [$self->name] } @{$self->get_positive_acls};

    for my $role (@{$self->get_roles})
    {	
	my $nested_roles = $role->get_nested_acls;

	for my $nested_role_id (keys %$nested_roles)
	{
	    $acls{$nested_role_id} //= [];
	    push @{$acls{$nested_role_id}}, 
	    @{$nested_roles->{$nested_role_id}};
	}
    }

    delete $acls{$_->id}
    for @{$self->get_negative_acls};
    
    \%acls;
}

sub get_nested_roles
{
    my $self = shift;
    my @roles = ($self->name);

    push @roles, @{$_->get_nested_roles}
	for @{$self->get_roles};
    \@roles;
}

sub is_allowed_to
{
    my ($self,$acl_name) = @_;
    my @acls = $self->_get_inherited_acls;
    $_ eq $acl_name && return 1 for @acls;
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


sub overlaps_with_role
{
    my ($self,$other_role) = @_;

    for my $a_role (@{$self->get_nested_roles})
    {
	for my $b_role (@{$other_role->get_nested_roles})
	{
	    return 1 if $a_role eq $b_role;

	}
    }
    return 0;
}

sub is_able_to
{
    my ($self,$acl_name) = @_;

    my $nested_roles_structure = 
	$self->get_nested_roles_structure;
    my $acls =  $nested_roles_structure->{$self->name}->{acls};
    defined $acls->{$acl_name} ? return 1 : return 0;
} 


sub get_nested_roles_structure
{
    my $self = shift;
    my ($nested_str,$flat_str) = 
	$self->get_nested_roles_structure_rec;
    return $nested_str;
}

sub get_nested_roles_structure_rec
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
	return ($nested_str,$flat_str) if
	    defined $flat_str->{$nested_role->name};

	my ($ns,$fs) = 
	    $nested_role->get_nested_roles_structure_rec($nested_str->{$self->name}->{nested},
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
	$self->get_nested_roles_structure_rec;

    return keys %$flat_str if $mods{return_value} eq 'name';
    return values %$flat_str if $mods{return_value} eq 'object';
    return map { $_->id } values %$flat_str if $mods{return_value} eq 'id';
    return map { $_->get_columns } values %$flat_str if $mods{return_value} eq 'columns';
}

sub kk
{
    my $self = shift;

    my ($nested_str,$flat_str) = 
	$self->get_nested_roles_structure_rec;

    $self->_get_nested_roles_structure_rec($nested_str->{$self->name}->{nested});
}

sub _get_nested_roles_structure_rec
{
    my ($self,$old_structure,$new_structure) = @_;
    $old_structure //= {};
    $new_structure //= {};

    for my $node_name (keys %$old_structure)
    {
	my $node_id = $old_structure->{$node_name}->{matrix}->id;
	$new_structure->{$node_id} = { name => $node_name,
				       inherited => {}};
	$self->_get_nested_roles_structure_rec(
	    $old_structure->{$node_name}->{nested},
	    $new_structure->{$node_id}->{inherited});
    }
    $new_structure;
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
	$self->get_nested_roles_structure_rec;
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
	    $self->get_nested_roles_structure_rec;
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

sub get_own_acls
{
    my $self = shift;
    { positive => [$self->_get_own_acls],
      negative => [$self->_get_own_acls(positive => 0)]};
}

sub get_inherited_acls_kk
{
    my $self = shift;
    my $out = {};

    for my $acl ($self->_get_inherited_acls(return_value => 'object'))
    {
	my @roles = grep { $_->is_allowed_to($acl->name) } 
	$self->_get_inherited_roles(return_value => 'object');
	
	$out->{$acl->name}->{roles} = [map { $_->name } @roles]; 
    }
    $out;
} 

sub get_own_roles
{
    my $self = shift;
    [$self->_get_own_roles];
}

sub get_inherited_roles_kk
{
    my $self = shift;
    $self->kk;
} 


1;
