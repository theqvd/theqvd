package QVD::HKD::Helpers;

use strict;
use warnings;
use Carp;

use Exporter;

our @EXPORT = qw(croak_invalid_opts);
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

1;
