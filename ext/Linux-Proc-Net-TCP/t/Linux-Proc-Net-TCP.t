#!/usr/bin/perl

use Test::More tests => 2;
use Linux::Proc::Net::TCP;

my $table = Linux::Proc::Net::TCP->read(files => ['t/sample_tcp']);
ok ($table);
is (scalar(@$table), 10);

__END__
