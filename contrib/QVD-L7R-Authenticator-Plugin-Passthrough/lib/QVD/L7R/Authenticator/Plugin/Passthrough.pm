package QVD::L7R::Authenticator::Plugin::Passthrough;

use 5.006;
use strict;
use warnings;
use QVD::Log;
use QVD::Config;

use parent qw(QVD::L7R::Authenticator::Plugin);

=head1 NAME

QVD::L7R::Authenticator::Plugin::Passthrough - Module to pass the L7R password to the container

=head1 VERSION

Version 0.01

=cut


#main

our $VERSION = '0.01';

my ($default_return_code, $sessionpasswd );
$default_return_code = cfg('auth.passthrough.return_code', 0) // ();
# If the auth.passthrough.return_code is the string true accept that as a 1
$default_return_code = (defined($default_return_code) && ($default_return_code =~ /^true$/xi || $default_return_code =~ /^1$/xi )) ? 1 : ();


=head1 DESCRIPTION

This module is used to pass information password information from the L7R to the VMA. Be aware that this module always returns false for the authentication, you need to combine it with another authentication  module. 

This module needs to be combined with a VMA hook that receives these parameters. Example hook in the VMA:

 vma.on_action_connect=/usr/local/bin/myscript

which would yield in the following invocation:

 /usr/local/bin/myscript ... qvd.vm.user.name loginname qvd.auth.passthrough.passwd thepassword ....

The information passed is:

=over 4

=item * qvd.vm.user.name The login is implicity fetched from this parameter.

=item * qvd.auth.passthrough.passwd The password used for login.

=back

=head1 EXAMPLES

 qvd-admin.pl config set l7r.auth.plugins=passthrough,ldap

 qvd-admin.pl config set auth.passthrough.return_code=1
 

=head1 OPTIONS

=over 4

=item * auth.passthrough.return_code (Optional, by default "false"). If you specify true, or 1 it will return true if not it will return false ().

=back

=head1 FUNCTIONS

=head2 authenticate_basic

Saves the password

=cut

sub authenticate_basic {
    my ($plugin, $auth, $login, $passwd, $l7r) = @_;

    $sessionpasswd = $passwd;

    DEBUG "Authentication pass for module passthrough for user $login is ".($default_return_code // 0);
    return $default_return_code;
}


=head2 before_connect_to_vm

Sets the password in the arguments of the VMA hooks

=cut
sub before_connect_to_vm {
    my ($plugin, $auth) = @_;

    $auth->{params}->{'qvd.auth.passthrough.passwd'} = $sessionpasswd;

    return;
}

=head1 AUTHOR

QVD Team, C<< <qvd-devel at theqvd.com> >>

=head1 BUGS

=head1 SEE ALSO

=over 4

=item * L<QVD::L7R::Authenticator::Plugin::Ldap>

=item * L<QVD::L7R::Authenticator::Plugin::Auto> 

=back




=head1 SUPPORT

Please contact L<http://theqvd.com> For support

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 QVD Team.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


=cut

1; # End of QVD::L7R::Authenticator::Plugin::Passthrough
