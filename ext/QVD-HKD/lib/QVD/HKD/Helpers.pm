package QVD::HKD::Helpers;

use strict;
use warnings;
use Carp;

use Exporter;

our @EXPORT_OK = qw(croak_invalid_opts mkpath boolean_db2perl);
our @CARP_NOT;
my %CARP_NOT;

sub import {
    $CARP_NOT{caller()} = 1;
    @CARP_NOT = keys %CARP_NOT;
    goto &Exporter::import;
}

sub croak_invalid_opts (\%) {
    my $opts = shift;
    croak "invalid option(s) '".join("', '", sort keys %$opts)."'"
        if %$opts;
}

sub mkpath {
    my ($path, $mask) = @_;
    $mask ||= 0755;
    my @dirs;
    my @parts = File::Spec->splitdir(File::Spec->rel2abs($path));
    while (@parts) {
        my $dir = File::Spec->join(@parts);
        if (-d $dir) {
            -d $_ or mkdir $_, $mask or return for @dirs;
            return -d $path;
        }
        unshift @dirs, $dir;
        pop @parts;
    }
    return;
}

sub boolean_db2perl {
    my $v = shift // return;
    ($v eq 'f' ? undef : $v);
}

1;
