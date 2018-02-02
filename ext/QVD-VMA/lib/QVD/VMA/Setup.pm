package QVD::VMA::Setup;

use strict;
use warnings;
use 5.010;

BEGIN {
    # ensure we load the VMA configuration
    $QVD::Config::USE_DB = 0;
    @QVD::Config::Core::FILES = ('/etc/qvd/vma.conf');
}

1;
