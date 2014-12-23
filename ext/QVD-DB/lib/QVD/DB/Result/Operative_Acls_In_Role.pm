package QVD::DB::Result::Operative_Acls_In_Role;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_acls_in_roles');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"
SELECT id as acl_id, name as acl_name from acls
"
);

__PACKAGE__->add_columns(

    acl_id  => { data_type => 'integer' },
    acl_name  => { data_type => 'varchar(64)' },
);

__PACKAGE__->set_primary_key( qw/ acl_id / );


sub roles
{
    my ($self,$roles) = @_;

    $self->{roles} = $roles
	if $roles;
    return $self->{roles};
}

1;
