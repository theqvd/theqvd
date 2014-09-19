package QVD::DB::Result::Role_Assignment_Relation;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('role_assignment_relations');
__PACKAGE__->add_columns(id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                         role_id  => { data_type => 'integer' },
			 administrator_id  => { data_type => 'integer' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(administrator_id role_id)]);
__PACKAGE__->belongs_to(administrator => 'QVD::DB::Result::Administrator', 'administrator_id');
__PACKAGE__->belongs_to(role => 'QVD::DB::Result::Role', 'role_id');

1;
