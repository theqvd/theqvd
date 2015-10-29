package QVD::Config;

our $VERSION = '0.02';

use warnings;
use strict;

use List::MoreUtils qw(uniq);
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
		$cfg = { map { $_->key => $_->value } QVD::DB::Simple::rs('Config')->search({tenant_id => -1}) };
    }
}

sub cfg {
    my $key = shift;
	my $tenant = shift // -1;

	# TODO Check if config key is mandatory
	my $mandatory = 1;

	# Try to get the value from different repositories
	my $value;

    if ($USE_DB) {

	    # SSL keys are only loaded on demand.
		if ($key =~ /^l7r\.ssl\./) {
	    require QVD::DB::Simple;
			$tenant != -1 and LOGDIE "Per tenant SSL properties are not supported";
	    my $row = QVD::DB::Simple::rs('SSL_Config')->search({ key => $key })->first;
	    return $row->value if defined $row;
	}

		# First try to get the value from the database
		if ($tenant != -1) {
            $USE_DB or LOGDIE "Can't read per tenant configuration when DB access is disabled";
            my $row = QVD::DB::Simple::rs('Config')->search({tenant_id => $tenant, key => $key})->first;
            $value = $row->value if defined $row;
        }

        unless (defined $value) {
			$USE_DB or LOGDIE "Can't read per tenant configuration when DB access is disabled";
			my $row = QVD::DB::Simple::rs('Config')->search({tenant_id => -1, key => $key})->first;
			$value = $row->value if defined $row;
		}

		# If not found in the DB, get it from the ones cached in memory
		unless (defined $value) {
            $cfg || reload;
            $value = $cfg->{$key};
        }

        }
    
	# Finally try to get it from the default values
	unless (defined $value) {
		$value = core_cfg($key);
    }

	# Substitute any reference to another token in the configuration value
	if (defined $value) {
		$value =~ s/\$\{(.*?)\}/cfg($1, $tenant)/ge;
	}

	# Raise an error if token is mandatory and not defined
	if ($mandatory and not defined $value) {
        LOGDIE "mandatory configuration entry $key missing";
    }

	return $value;
}

sub cfg_keys {
    $cfg // reload;
	my $tenant = shift // -1;

	my @keys_array = ();
	push @keys_array, core_cfg_keys;
	push @keys_array, keys %$cfg;
	push @keys_array, map { $_->key } QVD::DB::Simple::rs('Config')->search({tenant_id => -1});
	push @keys_array, map { $_->key } QVD::DB::Simple::rs('Config')->search({tenant_id => $tenant}) if $tenant != -1;

	return uniq(@keys_array);
}

1;

__END__

=head1 NAME

QVD::Config - Retrieve QVD configuration from database.

=head1 SYNOPSIS

This module encapsulate configuration access.

    use QVD::Config;
    my $foo = cfg('field');
    my $bar = cfg('bar', $tenant_id);

=head1 DESCRIPTION

Module to retrieve active configuration for each tenant.

=head2 FUNCTIONS

=over

=item cfg($key)

=item cfg($key, $tenant_id)

Returns the configuration associated to the given key for a given tenant.

If no tenant is defined, the value -1 for global configuration is used.

If no entry exists on the database, it returns the default value if
given or otherwise undef.

=item cfg_keys

=item cfg_keys($tenant_id)

Returns the all the configuration keys for a given tenant.

If no tenant is defined, the value -1 for global configuration is used.

If no entry exists on the database, it returns an empty array.

=back

=head1 AUTHORS

Francisco Trapero Cerezo (ftrapero@qindel.com)

Hugo Cornejo (hcornejo at qindel.com)

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
