#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'QVD::EasyCustomize' ) || print "Bail out!\n";
}

diag( "Testing QVD::EasyCustomize $QVD::EasyCustomize::VERSION, Perl $], $^X" );
