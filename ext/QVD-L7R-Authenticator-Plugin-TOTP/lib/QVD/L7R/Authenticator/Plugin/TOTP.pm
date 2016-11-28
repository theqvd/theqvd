package QVD::L7R::Authenticator::Plugin::TOTP;

use strict;
use warnings;

use QVD::DB::Simple;
use QVD::Log;
use QVD::Config;

use Digest::HMAC_SHA1 qw(hmac_sha1_hex);
use Convert::Base32 qw(decode_base32);

use parent 'QVD::L7R::Authenticator::Plugin';

sub authenticate_basic_2f_split {
    my ($plugin, $auth, $passwd, $l7r) = @_;
    DEBUG "extracting 2FA token from password";
    my $size = cfg('l7r.auth.plugin.totp.token_size', 0) // 6;
    my $token = substr($passwd, -$size, $size, "");
    return ($passwd, $token);
}

sub authenticate_basic_2f {
    my ($plugin, $auth, $login, $token, $l7r) = @_;
    my $now = time;

    my $user = rs(User)->find({login => $login});
    unless ($user) {
        ERROR "Internal error: Can not find user $login in database";
        return;
    }
    my $prop = $user->properties->find({ key => 'l7r.auth.plugin.totp.secret32' });
    unless (defined $prop) {
        ERROR "user $login property 'l7r.auth.plugin.totp.secret32' is missing, 2FA aborted";
        return;
    }

    my $secret32 = $prop->value;
    my $secret = eval { decode_base32($secret32) };
    unless (defined $secret) {
        ERROR "Bad value in user $login property 'l7r.auth.plugin.totp.secret32'";
        return;
    }

    my $size     = cfg('l7r.auth.plugin.totp.token_size',    0) //  6;
    my $interval = cfg('l7r.auth.plugin.totp.interval',      0) // 30;
    my $t0       = cfg('l7r.auth.plugin.totp.t0',            0) //  0;
    my $before   = cfg('l7r.auth.plugin.totp.leeway_before', 0) //  0;
    my $leeway   = cfg('l7r.auth.plugin.totp.leeway',        0) //  1;

    my $n = int(($now - $t0) / $interval);
    for my $i ($n - $leeway .. $n + $before) {
        my $hmac = hmac_sha1_hex(pack( 'H*', sprintf( '%016x', $i ) ), $secret);
        my $off = hex(substr($hmac, -1)) * 2;
        my $good = hex(substr($hmac, $off, 8)) & 0x7fffffff;

        $good = substr(("0" x $size) . $good, -$size);
        # DEBUG "given code: $token, good: $good (i: $i)";
        if ($good eq $token) {
            DEBUG "TOTP token validation succeeded for user $login! (offset: " . ($i - $n) . ", in interval: ". ($now - ($n * $interval + $t0)).")";
            return 1;
        }
    }

    DEBUG "TOTP token validation failed for user $login";
    return;
}

1;

__END__

=head1 NAME

QVD::L7R::Autenticator::Plugin::TOTP - TOTP authentication plugin.

=head1 DESCRIPTION

This module is used to authenticate users using TOTP on top of any
other password based authentication mechanism (i.e. using the default
or LDAP plugins).

The module breaks the string introduced by the user into the client
password field into a password and a token.

The password is then handled by any other configured plugin and the
token checked using the TOTP algorithm.

The user secret must be stored as the user property
C<l7r.auth.plugin.totp.secret32> encoded in base32. The companion
program L<qvd-make-totp-secret> can be used to create the secret and
to send it to the user as a QR-code by e-mail.

=head2 OPTIONS

The following configuration settings can be used to customize the
plugin:

=over 4

=item l7r.auth.plugin.totp.token_size

size of the token (defaults to six characteres).

=item l7r.auth.plugin.totp.interval

Duration of the TOTP interval (defaults to 30 seconds).

=item l7r.auth.plugin.totp.t0

Reference t0 value for the TOTP calculation as an offset from the Unix
epoch (defaults to zero).

=item l7r.auth.plugin.totp.leeway

For how many intervals the token remains valid (defaults to one).

=item l7r.auth.plugin.totp.leeway_before

The user has a time-travel machine and can use tokens from the
future*, this variable indicates from how many intervals away in the
future at most (defaults to zero, no time travel!).

* well, or its machine clock is just screwed.

=back

Note that the default options are those used by common services as
Google Authenticator.

=head1 SEE ALSO

L<qvd-make-totp-secret>.

The L<TOTP Algorithm|https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm>.

The L<Google Authenticator|https://en.wikipedia.org/wiki/Google_Authenticator>.


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Qindel FormaciE<oacute>n y Servicios SL.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License version 3 as published
by the Free Software Foundation.

See http://dev.perl.org/licenses/ for more information.

=cut
