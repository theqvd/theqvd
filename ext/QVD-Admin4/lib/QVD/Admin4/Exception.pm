package QVD::Admin4::Exception;
use Moo;
use  5.010;

with 'Throwable';

# This class implements the exceptions used by the API

## PARAMETERS

# Either code, exception or failures must be provided in order
# to build a proper exception:

# a) code: is a specific numeric code that must be supported by this class
# b) exception: is another exception object that can be used to recursively build the current one
# c) failures: is a set of multiple failures reported by some action. A certain kind of exception
#              can be built from this multiple report

has 'code', is => 'ro', isa => sub { die "Invalid type for attribute code" if ref(+shift); };
has 'exception', is => 'ro', isa => sub {};
has 'failures', is => 'ro', isa => sub {
	die "Invalid type for attribute failures" unless ref(+shift) eq 'HASH';
};

## OPTIONAL PARAMETERS

# When throwing an exception, it can be specified the kind of query to DB
# that caused the exception (i.e. creation, update, etc.)
has 'query', is => 'ro', isa => sub { die "Invalid type for attribute nested" if ref(+shift); };

# When throwing an exception, it can be specified the object that 
# caused the exception (i.e. a certain unavailable filter)
has 'object', is => 'ro', isa => sub { die "Invalid type for attribute object" if ref(+shift); };

# When throwing an exception, it can be specified a custom message for the
# exception, that can be used to provide additional information
has 'additional_info', is => 'ro', isa => sub {};

## CLASS VARIABLES

# This is the mapper that relates numeric codes of exceptions
# with its corresponding messages. Supported codes must be listed in here

my $code2message_mapper = {
    0000 => 'Successful completion',

    1000 => 'In progress', 
    1100 => 'Internal server error',
    1200 => 'Action not accomplished for all elements',
    1300 => 'Zero items selected, no item has been changed',

    2100 => 'No connection to database',
    2210 => 'Unable to copy disk image from staging',
    2211 => 'Unable to copy whole disk image (lack of space?)',
    2220 => 'Unable to find images directory in filesystem',
    2230 => 'Unable to find staging directory in filesystem',
    2240 => 'Unable to find disk image in staging directory',
    2250 => 'Unable to upload disk image', 
    2251 => 'Unable to move uploaded disk image', 
    2260 => 'Unable to download disk image', 
    2261 => 'Unable to move downloaded disk image', 
	2270 => 'Unable to read file from disk',

    3100 => 'No credentials provided for authentication',
	3200 => 'Wrong credentials - Login again',
    3300 => 'Session expired - Login again',
    3400 => 'Problems to update expiration time in session',
	3500 => 'Access to tenant is restricted',

    4100 => 'Unavailable action',
    4110 => 'Invalid or null action name provided',
    4210 => 'Forbidden action for this administrator',
    4220 => 'Forbidden filter for this administrator',
    4221 => 'Forbidden filter value for this administrator',
    4230 => 'Forbidden argument for this administrator',
    4240 => 'Forbidden massive action for this administrator',
    4250 => 'Forbidden field for this administrator',
    4260 => 'Forbidden sorted by field for this administrator',
    
    5110 => 'Unable to disconnect user in current state',
    5120 => 'Unable to stop VM in current state',
    5130 => 'Unable to start VM in current state',
    5140 => 'Unable to assign host, no host available',

    6100 => 'Syntax errors in input json',
    6210 => 'Inappropiate filter for this action',
    6220 => 'No mandatory filter for this action',
    6230 => 'Inappropiate argument for this action',
	6231 => 'Inappropiate argument for the nested query action',
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
    6380 => 'Invalid config token',
    6410 => 'Lack of value for a not nullable field',
    6420 => 'No property value provided',
    6430 => 'No tag provided',
    6440 => 'No acl provided',
    6450 => 'No role provided',
    6600 => 'Invalid order direction',
    6610 => 'Invalid order by field',
    
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
    7370 => 'Unable to remove a core config item',
    7373 => 'Unable to switch to monotenant mode - More than one tenant in the system',
    7382 => 'Cannot create new configuration token',
	7390 => 'Configuration token value is already set to the default one',

};

# When an exception is thrown by DBIx::Class, it is catched and passed as a parameter 
# to the constructor of this class. In order to build a new exception of this class
# from an exception of DBIx::Class, it's needed to identify the original class with one
# of the numeric codes of this class. This is the mapper that relates both of them.

my $exception2code_mapper = {
    default => { default => 1100},

	'DBIx::Error::DataException' => {
		default => 6310, select => 6320, update => 6330, create => 6330, set => 6330,
		properties => 6340, tags => 6350, acls => 6360, roles => 6370
	},

    'DBIx::Error::NotNullViolation' => { default => 6410, tags => 6430, acls => 6440, roles => 6450 },

    'DBIx::Error::ForeignKeyViolation' => { default => 7100, update => 7110, create => 7110, set => 7110, delete => 7120},

    'DBIx::Error::UniqueViolation' => { default => 7200, properties => 7210, acls => 7220, roles => 7230},

    'DBIx::Error::CheckViolation' => { default => 1100, vm_runtimes_consisten_expiration_dates => 7360},
};


sub BUILD
{
    my $self = shift;

	# At least one of these parameters must be  provided
	# in order to build a proper exception

    $self->code || $self->exception || $self->failures ||
	die "needed either code, exception or failures attribute";

	# This object is recursive if a QVD::Admin4::Exception object was
	# provided via the exception parameter. In that case, this object
	# is built from that one
 
    $self->rebuild_recursively if $self->recursive;

    $self->figure_out_code_from_exception
	unless $self->code || $self->failures;

    $self->figure_out_code_from_failures
	if $self->failures;

	# prints useful error messages via console

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

# Checks if this exception object 
# has been built (or must be built)
# from another exception object of the same class

sub recursive
{
    my $self = shift;
	my $is_recursive = 0;
	if (($self->exception) && ref($self->exception) &&
		$self->exception->isa('QVD::Admin4::Exception')){
		$is_recursive = 1;
	}
	return $is_recursive;
}

# Sets object info from the info of another 
# object of the same class

sub rebuild_recursively
{
    my $self = shift;
    $self->{code} = $self->exception->code;
    $self->{query} = $self->exception->query;
    $self->{object} = $self->exception->object;
    $self->{exception} = $self->exception->exception;
}

# Provides the exception message

sub message
{
    my $self = shift;
    my $message = $code2message_mapper->{$self->code};
    $message .= " (".$self->object.")" if defined $self->object;
    $message; 
}

sub get_default_additional_info_text {
	my $self = shift;
	return "No additional information";
}

sub get_additional_info {
	my $self = shift;
	my $text = (defined $self->additional_info) ? $self->additional_info : $self->get_default_additional_info_text();
	return $text;
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

# Provides the exception info in JSON format.
# It's crucial that the output of this method is 
# equivalent to the output of the json method in QVD::Admin4::REST::Response
# Thanks to that both exceptions and successful responses can be used
# as equivalent objects to be retrieved by the API

sub json
{
    my $self = shift;
	return {
		status => $self->code,
		message => $self->message(),
		additional_info => $self->get_additional_info(),
		$self->failures ? (failures => $self->failures) : (),
	};
}

1;
