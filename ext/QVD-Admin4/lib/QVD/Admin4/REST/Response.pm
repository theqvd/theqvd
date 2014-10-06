package QVD::Admin4::REST::Response;
use strict;
use warnings;
use Moo;

has 'status',  is => 'ro', isa => sub { die "Invalid type" if ref(+shift); }, required => 1;
has 'result', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'HASH'; }, default => sub {{};};
has 'failures', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'HASH'; }, default => sub {{};};
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::Admin4::REST::Model'; };

my $mapper = 
{
    0 => 'Successful completion',
    1 => 'Undefined error',
    2 => 'Unable to connect to database',
    3 => 'Unable to log in in database',
    4 => 'Internal server error',
    5 => 'Action non supported',
    6 => 'Unable to assign tenant to admin: permissions problem',
    7 => 'Unable to assign role to admin: permissions problem',
    8 => 'Forbidden action for this administrator',
    9 => 'Inappropiate filter for this action',
    10 => 'No mandatory filter for this action',
    11 => 'Unknown filter for this action',
    12 => 'Innapropiate argument for this action',
    13 => 'Unknown argument for this action',
    14 => 'Unknown order element',
    15 => 'Syntax errors in input json',
    16 => 'Condition to delete violated',
    17 => 'Condition to create violated',
    18 => 'Imposible to change state in current state',
    19 => 'Related arguments are not part of this tenant',
    20 => 'Unknow role',
    21 => 'Unknown acl',
    23 => 'Condition to update violated',
    24 => 'Problems when building response info',
    25 => 'Trivial operation. Nothing has been changed',
    26 => 'Imposible to add role. No loops in inheritance relations allowed',
    27 => 'Imposible to add and delete the same acl at the same time',
    23503 => 'Foreign Key violation',
    23502 => 'Lack of mandatory argument violation',
    23505 => 'Unique Key violation',
    23007 => 'Invalid type of argument',
};

sub BUILD
{
    my $self = shift;

    eval { $self->map_result_from_dbix_objects_to_output_info
	       if $self->qvd_object_model };
    if ($@) { print $@; }

    $self->{status} = 24 if ($@ && (not $self->status));
    while (my ($id, $code) = each %{$self->failures})
    {
	$self->failures->{$id} = $self->message($code);
	$self->{status} = 1;
    }
}

sub map_result_from_dbix_objects_to_output_info
{
    my $self = shift;
    return unless defined $self->result->{rows};
    $_ = $self->map_dbix_object_to_output_info($_)
	for @{$self->result->{rows}};

    $self->map_result_to_list_of_ids
	if $self->qvd_object_model->type_of_action eq 'all_ids';
}

sub map_dbix_object_to_output_info
{
    my ($self,$dbix_object) = @_;
    my $result = {};

    for my $field_key ($self->qvd_object_model->available_fields)
    {
	my $dbix_field_key = $self->qvd_object_model->map_field_to_dbix_format($field_key);
	my ($table,$column) = $dbix_field_key =~ /^(.+)\.(.+)$/;

	$result->{$field_key} = 
	    eval { $table eq "me" ? 
		       $dbix_object->$column : 
		       $dbix_object->$table->$column } // undef;
	print $@ if $@;
    }
#    $result->{kk} = $dbix_object->get_column('kk');
    $result;
}

sub map_result_to_list_of_ids
{
    my $self = shift;

    $self->result->{rows} = 
	[ map { $_->{id} } @{$self->result->{rows}} ];
}

sub message
{
    my $self = shift;
    my $status = shift // $self->status;
    return $mapper->{$status} || 
	'No translation to code '.$status.': ask Batman...';
}

sub json
{
    my $self = shift;
    
   { status  => $self->status,
     message => $self->message,
     result  => $self->result,
     failures  => $self->failures};
}

1;
