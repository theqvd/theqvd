package QVD::Config::SSL;

our $VERSION = '0.01';

use warnings;
use strict;

use QVD::DB::Simple;

use Exporter qw(import);
our @EXPORT = qw(ssl_cfg);

sub ssl_cfg {
    my $slot = rs(SSL_Config)->search({ key => $_[0] })->first;
    defined $slot ? $slot->value : undef;
}

1;
