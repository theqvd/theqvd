package QVD::L7R::Authenticator::Plugin::Ldap;

our $VERSION = '0.01';

use warnings;
use strict;

use QVD::Config;
use QVD::Log;
use Net::LDAP qw(LDAP_SUCCESS LDAP_INVALID_CREDENTIALS);
use Net::LDAP::Util qw(escape_dn_value);
use parent qw(QVD::L7R::Authenticator::Plugin);

sub authenticate_basic {
    my ($class, $auth, $login, $password, $l7r) = @_;

    # ldap connection
    my $host = cfg('auth.ldap.host');
    my $ldap = Net::LDAP->new($host);
    unless ($ldap) {
	ERROR "Unable to connect to LDAP server $host for user $login: $@\n";
	return;
    }

    my $escaped_login = escape_dn_value($login);

    # Bind directly with a dn pattern (no previous search) if defined
    if (defined(my $userbindpattern = cfg('auth.ldap.userbindpattern', 0))) {
	$userbindpattern =~ s/\%u/$escaped_login/g;
	DEBUG("auth.ldap.userbindpattern provided trying login with <$userbindpattern> for user $login");
	my $msg = $ldap->bind($userbindpattern, password => $password);
	if (!$msg->code) {
	    DEBUG "auth.ldap.userbindpattern login with <$userbindpattern> was success for user $login";
	    return 1;
	}
	WARN "auth.ldap.userbindpattern login with <$userbindpattern> failed, continuing next bit for user $login";
    }

    my @bind_args;
    if (defined (my $binddn = cfg('auth.ldap.binddn', 0))) {
        $binddn =~ s/\%u/$escaped_login/g;
        push @bind_args, $binddn;
        DEBUG "binding with query '$binddn'";
        if (defined(my $bindpass = cfg('auth.ldap.bindpass', 0))) {
            push @bind_args, password => $bindpass;
        }
        else {
            DEBUG("auth.ldap.bindpass is not set, using login password from user '$login'");
            push @bind_args, password => $password;
        }
    }
    else {
        DEBUG "binding anonymously";
    }

    my $msg = $ldap->bind(@bind_args);
    if ($msg->code) {
        ERROR "bind failed: " . $msg->error . "\n";
	return;
    }

    # Search for user
    my $base   = cfg('auth.ldap.base');
    my $filter = cfg('auth.ldap.filter', 0) // '(uid=%u)';
    $filter =~ s/\%u/$escaped_login/g;
    my $scope  = cfg('auth.ldap.scope' , 0) // 'base';
    $scope =~ /^(?:base|one|sub)$/ or WARN "bad value $scope for auth.ldap.scope";
    my $deref = cfg('auth.ldap.deref', 0) // 'never';
    $deref =~ /^(?:never|search|find|always)$/ or WARN "bad value $deref for auth.ldap.deref";
    $msg = $ldap->search(base   => $base,
			 filter => $filter,
			 deref  => $deref,
                         scope  => $scope);
    DEBUG("searching in $base with filter $filter for user $login");
    if ($msg->code) {
	ERROR "Error in DN search $base with filter $filter for user $login. " .
            "LDAP response code: " . $msg->code . "(" . $msg->error_desc . ")";
	return;
    }

    # User not found
    if ($msg->count == 0) {
	ERROR "Error in DN search $base with filter $filter for user $login. No entries found";
	return ();
    }

    # More than one user found
    if ($msg->count > 1) {
	my @entries = map { $_->dn() } $msg->entries;
	ERROR "Error in DN search $base with filter $filter for user $login. More than one entry found: ".join(",", @entries);
	return ();
    }

    my $entry = ($msg->entries)[0];
    unless (defined ($entry)) {
 	# This should never happen
	DEBUG "Internal error: no entry found for $base with filter $filter for user $login";
	return ();
    }

    # Authenticate the user running a bind
    my $dn = $entry->dn;
    DEBUG("Found DN $dn for for user $login");
    $msg = $ldap->bind($dn, password => $password);
    if ($msg->code) {
        my $server_error = $msg->server_error;
        my $racf_regex = cfg('auth.ldap.racf_allowregex', 0);
        # In case of failed credentials and if racf_regex is
        # defined, allow to login when the error message matches
        if ($msg->code == LDAP_INVALID_CREDENTIALS and
            defined $server_error and
            defined $racf_regex) {
            if ($server_error =~ /$racf_regex/) {
                $auth->{params}{'qvd.auth.ldap.racf_detailed_error'} = $server_error;
                DEBUG "binding to DN $dn for user $login failed but server error ".
                    "'$server_error' matches '$racf_regex'";
            }
            else {
                DEBUG "binding to DN $dn for user $login failed and server error ".
                    "'$server_error' DOESN'T match '$racf_regex'";
                return;
            }
        }
        else {
            DEBUG "Error in authentication. LDAP return code: " .
                $msg->code . " (" . $msg->error_desc . "), server error: " . ($server_error // 'none');
            return;
        }
    }
    else {
	INFO("DN $dn for user $login was authenticated");
    }

    my $uidNumber = $entry->get_value('uidNumber');
    $auth->{params}{'qvd.vm.user.uid'} = $uidNumber if defined $uidNumber;

    my $gidNumber = $entry->get_value('gidNumber');
    $auth->{params}{'qvd.vm.user.gid'} = $gidNumber if defined $gidNumber;

    if (defined (my $uid = $entry->get_value('uid'))) {
        $auth->{params}{'qvd.vm.user.ldap.name'} = $uid;
        if (cfg('auth.ldap.normalize.name', 0)) {
            # we do the normalization here because the normalize_name
            # method is called too early
            $auth->{normalized_login} = $uid;
        }
    }
    return 1;
}

1;

__END__

=head1 NAME

QVD::L7R::Authenticator::Plugin::Ldap - LDAP Authentication plugin


=head1 DESCRIPTION

This module is used to authenticate users against an LDAP directory.

This module is commonly used with the QVD::L7R::Authenticator::Plugin::Auto
plugin.

=head2 EXAMPLE

An example configuration would be:

 qa config set l7r.auth.plugins=ldap
 qa config set auth.ldap.host=ds.theqvd.com
 qa config set auth.ldap.base=ou=People,dc=theqvd,dc=com

Another example configuration would be (including the auto config):

 qa config set l7r.auth.plugins=auto,ldap
 qa config set auth.ldap.host=ldaps://ds.theqvd.com:1636
 qa config set auth.ldap.base=ou=People,dc=theqvd,dc=com
 qa config set auth.ldap.scope=sub
 qa config set auth.ldap.filter=(&(objectClass=inetOrgPerson)(cn=%u))
 qa config set auth.auto.osf_id=1
 qa config set auth.ldap.normalize.name=1

=head2 OPTIONS

To enable the plugin add "ldap" to C<l7r.auth.plugins>. And the following configuration
items:

=over 4

=item * auth.ldap.host (Required). Can be a host or an LDAP uri as specified in Net::LDAP

=item * auth.ldap.base (Required). The search base where to find the users with the
auth.ldap.filter (see below)

=item * auth.ldap.filter (Optional by default '(uid=%u)'). The string %u will be
substituted with the login name

=item * auth.ldap.binddn (Optional by default empty). The initial bind to find the users.
By default the initial bind is done as anonymous unless this parameter is specified. If 
it contains the string %u, that is substituted with the login

=item * auth.ldap.bindpass (Optional by default empty). The password for the binddn

=item * auth.ldap.scope (Optional by default 'base'). See the Net::LDAP scope attribute
in the search operation. If this is empty the password provided in during
the authentication is used

=item * auth.ldap.userbindpattern (Optional by default empty). If specified an initial
bind with this string is attempted. The login attribute is susbsituted with %u.

=item * auth.ldap.deref (Optional by default never). How aliases are dereferenced, the
accepted values are never, search, find and always. See L<Net::LDAP> for more info.

=item * auth.ldap.racf_allowregex (Optional by default not set). This is a regex to allow
to authenticate some RACF error codes. An example setting would be "^R004109 ".
One of the common cases is R004109 which returns an ldap code 49 (invalid credentials)
and a text message such as "R004109 The password has expired 
(srv_authenticate_native_password))". If you don't have RACF this is probably not for you.

This will also set the variable qvd.auth.ldap.racf_detailed_error which can be used to
determine the error which let the user authenticate in the VMA. See the Plugin Developer
Guide for more info.

Example RACF errors:

=over 4

=item * R004107 The password function failed; not loaded from a program controlled library.

=item * R004108 TDBM backend password API resulted in an internal error.

=item * R004109 The password has expired.

=item * R004110 The userid has been revoked.

=item * R004128 Native authentication password change failed. The new password is not
valid or does not meet requirements.

=item * R004111 The password is not correct.

=item * R004112 A bind argument is not valid.

=item * R004118 Entry native user ID (ibm-nativeId,uid) is not defined to the Security Server.

=back

=back

=head2 AUTHENTICATCION ALGORITHM

The authentication algorith is as follows:

=over 4

=item * If auth.ldap.userbindpattern is defined then a bind is tried with this DN
subsitutiting %u with the login. If it is successful the user is authenticated and 
if it fails the following steps are attempted

=item * A bind as anonymous user (if auth.ldap.binddn is not defined, if not a bind
as that user is done) and search for the user dn, with the search path specified in
auth.ldap.base and the user filter specified as auth.ldap.filter. The
auth.ldap.filter gets substituted %u with the login name. If no user is found
authentication fails.

=item * If a userdn is found a bind with that user is tried.

=back

=head1 METHODS

=head2 authenticate_basic

Main authentication function. The parameters received are:

=over 4

=item $self

The QVD::L7R::Authenticator::Plugin::Ldap object

=item $auth

The L<QVD::L7R::Authenticator> object this object usually stores the
login and other common information.

=item $login

The username.

=item $password

The password.

=item $l7r

The L7R object.

You can obtain the source IP address as C<$l7r->{server}{client}->peerhost>

=back

=cut


=head1 SEE ALSO

L<QVD::L7R::Authenticator::Plugin::Auto> and <Net::LDAP>

=head1 SUPPORT

Please contact L<http://theqvd.com> For support


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010-2015 Qindel FormaciE<oacute>n y Servicios SL.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License version 3 as published
by the Free Software Foundation.

See http://dev.perl.org/licenses/ for more information.

=cut

