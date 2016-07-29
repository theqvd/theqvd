package QVD::Log;

use QVD::Config::Core;
use Carp qw(cluck);
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

    # We failed to open the normal log file. Try really hard to log SOMEWHERE,
    # because Log::Log4perl will cause an abort if logging can't be done.

    my @tempdirs;
    my $fd;

    if ( $^O =~ /Win32/ ) {
        # On Win32, first of all, try the temp path.

        require Win32::API;
        my $gettemppath = Win32::API->new('kernel32', 'GetTempPath', [qw(N P)], 'N');
        my $path = " " x 256;
        my $len = $gettemppath->Call(length($path), $path);
        if ( $len > 0 ) {
            $path = substr($path,0,$len);
            push @tempdirs, $path if (-d $path);
        } else {
            warn "Call to GetTempPath failed: $^E";
        }
    }

    # Variables that indicate a temp directory
    foreach my $var ("TEMP", "TMP", "TMPDIR") {
        push @tempdirs, $ENV{$var} if ($ENV{$var} && -d $ENV{$var});
    }

    # Finally, if all else failed, try hardcoded paths
    foreach my $dir (qw(/tmp c:\\temp c:\\windows\\temp)) {
        push @tempdirs, $dir if (-d $dir);
    }

    # Try to open a log file
    foreach my $dir (@tempdirs) {
        $logfile = File::Spec->join($dir, defined $DAEMON_NAME ? "qvd-$DAEMON_NAME.log" : "qvd-$0.log");

        if (not open $fd, '>>', $logfile) {
            warn "Can't open '$logfile': $!";
        } else {
            close $fd;
            last;
        }
    }

    if (!$fd) {
        my $errmsg = "Failed at all attempts to open a log file.\n" .
                     "The program will probably fail at the first attempt to log a message.\n\n" .
                     "Found temp directories: " . join(', ', @tempdirs);

        if ( $^O =~ /Win32/ ) {
             require Win32;
             Win32::MsgBox($errmsg, 0, "QVD");
        }

        cluck($errmsg);
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

use Log::Log4perl qw();
Log::Log4perl::init_once(\%config);

Log::Log4perl->wrapper_register(__PACKAGE__);

our $logger = Log::Log4perl::get_logger;

for (qw(TRACE DEBUG INFO WARN ERROR FATAL)) {
    my $level = $_;
    my $is_level = "is_" . lc $level;
    Log::Log4perl::easy_closure_create(__PACKAGE__, $_,
                                       ($logger->$is_level
                                        ? sub {
                                            local ($@, $SIG{__DIE__});
                                            eval { $logger->{$level}->($logger, @_, $level) } }
                                        : sub {}),
                                        $logger);
}

Log::Log4perl::easy_closure_create(__PACKAGE__, 'LOGDIE',
                                   sub {
                                       local ($@, $SIG{__DIE__});
                                       eval { $logger->{FATAL}->($logger, @_, 'FATAL') };
                                       if (open my $fh, ">/tmp/hkd-last-breath") {
                                           print $fh "@_\n";
                                           close $fh;
                                       }
                                       exit (1)
                                   },
                                   $logger);

use Exporter qw(import);
our @EXPORT = qw(DEBUG WARN INFO ERROR LOGDIE $logger);

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
