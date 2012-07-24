package QVD::Config;

our $VERSION = '0.02';

use warnings;
use strict;

use Config::Properties;
use QVD::Config::Core qw(core_cfg core_cfg_keys);
use QVD::Log;

use Exporter qw(import);
our @EXPORT = qw(cfg ssl_cfg cfg_keys);

our $USE_DB //= 1;

my $cfg;

sub reload {
    if ($USE_DB) {
	# we load the database module on demand in order to avoid circular
	# dependencies
	require QVD::DB::Simple;
	$cfg = { map { $_->key => $_->value } QVD::DB::Simple::rs('Config')->all }
    }
}

sub cfg {
    my $key = shift;
    my $mandatory = shift // 1;
    if ($USE_DB) {
	if ($key =~ /^l7r\.ssl\./) {
	    # SSL keys are only loaded on demand.
	    require QVD::DB::Simple;
	    my $slot = QVD::DB::Simple::rs('SSL_Config')->search({ key => $key })->first;
	    return $slot->value if defined $slot;
	}
	$cfg // reload;
	my $value = $cfg->{$key};
	if (defined $value) {
	    $value =~ s/\$\{(.*?)\}/cfg($1)/ge;
	    return $value;
	}
    }
    my $v = core_cfg($key, 0);
    if ($mandatory and not defined $v) {
        LOGDIE "mandatory configuration entry $key missing";
    }
    $v
}

sub cfg_keys {
    $cfg // reload;
    my %keys = map { $_ => 1 } core_cfg_keys, keys %$cfg;
    return keys %keys;
}

1;

__END__

=head1 NAME

QVD::Config - Retrieve QVD configuration from database.

=head1 SYNOPSIS

This module encapsulate configuration access.

    use QVD::Config;
    my $foo = cfg('field');
    my $bar = cfg('bar', $is_mandatory);

=head1 DESCRIPTION

FIXME Write the description

=head2 FUNCTIONS

=over

=item cfg($key)

=item cfg($key, $is_mandatory)

Returns the configuration associated to the given key.

If no entry exist on the database it returns the default value if
given or otherwise undef.

=item core_cfg($key)

=item core_cfg($key, $is_mandatory)

Returns configuration entries from the local file config.ini

Mostly used to configure database access and bootstrap the configuration system.

=back

=head1 AUTHORS

Hugo Cornejo (hcornejo at qindel.com)

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
