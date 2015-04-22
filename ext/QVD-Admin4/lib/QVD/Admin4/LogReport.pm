package QVD::Admin4::LogReport;
use strict;
use warnings;
use Moo;
use QVD::DB::Simple;
use Mojo::JSON qw(encode_json);
use Scalar::Util qw(blessed);

has 'administrator', is => 'ro', isa => \&check_administrator_attr, required => 1;
has 'object', is => 'ro', isa => \&check_object_attr, required => 1;
has 'tenant', is => 'ro', isa => \&check_tenant_attr, required => 1;
has 'qvd_object', is => 'ro', isa => sub {}, required => 1;
has 'action', is => 'ro', isa => \&check_action_attr, required => 1;
has 'ip', is => 'ro', isa => sub { die "Invalid type for attribute ip" if ref(+shift);};
has 'source', is => 'ro', isa => sub { die "Invalid type for attribute source" if ref(+shift); };
has 'arguments', is => 'ro', isa => sub { die "Invalid type for attribute arguments" unless eval { ref(+shift) eq 'HASH' };};
has 'status', is => 'ro', isa => sub { die "Invalid type for attribute source" if ref(+shift); }, required => 1;

sub check_administrator_attr
{
    my $administrator = shift;
    return unless defined $administrator;
    if (ref($administrator) eq 'QVD::DB::Result::Administrator')
    {
	return 1;
    }
    elsif (ref($administrator) eq 'HASH')
    {
	exists $administrator->{$_} || die "No $_ in attribute administrator"
	    for qw(administrator_id administrator_name superadmin);
    }
    else
    {
	die "Invalid type for attribute administrator";
    }
}

sub check_object_attr
{
    my $object = shift;
    return unless defined $object;
    if (ref($object) =~ /^QVD::DB::Result::.+$/ )
    {
	return 1;
    }
    elsif (ref($object) eq 'HASH')
    {
	exists $object->{$_} || die "No $_ in attribute object"
	    for qw(object_id object_name);
    }
    else
    {
	die "Invalid type for attribute object";
    }
}

sub check_tenant_attr
{
    my $tenant = shift;
    return unless defined $tenant;


    if (ref($tenant) eq 'QVD::DB::Result::Tenant')
    {
	return 1;
    }
    elsif (ref($tenant) eq 'HASH')
    {
	exists $tenant->{$_} || die "No $_ in attribute tenant"
	    for qw(tenant_id tenant_name);
    }
    else
    {
	die "Invalid type for attribute tenant";
    }
}

sub check_action_attr
{
    my $action = shift;
    return unless defined $action;
    if (ref($action) eq 'QVD::Admin4::Action')
    {
	return 1;
    }
    elsif (ref($action) eq 'HASH')
    {
	exists $action->{$_} || die "No $_ in attribute action"
	    for qw(action type_of_action);
    }
    else
    {
	die "Invalid type for attribute action";
    }
}

my $DB;

sub BUILD
{
    my $self = shift;

    $DB = db();
    
    my $localtime = localtime;

    $self->arguments->{password} = '**********' if defined eval { $self->arguments->{password} };

    $self->{log_entry} = { time => $localtime, qvd_object => $self->qvd_object, 
			   ip => $self->ip, source => $self->source,
			   arguments => encode_json($self->arguments), status => $self->status};
    
    $self->set_administrator_in_log_entry;
    $self->set_object_in_log_entry;
    $self->set_tenant_in_log_entry;
    $self->set_action_in_log_entry;
}

sub set_administrator_in_log_entry
{
    my $self = shift;

    if (blessed $self->administrator &&
	$self->administrator->isa('QVD::DB::Result::Administrator'))
    {
	@{$self->{log_entry}}{qw(administrator_id administrator_name superadmin)} = 
	    ($self->administrator->id, $self->administrator->name, 
	     $self->administrator->is_superadmin);
    }
    elsif (ref($self->administrator) eq 'HASH')
    {
	$self->{log_entry} = {%{$self->{log_entry}},%{$self->administrator}};
    }
}

sub set_object_in_log_entry
{
    my $self = shift;

    if (ref($self->object) =~ /^QVD::DB::Result::.+$/)
    {  
	@{$self->{log_entry}}{qw(object_id object_name)} = 
	    ( eval { $self->object->get_column('id') } , eval { $self->object->name } // undef);

    }
    elsif (ref($self->object) eq 'HASH')
    {
	$self->{log_entry} = {%{$self->{log_entry}},%{$self->object}};
    }
}

sub set_tenant_in_log_entry
{
    my $self = shift;

    if (blessed $self->tenant &&
	$self->tenant->isa('QVD::DB::Result::Tenant'))
    {
	@{$self->{log_entry}}{qw(tenant_id tenant_name)} = 
	    ($self->tenant->id, $self->tenant->name);
    }
    elsif (ref($self->tenant) eq 'HASH')
    {
	$self->{log_entry} = {%{$self->{log_entry}},%{$self->tenant}};
    }
}

sub set_action_in_log_entry
{
    my $self = shift;

    if (blessed $self->action && 
	$self->action->isa('QVD::Admin4::Action'))
    {
	@{$self->{log_entry}}{qw(action type_of_action)} = 
	    ($self->action->name, $self->action->type);
    }
    elsif (ref($self->action) eq 'HASH')
    {
	$self->{log_entry} = {%{$self->{log_entry}},%{$self->action}};
    }
}

sub log_entry
{
    my $self = shift;
    $self->{log_entry};
}

sub report
{
    my ($self,%args) = @_; 

    $DB->resultset('Log')->create($self->log_entry);
}

1;
