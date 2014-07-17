package QVD::DB::Result::DI_Tag;
use base qw/DBIx::Class/;

use strict;
use warnings;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('di_tags');
__PACKAGE__->add_columns( id     => { data_type => 'integer',
                                       is_auto_increment => 1 },
                          di_id => { data_type => 'integer' },
                          tag   => { data_type => 'varchar(1024)' },
                          fixed => { data_type => 'boolean', default_value => 0 } );

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(di => 'QVD::DB::Result::DI', 'di_id');

# __PACKAGE__->add_unique_constraint(['di.osf.osf_id', 'tag']);

sub get_has_many { qw(); }
sub get_has_one { qw(); }
sub get_belongs_to { qw(di); }



1;
