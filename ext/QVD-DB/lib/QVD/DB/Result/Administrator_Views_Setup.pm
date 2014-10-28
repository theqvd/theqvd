package QVD::DB::Result::Administrator_Views_Setup;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('administrator_views_setups');
__PACKAGE__->add_columns(id          => { data_type => 'integer',
                                           is_auto_increment => 1 },
                         field  => { data_type => 'varchar(64)' },
			 administrator_id  => { data_type => 'integer' },
                         visible  => { data_type => 'boolean' },
			 view_type  => { data_type => 'varchar(64)' },
			 device_type  => { data_type => 'varchar(64)' });

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw(administrator_id field)]);
__PACKAGE__->belongs_to(administrator => 'QVD::DB::Result::Administrator', 'administrator_id');

1;
