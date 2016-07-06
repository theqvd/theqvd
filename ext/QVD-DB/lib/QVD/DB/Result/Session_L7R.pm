package QVD::DB::Result::Session_L7R;
use base qw/DBIx::Class/;
use strict;
use warnings;
use QVD::DB::Simple qw(db);

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('session_l7r');
__PACKAGE__->add_columns(
    sid      => { data_type => 'varchar(40)' },
    user_id  => { data_type => 'integer' },
    vm_id    => { data_type => 'integer', is_nullable => 1 },
    expires  => { data_type => 'integer' }
);

__PACKAGE__->set_primary_key('sid');


1;