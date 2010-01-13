package QVD::Config::SSL;

our $VERSION = '0.01';

use warnings;
use strict;

use QVD::DB::Simple;

sub get {
    my ($class, $key) = @_;
    my $slot = rs(SSL_Config)->search({ key => $key })->first;
    defined $slot ? $slot->value : undef;
}

1;
