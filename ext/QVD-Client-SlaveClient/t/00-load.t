#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::SlaveServer' ) || print "Bail out!\n";
}

diag( "Testing QVD::SlaveServer $QVD::SlaveServer::VERSION, Perl $], $^X" );
