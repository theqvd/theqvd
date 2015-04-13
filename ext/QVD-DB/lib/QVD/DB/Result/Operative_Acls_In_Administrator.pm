package QVD::DB::Result::Operative_Acls_In_Administrator;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_acls_in_administrators');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"

SELECT ad.id as admin_id, 
       CASE WHEN a.name ~ ? THEN FALSE ELSE CASE WHEN a.name ~ ? THEN TRUE ELSE CASE WHEN j.acl_id IS NULL THEN FALSE ELSE TRUE END END END as operative,
       j.inheritor_id as role_id, 
       a.id as acl_id, 
       a.description as acl_description, 
       json_agg(r.*)::text as roles_json, 
       a.name as acl_name

FROM acls a 
CROSS JOIN administrators ad
LEFT JOIN (all_acl_role_relations j JOIN roles r ON r.id=j.inheritor_id JOIN role_administrator_relations i ON i.role_id=r.id) ON i.administrator_id= ad.id AND a.id=j.acl_id  
WHERE a.name !~ ? 
GROUP BY j.acl_id, a.name, j.inheritor_id, ad.id, a.id

"
);

__PACKAGE__->add_columns(

    operative  => { data_type => 'boolean' },
    admin_id  => { data_type => 'integer' },
    acl_id  => { data_type => 'integer' },
    acl_name  => { data_type => 'varchar(64)' },
    acl_description  => { data_type => 'varchar(80)' },
    roles_json  => { data_type => 'varchar' },
);

__PACKAGE__->set_primary_key( qw/ acl_id admin_id / );

sub roles
{
    my ($self,$roles) = @_;

    my $roles_list = decode_json $self->roles_json;
    my @roles_list = grep { defined $_ } @$roles_list;
    my $roles = {};
    $roles->{$_->{id}} = $_->{name} for @roles_list; 
    $roles;
}

1;
