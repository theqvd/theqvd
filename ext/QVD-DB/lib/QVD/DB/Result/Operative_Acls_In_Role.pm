package QVD::DB::Result::Operative_Acls_In_Role;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
use QVD::Admin4::AclsOverwriteList;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_acls_in_roles');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

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
    $roles->{$_->{id}} = $_->{name} for @$roles_list; 
    $roles;
}

1;
