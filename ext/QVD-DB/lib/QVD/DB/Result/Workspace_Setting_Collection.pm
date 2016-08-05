package QVD::DB::Result::Workspace_Setting_Collection;
use base qw/DBIx::Class/;
use warnings;
use strict;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('workspace_setting_collection');
__PACKAGE__->add_columns(
    id           => { data_type => 'integer', is_auto_increment => 1 },
    setting_id   => { data_type => 'integer' },
    item_value   => { data_type => 'text' },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->belongs_to(setting => 'QVD::DB::Result::Workspace_Setting',  'setting_id');

1;