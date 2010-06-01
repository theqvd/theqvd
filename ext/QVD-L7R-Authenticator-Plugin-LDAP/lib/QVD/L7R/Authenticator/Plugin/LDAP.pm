package QVD::L7R::Authenticator::Plugin::LDAP;

our $VERSION = '0.01';

use warnings;
use strict;

use QVD::Config;
use QVD::Log;
use QVD::HTTP::StatusCodes;

my $ldap_host   = cfg('auth.ldap.host');
my $ldap_base   = cfg('auth.ldap.base');
my $ldap_filter = cfg('auth.ldap.filter', 0) // '(uid=%u)';
my $ldap_scope  = cfg('auth.ldap.scope' , 0) // 'base';

$ldap_scope =~ /^(?:base|one|sub)$/ or die "bad value $ldap_scope for auth.ldap.scope";

sub authenticate_basic {
    my ($class, $auth, $login, $passwd) = @_;
    my $ldap = Net::LDAP->new($ldap_host)
	// die "Unable to connect to LDAP server\n";
    my $msg = $ldap->bind;
    $msg->code and die "LDAP bind failed: " . $msg->error . "\n";
    $msg = $ldap->search(base   => $ldap_base,
			 filter => "(uid=$login)");
    $msg->code and return ();

    my $entry = ($msg->entries)[0]
    $foreach my $entry ($mesg->entries) {
}

1;

__END__

=head1 NAME

QVD::L7R::Authenticator::Plugin::LDAP - The great new QVD::L7R::Authenticator::Plugin::LDAP!


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::L7R::Authenticator::Plugin::LDAP;

    my $foo = QVD::L7R::Authenticator::Plugin::LDAP->new();
    ...

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-l7r-authenticator-plugin-ldap at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-L7R-Authenticator-Plugin-LDAP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-L7R-Authenticator-Plugin-LDAP>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-L7R-Authenticator-Plugin-LDAP>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-L7R-Authenticator-Plugin-LDAP>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-L7R-Authenticator-Plugin-LDAP/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Qindel FormaciE<oacute>n y Servicios SL.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License version 3 as published
by the Free Software Foundation.

See http://dev.perl.org/licenses/ for more information.

=cut

