
package QVD::API::REST::Request::Config_Field;
use strict;
use warnings;
use Moose;
use Mojo::JSON qw(decode_json encode_json);

extends 'QVD::API::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;

    $self->json->{arguments}->{filter_options} = 
	encode_json($self->json->{arguments}->{filter_options})
	if defined $self->json->{arguments}->{filter_options};

    $self->_check;
    $self->_map;
}

1;

__DATA__

id = me.id
name = me.name
qvd_obj = me.qvd_obj
get_details = me.get_details
get_list = me.get_list
filter_list = me.filter_list
filter_details = me.filter_details
argument = me.argument
tenant = me.tenant_id
filter_options = me.filter_options
