package QVD::DB::Result::Tenant_View;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('tenant_views');
__PACKAGE__->add_columns(id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                         acl_id  => { data_type => 'integer' },
			 tenant_id  => { data_type => 'integer' },
                         positive  => { data_type => 'boolean' },
			 view_type  => { data_type => 'varchar(64)' },
			 device_type  => { data_type => 'varchar(64)' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(tenant_id acl_id)]);
__PACKAGE__->belongs_to(acl => 'QVD::DB::Result::ACL', 'acl_id');
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant', 'tenant_id');

1;

