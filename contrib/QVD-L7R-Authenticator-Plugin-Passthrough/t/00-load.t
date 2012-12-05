#!perl

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::L7R::Authenticator::Plugin::Passthrough' ) || print "Bail out!\n";
}

diag( "Testing QVD::L7R::Authenticator::Plugin::Passthrough $QVD::L7R::Authenticator::Plugin::Passthrough::VERSION, Perl $], $^X" );
