package QVD::VmaHook::Passthrough;

use 5.006;
use strict;
use warnings;
use QVD::Config::Core;
use QVD::Log;
use File::Spec;
use File::Slurp;
use POSIX qw(geteuid);
our @EXPORT_OK = qw(save_credentials);


=head1 NAME

QVD::VmaHook::Passthrough - Saves the authentication token in a file

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
my $user_envfile=core_cfg('qvd.vmahook.passthrough.envfile', 0) // '.qvdpassthrough';


=head1 DESCRIPTION

This module receives the following parameters:

=over 4

=item * Credentials from the L<QVD::L7R::Authenticator::Plugin::Passthrough>

=over 4

=item * qvd.vm.user.name The username used for login

=item * qvd.auth.passthrough.passwd The password used for login

=back

=back

and saves them in the file specified by qvd.vmahook.passthrough.envfile as:

 qvduser=mytestuser
 qvdpassword=mytestpassword

This file can be read in perl (among others) with Config::Properties, or from a shell script by sourcing it.

=head1 INSTALLATION

Please install the module in the target image and do not forget to set up the following entry in the /etc/qvd/vma.conf file in the image
 
 vma.on_action.connect: /usr/lib/qvd/bin/qvd_passthrough_hook

=head1 OPTIONS

you can set the following options in vma.conf

=over 4 

=item * qvd.vmahook.passthrough.envfile. This is the file where the environment variable holding the credentials will be hold. If not specified, this file is ".qvdpassthrough" which is relative to the home directory


=back

=head1 SUBROUTINES/METHODS

=head2 save_credentials

Receives as argument a reference to the array @ARGV, and saves them to the parameter specified in qvd.vmahook.passthrough.envfile.


Example @ARGV to use
my @_ = (
    'qvd.vm.user.name', 'testuser',
    'qvd.auth.passthrough.passwd', 'testpass',
    );

=cut

sub save_credentials {
    my $argv = shift;
    $argv = (ref $argv eq 'ARRAY' || ref $argv eq 'HASH') ? $argv : [];
    my %args = @$argv;
    my $envfile;
    if (exists($args{'qvd.vm.user.home'}) && $args{'qvd.vm.user.home'} =~ /^(\/.*)$/x) {
	$envfile=File::Spec->catfile($1, $user_envfile);
	DEBUG("save_credentials: envfile is $envfile");
    }
    umask 0077;
    if (!exists($args{'qvd.vm.user.name'}) 
	|| !exists($args{'qvd.auth.passthrough.passwd'})
	|| !exists($args{'qvd.vm.user.home'})
	) {
	ERROR "parameters qvd.vm.user.name, qvd.vm.user.home, qvd.auth.passthrough.passwd were not passed not setting $user_envfile:".join(" ", @$argv);
	
	unlink $envfile if (defined($envfile));
	return 0;
    }

    my $user = $args{'qvd.vm.user.name'};
    my $content= "qvduser=$user\n".
	"qvdpassword=".$args{'qvd.auth.passthrough.passwd'}."\n";
    my $result = write_file($envfile, $content);
    if (!$result) {
	ERROR "save_credentials: Error writing file $envfile";
	return 0;
    }
    my ($login,$pass,$uid,$gid) = getpwnam($user);

    if (!$uid || !$gid) {
	ERROR "save_credentials: Failed getwnam($user)";
	return 0;
    }
    $result = chown $uid, $gid, $envfile;
    if (!$result && geteuid() == 0) {
	ERROR "save_credentials: Failed chown $uid:$gid $envfile";
	return 0;
    }
    return 1;
}

=head1 SEE ALSO

=over 4

=item * L<QVD::L7R::Authenticator::Plugin::Passthrough>

=back 

=head1 AUTHOR

QVD Team, C<< <qvd-devel at theqvd.com> >>

=head1 TODO

=head1 BUGS

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::VmaHook::Passthrough

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

1; # End of QVD::VmaHook::Passthrough
