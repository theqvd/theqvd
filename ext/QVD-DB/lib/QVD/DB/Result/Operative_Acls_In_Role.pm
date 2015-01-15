package QVD::DB::Result::Operative_Acls_In_Role;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
use QVD::Admin4::AclsOverwriteList;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_acls_in_roles');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

#WITH operative_acls_in_roles_with_inheritance_info AS

#(

#SELECT ior.*, json_agg(DISTINCT (rr.*))::text as roles_json 
#FROM operative_acls_in_roles_basic ior 
#LEFT JOIN (operative_acls_in_roles_basic ied JOIN roles rr ON rr.id=ied.role_id) ON ied.operative=true AND ior.operative=true AND ied.acl_id=ior.acl_id 
#AND ior.role_id IN (SELECT inheritor_id FROM role_role_relations WHERE inherited_id=ied.role_id) 
#GROUP BY ior.acl_id, ior.role_id, ior.operative

#)


"

SELECT op.acl_id, op.role_id, op.roles_json, ac.name as acl_name,
       CASE WHEN ac.name ~ ? THEN FALSE ELSE op.operative END
FROM operative_acls_in_roles_with_inheritance_info op
JOIN acls ac ON  op.acl_id=ac.id
WHERE ac.name !~ ?

"
);

__PACKAGE__->add_columns(

    operative  => { data_type => 'boolean' },
    role_id  => { data_type => 'integer' },
    acl_id  => { data_type => 'integer' },
    acl_name  => { data_type => 'varchar(64)' },
    roles_json  => { data_type => 'varchar' },
);

__PACKAGE__->set_primary_key( qw/ acl_id / );


sub roles
{
    my ($self,$roles) = @_;

    my $roles_list = decode_json $self->roles_json;
    my $roles = {};
    my @roles_list = grep { defined $_ } @$roles_list;
    $roles->{$_->{id}} = $_->{name} for @roles_list; 
    $roles;
}

1;
