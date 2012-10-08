#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::CommandInterpreter' ) || print "Bail out!
";
}

diag( "Testing QVD::CommandInterpreter $QVD::CommandInterpreter::VERSION, Perl $], $^X" );
