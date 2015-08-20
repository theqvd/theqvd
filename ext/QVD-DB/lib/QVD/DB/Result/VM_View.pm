package QVD::DB::Result::VM_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('vms_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"SELECT me.id            as id, 
        json_agg(DISTINCT properties)   as properties_json

 FROM      vms me 
 LEFT JOIN (vm_properties p LEFT JOIN properties_list pl ON(p.property_id=pl.id)) properties ON(properties.vm_id=me.id) 
 GROUP BY me.id"

);

__PACKAGE__->add_columns(
    'id' => {
	data_type => 'integer'
    },

    'properties_json' => {
	data_type => 'JSON',
    },

    );

sub properties
{
    my $self = shift;
    my $property = shift;
    my $properties = decode_json $self->properties_json;
    my $out = { map { $_->{property_id} => { key => $_->{key}, value => $_->{value}, tenant_id => $_->{tenant_id}} } grep { defined $_->{key}  } @$properties };
    defined $property ? return $out->{$property} : $out; 
}


1;
