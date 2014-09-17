package QVD::DB::Result::ACL;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('acls');
__PACKAGE__->add_columns(id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                         name        => { data_type => 'varchar(64)' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(name)]);
__PACKAGE__->has_many(roles => 'QVD::DB::Result::ACL_Setting', 'acl_id', { cascade_delete => 0 } );



sub get_roles
{
    my $self = shift;
    map { $_->role } $self->roles;
}

1;
