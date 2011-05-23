package QVD::Log;

use QVD::Config;

use warnings;
use strict;

our $VERSION = '0.01';

my $logfile = core_cfg('log.filename');
if (!-w $logfile) {
    my $err = $!;
    if (!open my $fd, '>>', '/tmp/qvd.log') {
        die "Can't write to '$logfile' ($err) and can't use '/tmp/qvd.log' ($!) as a replacement";
    }
    close $fd;
    warn "Using '/tmp/qvd.log' instead of '$logfile' as a log file\n";
    $logfile = '/tmp/qvd.log';
}

my %config = ( 'log4perl.appender.LOGFILE'          => 'Log::Log4perl::Appender::File',
	       'log4perl.appender.LOGFILE.mode'     => 'append',
	       'log4perl.appender.LOGFILE.layout'   => 'PatternLayout',
	       'log4perl.appender.LOGFILE.layout.ConversionPattern'
                                                    => '%d %P %F %L %c - %m%n',
	       'log4perl.appender.LOGFILE.filename' => $logfile,
	       'log4perl.rootLogger'                => core_cfg('log.level') . ", LOGFILE",
	       grep /^log4perl\./, core_cfg_all );

use Log::Log4perl qw(:levels :easy);
Log::Log4perl::init_once(\%config);

use Exporter qw(import);
our @EXPORT = qw(DEBUG WARN INFO ERROR);

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

=head1 AUTHOR

QVD Team, C<< <qvd at qindel.com> >>

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
