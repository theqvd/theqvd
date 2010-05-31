package QVD::L7R::Authenticator::Plugin::Default;

use strict;
use warnings;

use QVD::DB::Simple;
use QVD::Log;

use parent 'QVD::L7R::Authenticator::Plugin';

sub authenticate_basic {
    my ($plugin, $auth, $login, $passwd) = @_;
    DEBUG "authenticating $login";
    my $rs = rs(User)->search({login => $login, password => $passwd});
    return () unless $rs->count > 0;
    DEBUG "authenticated ok";
    my $user_id = $rs->first->id;
    $auth->{user_id} = $user_id;
    $auth->{params}{'qvd.user.id'} = $user_id;
    $auth->{params}{'qvd.user.login'} = $login;
    1;
}

1;
