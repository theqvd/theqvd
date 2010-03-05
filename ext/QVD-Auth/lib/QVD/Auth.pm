package QVD::Auth;

use warnings;
use strict;

use QVD::Auth::Basic;
use QVD::Auth::LDAP;

use QVD::Config;

sub login {
    my $mode = cfg('auth_mode');
    if ($mode eq "basic") {
	QVD::Auth::Basic::login(@_);
    } elsif ($mode eq "ldap") {
	QVD::Auth::LDAP::login(@_);
    } else {
	0;
    }
}

=head1 NAME

QVD::Auth - The great new QVD::Auth!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::Auth;

    my $foo = QVD::Auth->new();
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

Please report any bugs or feature requests to C<bug-qvd-auth at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-Auth>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::Auth


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-Auth>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-Auth>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-Auth>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-Auth/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2010 Hugo Cornejo.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of QVD::Auth
