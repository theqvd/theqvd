package QVD::Log;

use QVD::Config::Core;

use warnings;
use strict;
use 5.010;

our $VERSION = '0.01';

our $DAEMON_NAME;
# warn "DAEMON_NAME is " . ($DAEMON_NAME // '<undef>');

my $logfile = core_cfg(defined $DAEMON_NAME ? "$DAEMON_NAME.log.filename" : "log.filename");

## create the file if it doesn't exist, ignore errors

unless (open my $fd, '>>', $logfile) {
    warn "Can't open $logfile: $!\n";
    $logfile = (defined $DAEMON_NAME ? "/tmp/qvd-$DAEMON_NAME.log" : '/tmp/qvd.log');
    if (not open my $fd, '>>', $logfile) {
        die "Can't open '$logfile': $!";
    }
}

# print STDERR "logging to $logfile\n";



my %config = ( 'log4perl.appender.LOGFILE'          => 'Log::Dispatch::FileRotate',
	       'log4perl.appender.LOGFILE.mode'     => 'append',
	       'log4perl.appender.LOGFILE.DatePattern'
	                           => 'yyyy-MM-dd',
	       'log4perl.appender.LOGFILE.size'     => '50',
	       'log4perl.appender.LOGFILE.max'      => '20',
	       'log4perl.appender.LOGFILE.layout'   => 'Log::Log4perl::Layout::PatternLayout',
	       'log4perl.appender.LOGFILE.layout.ConversionPattern'
                                                    => '%d %P %p %F %L - %m%n',
	       'log4perl.appender.LOGFILE.filename' => $logfile,
	       'log4perl.rootLogger'                => core_cfg('log.level') . ", LOGFILE",
	       map { $_ => core_cfg $_ } grep /^log4perl\./, core_cfg_all );

use Log::Log4perl qw(:levels :easy);
Log::Log4perl::init_once(\%config);

use Exporter qw(import);
our @EXPORT = qw(DEBUG WARN INFO ERROR LOGDIE);

1;

__END__

=head1 NAME

QVD::Log - QVD logging utilities

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Initializes Log::Log4perl with QVD configuration. For example:

    use Log::Log4perl qw(:easy :levels);
    use QVD::Log;

    INFO "Logging works!";

To modify the default you can add log4perl tags into the /etc/qvd/node.conf. Something like

 log4perl.appender.Mailer=Log::Dispatch::Email::MailSend
log4perl.appender.Mailer.Threshold=WARN
log4perl.appender.Mailer.to      = qvd@theqvd.com
log4perl.appender.Mailer.subject = Alert for QVD system
log4perl.appender.Mailer.layout  = SimpleLayout
log4perl.logger.QVD = DEBUG, Mailer

=head1 AUTHOR

QVD Team, C<< <qvd at qindel.com> >>

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
