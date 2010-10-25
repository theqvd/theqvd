#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::L7R::Authenticator::Plugin::Auto' ) || print "Bail out!
";
}

diag( "Testing QVD::L7R::Authenticator::Plugin::Auto $QVD::L7R::Authenticator::Plugin::Auto::VERSION, Perl $], $^X" );
