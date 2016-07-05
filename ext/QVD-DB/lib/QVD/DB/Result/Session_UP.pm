package QVD::DB::Result::Session_UP;
use base qw/DBIx::Class/;
use strict;
use warnings;
use QVD::DB::Simple qw(db);

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('session_up');
__PACKAGE__->add_columns(
    sid     => { data_type => 'varchar(40)' },
    data    => { data_type => 'text', is_nullable => 1},
    expires => { data_type => 'integer' }
);

__PACKAGE__->set_primary_key('sid');


1;