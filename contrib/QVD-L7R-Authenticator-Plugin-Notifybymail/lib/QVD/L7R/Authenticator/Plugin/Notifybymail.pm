package QVD::L7R::Authenticator::Plugin::Notifybymail;

use warnings;
use strict;
use QVD::Config;
use QVD::Log;
use Net::SMTP;

use parent qw(QVD::L7R::Authenticator::Plugin);

=head1 NAME

QVD::L7R::Authenticator::Plugin::Notifybymail - Sends an email whenever a user connects

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

Whenever someone connects to QVD it alerts via email of who is trying to connect

=head1 CONFIGURATION
To activate this module configure the following entry:

=over 4

=item * l7r.auth.plugins. 

Set this entry to opensso. 

qvd-admin.pl config set l7r.auth.plugins=notifybymail,default

B<Note:> This module always returns 0, that is it will never authenticate.

=back


This module accepts the following configuration parameters. 
(The ones marked with (*) are required:

=over 4

=item * auth.notifybymail.smtphost (*). 

This is a required parameter it is the uri where the http connection is made.

=item * auth.notifybymail.smtpto (*) 

The user who receives the email. You can specify several users 

auth.notifybymail.smtpto=nito@qindel.es,nito@qindel.com

=item * auth.notifybymail.smtpfrom

The mail from address. By default this is "qvd@$HOSTNAME"

=item * auth.notifybymail.smtpsubject 

he subject in the email. By default this is "User $USER has tried to connecto to QVD at $HOSTNAME"

=item * auth.notifybymail.debug

Enables the debug in Net::SMTP

=back


Example:

Configure in /etc/qvd/node.conf the following (or via qvd-admin.pl);

 auth.notifybymail.smtphost=smtp.qindel.com
 auth.notifybymail.smtpto=nito\@qindel.com

qvd-admin.pl config set l73.auth.plugins=notifybymail,default


=head1 SUBROUTINES/METHODS

=head2 authenticate_basic

Accepts as parameters:

=over 4

=item * auth. The authentication object

=item * login. The login user to test

=item * passwd. The password for the user

=back

This authentication module fails always.

=cut
$ENV{PATH}='/bin:/usr/bin:/sbin:/usr/sbin';
my $hostname = `hostname -f`;
my $smtphost =  cfg('auth.notifybymail.smtphost', 0) // '';
my $smtpto = cfg('auth.notifybymail.smtpto', 0) // '';
my $smtpfrom = cfg('auth.notifybymail.smtpfrom', 0) || 'qvd@'.$hostname;
my $debug = cfg('auth.notifybymail.debug', 0) // 0;

sub authenticate_basic  {
    my ($plugin, $auth, $login, $passwd) = @_;
    return ();
}

=head2 before_list_of_vms

Accepts as parameters:

=over 4

=item * auth. The authentication object

=back

This hook sends the notification email

=cut

sub before_list_of_vms {
    my ($plugin, $auth) = @_;
    my $login=$auth->login;

    if ($smtphost eq '' || $smtpto eq '') {
	ERROR 'You have defined in the auth plugins l73.auth.plugins notifybymail, '.
	    'but you have not defined the mailhost (auth.notifybymail.smtphost) or the '.
	    'destination email< auth.notifybymail.smtpto=nito@qindel.com >)';
	return ();
    }
    my @smtpto = split /,/, $smtpto;
    my $now = localtime;
    my $smtp = Net::SMTP->new($smtphost, Debug => $debug);
    if (!defined($smtp)) {
	ERROR "Error creating smtp object to smtp host $smtphost";
	return ();
    }

    my $smtpsubject = cfg('auth.notifybymail.smtpsubject', 0) || 'User '.$login.' has tried to connecto to QVD at '.$hostname;

    $smtp->mail($smtpfrom);
    foreach my $to (@smtpto) {
	$smtp->to($to);
    }
    $smtp->data();
    $smtp->datasend("From: $smtpfrom\n");
    foreach my $to (@smtpto) {
	$smtp->datasend("To: $to\n");
    }
    $smtp->datasend("Subject: $smtpsubject\n");
    $smtp->datasend("\n");
    $smtp->datasend("$smtpsubject at $now\n");
    $smtp->dataend();
    $smtp->quit();

    DEBUG "Sending notification email to $smtpto";
    return ();

}

1;

__END__

=head1 TODO


=head1 AUTHOR

Qindel Formacion y Servicios, SL, C<< <Nito at Qindel.ES> >>


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::L7R::Authenticator::Plugin::Notifybymail


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Qindel Formacion y Servicios, SL.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.
   
See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of QVD::L7R::Authenticator::Plugin::Notifybymail
