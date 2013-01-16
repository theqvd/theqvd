#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'QVD::UntarDIs' ) || print "Bail out!\n";
}

diag( "Testing QVD::UntarDIs $QVD::UntarDIs::VERSION, Perl $], $^X" );
