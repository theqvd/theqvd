package QVD::DB::Result::Tenant;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('roles');
__PACKAGE__->add_columns( id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                          name        => { data_type => 'varchar(80)' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->has_many(users => 'QVD::DB::Result::User', 'tenant_id', { cascade_delete => 0 } );
__PACKAGE__->has_many(osfs => 'QVD::DB::Result::OSF', 'tenant_id', { cascade_delete => 0 } );

1;
