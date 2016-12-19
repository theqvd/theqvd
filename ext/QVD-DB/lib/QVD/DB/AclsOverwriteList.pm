package QVD::DB::AclsOverwriteList;
use Moo;
use  5.010;
use strict;
use warnings;
use Moo;
use QVD::DB::Simple qw(db);
use QVD::Config;

# This class provides regular expresions that denote sets 
# of acls. The constructor takes an admin as a parameter and,
# according to that admin, is able to return the correspondant 
# regular expressions 

has 'admin_id', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute admin_id" if ref($name) &&  (not ref($name) eq 'ARRAY'); }, required => 1;
has 'admin', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute admin" unless ref($name) eq 'QVD::DB::Result::Administrator'; };

# Disable any Log acls temporary
#my $FOR_NON_SUPERADMINS_RE = 'tenant\..*';
my $FOR_NON_SUPERADMINS_RE = '^((tenant|log)\..+|.+\.log)$';
my $FOR_RECOVERY_ADMINS_RE = '(administrator|config|tenant|role)\..*';
#my $NOTHING_RE = '^$';
my $NOTHING_RE = '^(log\..+|.+\.log)$';

sub BUILD
{
    my $self = shift;
    
    return if $self->admin;
    my $DB = QVD::DB::Simple::db();
    $self->{admin} = $DB->resultset('Administrator')->search(
	{'me.id' => $self->admin_id})->first;
}


# Returns the regex that express a set of acls
# that must be allowed to the admin

sub acls_to_open_re
{
    my $self = shift;
    $self->admin->is_recovery_admin ?
	return $FOR_RECOVERY_ADMINS_RE:
	return $NOTHING_RE;
}


# Returns the regex that express a set of acls
# that must be forbidden for the admin

sub acls_to_close_re
{
    $NOTHING_RE;
}

# Returns the regex that express a set of acls
# that must be not only forbidden, but hidden for the admin

sub acls_to_hide_re
{
    my $self = shift;

    ($self->admin->is_superadmin && 
     cfg('wat.multitenant')) ? return $NOTHING_RE : 
     return $FOR_NON_SUPERADMINS_RE;
}

1;
