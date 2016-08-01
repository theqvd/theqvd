package QVD::DB::Result::Workspace;
use base qw/DBIx::Class/;
use warnings;
use strict;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('workspaces');
__PACKAGE__->add_columns(
    id          => { data_type => 'integer', is_auto_increment => 1 },
    user_id     => { data_type => 'integer' },
    name        => { data_type => 'varchar(128)' },
    fixed       => { data_type => 'boolean', default_value => 0 },
    active      => { data_type => 'boolean', default_value => 0 },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint(['user_id', 'name']);

__PACKAGE__->belongs_to(user => 'QVD::DB::Result::User',  'user_id');
__PACKAGE__->has_many(settings => 'QVD::DB::Result::Workspace_Setting', 'workspace_id');


1;