package QVD::DB::Result::User_Auth_Parameters;
use base qw/DBIx::Class/;
use strict;
use warnings;

use QVD::DB::Simple qw(db rs);
use Session::Token;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('user_auth_parameters');
__PACKAGE__->add_columns(
    id          => { data_type => 'integer', is_auto_increment => 1 },
    parameters  => { data_type => 'json' },
);

__PACKAGE__->set_primary_key('id');

1;