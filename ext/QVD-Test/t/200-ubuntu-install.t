#!perl 
use Test::More;
use strict;
use warnings;
use version;

if ( $^O ne 'linux' ) {
	plan  skip_all => "Test only works on Linux ($^O detected)";
}


if ( -x "/usr/bin/lsb_release" ) {
	my $distributor = `/usr/bin/lsb_release -i`;

	if ( $distributor !~ /Ubuntu/ ) {
		plan skip_all => "Distributor $distributor is not Ubuntu linux";
	}

	my $ver = `/usr/bin/lsb_release -r`;
	$ver =~ /:\s+([.0-9]+)/;

	plan tests => 11;
	ok(version->parse("v$ver") ge 'v10.04', "Detected Ubuntu $ver, need at least 10.04");
} else {
	plan skip_all => "Not Ubuntu linux (/usr/bin/lsb_release not found)";
}


open my $sources_fh, '<', '/etc/apt/sources.list';
my @sources = <$sources_fh>;
close $sources_fh;
@sources = grep m!^deb http://qvd.qindel.com/debian!, @sources;
ok(@sources, 		'Presence of QVD debian repository in sources.list');

ok(!system('apt-get -y --force-yes install qvd-node'), 'Installing qvd-node') 
or return "qvd-node not installed";

ok(-x '/usr/bin/qvd-noded.pl', 	'Existence of qvd-noded.pl');
ok(-x '/etc/init.d/qvd-node',	'Existence of qvd-noded init script');

ok(!system('dpkg -l qemu-kvm'),	'Presence of qemu-kvm');
ok(!system('dpkg -l dnsmasq'),	'Presence of dnsmasq');

ok(!system('apt-get -y purge qvd-node'), 'Purging qvd-node');

# remove automatically installed dependencies
system('apt-get -y autoremove');

ok(!system('apt-get -y --force-yes install qvd-wat'), 'Installing qvd-wat') 
or return "qvd-wat not installed";

ok(-x '/etc/init.d/qvd-wat', 'qvd-wat init script is installed');

ok(!system('apt-get -y purge qvd-wat'), 'Purging qvd-wat');

# remove automatically installed dependencies
system('apt-get -y autoremove');

1;
