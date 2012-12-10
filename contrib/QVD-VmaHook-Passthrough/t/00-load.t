#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::VmaHook::Passthrough' ) || print "Bail out!\n";
}

diag( "Testing QVD::VmaHook::Passthrough $QVD::VmaHook::Passthrough::VERSION, Perl $], $^X" );
