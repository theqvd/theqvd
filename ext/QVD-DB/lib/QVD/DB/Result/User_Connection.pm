package QVD::DB::Result::User_Connection;
use base qw/DBIx::Class/;
use warnings;
use strict;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_connections');
__PACKAGE__->add_columns(
    id         => { data_type => 'integer'},
    ip_address => { data_type => 'inet', is_nullable => 1},
    location   => { data_type => 'text', is_nullable => 1 },
    datetime   => { data_type => 'datetime', is_nullable => 1 },
    browser    => { data_type => 'text', is_nullable => 1 },
    os         => { data_type => 'text', is_nullable => 1 },
    device     => { data_type => 'text', is_nullable => 1 },
);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(id => 'QVD::DB::Result::User',  'id');

1;