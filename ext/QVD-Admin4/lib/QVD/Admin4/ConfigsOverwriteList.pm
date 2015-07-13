package QVD::Admin4::ConfigsOverwriteList;
use Moo;
use  5.010;
use strict;
use warnings;
use Moo;
use QVD::DB::Simple qw(db);
use QVD::Config;

# This class provides regular expresions that denote sets 
# of configuration tokens. The constructor takes an admin as a parameter and,
# according to that admin, is able to return the correspondant regular expressions 

has 'admin_id', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute admin_id" if ref($name) &&  (not ref($name) eq 'ARRAY'); }, required => 1;
has 'admin', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute admin" unless ref($name) eq 'QVD::DB::Result::Administrator'; };

my $AT_GENERAL_LEVEL = '^(?!(vma|internal|client|database)\.)';
my $AT_TENANT_LEVEL = '^auth\.';

sub BUILD
{
    my $self = shift;
    
    return if $self->admin;
    my $DB = QVD::DB::Simple::db();
    $self->{admin} = $DB->resultset('Administrator')->search(
	{'me.id' => $self->admin_id})->first;
}

# Returns the regex that express a set of configuration
# tokens that can be managed from the API

sub configs_to_show_re
{
    my $self = shift;
 
    if ($self->admin->is_superadmin)
    {
	return $AT_GENERAL_LEVEL;
    }
    else
    {
	cfg('wat.multitenant') ? 
	    return $AT_TENANT_LEVEL :
	    return $AT_GENERAL_LEVEL;
    }
}

1;
