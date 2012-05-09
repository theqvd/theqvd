#!perl -T

use Test::More;
use strict;
use warnings;
use version;

my $DEBUG;
my $REPO =  "nfs://sles11-sp2-dev/usr/src/packages";

%ENV = ();
$ENV{PATH} = "/bin:/sbin:/usr/bin:/usr/sbin:/usr/lib/qvd/bin";

if ( $^O ne "linux" ) {
	plan skip_all => 'Node installation can be tested only on linux';
}


if ( open(SR, '<', '/etc/SuSE-release' ))  {
	my ($ver, $rev);

	while(my $line = <SR>) {
		chomp $line;
		$ver = $1 if ( $line =~ /VERSION = (\d+)/ );
		$rev = $1 if ( $line =~ /PATCHLEVEL = (\d+)/ );
	}

	plan tests => 45;

	ok(version->parse("v$ver.$rev") ge 'v11.2', "Detected SLES $ver.$rev, need at least 11.2");
} else {
	plan skip_all => "Not SuSE linux (/etc/SuSE-release not found)";
}


my $ret = check_repo("QVD", $REPO);
ok( 1, "Check repository" );

SKIP: {
	skip( "Repository deletion not needed", 1 ) if ( $ret != -1 );
	ok( run("zypper", "removerepo", "QVD" ), "Remove repository" );
}

SKIP: {
	skip( "Repository addition not needed", 1 ) if ( $ret == 1 );
	ok( run("zypper", "addrepo", "--gpg-auto-import-keys" ,"-c", $REPO, "QVD"), "Add repository");
}


ok( inst_pkg("perl-QVD-Node"), 'Installing qvd-node');

ok(-x '/usr/lib/qvd/bin/qvd-hkd',  'Existence of qvd-hkd');
ok(-x '/etc/init.d/qvd-hkd',   'Existence of HKD init script');

ok(-x '/usr/lib/qvd/bin/qvd-l7r',  'Existence of qvd-l7r');
ok(-x '/etc/init.d/qvd-l7r',   'Existence of L7R init script');

ok( check_pkg("kvm"), "Presence of KVM package");
ok( check_pkg("dnsmasq"), "Presence of dnsmasq package");


for my $pkg qw( perl-QVD-HTTP qvd-lxc perl-QVD-Config perl-QVD-HKD perl-QVD-L7R-LoadBalancer perl-QVD-URI qvd-fuse-unionfs qvd-node-libs
                perl-QVD-StateMachine-Declarative perl-QVD-HTTPC perl-QVD-HTTPD perl-QVD-SimpleRPC perl-QVD-L7R qvd-perl qvd-common-libs
		perl-QVD-Log perl-QVD-DB perl-QVD-Node ) {

	ok(del_pkg($pkg), "Remove $pkg");
}

my $count = `find /usr/lib/qvd -type f | wc -l`;
ok( $? == 0 && $count == 0, "No files remain in /usr/lib/qvd" );

ok( inst_pkg("perl-QVD-Admin-Web" ));


ok(-x '/usr/lib/qvd/bin/qvd_admin_web_cgi.pl',  'Existence of qvd_admin_web_cgi.pl');
ok(-x '/etc/init.d/qvd-wat',   'Existence of WAT init script');


for my $pkg qw( qvd-perl perl-QVD-Log perl-QVD-Admin-Web qvd-common-libs perl-QVD-Config perl-QVD-DB perl-QVD-Admin
                qvd-admin-web-libs perl-QVD-L7R-LoadBalancer ) {
	ok(del_pkg($pkg), "Remove $pkg");
}

$count = `find /usr/lib/qvd -type f | wc -l`;
ok( $? == 0 && $count == 0, "No files remain in /usr/lib/qvd" );

ok( inst_pkg("perl-QVD-Node" ));
ok( inst_pkg("perl-QVD-Admin-Web" ));
ok( inst_pkg("QVD-default-config" ));

sub run {
	my @cmd = @_;
	my $cmd_str = join(" ", @cmd);

	print "CMD: $cmd_str\n" if ( $DEBUG );
	
	system(@cmd);

	if ( $? == -1 ) {
		warn "Failed to execute '$cmd_str': $!";
		return undef;
	} elsif ( $? & 127 ) {
		warn sprintf("Command '$cmd_str' died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without');
		return undef;
	} elsif ( ($? >> 8) > 0 )  {
		warn sprintf("Command '$cmd_str' exited with signal %d", $? >> 8);
		return undef;
	}

	return 1;
}

sub check_repo {
	my ($repo, $url) = @_;

	$ENV{LC_ALL} = "C";
	my @out = `zypper lr $repo`;
	chomp @out;
	foreach my $line (@out) {
		if ( $line =~ /^Repository .*? not found by its alias, number, or URI./ ) {
			return 0;
		}

		if ( $line =~ /^URI\s+: (.*?)$/ ) {
			if ( $1 eq $url ) {
				return 1;
			} else {
				return -1;
			}
		}
	}
}

sub check_pkg {
	my $pkg = shift;
	return run("rpm", "--quiet", "-q", $pkg);
}

sub inst_pkg {
	my $pkg = shift;
	return run("zypper", "-n", "-q", "install", $pkg);

}

sub del_pkg {
	my $pkg = shift;
	return run("zypper", "-n", "-q", "remove", $pkg);
}
