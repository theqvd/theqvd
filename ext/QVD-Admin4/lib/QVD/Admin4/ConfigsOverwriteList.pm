package QVD::Admin4::ConfigsOverwriteList;
use Moo;
use  5.010;
use strict;
use warnings;
use Moo;
use QVD::DB::Simple qw(db);
use QVD::Config;

has 'admin_id', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute admin_id" if ref($name) &&  (not ref($name) eq 'ARRAY'); }, required => 1;
has 'admin', is => 'ro', isa => sub { my $name = shift; die "Invalid type for attribute admin" unless ref($name) eq 'QVD::DB::Result::Administrator'; };

my $AT_GENERAL_LEVEL = '^(?!(vma|internal|client)\.)';
my $AT_TENANT_LEVEL = '^$';

sub BUILD
{
    my $self = shift;
    
    return if $self->admin;
    my $DB = db();
    $self->{admin} = $DB->resultset('Administrator')->search(
	{'me.id' => $self->admin_id})->first;
}


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
