package QVD::DB::Result::Administrator_View;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('administrator_views');
__PACKAGE__->add_columns(id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                         acl_id  => { data_type => 'integer' },
			 administrator_id  => { data_type => 'integer' },
                         positive  => { data_type => 'boolean' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(administrator_id acl_id)]);
__PACKAGE__->belongs_to(acl => 'QVD::DB::Result::ACL', 'acl_id');
__PACKAGE__->belongs_to(administrator => 'QVD::DB::Result::Administrator', 'administrator_id');

1;
