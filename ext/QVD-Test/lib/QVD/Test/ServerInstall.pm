package QVD::Test::ServerInstall;
use parent qw(QVD::Test);

use strict;
use warnings;

use Test::More	qw(no_plan);

sub check_environment : Test(startup => 3) {
    is($^O, 'linux', 'Node installation can be tested only on linux');

    open my $issue_fh, '<', '/etc/issue';
    my $issue = <$issue_fh>;
    close $issue_fh;

    chomp $issue;
    if ($issue =~ /Ubuntu ([.0-9]+)/) {
	my $version = $1;
	ok(version->parse("v$version") ge 'v10.04',
	    "Detected Ubuntu $version, need at least 10.04");
    } else {
	fail("Not Ubuntu linux (I read $issue from /etc/issue)");
    }

    open my $sources_fh, '<', '/etc/apt/sources.list';
    my @sources = <$sources_fh>;
    close $sources_fh;
    @sources = grep m!^deb http://qvd.qindel.com/debian!, @sources;
    ok(@sources, 		'Presence of QVD debian repository in sources.list');
}

sub install_node : Test(6) {
    ok(!system('apt-get -y --force-yes install qvd-node'), 'Installing qvd-node') 
	or return "qvd-node not installed";
    
    ok(-x '/usr/bin/qvd-noded.pl', 	'Existence of qvd-noded.pl');
    ok(-x '/etc/init.d/qvd-node',	'Existence of qvd-noded init script');

    ok(!system('dpkg -l qemu-kvm'),	'Presence of qemu-kvm');
    ok(!system('dpkg -l dnsmasq'),	'Presence of dnsmasq');

    ok(!system('apt-get -y purge qvd-node'), 'Purging qvd-node');

    # remove automatically installed dependencies
    system('apt-get -y autoremove');
}

sub install_wat : Test(3) {
    ok(!system('apt-get -y --force-yes install qvd-wat'), 'Installing qvd-wat') 
	or return "qvd-wat not installed";

    ok(-x '/etc/init.d/qvd-wat', 'qvd-wat init script is installed');

    ok(!system('apt-get -y purge qvd-wat'), 'Purging qvd-wat');

    # remove automatically installed dependencies
    system('apt-get -y autoremove');
}

1;
