package QVD::Admin4::REST::Response;
use strict;
use warnings;
use Moo;

has 'result', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'HASH'; }, default => sub {{};};
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::Admin4::REST::Model'; };
has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::Admin4::REST::JSON'; };

sub BUILD
{
    my $self = shift;

    $self->map_result_from_dbix_objects_to_output_info
	if $self->qvd_object_model;
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
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    my @available_fields =  $self->qvd_object_model->available_fields;
    @available_fields = grep { $self->json_wrapper->has_field($_) } @available_fields if $self->json_wrapper->fields_list;
    @available_fields = grep  { $admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_field($_)) } @available_fields;

    for my $field_key (@available_fields)
    {
	my $dbix_field_key = $self->qvd_object_model->map_field_to_dbix_format($field_key);
	my ($info_provider,$method) = $self->get_info_provider_and_method($dbix_field_key,$dbix_object);
	$result->{$field_key} = eval { $info_provider->$method } // undef;
	print $@ if $@;
    }

    $result;
}

sub map_result_to_list_of_ids
{
    my $self = shift;
    $self->result->{rows} = 
	[ map { $_->{id} } @{$self->result->{rows}} ];
}

sub get_info_provider_and_method
{
    my ($self,$dbix_field_key,$dbix_object) = @_;
    my ($table,$column) = $dbix_field_key =~ /^(.+)\.(.+)$/;
   
    return ($dbix_object,$column) if $table eq 'me';
    return ($self->result->{extra}->{$dbix_object->id},$column) if $table eq 'view';
    return ($dbix_object->$table,$column);
}


sub json
{
    my $self = shift;
    delete $self->result->{extra};
    { status => 0,message => 'Successful completion',%{$self->result}};
}

1;
