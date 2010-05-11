package QVD::Log;

use Config::Tiny;
use Log::Log4perl qw(:easy);

use warnings;
use strict;

our $VERSION = '0.01';

my $config = {
    'log4perl.rootLogger' => 'INFO, LOGFILE',
    'log4perl.appender.LOGFILE' => 'Log::Log4perl::Appender::File',
    'log4perl.appender.LOGFILE.filename' => '/var/log/qvd.log',
    'log4perl.appender.LOGFILE.mode' => 'append',
    'log4perl.appender.LOGFILE.layout' => 'PatternLayout',
    'log4perl.appender.LOGFILE.layout.ConversionPattern' => '%d %P %F %L %c - %m%n',
};

if (! Log::Log4perl->initialized()) {
    my $ini = Config::Tiny->read('/etc/qvd/config.ini');
    if (defined $ini and defined $ini->{logging}) {
	$config->{'log4perl.appender.LOGFILE.filename'} 
	    //= $ini->{logging}{filename};

	if (defined $ini->{logging}{level}) {
	    $config->{'log4perl.rootLogger'} 
		= $ini->{logging}{level}.', LOGFILE'
	}
    }
    Log::Log4perl::init_once($config);
} else {
    DEBUG 'Refusing to initialize Log4perl for the second time';
}

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
