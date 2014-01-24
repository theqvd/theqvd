#!perl -T
use 5.10;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'QVD::SlaveClient' ) || print "Bail out!\n";
}

diag( "Testing QVD::SlaveClient $QVD::SlaveClient::VERSION, Perl $], $^X" );
