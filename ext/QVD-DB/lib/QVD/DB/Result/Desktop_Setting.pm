package QVD::DB::Result::Desktop_Setting;
use base qw/DBIx::Class/;
use warnings;
use strict;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('desktop_settings');
__PACKAGE__->add_columns(
    id           => { data_type => 'integer', is_auto_increment => 1 },
    desktop_id   => { data_type => 'integer' },
    parameter    => { data_type => 'user_portal_parameters_enum' },
    value        => { data_type => 'text' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['parameter']);

__PACKAGE__->belongs_to(desktop => 'QVD::DB::Result::Desktop',  'desktop_id');
__PACKAGE__->has_many(collection => 'QVD::DB::Result::Desktop_Setting_Collection',  'setting_id');

1;