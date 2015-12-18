package QVD::DB::Result::DI_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('dis_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
"
SELECT
  me.id as id,
        json_agg(DISTINCT properties)   as properties_json,
        json_agg(DISTINCT tags) as tags_json 
FROM dis me
  LEFT JOIN (
    SELECT
      di_props.di_id as di_id,
      di_props.value as value,
      prop_list.id as property_id,
      prop_list.key as key,
      prop_list.tenant_id as tenant_id,
      prop_list.description as description
    FROM di_properties di_props
      INNER JOIN qvd_object_properties_list qvd_obj_props ON (di_props.property_id=qvd_obj_props.id)
      INNER JOIN properties_list prop_list ON(qvd_obj_props.property_id=prop_list.id)
  ) properties ON(properties.di_id=me.id)
 LEFT JOIN di_tags tags ON(tags.di_id=me.id) 
GROUP BY me.id
"
);

__PACKAGE__->add_columns(
	'id'              => { data_type => 'integer' },
	'properties_json' => { data_type => 'JSON', },
	'tags_json'       => { data_type => 'JSON', },
);

sub properties
{
    my $self = shift;
    my $property = shift;
    my $properties = decode_json($self->properties_json);
    my $out = { map { $_->{property_id} => { key => $_->{key}, value => $_->{value}, tenant_id => $_->{tenant_id}} } grep { defined $_->{key}  } @$properties };
    defined $property ? return $out->{$property} : $out; 
}

sub tags
{
    my $self = shift;

    my $tags = decode_json($self->tags_json);
    my $out = [ sort { $a->{tag} cmp $b->{tag} }  
		map { { id => $_->{id}, tag => $_->{tag}, fixed => $_->{fixed}  } } 
		@$tags ];
}


1;
