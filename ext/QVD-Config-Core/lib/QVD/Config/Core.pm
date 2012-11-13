package QVD::Config::Core;

our $VERSION = '0.01';

use warnings;
use strict;

use Config::Properties;
use QVD::Config::Core::Defaults;
my $core_cfg = Config::Properties->new($QVD::Config::Core::defaults);

use Exporter qw(import);
our @EXPORT = qw(core_cfg core_cfg_all core_cfg_keys save_core_cfg set_core_cfg);

our @FILES;
@FILES = '/etc/qvd/node.conf' unless @FILES;

for my $FILE (@FILES) {
    open my $cfg_fh, '<', $FILE or next;
    $core_cfg = Config::Properties->new(defaults => $core_cfg);
    $core_cfg->load($cfg_fh);
    close $cfg_fh;
}

sub core_cfg {
    my $key = shift;
    my $mandatory = shift // 1;
    my $value = $core_cfg->getProperty($key);
    if (defined $value) {
	$value =~ s/\$\{(.*?)\}/core_cfg($1)/ge;
    }
    elsif ($mandatory) {
	die "Configuration entry for $key missing\n";
    }
    $value;
}

sub core_cfg_all {
    map { $_ => core_cfg($_) } $core_cfg->propertyNames
}

sub core_cfg_keys { $core_cfg->propertyNames }

sub set_core_cfg {
    $core_cfg->changeProperty(@_);
}

sub save_core_cfg {
    my $path = shift;
    open my $cfg_fh, '>', $path
	or die "Unable to save configuration to '$path': $^E";
    $core_cfg->save($cfg_fh);
    close $cfg_fh;
}

1;

__END__

=head1 NAME 

QVD::Config::Core - Core QVD Configuration

=head1 SYNOPSYS

TODO

=head1 DESCRIPTION

TODO

=head1 AUTHORS

The QVD Team (qvd@qindel.com) 

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

