package QVD::DB::Result::Wat_Log;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('wat_log');
__PACKAGE__->add_columns( id                      => { data_type => 'integer', 
						       is_auto_increment => 1 },
                          administrator_id        => { data_type => 'integer' },
                          action                  => { data_type => 'varchar(80)' },
                          type_of_action          => { data_type => 'varchar(80)', 					      
						       is_enum     => 1,
						       extra       => { list => [qw(vm user osf di host tenant admin role acl config tenant_view admin_view)] } },
                          arguments               => { data_type => 'text' },
                          qvd_object              => { data_type => 'varchar(80)',
						       is_enum     => 1,
						       extra       => { list => [qw(create delete update exec)] } },
                          object_id               => { data_type => 'integer' },
                          time                    => { data_type => 'timestamp' },
                          status                  => { data_type => 'integer' },
                          source                  => { data_type => 'varchar(80)', is_nullable => 1 },
                          ip                      => { data_type => 'varchar(80)' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(administrator => 'QVD::DB::Result::Administrator', 'administrator_id');

1;
