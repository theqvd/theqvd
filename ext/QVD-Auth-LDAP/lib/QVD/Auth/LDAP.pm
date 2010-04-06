package QVD::Auth::LDAP;

use warnings;
use strict;

use QVD::Config;

use Net::LDAP;

sub login {
    my $self = shift;
    my $user = shift;
    my $passwd = shift;
    
    my $ldap = Net::LDAP->new (cfg('auth_ldap_host')) or return 0;
    
    my $mesg = $ldap->bind; 
    
    $mesg = $ldap->search(base   => cfg('auth_ldap_base'),
                          filter => "(uid=$user)"
                      );
    
    if ($mesg->code != 0) {
	warn $mesg->error;
	return 0;
    }
    
    my $dn;
    foreach my $entry ($mesg->entries) { $dn = $entry->dn; }
    
    $mesg = $ldap->bind( $dn, password => $passwd);
    
    if ($mesg->code != 0) {
	warn $mesg->error;
	return 0;
    }
    
    1
}

=head1 NAME

QVD::Auth::LDAP - The great new QVD::Auth::LDAP!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::Auth::LDAP;

    my $foo = QVD::Auth::LDAP->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Hugo Cornejo, C<< <hcornejo at qindel.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-auth-ldap at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-Auth-LDAP>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::Auth::LDAP


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-Auth-LDAP>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-Auth-LDAP>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-Auth-LDAP>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-Auth-LDAP/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Hugo Cornejo.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of QVD::Auth::LDAP
