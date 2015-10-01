package QVD::DB::Result::ACL;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('acls');
__PACKAGE__->add_columns(
	id          => { data_type => 'integer', is_auto_increment => 1 },
                         name        => { data_type => 'varchar(64)' },
	description => { data_type => 'varchar(80)', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(name)]);
__PACKAGE__->has_many(role_rels => 'QVD::DB::Result::ACL_Role_Relation', 'acl_id', { cascade_delete => 0 } );



sub get_roles
{
    my $self = shift;
    map { $_->role } $self->role_rels;
}

sub get_roles_ids
{
    my $self = shift;
    map { $_->id } $self->get_roles;
}

sub get_roles_names
{
    my $self = shift;
    map { $_->name } $self->get_roles;
}


1;
