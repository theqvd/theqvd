package QVD::Admin4::Exception;
use Moo;
use  5.010;

with 'Throwable';

has 'code', is => 'ro', isa => sub { die "Invalid type for attribute code" if ref(+shift); };
has 'query', is => 'ro', isa => sub { die "Invalid type for attribute nested" if ref(+shift); };
has 'nested_query', is => 'ro', isa => sub { die "Invalid type for attribute nested" if ref(+shift); };
has 'object', is => 'ro', isa => sub { die "Invalid type for attribute object" if ref(+shift); };
has 'exception', is => 'ro', isa => sub {};
has 'failures', is => 'ro', isa => sub { die "Invalid type for attribute failures" 
					      unless ref(+shift) eq 'HASH'; };

my $mapper = 
{
    0 => 'Successful completion',

    11 => 'Internal server error',
    12 => 'Action not accomplished for all elements',
    13 => 'Zero items selected: no item has been changed',

    21 => 'No connection to database',
    22 => 'No credentials provided for authentication',
    23 => 'Wrong login or password',
    24 => 'Session expired',
    25 => 'Problems to update expiration time in session',
    26 => 'Unavailable action',
    27 => 'Unavailable action for this administrator',

    31 => 'Syntax errors in input json',

    41 => 'Invalid value',
    42 => 'Invalid filter value',
    43 => 'Invalid argument value',
    44 => 'Invalid property value',
    45 => 'Invalid tag value',
    46 => 'Invalid acl value',
    47 => 'Invalid role value',

    51 => 'Lack of value for a not nullable field',
    511 => 'No property value provided',
    512 => 'No tag provided',
    513 => 'No acl provided',
    514 => 'No role provided',
    52 => 'Foreign Key violation in DB',
    521 => 'Unable to create this item: refered related items don\'t exist',
    522 => 'Unable to remove this item: other items depend on it',
    53 => 'This element already exists',
    54 => 'This property already exists',
    55 => 'This acl has already been assigned',
    56 => 'This role has already been assigned',

    61 => 'Unable to remove VM. This VM is running',
    62 => 'Unable to remove DI. There are VMs running with it',
    63 => 'Unable to reassign a Tag fixed to another DI',
    64 => 'Fixed, Head and Default Tags cannot be deleted',
    65 => 'Unable to assign/unassign role. That role doesn\'t exist',
    66 => 'Unable to assign/unassign acl. That acl doesn\'t exist',
    67 => 'Forbidden role assignment: inherited role inherits from inheritor'
};

sub BUILD
{
    my $self = shift;
    $self->code || $self->exception || $self->failures ||
	die "needed either code, exception or failures attribute";

    $self->rebuild_recursively if $self->recursive;

    $self->figure_out_code_from_exception
	unless $self->code || $self->failures;

    $self->figure_out_code_from_failures
	if $self->failures;
}


sub recursive
{
    my $self = shift;
    return 1 
	if $self->exception && 
	ref($self->exception) &&
	$self->exception->isa('QVD::Admin4::Exception'); 
}

sub rebuild_recursively
{
    my $self = shift;
    $self->{code} = $self->exception->code;
    $self->{query} = $self->exception->query;
    $self->{nested_query} = $self->exception->nested_query;
    $self->{object} = $self->exception->object;
    $self->{exception} = $self->exception->exception;
}

sub message
{
    my $self = shift;
    my $message = $mapper->{$self->code};
    $message .= ": ".$self->object if defined $self->object;
    $message = "(".$self->nested_query.") $message" if defined $self->nested_query;
    $message; 
}

sub figure_out_code_from_exception
{
    my $self = shift;
    my $e = $self->exception;

    unless (ref($e)) 
    { $self->{code} = 11; print $e; return; }

    my $code;
    if ($e->isa('DBIx::Error::DataException')) 
    { 
	$code = 42 if ($self->query && $self->query eq 'select');
	$code = 43 if ($self->query && $self->query =~ /^update|create|set$/);
	$code = 44 if ($self->query && $self->query eq 'properties');
	$code = 45 if ($self->query && $self->query eq 'tags');
	$code = 46 if ($self->query && $self->query eq 'acls');
	$code = 47 if ($self->query && $self->query eq 'roles');
	$code = 41 unless defined $code;
    } 
    elsif ($e->isa('DBIx::Error::NotNullViolation')) 
    { 
	$code = 511 if ($self->query && $self->query eq 'properties');
	$code = 512 if ($self->query && $self->query eq 'tags');
	$code = 513 if ($self->query && $self->query eq 'acls');
	$code = 514 if ($self->query && $self->query eq 'roles');
	$code = 51 unless defined $code;
    } 
    elsif ($e->isa('DBIx::Error::ForeignKeyViolation')) 
    {  
	$code = 52 if ((not $self->query) || $self->query !~ /^create|delete|set$/);
	$code = 521 if ($self->query && $self->query =~ /^create|set$/);
	$code = 522 if ($self->query && $self->query eq 'delete');
    
    } elsif ($e->isa('DBIx::Error::UniqueViolation')) 
    { 
	$code = 54 if ((not $self->query) || $self->query eq 'properties');
	$code = 55 if ((not $self->query) || $self->query eq 'acls');
	$code = 56 if ((not $self->query) || $self->query eq 'roles');
	$code = 53 unless $code; 
    }
    else
    { 
	$code = 11; print "$e"; 
    }

    $self->{code} = $code; 
}


sub figure_out_code_from_failures
{
    my $self = shift;
    $self->{code} = 12;
}

sub json
{
    my $self = shift;
    { status => $self->code, 
      message => $self->message,
      $self->failures ? (failures => $self->failures) : () };
}

1;

#
#    0 => 'Successful completion',
#    1 => 'Undefined error',
#    2 => 'Unable to connect to database',
#    3 => 'Unable to login in database',
#    4 => 'Internal server error',
#    5 => 'Action non supported',
#    6 => 'Unable to assign tenant to admin: permissions problem',
#    7 => 'Unable to assign role to admin: permissions problem',
#    8 => 'Forbidden action for this administrator',
#    9 => 'Inappropiate filter for this action',
#    10 => 'No mandatory filter for this action',
#    11 => 'Unknown filter for this action',
#    12 => 'Innapropiate argument for this action',
#    13 => 'Unknown argument for this action',
#    14 => 'Unknown order element',
#    15 => 'Syntax errors in input json',
#    16 => 'Condition to delete violated',
#    17 => 'Condition to create violated',
#    18 => 'Imposible to change state in current state',
#    19 => 'Related arguments are not part of this tenant',
#    20 => 'Unknow role',
#    21 => 'Unknown acl',
#    23 => 'Condition to update violated',
#    24 => 'Problems when building response info',
#    25 => 'Trivial operation. Nothing has been changed',
#    26 => 'Imposible to add role. No loops in inheritance relations allowed',
#    27 => 'Imposible to add and delete the same acl at the same time',
#    28 => 'Your session has expired. Login again',
#    29 => 'Please, login first',
#    30 => 'Unable to copy disk image from staging',
#    31 => 'Unable to find images directory in filesystem',
#    32 => 'Unable to find staging directory in filesystem',
#    33 => 'Unable to find disk image in staging directory',
#    34 => 'Forbidden filter for this administrator',
#    35 => 'Forbidden argument for this administrator',
#    36 => 'Forbidden field for this administrator',
#    37 => 'Innapropiate nested query for this action',
#    38 => 'Forbidden nested query for this administrator',
#    39 => 'Concurrent update problem while updating expiration time in session',
#    40 => 'Unknown administrator',
#    41 => 'Unknown QVD object. Available QVD objects are: VM, User, Host, OSF and DI',
#    23503 => 'Foreign Key violation',
#    23502 => 'Lack of mandatory argument violation',
#    23505 => 'Unique Key violation',
#    23007 => 'Invalid type of argument',
#    '22P02' => 'Invalid type of argument in enumeration field'
#
