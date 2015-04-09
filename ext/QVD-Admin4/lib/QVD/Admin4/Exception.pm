package QVD::Admin4::Exception;
use Moo;
use  5.010;

with 'Throwable';

has 'code', is => 'ro', isa => sub { die "Invalid type for attribute code" if ref(+shift); };
has 'query', is => 'ro', isa => sub { die "Invalid type for attribute nested" if ref(+shift); };
has 'object', is => 'ro', isa => sub { die "Invalid type for attribute object" if ref(+shift); };
has 'exception', is => 'ro', isa => sub {};
has 'failures', is => 'ro', isa => sub { die "Invalid type for attribute failures" 
					      unless ref(+shift) eq 'HASH'; };

my $code2message_mapper = 
{
    0000 => 'Successful completion',

    1100 => 'Internal server error',
    1200 => 'Action not accomplished for all elements',
    1300 => 'Zero items selected, no item has been changed',

    2100 => 'No connection to database',
    2210 => 'Unable to copy disk image from staging',
    2211 => 'Unable to copy whole disk image (lack of space?)',
    2220 => 'Unable to find images directory in filesystem',
    2230 => 'Unable to find staging directory in filesystem',
    2240 => 'Unable to find disk image in staging directory',

    3100 => 'No credentials provided for authentication',
    3200 => 'Wrong login or password - Login again',
    3300 => 'Session expired - Login again',
    3400 => 'Problems to update expiration time in session',

    4100 => 'Unavailable action',
    4110 => 'Invalid or null action name provided',
    4210 => 'Forbidden action for this administrator',
    4220 => 'Forbidden filter for this administrator',
    4221 => 'Forbidden filter value for this administrator',
    4230 => 'Forbidden argument for this administrator',
    4240 => 'Forbidden massive action for this administrator',
    4250 => 'Forbidden field for this administrator',

    5110 => 'Unable to disconnect user in current state',
    5120 => 'Unable to stop VM in current state',
    5130 => 'Unable to start VM in current state',
    5140 => 'Unable to assign host, no host available',

    6100 => 'Syntax errors in input json',
    6210 => 'Inappropiate filter for this action',
    6220 => 'No mandatory filter for this action',
    6230 => 'Inappropiate argument for this action',
    6240 => 'No mandatory argument for this action',
    6250 => 'Inappropiate field for this action',
    6310 => 'Invalid value',
    6320 => 'Invalid filter value',
    6321 => 'Unambiguous filter value needed',
    6322 => 'Unique filter value needed',
    6330 => 'Invalid argument value',
    6340 => 'Invalid property value',
    6350 => 'Invalid tag value',
    6360 => 'Invalid acl value',
    6370 => 'Invalid role value',
    6410 => 'Lack of value for a not nullable field',
    6420 => 'No property value provided',
    6430 => 'No tag provided',
    6440 => 'No acl provided',
    6450 => 'No role provided',

    7100 => 'Refered related items don\'t exist',
    7110 => 'Unable to accomplish, refered related items don\'t exist',
    7120 => 'Unable to remove, other items depend on it',
    7200 => 'This element already exists',
    7210 => 'This property already exists',
    7220 => 'This acl has already been assigned',
    7230 => 'This role has already been assigned',
    7310 => 'Unable to remove VM - This VM is running',
    7320 => 'Unable to remove DI - There are VMs running with it',
    7330 => 'Unable to reassign a Tag fixed to another DI',
    7340 => 'Fixed, Head and Default Tags cannot be deleted',
    7350 => 'Forbidden role assignment, inherited role inherits from inheritor',
    7360 => 'Incompatible expiration dates - Soft date must precede the hard one',
    7371 => 'Non core config items haven\'t default value',
    7372 => 'Unable to remove a core config item',
};


my $exception2code_mapper = 
{
    default => { default => 1100},

    'DBIx::Error::DataException' => { default => 6310, select => 6320, update => 6330, create => 6330, set => 6330,
				      properties => 6340, tags => 6350, acls => 6360, roles => 6370 },

    'DBIx::Error::NotNullViolation' => { default => 6410, properties => 6420, tags => 6430, acls => 6440, roles => 6450 },

    'DBIx::Error::ForeignKeyViolation' => { default => 7100, update => 7110, create => 7110, set => 7110, delete => 7120},

    'DBIx::Error::UniqueViolation' => { default => 7200, properties => 7210, acls => 7220, roles => 7230},

    'DBIx::Error::CheckViolation' => { default => 1100, vm_runtimes_consisten_expiration_dates => 7360},
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


    $self->print_unknown_exception
	if $self->exception;
}

sub print_unknown_exception
{
    my $self = shift;
    return unless $self->code eq
	$exception2code_mapper->{default}->{default};
    my $e = $self->exception; print "$e";
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
    $self->{object} = $self->exception->object;
    $self->{exception} = $self->exception->exception;
}

sub message
{
    my $self = shift;
    my $message = $code2message_mapper->{$self->code};
    $message .= " (".$self->object.")" if defined $self->object;
    $message; 
}

sub figure_out_code_from_exception
{
    my $self = shift;
    
    my $e = 'default';

    if (my $exception = $self->exception)
    {
	for my $class (keys %$exception2code_mapper)
	{
	    if (eval { $exception->isa($class) })
	    {
		$e = $class;
		last;
	    }
	}
    }

    my ($q) = $e eq 'DBIx::Error::CheckViolation' ?
	$self->exception->message  =~ /^.+?violates check constraint "([^"]+)"/ :
	$self->query;
    $q //= 'default';
    $q = 'default' unless exists $exception2code_mapper->{$e}->{$q}; 	
    
    $self->{code} = $exception2code_mapper->{$e}->{$q}; 
}


sub figure_out_code_from_failures
{
    my $self = shift;
    $self->{code} = 1200;
}

sub json
{
    my $self = shift;
    { status => $self->code, 
      message => $self->message,
      $self->failures ? (failures => $self->failures) : () };
}

1;
