#!/usr/bin/perl -w
use strict;
use Cwd;
use Win32::Console::ANSI;
use Term::ANSIColor;
use File::Copy;
use File::Copy::Recursive qw(dircopy);
use File::Basename;
use Getopt::Long;

my $no_debug_installer;

GetOptions("--no-debug-installer" => \$no_debug_installer);

$| = 1;

my ($VER_MAJOR, $VER_MINOR, $VER_REVISION, $VER_BUILD, $VER_STRING, $VER_STRING_COMPACT);
my ($GIT_COMMIT, $GIT_TAG, $GIT_BRANCH);

$VER_BUILD = $ENV{BUILD_NUMBER} // 0;

my $color = 1;
my $prog = $ENV{PROGRAMFILES};
my $swperl = 'C:\strawberry';
my $gettext = "C:\\gettext";



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
		"$swperl\\perl\\site\\lib\\auto\\Net\\SSLeay\\libeay32.xs.dll",
		"$swperl\\perl\\site\\lib\\auto\\Net\\SSLeay\\ssleay32.xs.dll",
		"$swperl\\perl\\site\\lib\\auto\\Net\\SSLeay\\ssleay.xs.dll",
		
		"$swperl\\perl\\vendor\\lib\\auto\\Net\\SSLeay\\libeay32.dll",
		"$swperl\\perl\\vendor\\lib\\auto\\Net\\SSLeay\\ssleay32.dll",
		"$swperl\\perl\\vendor\\lib\\auto\\Net\\SSLeay\\ssleay.dll",
		"$swperl\\perl\\vendor\\lib\\auto\\Net\\SSLeay\\libeay32.xs.dll",
		"$swperl\\perl\\vendor\\lib\\auto\\Net\\SSLeay\\ssleay32.xs.dll",
		"$swperl\\perl\\vendor\\lib\\auto\\Net\\SSLeay\\ssleay.xs.dll",	
	],
	[
		"$swperl\\perl\\site\\lib\\auto\\Crypt\\OpenSSL\\X509\\X509.dll",
		"$swperl\\perl\\site\\lib\\auto\\Crypt\\OpenSSL\\X509\\X509.xs.dll"
	],
	"$swperl\\c\\bin\\libeay32_.dll",
	"$swperl\\c\\bin\\ssleay32_.dll",
	"$swperl\\c\\bin\\zlib1_.dll",

	"$swperl\\c\\bin\\libiconv-2_.dll",
	"$gettext\\bin\\libintl3.dll",
	"$gettext\\bin\\libasprintf-0.dll",
	"$gettext\\bin\\libgcc_s_dw2-1.dll",
	"$gettext\\bin\\libgettextlib-0-18-1.dll",
	"$gettext\\bin\\libgettextpo-0.dll",
	"$gettext\\bin\\libgettextsrc-0-18-1.dll"
);


my @modules = (
	"X11::Protocol::Ext::XC_MISC"
);

foreach my $dir (@paths) {
	die "Failed to find path '$dir'" unless ( -d $dir );
	$ENV{PATH} .= ";\"$dir\"";
}

msg("PATH: $ENV{PATH}\n");


my $perl_bin      = find_binary_path("perl.exe", "$swperl/perl/bin/", $ENV{PATH});
my $pp_bin        = find_binary_path("pp", "$swperl/perl/site/bin/",dirname($perl_bin) . "/../site/bin",  $ENV{PATH});
my $reshacker_bin = find_binary_path(["reshacker.exe", "ResourceHacker.exe"], "$prog/Resource Hacker", $ENV{PATH});
my $git_bin       = find_binary_path("git.exe", "$prog/git", "c:\\cygwin\\bin", $ENV{PATH});
my $gorc_bin      = find_binary_path("GoRC.exe", "$prog/GoRC", $ENV{PATH});


msg("Adding $swperl\\c\\lib to PATH\n");
$ENV{PATH} = "$ENV{PATH};$swperl\\c\\lib";



# This environment variable tells the client it's being called in a PP
# build. That will make it exit automatically. This makes automated
# builds work.

$ENV{QVD_PP_BUILD} = 1;

set_git_info();
msg("Writing version resource file...\n");
write_version_rc("version.rc");

msg("Compiling version resource file...\n");
run($gorc_bin, "/fo", "version.res", "version.rc");



msg("Looking for wxWidgets DLL directory... ");
my $wxglob = $swperl . '\perl\site\lib\Alien\wxWidgets\msw*';
my $wxdir  = glob($wxglob);
die "Failed to match $wxglob" unless ( -d $wxdir );
msg("$wxdir\n");

msg("Looking for wxWidgets DLLs...\n");

foreach my $pat ( 'wxbase*.dll', 'wxmsw*_adv_*.dll', 'wxmsw*_core_*.dll') {
    my $wxglob   = "$wxdir\\lib\\$pat";
	my @dllpaths = grep { !/(net|xml)/ } glob( $wxglob );
	die "Failed to match $wxglob" unless ( @dllpaths );
	msg("\t$pat:\n");
	
	foreach my $f (@dllpaths) {
		msg("\t\t$f\n");
	}
	
	push @dlls, @dllpaths;
}


msg("Clearing output folder...\n");
unlink glob('..\Output\*');
	
	
msg("Generating locale...\n");
my $installer_dir = getcwd();
chdir("..\\..\\ext\\QVD-Client") or die "Can't chdir to QVD-Client directory";
run("perl", "Build.PL");
run("perl", "Build");

msg("Copying locale files...\n");
dircopy("blib\\locale", "..\\..\\windows\\installer\\locale") or die "Failed to copy locale files";
chdir($installer_dir);


run("exetype", "NX\\nxproxy.exe", "WINDOWS");

my @pp_args = ("-vvv", "-x", 
    mklist('-I', 'dir', @includes),
 	mklist('-l', 'file', @dlls),
	mkmodlist( @modules),
	'-o', 'qvd-client-1.exe', '-log', 'pp.log',
	'..\..\ext\QVD-Client\bin\qvd-gui-client.pl');

run($pp_bin, "-gui", @pp_args);

run($reshacker_bin, "-addoverwrite", "qvd-client-1.exe, qvd-client-2.exe, pixmaps\\qvd.ico,icongroup,WINEXE,");
run($reshacker_bin, "-addoverwrite", "qvd-client-2.exe, qvd-client.exe, version.res,,,");

unlink('qvd-client-1.exe');
unlink('qvd-client-2.exe');
unlink glob('..\Output\*');
mkdir "..\\archive";


build_installer();

msg("Preparing debug version\n");


unless( $no_debug_installer ) {
	msg("Generating debug installer\n");
	run("pp", @pp_args);
	run("exetype", "NX\\nxproxy.exe", "CONSOLE");

	build_installer("--suffix -debug");
} else {
	msg("Debug installer disabled, skipping");
}

	
msg("Undoing changes to nxproxy\n");
run($git_bin, "checkout", is_cygwin($git_bin) ? "NX/nxproxy.exe" : "NX\\nxproxy.exe");

msg("Done!\n");

sub build_installer {
	my ($extra_opts) = @_;
	
	
	run($perl_bin, "..\\script.pl", "--version=$VER_STRING_COMPACT", "--output=..\\script.iss");
	run("ISCC.exe", "..\\script.iss");
	
	my ($filename) = glob("..\\Output\\*");
	$filename = basename($filename);
	$filename =~ s/\.exe$//;
	
	rename("pp.log", "..\\Output\\${filename}.log");
	
	for my $file ( glob("..\\Output\\*" )) {
		copy($file, "..\\archive\\" . basename($file));
	}
}

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

sub find_binary_path {
	my ($arg_binaries, @paths) = @_;
	
	
	my @binaries = ref($arg_binaries) eq "ARRAY" ? @$arg_binaries :  ($arg_binaries);
	@paths = map { split /;/ } @paths;
	

	my $fullpath;
	my $bin;
	my $path;
	
	msg("Trying to find ");
	my $first_bin = 1;
	my $found;
	
	foreach $bin (@binaries) {
		msg(" or ") unless ($first_bin);
		msg($bin);
		undef $first_bin;
		
		foreach $path (@paths) {
			$fullpath = File::Spec->catdir($path, $bin);
			if ( -f $fullpath ) {
				$found = 1;
				last;
			}
			
		}
	}
	msg("... ");
	
	if ( $found ) {
		msg("Found at $fullpath\n");
		return $fullpath;
	} else {
		die "Not found! Tried looking at: " . join("\n", @paths);
	}
}

# Check whether a binary cygwin one.
# Currently using a rather simplistic approach.
sub is_cygwin {
	my ($file) = @_;
	my $buf = "";
	my $buf2 = "";
	my $read;
	my $read_size = 1024;
	
	my $is_cygwin = 0;
	
	open(my $fh, '<', $file) or die "Can't open $file: $!";
	while( ($read = read($fh, $buf, $read_size)) > 0 ) {
		# Keep twice the read size in memory to deal with the possibility
		# of the string being split across reads.
		
		$buf2 .= $buf;
		if ( $buf2 =~ /cygwin\d+\.dll/ ) {
			$is_cygwin = 1;
			last;
		}
		$buf2 = substr($buf2, $read_size) if length($buf) > $read_size;
	}
	close $file;
	
	return $is_cygwin;
	
}


sub mkmodlist {
	# TODO: do verification
	
	my (@modules) = @_;
	my @ret;
	
	foreach my $mod (@modules) {
		my $ret = system("perl", "-M$mod", "-e", "CORE::say 'Module $mod works';");
		if (!$ret) {
			push @ret, '-M', $mod;
		} else {
			die "Module $mod not found";
		}
	}
	
	return @ret;
}
sub run {
	my @args = @_;
	my $cmd = join(' ', @args);
	msg("Running: $cmd\n");
	!system(@args) or die "Failed to run $cmd: $!";
}


sub get_stdin {
	my @args = @_;
	my $cmd = join(' ', @args);
	msg("Running: $cmd\n");
	open(my $fh, '-|', @args) or die "Failed to execute $cmd: $!";
	local $/; undef $/;
	my $data = <$fh>;

	# We may invoke unix or windows style tools in here, so make sure
	# the endline gets chomped off either way.
	$data =~ s/\n+$//;
	$data =~ s/\r+$//;
	chomp $data;

	close $fh;

	if ( $? & 127 ) {
		die "Command $cmd died with signal " . ( $? & 127 ) . (($? & 128) ? ' with' : ' without') . " coredump";
	} elsif ( $? >> 8 ) {
		die "Command $cmd exited with return code $?";
	}

	return $data;
}

sub set_git_info {
	my $no_revision;
	my $no_build;

	msg("Retrieving git info...\n");
	$GIT_COMMIT = get_stdin($git_bin, "rev-parse", "--verify", "HEAD");
	$GIT_TAG    = get_stdin($git_bin, "name-rev", "--tags", "--name-only", $GIT_COMMIT);
	$GIT_BRANCH = get_stdin($git_bin, "rev-parse", "--abbrev-ref", "HEAD");

	msg("\tCommit: $GIT_COMMIT\n");
	msg("\tTag   : $GIT_TAG\n");
	msg("\tBranch: $GIT_BRANCH\n");
	msg("\n");

	if ( $GIT_TAG !~ /undefined/ ) {
		if ( $GIT_TAG =~ /^QVD-(\d+)\.(\d+)\.(\d+)(\^.*)?$/ ) {
			($VER_MAJOR, $VER_MINOR, $VER_REVISION) = ($1, $2, $3);
			$no_build = 1; 
			msg("\tWe're currently on a tag\n");
		} else {
			die "Don't know how to parse tag $GIT_TAG";
		}
	} elsif ( $GIT_BRANCH =~ /^QVD-(\d+)\.(\d+)$/ ) {
		msg("\tWe're currently on a branch\n");
		($VER_MAJOR, $VER_MINOR, $VER_REVISION) = ($1, $2, 0);
		$no_revision = 1;
	} else {
		msg("\tWe're currently on a feature branch. The version number is unknown.\n");
		($VER_MAJOR, $VER_MINOR, $VER_REVISION) = (0,0,0);
	}

	if ( $VER_MAJOR > 0 ) {
		$VER_STRING = "${VER_MAJOR}.${VER_MINOR}";
		$VER_STRING .= ".${VER_REVISION}" unless( $no_revision );
		$VER_STRING .= ", build $VER_BUILD";

		$VER_STRING_COMPACT  = "${VER_MAJOR}.${VER_MINOR}";
		$VER_STRING_COMPACT .= ".${VER_REVISION}" unless( $no_revision );
		$VER_STRING_COMPACT .= "-${VER_BUILD}" unless ($no_build);
	} else {
		$VER_STRING = "$GIT_BRANCH, build $VER_BUILD";
		$VER_STRING_COMPACT = "${GIT_BRANCH}-${VER_BUILD}";
	}
	msg("\tVersion number: $VER_MAJOR, $VER_MINOR, $VER_REVISION, $VER_BUILD\n");
	msg("\tVersion string: $VER_STRING\n");

}

sub write_version_rc {
	my ($filename) = @_;
	my $year = (localtime)[5] + 1900;

	open(my $fh, '>', $filename) or die "Can't create $filename: $!";
	print $fh <<VER;
VS_VERSION_INFO VERSIONINFO
    FILEVERSION    $VER_MAJOR,$VER_MINOR,$VER_REVISION,$VER_BUILD
    PRODUCTVERSION $VER_MAJOR,$VER_MINOR,$VER_REVISION,$VER_BUILD
{
    BLOCK "StringFileInfo"
    {
        BLOCK "040904b0"
        {
            VALUE "CompanyName",        "Qindel Group\0"
            VALUE "FileDescription",    "QVD Client\0"
            VALUE "FileVersion",        "$VER_STRING ($GIT_COMMIT)\0"
            VALUE "LegalCopyright",     "© $year Qindel Group. All Rights Reserved\0"
            VALUE "OriginalFilename",   "QVD Client.exe\0"
            VALUE "ProductName",        "QVD\0"
            VALUE "ProductVersion",     "$VER_STRING ($GIT_COMMIT)\0"
        }
    }
    BLOCK "VarFileInfo"
    {
        VALUE "Translation", 0x409, 1200
    }
}
VER
	close $fh;

}

sub msg {
	my ($msg) = @_;
	print color 'bold green' if ($color);
	print $msg;
	print color 'reset';
}
