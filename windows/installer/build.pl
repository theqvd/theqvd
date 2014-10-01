#!/usr/bin/perl -w
use strict;
$| = 1;

my $prog = $ENV{PROGRAMFILES};
my $swperl = 'C:\strawberry';

my @paths = (
	"$prog\\Resource Hacker",
	"$prog\\Inno Setup 5"
);

my @includes = (
	'..\\..\\ext\\IO-Socket-Forwarder\\lib',
	'..\\..\\ext\\QVD-Config\\lib',
	'..\\..\\ext\\QVD-Config-Core\\lib',
	'..\\..\\ext\\QVD-Client\\lib',
	'..\\..\\ext\\QVD-HTTP\\lib',
	'..\\..\\ext\\QVD-HTTPC\\lib',
	'..\\..\\ext\\QVD-Log\\lib',
	'..\\..\\ext\\QVD-URI\\lib'
);

my @dlls = (
	[
		"$swperl\\perl\\site\\lib\\auto\\Net\\SSLeay\\libeay32.dll",
		"$swperl\\perl\\site\\lib\\auto\\Net\\SSLeay\\ssleay32.dll",
		"$swperl\\perl\\site\\lib\\auto\\Net\\SSLeay\\ssleay.dll",
	],
	"$swperl\\c\\bin\\libeay32_.dll",
	"$swperl\\c\\bin\\ssleay32_.dll",
	"$swperl\\c\\bin\\zlib1_.dll",
	"$swperl\\perl\\site\\lib\\auto\\Crypt\\OpenSSL\\X509\\X509.dll"
);

foreach my $dir (@paths) {
	die "Failed to find path '$dir'" unless ( -d $dir );
	$ENV{PATH} .= ";\"$dir\"";
}

print "PATH: $ENV{PATH}\n";

# This environment variable tells the client it's being called in a PP
# build. That will make it exit automatically. This makes automated
# builds work.

$ENV{QVD_PP_BUILD} = 1;

print "Looking for wxWidgets DLL directory... ";
my $wxglob = $swperl . '\perl\site\lib\Alien\wxWidgets\msw*';
my $wxdir  = glob($wxglob);
die "Failed to match $wxglob" unless ( -d $wxdir );
print "$wxdir\n";

print "Looking for wxWidgets DLLs...\n";

foreach my $pat ( 'wxbase*.dll', 'wxmsw*_adv_*.dll', 'wxmsw*_core_*.dll') {
    my $wxglob   = "$wxdir\\lib\\$pat";
	my @dllpaths = grep { !/(net|xml)/ } glob( $wxglob );
	die "Failed to match $wxglob" unless ( @dllpaths );
	print "\t$pat:\n";
	
	foreach my $f (@dllpaths) {
		print "\t\t$f\n";
	}
	
	push @dlls, @dllpaths;
}


run("exetype", "NX\\nxproxy.exe", "WINDOWS");

run("pp", "-vvv", "-x", "-gui", 
    mklist('-I', 'dir', @includes),
 	mklist('-l', 'file', @dlls),
	'-o', 'qvd-client-1.exe',
	'..\..\ext\QVD-Client\bin\qvd-gui-client.pl');
	





run("reshacker -addoverwrite qvd-client-1.exe, qvd-client.exe, pixmaps\\qvd.ico,icongroup,WINEXE,");
unlink('qvd-client-1.exe');
unlink glob('..\Output\*');

run("perl ..\\script.pl >..\\script.iss");
run("ISCC.exe ..\\script.iss");



sub mklist {
	my ($arg, $type, @paths) = @_;
	my @ret;
	my $missing;
	
	foreach my $path (@paths) {
		my @altpaths;
		
		if ( ref($path) eq "ARRAY" ) {
			@altpaths = @$path;
		} else {
			@altpaths = ($path);
		}
		
		my $exists;
		foreach my $alt ( @altpaths ) {
			if ( ($type eq "dir" && -d $alt) || $type eq "file" && -f $alt ) {
				$exists = 1;
				push @ret, $arg, $alt;
				last;
			}
		}
		
		unless ($exists) {
			warn "$type {" . join(', ', @altpaths) . "} doesn't exist";
			$missing = 1;
		}
		
		
	}
	die "Missing files" if ($missing);
	return @ret;
}

sub run {
	my @args = @_;
	my $cmd = join(' ', @args);
	print STDERR "Running: $cmd\n";
	
	!system(@args) or die "Failed to run $cmd: $!";
}