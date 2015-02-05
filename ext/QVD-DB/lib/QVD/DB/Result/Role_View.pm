package QVD::DB::Result::Role_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('role_views');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"
SELECT mr.id as id,
       json_agg(DISTINCT(rr.*))::text AS roles_json, 
       json_agg(DISTINCT(paa.name))::text as positive_acls_json,
       json_agg(DISTINCT(naa.name))::text as negative_acls_json
FROM roles mr 
LEFT JOIN (role_role_relations r JOIN roles rr ON r.inherited_id=rr.id) ON r.inheritor_id=mr.id
LEFT JOIN (acl_role_relations pa JOIN acls paa ON pa.acl_id=paa.id) ON pa.role_id=mr.id AND pa.positive='1'
LEFT JOIN (acl_role_relations na JOIN acls naa ON na.acl_id=naa.id) ON na.role_id=mr.id AND na.positive='0'

GROUP BY mr.id

"

);

__PACKAGE__->add_columns(

    id  => { data_type => 'integer' },
    roles_json  => { data_type => 'JSON' },
    positive_acls_json  => { data_type => 'JSON' },
    negative_acls_json  => { data_type => 'JSON' },
);

__PACKAGE__->set_primary_key( qw/ id / );



sub roles
{
    my $self = shift;
    my $roles = decode_json $self->roles_json;
    my $out = {};

    for my $role ( grep { defined $_ } @$roles )
    {
	my $id = delete $role->{id};
	$out->{$id} = $role;
    }

    $self->{roles} = $out;
}

sub acls
{
    my $self = shift;
    my $posotive_acls = decode_json $self->positive_acls_json;
    my $negative_acls = decode_json $self->negative_acls_json;

    my $out = { positive => [], negative => []};
    $out->{positive} = [ sort grep { defined $_ } @$posotive_acls  ];
    $out->{negative} = [ sort grep { defined $_ } @$negative_acls  ];
    $out; 
}



1;
