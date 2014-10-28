package QVD::DB::Result::Host_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('host_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"SELECT me.id            as id, 
        json_agg(properties)   as properties_json,
        COUNT(vm_runtimes) as number_of_vms_connected
 FROM      hosts me 
 LEFT JOIN host_properties properties ON(properties.host_id=me.id) 
 LEFT JOIN vm_runtimes vm_runtimes ON(vm_runtimes.host_id=me.id and vm_runtimes.vm_state='running') 
 GROUP BY me.id"

);

__PACKAGE__->add_columns(
    'id' => {
	data_type => 'integer'
    },

        'properties_json' => {
	data_type => 'JSON',
    },

    'number_of_vms_connected' => {
	data_type => 'integer',
    },
    );

sub properties
{
    my $self = shift;

    my $properties = decode_json $self->properties_json;
    my $out = { map { $_->{key} => $_->{value} } grep { defined $_->{key}  } @$properties };
}

1;
