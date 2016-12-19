package QVD::DB::Result::User_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('users_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
"
SELECT
  me.id as id, 
        json_agg(DISTINCT properties)   as properties_json,
        COUNT(DISTINCT vm_runtimes) as number_of_vms_connected, 
        COUNT(DISTINCT vms)         as number_of_vms
FROM users me 
  LEFT JOIN (
    SELECT
      user_props.user_id as user_id,
      user_props.value as value,
      prop_list.id as property_id,
      prop_list.key as key,
      prop_list.tenant_id as tenant_id,
      prop_list.description as description
    FROM user_properties user_props
      INNER JOIN qvd_object_properties_list qvd_obj_props ON (user_props.property_id=qvd_obj_props.id)
      INNER JOIN properties_list prop_list ON(qvd_obj_props.property_id=prop_list.id)
  ) properties ON(properties.user_id=me.id)
 LEFT JOIN vms vms         ON(vms.user_id=me.id) 
 LEFT JOIN vm_runtimes vm_runtimes ON(vm_runtimes.vm_id=vms.id and vm_runtimes.user_state='connected') 
GROUP BY me.id
"
);

__PACKAGE__->add_columns(
	'id'                      => { data_type => 'integer' },
	'properties_json'         => { data_type => 'JSON', },
	'number_of_vms_connected' => { data_type => 'integer', },
	'number_of_vms'           => { data_type => 'integer', },
);

sub properties
{
    my $self = shift;
    my $property = shift;
    my $properties = decode_json($self->properties_json);
    my $out = { map { $_->{property_id} => { key => $_->{key}, value => $_->{value}, tenant_id => $_->{tenant_id}} } grep { defined $_->{key}  } @$properties };
    defined $property ? return $out->{$property} : return $out; 
}

1;

