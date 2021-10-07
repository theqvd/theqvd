package QVD::Log;

use QVD::Config::Core;
use Carp qw(cluck);
use warnings;
use strict;
use 5.010;
use File::Basename qw(basename);

our $VERSION = '0.01';

# Set to 1 by QVD::Log if we're using 'stdout' or 'stderr' output. This is intended to be used to suppress
# log output in places where stdout is a socket.
our $CONSOLE = 0;

# Set to 1 by users of QVD::Log when they are in a section of code that connects stdout to a socket.
# This will have the effect of suppressing log output while this variable is set.
#
# Log output will be SILENTLY DISCARDED while it's set.
our $SOCKET_SECTION = 0;

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
        $logfile = File::Spec->join($dir, defined $DAEMON_NAME ? "qvd-$DAEMON_NAME.log" : "qvd-" . basename($0) . ".log");

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
my %config;
my $preset = lc( $ENV{QVD_LOG_PRESET} // core_cfg('log.preset') );
use Log::Log4perl qw();


if ( $preset eq "stdout" || $preset eq "stderr" ) {
    %config = (
               # Log4perl is strange. Can't use a sub ref, actually got to put the sub in a string.
               'log4perl.filter.SocketFilter'           => 'sub { $QVD::Log::SOCKET_SECTION == 0 }',
               'log4perl.appender.SCREEN'               => 'Log::Log4perl::Appender::Screen',
               'log4perl.appender.SCREEN.stderr'        => ($preset eq "stderr"),
               'log4perl.appender.SCREEN.utf8'          => 1,
               'log4perl.appender.SCREEN.layout'        => 'Log::Log4perl::Layout::PatternLayout',
               'log4perl.appender.SCREEN.layout.ConversionPattern'
                                                        => $ENV{QVD_LOG_PATTERN} // core_cfg('log.pattern'),
               'log4perl.appender.SCREEN.Filter'        => 'SocketFilter',
               'log4perl.appender.LOGFILE'              => 'Log::Dispatch::FileRotate',
               'log4perl.appender.LOGFILE.mode'         => 'append',
               'log4perl.appender.LOGFILE.DatePattern'  => 'yyyy-MM-dd',
               'log4perl.appender.LOGFILE.size'         => '50',
               'log4perl.appender.LOGFILE.max'          => '20',
               'log4perl.appender.LOGFILE.layout'       => 'Log::Log4perl::Layout::PatternLayout',
               'log4perl.appender.LOGFILE.layout.ConversionPattern'
                                                        => $ENV{QVD_LOG_PATTERN} // core_cfg('log.pattern'),
               'log4perl.appender.LOGFILE.filename'     => $logfile,
               'log4perl.rootLogger'                    => ($ENV{QVD_LOG_LEVEL} // core_cfg('log.level')) . ", SCREEN, LOGFILE"
              );
    $CONSOLE = 1;
} elsif ( $preset eq "custom" ) {
    my $log_config_file = $ENV{QVD_LOG_CONFIG_FILE} // core_cfg('log.config');

    if ( $log_config_file ) {
        Log::Log4perl::init_once($log_config_file);
    } else {
        die "Log type is set to 'custom', but no config file was specified.\n" .
            "Please define log.config or use the QVD_LOG_CONFIG_FILE environment variable.";
    }
} else {
    # Officially, 'file', but we fall through into here if nothing matches

    %config = ( 'log4perl.appender.LOGFILE'              => 'Log::Dispatch::FileRotate',
    	        'log4perl.appender.LOGFILE.mode'         => 'append',
    	        'log4perl.appender.LOGFILE.DatePattern'  => 'yyyy-MM-dd',
    	        'log4perl.appender.LOGFILE.size'         => '50',
    	        'log4perl.appender.LOGFILE.max'          => '20',
    	        'log4perl.appender.LOGFILE.layout'       => 'Log::Log4perl::Layout::PatternLayout',
    	        'log4perl.appender.LOGFILE.layout.ConversionPattern'
                                                         => $ENV{QVD_LOG_PATTERN} // core_cfg('log.pattern'),
    	        'log4perl.appender.LOGFILE.filename'     => $logfile,
    	        'log4perl.rootLogger'                    => ($ENV{QVD_LOG_LEVEL} // core_cfg('log.level')) . ", LOGFILE"
    );
}
%config = (%config,  map { $_ => core_cfg $_ } grep /^log4perl\./, core_cfg_all );

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
our @EXPORT = qw(DEBUG WARN INFO ERROR LOGDIE FATAL TRACE $logger);

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

=head1 ENVIRONMENT VARIABLES

=over

=item QVD_LOG_PRESET

Same as log.preset, sets up a predefined logging configuration. The following options are available:

=over

=item stdout: Dump all log output on stdout

=item stderr: Dump all log output on stderr

=item file: Create a log file, with a filename chosen based on $DAEMON

=item custom: Use an external Log::Log4perl configuration file

=back

By default 'file' is used.

=item QVD_LOG_CONFIG

Log::Log4perl configuration file for when the 'custom' log preset is being used. Ignored otherwise.

=item QVD_LOG_LEVEL

Minimum logging level. Available ones are: TRACE, DEBUG, INFO, WARN, ERROR, FATAL

=item QVD_LOG_PATTERN

Log::Log4perl::Layout::PatternLayout logging pattern.

=back

=head1 VARIABLES

=over

=item $CONSOLE

Set to 1 when the preset is 'stdout' or 'stderr', and logging is being done to the console. This does not work if console logging is manually defined via the 'custom' preset. This is intended to be checked by external code that uses STDOUT for other purposes, and for instance suppress logging to avoid a conflict.

=item $SOCKET_SECTION

Can be set to a true value by the user of QVD::Log to suppress logging to the console in 'stdout' and 'stderr' mode. This is intended to be used in parts of the code where STDOUT is a socket, and writing to it would cause corruption.

=back

=head1 AUTHOR

QVD Team, C<< <qvd at qindel.com> >>

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
