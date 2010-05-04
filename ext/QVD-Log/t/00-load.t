#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::Log' ) || print "Bail out!
";
}

diag( "Testing QVD::Log $QVD::Log::VERSION, Perl $], $^X" );
