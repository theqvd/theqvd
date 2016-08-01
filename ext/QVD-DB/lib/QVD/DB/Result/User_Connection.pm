package QVD::DB::Result::User_Connection;
use base qw/DBIx::Class/;
use warnings;
use strict;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_connections');
__PACKAGE__->add_columns(
    id         => { data_type => 'integer'},
    ip_address => { data_type => 'inet' },
    location   => { data_type => 'text' },
    datetime   => { data_type => 'datetime' },
    browser    => { data_type => 'text' },
    os         => { data_type => 'text' },
    device     => { data_type => 'text' },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(id => 'QVD::DB::Result::User',  'id');

1;