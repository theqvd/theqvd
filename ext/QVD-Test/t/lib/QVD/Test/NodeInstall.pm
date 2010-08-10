package QVD::Test::NodeInstall;
use parent qw(QVD::Test);

use Test::More;

sub check_environment : Test(startup) {
    BAIL_OUT('Environment check not implemented');
}


1;
