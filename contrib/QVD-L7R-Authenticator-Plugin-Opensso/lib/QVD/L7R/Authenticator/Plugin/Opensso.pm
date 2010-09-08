package QVD::L7R::Authenticator::Plugin::Opensso;

use warnings;
use strict;
use QVD::Config;
use QVD::Log;
use HTTP::Status qw(:constants);
use LWP::UserAgent;
use URI;
use Data::Dumper;

use Readonly;
Readonly my $USERAGENT => 'QVD OpenSSO Plugin/0.1 ';
use parent qw(QVD::L7R::Authenticator::Plugin);

=head1 NAME

QVD::L7R::Authenticator::Plugin::Opensso - Authentication plugin for Opensso

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

my $auth_uri   = cfg('auth.opensso.rest_auth_uri');
my $cookie_domain =cfg('auth.opensso.cookiedomain', 0) // '';
my $default_attributes_uri = $auth_uri;
my $default_authorize_uri = $auth_uri;
my $default_target_uri = $auth_uri;
$default_attributes_uri =~ s|/[^/]+(/?)$|/attributes$1|xg;
$default_authorize_uri =~ s|/[^/]+(/?)$|/authorize$1|xg;
$default_target_uri =~ s|/[^/]+/[^/]+(/?)$|/console$1|xg;

my $attributes_uri = cfg('auth.opensso.rest_attributes_uri', 0) // $default_attributes_uri;
my $authorize_uri = cfg('auth.opensso.rest_authorize_uri', 0) // $default_authorize_uri;
my $authorize_action = cfg('auth.opensso.authorize_action', 0) // 'POST';

my $target_uri   = cfg('auth.opensso.target_uri', 0) // '';
my $user_attr   = cfg('auth.opensso.user_attr', 0) // 'username' ;
my $pass_attr   = cfg('auth.opensso.pass_attr', 0) // 'password' ;
my $uri_attr   = cfg('auth.opensso.uri_attr', 0) // 'uri' ;
my $action_attr   = cfg('auth.opensso.action_attr', 0) // 'action' ;
my $subjectid_attr = cfg('auth.opensso.subjectid_attr', 0) // 'subjectid';

=head1 SYNOPSIS

Does simple authentication with opensso

=head1 DESCRIPTION

The quick configuration steps are as follows

=over 4

=item * Configure the authentication URI

=item * Disable the authorization uri (set this to the empty string)

=item * Assign the opensso module 

=back

This can be done as:

 qvd-admin.pl config set auth.opensso.rest_auth_uri=http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate
 qvd-admin.pl config set auth.opensso.cookiedomain=.qindel.com
 qvd-admin.pl config set auth.opensso.target_uri=
 qvd-admin.pl config set l7r.auth.plugins=opensso


If you want to use authorization you need a target uri and this can be configured as follows:

 qvd-admin.pl config set auth.opensso.rest_auth_uri=http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate
 qvd-admin.pl config set auth.opensso.target_uri=http://ptemsso.int.qindel.com:8080/myqvd 
 qvd-admin.pl config set l7r.auth.plugins=opensso


=head1 Hook parameters

By default this module passes the following parameters to the possible hook in 
QVD image:

=over 4

=item * qvd.auth.opensso.roles. This is the list of nsrole attributes for the authenticated entry. If more than one role is returned then they are separated by ":". If no roles are passed then the this attribute is the empty string

=item * qvd.auth.opensso.uri. This is the target uri used for authorization. If no authorization is used, this is usually the empty string.

=item * qvd.auth.opensso.cookie. This is the cookie that can be embedded in the firefox.

=item * qvd.auth.opensso.cookiedomain. This is the host or domain where the cookie applies to

=back

=head1 CONFIGURATION

To activate this module configure the following entry:

=over 4

=item * l7r.auth.plugins. 

Set this entry to opensso. 

qvd-admin.pl config set l7r.auth.plugins=opensso

B<Note:> this module works well also with the auto module, see below.

=back


This module accepts the following configuration parameters. 
(The ones marked with (*) are required:

=over 4

=item * auth.opensso.rest_auth_uri (*). 

This is a required parameter it is the uri where the http connection is made, that is the opensso uri.


=item * auth.opensso.cookiedomain. 

This is a required parameter it is the domain where the received cookie will set to (this will be done in the hook).


=item * auth.opensso.target_uri. 

This is an optional parameter with the URI where the user should have access
to. This uri is defined in OpenSSO as the access uri for the user.
This URI is virtual, QVD does not use this URI, it is only used for authorization.

If you define it as the empty string authorization is skipped

=item * auth.opensso.rest_authorize_uri

This is an optional parameter with the REST method for the authorization URI.
By default it is the auth.opensso.rest_auth_uri where the last component is 
substituted by B<authorize>.
That is if the auth url is 

  http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate/

then the attributes_uri becomes

  http://ptemsso.int.qindel.com:8080/opensso/identity/authorize/

If you define this attribute as empty, then only the authentication is executed
and the authorize phase is skipped

=item * auth.opensso.rest_attributes_uri

These is the OpenSSO URL to retrieve the REST attributes. By default it is 
the auth.opensso.rest_auth_uri where the last component is substituted by B<attributes>.
That is if the auth url is 

  http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate/

then the attributes_uri becomes

  http://ptemsso.int.qindel.com:8080/opensso/identity/attributes/


=item * auth.opensso.authorize_action

It is the action we request for the auth.opensso.target_uri. This is usually
GET or POST. If not specified, POST is used.

=item * auth.opensso.user_attr. 

The username attribute key name in the uri.
The default value is B<username>

You usually don't use this key

=item * auth.opensso.pass_attr. 

The password attribute key name used in the uri.
The default value is B<password>x

You usually don't use this key

=item * auth.opensso.uri_attr

The uri attribute key name used in the uri.
The default value is B<uri>

You usually don't use this key

=item * auth.opensso.action_attr

The acton attribute key name used in the authorize action.
The default value is B<action>

You usually don't use this key

=back

The authentication uri would be something like:

auth.opensso.rest_auth_uri?auth.opensso.user_attr=USERNAME&auth.opensso.pass_attr=PASS&auth.opensso.uri_attr=auth.opensso.target_uri

Example:

Configure in /etc/qvd/node.conf the following (or via qvd-admin.pl);

 auth.opensso.rest_auth_uri=http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate
 auth.opensso.target_uri=http://qvdadmin.int.qindel.com/myqvd
 auth.opensso.rest_authorize_uri=http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate

Then the authentication URI for a user qvdu with password qvd123 would be:

 http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate?username=qvdtu&password=qvd123&uri=http://qvdadmin.int.qindel.com/myqvd

If the authorization uri is defined then authorization would be something like:

 http://ptemsso.int.qindel.com:8080/opensso/identity/authorize?subjectid=AQIC5wM2LY4SfcwKgn6RrT9NXJwJcijzndGgWUBYSA4pJAE=@AAJTSQACMDE=#&action=POST&uri=http://qvdadmin.int.qindel.com/myqvd

If the authorization URI is not defined it is not used, and login will be granted with authentication alone

=head1 Autoprovision module and Opensso

It works well with the autoprovision module. Please see for details the
documentation for the provisioning module. The general steps
are outlined here:

=over 4

=item * Configure the REST uri

=item * Assign the default osi_id for provisioning the new users

=item * Assign the auto and the opensso module 

=back

This can be done as:

 qvd-admin.pl config set auth.opensso.rest_auth_uri=http://ptemsso.int.qindel.com:8080/opensso/identity/authenticate
 qvd-admin.pl config set auth.opensso.rest_authorize_uri=
 qvd-admin.pl config set auth.auto.osi_id=1
 qvd-admin.pl config set l7r.auth.plugins=auto,opensso


=head1 SUBROUTINES/METHODS

=head2 authenticate_basic

Accepts as parameters:

=over 4

=item * auth. The authentication object, used to pass parameters to the hook.

=item * login. The login user to test

=item * passwd. The password for the user

=back

On successful authentication it returns 1 and 1 otherwise

=cut

# Build the uri for the REST method
sub _build_uri {
    my ($base_uri, %attributes) = @_;

    my $uri = URI->new($base_uri);
    $uri->query_form(%attributes);

    if (exists $attributes{$pass_attr}) {
        $attributes{$pass_attr} = "********";
    }

    my $censored_uri = URI->new($base_uri);
    $censored_uri->query_form(%attributes);
    DEBUG __PACKAGE__."uri is <".$censored_uri->as_string.">";

    return HTTP::Request->new(GET => $uri->as_string);
}

sub authenticate_basic {
    my ($plugin, $auth, $login, $passwd) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent($USERAGENT);
    my $res=$ua->request(_build_uri($auth_uri, $user_attr => $login, $pass_attr => $passwd, $uri_attr => $target_uri));

    DEBUG __PACKAGE__.":HTTP request for user $login is ". Dumper($ua, $res);
    if ($res->is_success) {
	DEBUG __PACKAGE__.":Successful authentication for user $login";
	# Obtain cookie from body
	if ( $res->content =~ /^token.id=(.*)$/x ) {
		my $cookie = $1;

		DEBUG __PACKAGE__.": Got cookie";
		$auth->{params}->{'qvd.auth.opensso.uri'}            = $target_uri;
                $auth->{params}->{'qvd.auth.opensso.auth_uri'}       = $auth_uri;
                $auth->{params}->{'qvd.auth.opensso.attributes_uri'} = $attributes_uri;
                $auth->{params}->{'qvd.auth.opensso.authorize_uri'}  = $authorize_uri;
		$auth->{params}->{'qvd.auth.opensso.cookie'}         = $cookie;
		$auth->{params}->{'qvd.auth.opensso.cookiedomain'}   = $cookie_domain;

		if (defined($target_uri) && $target_uri ne '') {
		    if (!_authorize_basic($login, $cookie, $authorize_action)) {
			return ();
		    }
		} else {
		    DEBUG __PACKAGE__.":No authorization uri defined for user $login. Authorization skipped.";
		}

		if ( $attributes_uri ) {
			return _get_attributes($plugin, $auth, $cookie);
		} else {
			DEBUG __PACKAGE__.": Not requesting attributes, URI not set";
		}

		return 1;
	} else {
		ERROR __PACKAGE__.": Failed to find cookie in reply to login request. Got: " . $res->content;
		return ();
	}
    } else {
	if ($res->code != HTTP_UNAUTHORIZED) {
	    INFO __PACKAGE__.":During authentication with user $login has wrong credentials";
	} else {
	    # Seems a wrong url or server down
	    ERROR __PACKAGE__.": Error during authentication for user $login in OpenSSO uri <$auth_uri>";
	}
	return ();
    }
}


sub _authorize_basic {
    my ($login, $cookie, $action) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->agent($USERAGENT);
    my $res=$ua->request(_build_uri($authorize_uri, $action_attr => $authorize_action, $uri_attr => $target_uri, $subjectid_attr => $cookie));
    DEBUG __PACKAGE__.":HTTP request for user $login is ". Dumper($ua, $res);

    if ($res->is_success) {
	DEBUG __PACKAGE__.":Successful auth for user $login";

	if ( $res->content =~ /^boolean=true$/xi ) {
	    DEBUG __PACKAGE__.":Successful authorization for user $login and uri $target_uri";
	    return 1;
	} elsif ( $res->content =~ /^boolean=false$/xi ) {
	    ERROR __PACKAGE__.":Failed authorization for user $login and uri $authorize_uri, although the authentication worked (???). Got: ". $res->content;
	} else {
	    ERROR __PACKAGE__.": Error parsing response content. Got: " . $res->content;
	}

    } else {

	if ($res->code != HTTP_UNAUTHORIZED) {
	    INFO __PACKAGE__.":During authorization with user $login has wrong credentials (wrong cookie?)";
	} else {
	    # Seems a wrong url or server down
	    ERROR __PACKAGE__.": Error during authorization for user $login in OpenSSO uri <$authorize_uri>";
	}

    }

    return ();
}

=head2 _get_attributes

Accepts as parameters:

=over 4

=item * auth. The authentication object, used to pass parameters to the hook.

=item * auth_token. The cookie for the object

=back

Parses the roles and gets passes them to the hook

=cut
sub _get_attributes {
	my ($plugin, $auth, $auth_token) = @_;

	DEBUG "Requesting attributes";
	
#	my $data = $self->_do_web_request("/identity/attributes", subjectid => $self->{auth_token}, attributes_names => $attribute);

	my $ua = LWP::UserAgent->new;
	$ua->agent($USERAGENT);
	my $res=$ua->request(_build_uri($attributes_uri, $subjectid_attr => $auth_token));

	DEBUG __PACKAGE__.":HTTP request for attributes is ".Dumper($ua, $res);
	if ($res->is_success) {
		DEBUG __PACKAGE__.":Successful attributes request";
		DEBUG $res->content;

		my $attrs = _parse_attributes($res->content);

		if ( exists $attrs->{nsrole} ) {
#		    my @roles = map {  my ($role) = m/^cn=\s*([^,]+)\s*,.*$/xg; } @{ $attrs->{nsrole} };
		    my @roles = map {  m/^cn=\s*([^,]+)\s*,.*$/xg; } @{ $attrs->{nsrole} };
		    $auth->{params}->{'qvd.auth.opensso.roles'} = join(':', @roles);
		    DEBUG __PACKAGE__.": Got roles ".$auth->{params}->{'qvd.auth.opensso.roles'};
		} else {
		    $auth->{params}->{'qvd.auth.opensso.roles'} = '';
			ERROR __PACKAGE__.": Failed to find roles in reply to attributes request. Got: " . $res->content;
		}
		return 1;
	} else {
		if ($res->code != HTTP_UNAUTHORIZED) {
		    INFO __PACKAGE__.":During attributes request with auth token $auth, not authorized (wrong cookie?)";
		} else {
		    # Seems a wrong url or server down
		    ERROR __PACKAGE__.":Error during attributes request with auth token $auth_token in OpenSSO uri <$attributes_uri>";
		}
		return ();
	}
}



sub _parse_attributes {
	my ($data) = @_;

	my %attrs;
	my $attr_name;
	my $attr_val;

	foreach my $line (split(/\n/x, $data)) {
		chomp $line;
		
		my ($k,$v) = ($line =~ /^([.[:alpha:]]+)=(.*)$/x);

		if ( $k eq "userdetails.attribute.name" ) {
			$attr_name = $v;
		} elsif ( $k eq "userdetails.attribute.value" ) {
			$attr_val = $v;

			if (!exists $attrs{$attr_name} ) {
				$attrs{$attr_name} = [$attr_val];
			} else {
				if (!ref $attrs{$attr_name}) {
					# More than one value for this attribute. Turn it into
					# an array ref, and append the second value
					$attrs{$attr_name} = [ $attrs{$attr_name}, $attr_val ];
				} else {
					# Already an array ref, append
					push @{$attrs{$attr_name}}, $attr_val;
				}
			}
		}
	}

	return \%attrs;
}


=head1 TODO

* Log errors

* Use config properties for getting parameters

* Document vars

* change mandatory attributes

* Ask for which is the timeout

* my $osi_id = cfg('auth.auto.osi_id'); Documentar el osi_id de la imagen por defecto

* Check what happens if no roles exists, document roles

* Check what roles to use

* Revise the provisioning example, include target_uri

=cut

1;

__END__
=head1 AUTHOR

Nito Martinez, C<< <Nito at Qindel.ES> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-l7r-authenticator-plugin-opensso at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-L7R-Authenticator-Plugin-Opensso>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::L7R::Authenticator::Plugin::Opensso


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-L7R-Authenticator-Plugin-Opensso>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-L7R-Authenticator-Plugin-Opensso>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-L7R-Authenticator-Plugin-Opensso>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-L7R-Authenticator-Plugin-Opensso/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Nito Martinez.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of QVD::L7R::Authenticator::Plugin::Opensso
