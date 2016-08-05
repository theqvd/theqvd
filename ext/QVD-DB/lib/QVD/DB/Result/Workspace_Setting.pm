package QVD::DB::Result::Workspace_Setting;
use base qw/DBIx::Class/;
use warnings;
use strict;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('workspace_settings');
__PACKAGE__->add_columns(
    id           => { data_type => 'integer', is_auto_increment => 1 },
    workspace_id => { data_type => 'integer' },
    parameter    => { data_type => 'user_portal_parameters_enum' },
    value        => { data_type => 'text' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['workspace_id','parameter']);

__PACKAGE__->belongs_to(workspace => 'QVD::DB::Result::Workspace',  'workspace_id');
__PACKAGE__->has_many(collection => 'QVD::DB::Result::Workspace_Setting_Collection',  'setting_id');

1;