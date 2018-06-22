package QVD::L7R::Authenticator::Plugin::AuthTester;

use strict;
use warnings;

use QVD::DB::Simple;
use QVD::Log;
use QVD::Config;
use Digest::SHA qw(sha256_base64);

use parent 'QVD::L7R::Authenticator::Plugin';

sub authenticate_basic {
    my ($plugin, $auth, $login, $passwd, $l7r) = @_;
    WARN "This is a testing module not to be used in production";
    INFO "authenticate_basic: login = '$login', passwd = '$passwd'";
    if ( exists $auth->{headers} ) {
        INFO "Auth headers:";
        foreach my $hdr ( keys %{ $auth->{headers} } ) {
            INFO "$hdr: " . $auth->{headers}->{$hdr};
        }
    } else {
        INFO "No auth headers";
    }

    INFO "Returning a hardcoded authentication failure";

    return ();
}

1;
