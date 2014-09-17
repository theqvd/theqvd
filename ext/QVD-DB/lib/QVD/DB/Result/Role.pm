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
__PACKAGE__->has_many(users => 'QVD::DB::Result::User', 'role_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(acls => 'QVD::DB::Result::ACL_Setting', 'role_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(roles => 'QVD::DB::Result::Inheritance_Roles_Rel', 'inheritor_id', { cascade_delete => 0 } );

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
    [map { $_->acl } $self->acls];
}

sub get_positive_acls
{
    my $self = shift;

    [map { $_->acl }
     grep { $_->positive }
     $self->acls];
}

sub get_negative_acls
{
    my $self = shift;

    [map { $_->acl }
     grep { not $_->positive }
     $self->acls];
}

sub get_roles
{
    my $self = shift;
    [map { $_->role } $self->roles];
}

sub get_nested_acls
{
    my ($self,%mods) = @_;

    my %acls = $mods{no_myself} ? () :
	map { $_->id => $_->name } @{$self->get_positive_acls};

    for my $role (@{$self->get_roles})
    {
	my %inherited_acls = %{$role->get_nested_acls};
	@acls{keys %inherited_acls} = values %inherited_acls;
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
    my ($self,$acl_id) = @_;
    my $acls = $self->get_nested_acls;

    defined $acls->{$acl_id} ? return 1 : return 0;
}

sub has_positive_acl
{
    my ($self,$acl_id) = @_;

    $_->id eq $acl_id && return $_
	for @{$self->get_positive_acls};
    return undef;

}

sub has_negative_acl
{
    my ($self,$acl_id) = @_;
    
    $_->id eq $acl_id && return $_
	for @{$self->get_negative_acls};
    return undef;
}

sub overlaps_with_role
{
    my ($self,$other_role) = @_;
    
    for my $a_role ($self->get_nested_roles)
    {
	for my $b_role ($other_role->get_nested_roles)
	{
	    return 0 if $a_role eq $b_role;

	}
    }
    retrun 1;
}

1;
