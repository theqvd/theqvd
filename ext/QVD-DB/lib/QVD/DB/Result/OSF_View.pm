package QVD::DB::Result::OSF_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('osf_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"
SELECT
  me.id as id,
        json_agg(DISTINCT properties)   as properties_json,
        COUNT(DISTINCT vms) as number_of_vms,
        COUNT(DISTINCT dis) as number_of_dis
FROM osfs me
  LEFT JOIN (
    SELECT
      osf_props.osf_id as osf_id,
      osf_props.value as value,
      prop_list.id as property_id,
      prop_list.key as key,
      prop_list.tenant_id as tenant_id,
      prop_list.description as description
    FROM osf_properties osf_props
      INNER JOIN qvd_object_properties_list qvd_obj_props ON (osf_props.property_id=qvd_obj_props.id)
      INNER JOIN properties_list prop_list ON (qvd_obj_props.property_id=prop_list.id)
  ) properties ON(properties.osf_id=me.id)
 LEFT JOIN vms vms ON(vms.osf_id=me.id)
 LEFT JOIN dis dis ON(dis.osf_id=me.id)  
GROUP BY me.id
"

);

__PACKAGE__->add_columns(
	'id' => { data_type => 'integer' },
	'properties_json' => { data_type => 'JSON', },
	'number_of_vms' => { data_type => 'integer', },
	'number_of_dis' => { data_type => 'integer', },
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
