#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN { use_ok 'Catalyst::Test', 'QVD::Client::Agent' }

ok( request('/')->is_success, 'Request should succeed' );

done_testing();
