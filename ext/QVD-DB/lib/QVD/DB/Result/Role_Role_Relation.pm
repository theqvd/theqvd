package QVD::DB::Result::Role_Role_Relation;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('role_role_relations');
__PACKAGE__->add_columns(id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                         inheritor_id  => { data_type => 'integer' },
			 inherited_id  => { data_type => 'integer' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(inheritor_id inherited_id)]);
__PACKAGE__->belongs_to(inheritor => 'QVD::DB::Result::Role', 'inheritor_id', { cascade_delete => 0 } );
__PACKAGE__->belongs_to(inherited => 'QVD::DB::Result::Role', 'inherited_id', { cascade_delete => 0 } );

1;
