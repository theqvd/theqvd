package QVD::L7R::Authenticator::Plugin::Default;

use strict;
use warnings;

use QVD::DB::Simple;
use QVD::Log;
use QVD::Config;
use Digest::SHA qw(sha256_base64);

use parent 'QVD::L7R::Authenticator::Plugin';

sub authenticate_basic {
    my ($plugin, $auth, $login, $passwd, $l7r) = @_;
    DEBUG "authenticating $login";

    # Reject passwordless login #1209
    return () if $passwd eq '';

    my $salt = cfg('l7r.auth.plugin.default.salt');
    my $token = sha256_base64("$salt$passwd");

    my $rs = rs(User)->search({login => $login, password => $token});
    return () unless $rs->count > 0;
    DEBUG "authenticated ok";
    $auth->{user_id} = $rs->first->id;
    1;
}

1;
