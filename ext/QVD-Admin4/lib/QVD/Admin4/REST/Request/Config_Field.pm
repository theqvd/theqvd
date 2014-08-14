
package QVD::Admin4::REST::Request::Config_Field;
use strict;
use warnings;
use Moose;

extends 'QVD::Admin4::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;
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
update = me.update
