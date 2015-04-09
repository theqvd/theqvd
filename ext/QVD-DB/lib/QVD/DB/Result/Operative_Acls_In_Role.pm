package QVD::DB::Result::Operative_Acls_In_Role;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
use QVD::Admin4::AclsOverwriteList;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_acls_in_roles');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(


"

SELECT CASE WHEN a.name ~ ? OR (j.acl_id IS NULL AND jj.acl_id IS NULL) OR jj.positive=FALSE THEN FALSE ELSE TRUE END as operative, 
       rr.id as role_id, 
       a.id as acl_id, 
       json_agg(r.*)::text as roles_json, 
       a.name as acl_name

FROM acls a
CROSS JOIN roles rr 
LEFT JOIN (all_acl_role_relations j JOIN roles r ON r.id=j.inheritor_id JOIN role_role_relations i ON i.inherited_id=r.id) ON i.inheritor_id=rr.id AND a.id=j.acl_id  
LEFT JOIN acl_role_relations jj ON a.id=jj.acl_id AND rr.id=jj.role_id
WHERE a.name !~ ? 
GROUP BY j.acl_id, a.name, a.id, rr.id, jj.acl_id, jj.positive

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
    my @roles_list = grep { defined $_ && $_->{id} ne $self->role_id } @$roles_list;
    $roles->{$_->{id}} = $_->{name} for @roles_list; 
    $roles;
}

1;

