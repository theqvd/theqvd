package QVD::DB::Result::OSF_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('osf_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"SELECT me.id            as id, 
        json_agg(properties)   as properties_json,
        COUNT(DISTINCT vms) as number_of_vms,
        COUNT(DISTINCT dis) as number_of_dis
 FROM      osfs me 
 LEFT JOIN osf_properties properties ON(properties.osf_id=me.id) 
 LEFT JOIN vms vms ON(vms.osf_id=me.id)
 LEFT JOIN dis dis ON(dis.osf_id=me.id)  
 GROUP BY me.id"

);

__PACKAGE__->add_columns(
    'id' => {
	data_type => 'integer'
    },

        'properties_json' => {
	data_type => 'JSON',
    },
    'number_of_vms' => {
	data_type => 'integer',
    },

    'number_of_dis' => {
	data_type => 'integer',
    },

    );

sub properties
{
    my $self = shift;
    my $property = shift;
    my $properties = decode_json $self->properties_json;
    my $out = { map { $_->{key} => $_->{value} } grep { defined $_->{key}  } @$properties };
    defined $property ? return $out->{$property} : $out; 
}

1;
