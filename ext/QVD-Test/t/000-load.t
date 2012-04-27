#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::Test' ) || print "Bail out!
";
}

diag( "Testing QVD::Test $QVD::Test::VERSION, Perl $], $^X" );
