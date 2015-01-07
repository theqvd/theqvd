package QVD::DB::Result::Operative_Acls_In_Administrator;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_acls_in_administrators');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(


"
SELECT a.id           as acl_id, 
       a.name         as acl_name,
       json_agg(r.*)::text  as roles_json,
       i.inheritor_id as role_id,
       j.administrator_id  as admin_id

FROM   all_acl_role_relations i 
JOIN   acls a on a.id=i.acl_id
JOIN   roles r on r.id=i.inheritor_id
JOIN   role_administrator_relations j on j.role_id=i.inheritor_id

GROUP BY j.administrator_id, i.inheritor_id, a.id
"
);

__PACKAGE__->add_columns(

    admin_id  => { data_type => 'integer' },
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
    $roles->{$_->{id}} = $_->{name} for @$roles_list; 
    $roles;
}

1;
