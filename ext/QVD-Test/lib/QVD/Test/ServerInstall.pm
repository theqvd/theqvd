package QVD::Test::ServerInstall;
use parent qw(QVD::Test);

use strict;
use warnings;

use Test::More	qw(no_plan);
use File::Slurp qw(slurp);

sub check_environment : Test(startup => 3) {
    is($^O, 'linux', 'Node installation can be tested only on linux');

    my $issue = slurp('/etc/issue');
    chomp $issue;
    if ($issue =~ /Ubuntu ([.0-9]+)/) {
	my $version = $1;
	ok(version->parse("v$version") ge 'v10.04',
	    "Detected Ubuntu $version, need at least 10.04");
    } else {
	fail("Not Ubuntu linux (I got $issue from /etc/issue)");
    }

    my @sources = grep m!^deb http://qvd.qindel.com/debian!, slurp('/etc/apt/sources.list');
    ok(scalar @sources, 'Check QVD debian repository in sources.list');


}

sub install_node : Test(4) {
    ok(!system('apt-get -y --force-yes install qvd-node'), 'Installing qvd-node') 
	or return "qvd-node not installed";
    
    ok(-x '/usr/bin/qvd-noded.pl', 'qvd-noded.pl is installed');
    ok(-x '/etc/init.d/qvd-node', 'qvd-noded init script is installed');

    ok(!system('apt-get -y purge qvd-node'), 'Purging qvd-node');

    # remove automatically installed dependencies
    system('apt-get -y autoremove');
}

sub install_wat : Test(3) {
    ok(!system('apt-get -y --force-yes install qvd-wat'), 'Installing qvd-wat') 
	or return "qvd-wat not installed";

    ok(-x '/etc/init.d/qvd-node', 'qvd-noded init script is installed');

    ok(!system('apt-get -y purge qvd-wat'), 'Purging qvd-wat');

    # remove automatically installed dependencies
    system('apt-get -y autoremove');
}

1;
