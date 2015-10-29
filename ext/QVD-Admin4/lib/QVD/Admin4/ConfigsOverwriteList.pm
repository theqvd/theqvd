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

my @hidden_regex = ("vma\.", "internal\.", "client\.", "database\.");
my @global_regex = ("wat\.");

my $GENERAL_TOKENS = sprintf('^(?!(%s))', join("|", (@hidden_regex, @global_regex)));
my $GLOBAL_TOKENS = sprintf('^(%s)', join("|", @global_regex));
my $EVERY_TOKEN = '.*'; # Matches everything
my $NO_TOKEN = 'a^'; # Matches nothing

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
	my $tenant = shift // $self->admin->tenant_id;
	my $regex;
 
	if(cfg('wat.multitenant')) {
    if ($self->admin->is_superadmin)
    {
			if ($tenant == - 1) {
				# Only superadmin can modify global tokens
				$regex = $GLOBAL_TOKENS;
			} else {
				# superadmin can modify its own tokens
				$regex = $GENERAL_TOKENS;
			}
    }
    else
    {
			if ($tenant == $self->admin->tenant_id) {
				# General tokens
				$regex = $GENERAL_TOKENS;
			} else {
				# Common admins can only access to their tokens
				$regex = $NO_TOKEN;
			}
    }
	} else { # No multitenant, so every token can be accessed
		$regex = $EVERY_TOKEN;
	}

	return $regex;
}

# Returns the regex that express a set of configuration
# tokens that are global for every tenant
sub configs_global_re{
	my $self = shift;
	my $regex;

	$regex = $GLOBAL_TOKENS;

	return $regex;
}

1;
