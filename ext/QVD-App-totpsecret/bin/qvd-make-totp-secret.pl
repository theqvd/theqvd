#!/usr/lib/qvd/bin/perl

use strict;
use warnings;

BEGIN {
	$QVD::Config::USE_DB = 0;
	@QVD::Config::Core::FILES = (
		'/etc/qvd/qa.conf',
		($ENV{HOME} || $ENV{APPDATA}).'/.qvd/qa.conf',
		'qa.conf',
	);
}

use QVD::Config qw(cfg);

use Math::Random::MT qw(rand);
use Image::PNG::QRCode qw(qrpng);
use URI::Escape qw(uri_escape);
use Getopt::Long;
use Mojo::UserAgent;
use Data::Dumper;

my $property_key = 'l7r.auth.plugin.totp.secret32';

my @chars = ('a'..'z', 2..7 );

my ($issuer, $login, $keyid, $fn, $quiet, $to, $from, $smtp,
    $template, $name, $subject, $debug, $cc, $bcc, $url, $api_ca,
    $tenant, $admin_tenant, $admin_login, $admin_password);

GetOptions('issuer|i'           => \$issuer,
           'login|user|l=s'     => \$login,
           'keyid|id|k=s'       => \$keyid,
           'out|o=s'            => \$fn,
           'quiet|q'            => \$quiet,
           'to|t=s'             => \$to,
           'cc|c=s'             => \$cc,
           'bcc|C=s'            => \$bcc,
           'from|f=s'           => \$from,
           'smtp|s=s'           => \$smtp,
           'template|e=s'       => \$template,
           'name|n=s'           => \$name,
           'subject|u=s'        => \$subject,
           'debug|d'            => \$debug,
           'api-url|A=s'        => \$url,
           'api-ca|C=s'         => \$api_ca,
           'tenant|T=s'         => \$tenant,
           'admin-login|L=s'    => \$admin_login,
           'admin-password|P=s' => \$admin_password,
           'admin-tenant|U=s'   => \$admin_tenant);


# Connect to the API, login and retrieve the user and properties information...
$url            //= cfg('qa.url');
$api_ca         //= cfg('qa.ca');
$admin_tenant   //= cfg('qa.tenant');
$admin_login    //= cfg('qa.login');
$admin_password //= cfg('qa.password');

my $ua = Mojo::UserAgent->new();
$ua->ca($api_ca) if length $api_ca;

$url = Mojo::URL->new($url)->path('api');
my $sid;

sub call_api {
    my $action = shift;
    my $tx;
    if ($action eq 'info') { # info is a special case...
        my $info_url = Mojo::URL->new('api/info')->base($url)->to_abs;
        $debug and warn "GET $info_url";
        $tx = $ua->get($info_url);
    }
    else {
        my %auth = ((defined $sid)
                    ? (sid => $sid)
                    : (password => $admin_password,
                       login => $admin_login,
                       tenant => $admin_tenant));
        my %json = (action => $action, %auth, @_);
        $debug and warn "$action request: " . Dumper(\%json);
        $tx = $ua->post($url, json => \%json);
    }
    if (my $res = $tx->success) {
        $debug and warn "$action response: " . Dumper($res->json);
        return $res if $res->json('/status') == 0;
        die "API call failed: ".$res->json('/message')."\n";
    }
    if (my $err = $tx->error) {
        my $message = $err->{message} // 'unknown error';
        my $code = $err->{code} // '???';
        die "API call failed: $message [$code]\n";
    }
    die "API call failed: unknown error";
}

my $res = call_api('current_admin_setup', fields => ['tenant_id']);
$sid = $res->json('/sid') // die "sid missing from API response\n";
$debug and warn "logging successfully, sid: $sid\n";

my $admin_tenant_id = $res->json('/tenant_id') // die "tenant_id missign from API response\n";
my $tenant_id;
if (defined $tenant) {
    if ($tenant eq $admin_tenant) {
        $tenant_id = $admin_tenant_id;
    }
    elsif ($admin_tenant_id == 0) {
        $res = call_api('tenant_get_list',
                        filters => { name => $tenant },
                        fields => [ 'id' ]);
        $tenant_id = $res->json('/rows/0/id') // die "Tenant '$tenant' lookup failed\n";
    }
    else {
        die "Administrator tenant and user tenant do not match"
    }
}
else {
    if ($admin_tenant_id == 0) {
        $res = call_api('info');
        $res->json('/multitenant') and
            die "Tenant missing (you have logged as a super-administrator and QVD is running in multitenant mode)\n";
        $tenant_id = 1;
    }
    else {
        $tenant_id = $admin_tenant_id;
    }
}

my @tenant_filter = ($admin_tenant_id == 0 ? (tenant_id => $tenant_id) : ());

# Property id lookup. The API doesn't have a way allowing us to do it
# efficiently. We have to retrieve all the properties and then search
# the one we are looking for.
my $property_id;
OUT: for my $i (0, 1) {
    $res = call_api('user_get_property_list');
    for my $row (@{$res->json('/rows')}) {
        if ($row->{key} eq $property_key and
            ($admin_tenant_id != 0 or $row->{tenant_id} eq $tenant_id)) {
            $property_id = $row->{id};
            $debug and warn "retrieved property_id: $property_id\n";
            last OUT;
        }
    }

    $i and die "user property $property_key has not been registered in database\n";

    my $res = call_api('property_create',
                       arguments => { key => $property_key,
                                      description => 'Secret key for TOTP authentication',
                                      __property_assign__ => ['user'],
                                      tenant_id => $tenant_id });
}

# At this point we have all the information we need from the API, so,
# go create the secret!

$issuer //= 'QVD Service';
$login // die "mandatory option login missing\n";
unless (defined $to) {
    $fn //= do {
        my $fn = "$issuer--$login";
        $fn =~ s/[^\w\-+]+/_/g;
        "$fn.png" };
};
$keyid //= $login;
$quiet //= 1 if defined $fn and $fn eq '-';

my $secret32 = join( '', map $chars[rand 32], 1..16);
my $otpauth = join('',
                   'otpauth://totp/',
                   uri_escape($issuer),
                   ':',
                   uri_escape($keyid),
                   '?secret=',
                   uri_escape($secret32),
                   '&issuer=',
                   uri_escape($issuer));

$res = call_api('user_get_list',
                filters => { name => $login,
                             @tenant_filter },
                fields => ['id']);

my $id = $res->json('/rows/0/id') or die "User lookup failed";
call_api('user_update',
         filters => {id => $id},
         arguments => {__properties_changes__ => {set => {$property_id => $secret32}}});

print qq(secret32: "$secret32", otpauth: $otpauth\n) unless $quiet;

# Have we been asked for a mail with the QR-Code to be delivered?
if (defined $to) {
    require MIME::Lite::TT;

    my $out;
    qrpng(text => $otpauth, out => \$out);

    $template //= \*DATA;
    $name //= $to;
    $subject //= "$issuer secret";
    $from //= 'qvd@theqvd.com';
    my @extra;
    push @extra, Cc => $cc if defined $cc;
    push @extra, Bcc => $bcc if defined $bcc;
    my $mail = MIME::Lite::TT->new(From => $from,
                                   To => $to,
                                   Subject => $subject,
                                   @extra,
                                   Template => $template,
                                   TmplParams => { from   => $from,
                                                   to     => $to,
                                                   issuer => $issuer,
                                                   name   => $name,
                                                   login  => $login });
    $mail->attach(Type => 'image/png',
                  Filename => 'qr-code.png',
                  Disposition => 'attachment',
                  Data => $out);

    $mail->send(defined $smtp ? (smtp => $smtp, Debug => $debug) : ())
        or die "Unable to send mail to $to\n";

    print "E-mail with QR code successfully sent to $to\n" unless $quiet;
}

if (defined $fn) {
    if ($fn eq '-') {
        my $out;
        qrpng (text => $otpauth, out => \$out);
        print $out;
    }
    else {
        qrpng (text => $otpauth, out => $fn);
    }
}

=head1 NAME

qvd-make-totp-secret

=head1 SYNOPSIS

  qvd-make-totp-secret                                     \
       --login <login>                                     \
       [--quiet] [--debug]                                 \
       [--issuer <issuer>]                                 \
       [--keyid <keyid>]                                   \
       [--out <filename | '-'>]                            \
       [--to <email> [--cc <email>] [--bcc <email>]        \
                     [--from <from>] [--subject <subject>] \
                     [--name <user_name>]                  \
                     [--template <template_filename>]      \
                     [--smtp <smtp_server>]]               \
       [--api-url <url>]                                   \
       [--api-ca <cert_path>                               \
       [--tenant <tenant_name>]                            \
       [--admin-login <admin_login>]                       \
       [--admin-password <admin_password>]


=head1 DESCRIPTION

C<qvd-make-totp-secret> generates a random secret for usage with the
QVD TOTP authentication plugin.

The generated secret is saved into the QVD database for usage by the
plugin and a QR-code saved into a file and/or sent by e-mail to the
user.

Note that C<qvd-make-totp-secret> must be run in a machine with access
to the QVD API service.

=head2 OPTIONS

=over 4

=item --login <login>

QVD login for the user.

This parameter is mandatory.

=item --quiet

Do not print the secret and otpauth string.

=item --debug

Print debugging information.

=item --issuer <issuer>

Name of the QVD service that may appear as the name of the service in
the TOTP token generator (i.e. the Google Authenticator App).

=item --keyid <keyid>

Name of the account that may appear in the TOTP token generator
(defaults to the login).

=item --out <filename>

Name of the file where the QR-code is saved.

If a dash (C<->) is given, the PNG data is printed to C<stdout>.

=item --to <user_email_address>

If this option is given, the QR-code is sent by email to the user.

=item --from <from_email_address>

The origin address for the email.

=item --cc <cc_email>

A copy of the email is sent to this address.

=item --bcc <bcc_email>

A copy of the email is ent to this address as BCC.

=item --subject <email_subject>

Text to be used as the subject of the message.

=item --name <user_name>

Full name of the user.

Used to greet him in the mail. The email address is used when not given.

=item --template <template_filename>

Template for the email.

It is processed with Perl module L<Template>. The parameters available
for interpolation are C<name>, C<from>, C<to>, C<issuer> and C<login>.

=item --smtp <smtp_server>

Name or address of the SMTP server to use for sending the mail.

If this option is not given, C<sendmail> is used to send the mail.

=item --api-url <api_url>

URL pointing to the QVD API service. When not given, its value would
be taken from the c<qa4> configuration file (usually at
C</etc/qvd/qa.conf > or C<~/.qvd/qa.conf>).

=item --api-ca <cert_path>

In case the API service is using a certificate not signed by a trusted
CA, this option can be used to pass the path to the CA public
certificate.

Read from the C<qa4> config file when not given.

=item --tenant <tenant>

Tenant for the admin and the user.

Read from the C<qa4> config file when not given.

=item --admin-login <admin_login>

=item --admin-password <admin_password>

Authentication credentials for administrator.

Read from the C<qa4> config file when not given.

=back

=head1 SEE ALSO

L<QVD::L7R::Authenticator::Plugin::TOTP>.

The L<TOTP Algorithm|https://en.wikipedia.org/wiki/Time-based_One-time_Password_Algorithm>.

The L<Google Authenticator|https://en.wikipedia.org/wiki/Google_Authenticator>.

=head1 LICENSE AND COPYRIGHT

Copyright 2016 Qindel FormaciE<oacute>n y Servicios SL.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License version 3 as published
by the Free Software Foundation.

See http://dev.perl.org/licenses/ for more information.

=cut

__DATA__

Dear [% name %],

The attached QR-code contains the secret that would allow you to log
as "[% login %]" into the QVD service "[% issuer %]" using two factor
authentication.

You should scan the QR-code using the Google Authenticator App (or any
other similar app of your choice).

Later, in order to log into QVD using any of the clients available
(desktop, mobile or web), you will have to enter your password
followed by the six digit code from the Google Authenticator App
without any spaces into the password field.

For example, if your password is "lobster" and the Google
Authenticator App shows the number "737 821", you will have to enter
"lobster737821".
