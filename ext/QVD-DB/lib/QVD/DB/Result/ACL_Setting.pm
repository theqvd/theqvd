package QVD::DB::Result::ACL_Setting;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('acl_setting');
__PACKAGE__->add_columns(id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                         acl_id  => { data_type => 'integer' },
			 role_id  => { data_type => 'integer' },
                         positive  => { data_type => 'boolean' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(role_id acl_id)]);
__PACKAGE__->belongs_to(acl => 'QVD::DB::Result::ACL', 'acl_id');
__PACKAGE__->belongs_to(role => 'QVD::DB::Result::Role', 'role_id');

1;
