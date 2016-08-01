package QVD::DB::Result::Desktop;
use base qw/DBIx::Class/;
use warnings;
use strict;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('desktops');
__PACKAGE__->add_columns(
    id          => { data_type => 'integer', is_auto_increment => 1 },
    vm_id       => { data_type => 'integer' },
    alias       => { data_type => 'text' },
    active      => { data_type => 'boolean', default_value => 0 },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['vm_id', 'alias']);

__PACKAGE__->belongs_to(vm => 'QVD::DB::Result::VM',  'vm_id');
__PACKAGE__->has_many(settings => 'QVD::DB::Result::Desktop_Setting', 'desktop_id');


1;