package QVD::Admin4::AclsOverwriteList;
use Moo;
use  5.010;
use strict;
use warnings;
use Moo;

has 'name', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute name" if ref($name) || (not defined $name) || $name eq ''; }, required => 1;


# where name ~ 'tenant\..*' FIX ME ADD DB ACCESS
my $TENANT_ADMIN_RESTRICTIONS =
{
    'tenant.see.block' => 0,
    'tenant.update.block' => 0,
    'tenant.create.'  => 0,
    'tenant.delete-massive.' => 0,
    'tenant.see-main.' => 0,
    'tenant.see.id' => 0,
    'tenant.delete.' => 0,
    'tenant.filter.name' => 0,
    'tenant.see.language' => 0,
    'tenant.update.language' => 0,
    'tenant.update.name' => 0,
    'tenant.see-details.' => 0,
};

# where name ~ '(administrator|config|tenant|role)\..*' FIX ME ADD DB ACCESS
my $RECOVERY_ADMIN_ACLS =
{
    'role.see.acl-list' => 1,
    'role.see.acl-list-roles' => 1,
    'role.see.id' => 1,
    'role.see.inherited-roles' => 1,
    'role.create.' => 1,
    'tenant.create.'  => 1,
    'role.delete.'  => 1,
    'role.delete-massive.'  => 1,
    'tenant.delete-massive.'  => 1,
    'role.see-details.'  => 1,
    'role.see-main.'  => 1,
    'tenant.see-main.'  => 1,
    'tenant.see.id'  => 1,
    'administrator.see.acl-list'  => 1,
    'administrator.see.roles'  => 1,
    'administrator.see.acl-list-roles'  => 1,
    'administrator.see.id'  => 1,
    'administrator.create.'  => 1,
    'administrator.delete.'  => 1,
    'administrator.delete-massive.'  => 1,
    'administrator.see-details.'  => 1,
    'role.update.name'  => 1,
    'role.update.assign-acl'  => 1,
    'role.update.assign-role'  => 1,
    'tenant.delete.'  => 1,
    'administrator.see-main.' => 1,
    'administrator.update.password'  => 1,
    'administrator.update.assign-role'  => 1,
    'administrator.filter.name'  => 1,
    'role.filter.name'  => 1,
    'tenant.filter.name'  => 1,
    'tenant.see.language'  => 1,
    'tenant.update.language'  => 1,
    'tenant.update.name'  => 1,
    'tenant.see-details.'  => 1,
    'tenant.see.block' => 1,
    'tenant.update.block' => 1,
    'config.wat.'  => 1,
    'config.qvd.'  => 1,
};

my $ACLS_OVERWRITE_LISTS =
{
    tenant_admin_acls_restrictions => $TENANT_ADMIN_RESTRICTIONS,
    recovery_admin_acls => $RECOVERY_ADMIN_ACLS,
};

sub get_positive_acls_list
{
    my $self = shift;
    my $list = $ACLS_OVERWRITE_LISTS->{$self->name} // 
	return ();
    my @positive_acls = grep { $list->{$_} } keys %$list;
}

sub get_negative_acls_list
{
    my $self = shift;
    my $list = $ACLS_OVERWRITE_LISTS->{$self->name} // 
	return ();
    my @negative_acls = grep { not $list->{$_} } keys %$list;
}

1;
