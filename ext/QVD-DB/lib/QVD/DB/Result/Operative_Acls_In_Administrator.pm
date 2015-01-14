package QVD::DB::Result::Operative_Acls_In_Administrator;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_acls_in_administrators');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(


"

SELECT op.acl_id, op.admin_id, op.roles_json, ac.name as acl_name,
       CASE WHEN ac.name ~ ? THEN FALSE ELSE CASE WHEN ac.name ~ ? THEN TRUE ELSE op.operative END END
FROM operative_acls_in_admins_with_inheritance_info op
JOIN acls ac ON  op.acl_id=ac.id
WHERE ac.name !~ ?

"
);

__PACKAGE__->add_columns(

    operative  => { data_type => 'boolean' },
    admin_id  => { data_type => 'integer' },
    acl_id  => { data_type => 'integer' },
    acl_name  => { data_type => 'varchar(64)' },
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
