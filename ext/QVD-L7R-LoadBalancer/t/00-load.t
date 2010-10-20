#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::L7R::LoadBalancer' ) || print "Bail out!
";
}

diag( "Testing QVD::L7R::LoadBalancer $QVD::L7R::LoadBalancer::VERSION, Perl $], $^X" );
