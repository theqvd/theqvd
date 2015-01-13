package QVD::Admin4::AclsOverwriteList;
use Moo;
use  5.010;
use strict;
use warnings;
use Moo;
use QVD::DB;
use QVD::Config;

has 'admin_id', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute admin_id" if ref($name) || (not defined $name) || $name eq ''; }, required => 1;
has 'admin', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute admin" unless ref($name) eq 'QVD::DB::Result::Administrator'; };

my $FOR_NON_SUPERADMINS_RE = 'tenant\..*';
my $FOR_RECOVERY_ADMINS_RE = '(administrator|config|tenant|role)\..*';
my $NOTHING_RE = '^$';

sub BUILD
{
    my $self = shift;
    
    return if $self->admin;
    my $DB = QVD::DB->new();
    $self->{admin} = $DB->resultset('Administrator')->search(
	{'me.id' => $self->admin_id})->first;
}


sub acls_to_open_re
{
    my $self = shift;
    $self->admin->is_recovery_admin ?
	return $FOR_RECOVERY_ADMINS_RE:
	return $NOTHING_RE;
}

sub acls_to_close_re
{
    $NOTHING_RE;
}

sub acls_to_hide_re
{
    my $self = shift;

    ($self->admin->is_superadmin && 
     cfg('wat.multitenant')) ? return $NOTHING_RE : 
     return $FOR_NON_SUPERADMINS_RE;
}

1;
