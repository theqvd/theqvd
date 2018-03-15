#!/usr/bin/perl -w
use strict;
use File::Copy;
use File::Basename;
use Getopt::Long;

use lib::glob "ext/*/lib";

my $DEBUG = 0;

my $win_out_root     = "c:\\temp\\out";
my $win_src_root     = "c:\\temp\\src";
my $win_cygwin       = "c:\\cygwin";
my $win_nxproxy_path = "c:\\nxproxy";
my $win_wrapper_path = "c:\\wrapper";

my $win_vcxsrv_path  = "c:\\vcxsrv";
my $win_source_path  = "c:\\qvd-src";

my $perl = "perl";
my $script = "ext/QVD-Client/bin/qvd-gui-client.pl";


my ($opt_help, $opt_gdb, $opt_no_setup, $opt_cli);

sub info($) {
	print STDERR @_;
}

sub dbg($) {
	print STDERR @_ if ($DEBUG);
}





GetOptions("help"    => \$opt_help,
           "gdb"     => \$opt_gdb,
		   "cli"     => \$opt_cli,
		   "nosetup" => \$opt_no_setup) or die "Getopt failed: $!";
		   
if ( $opt_help ) {
	print <<HELP;
$0 [options] [client args]
Runs the QVD Client

Options:
	--help      Shows this text
	--gdb       Run perl under gdb
	--cli       Run the commandline client
	--nosetup   Skip the system setup phase on Win32

On Win32 this script will configure the settings and create a
slave channel wrapper to make everything work from the source tree.

HELP
	exit 0;
}

if ( $opt_cli ) {
	 $script = "ext/QVD-Client/bin/qvd-client.pl";
}

	

my @cmd = ($perl, "-Mlib::glob=ext/*/lib", $script, @ARGV);
my $cmd_str = join(' ', @cmd);

if ($opt_gdb) {
	unshift(@cmd, "gdb", "--args");
}

if ( $^O =~ /Win32/ ) {
	setup_windows_environment() unless ($opt_no_setup);
	# exec doesn't seem to work right on Win32
	info "\n\n";
	info "CMD: $cmd_str\n";
	info "=== Client start ===\n";
	system(@cmd);
} else {
    info "\n\n";
	info "CMD: $cmd_str\n";
	info "=== Client start ===\n";
	exec(@cmd) or die "Failed to exec: $!";
}



sub setup_windows_environment {
	print "Preparing Win32 environment...\n";
	
	print "Preparing nxproxy directory...\n";
	mkdir($win_nxproxy_path);

	copy_files("$win_src_root\\nxproxy\\nxcomp\\src\\.libs\\", $win_nxproxy_path, qr/.dll$/);
	
	for my $fn ("cygpng16-16.dll", "cygstdc++-6.dll", "cygwin1.dll", "cygz.dll") {
		copy_files("$win_cygwin\\bin\\$fn", $win_nxproxy_path);
	}
	
	
	my $config_file =  $ENV{"APPDATA"} . "\\QVD\\client.conf";
	no warnings;
	@QVD::Config::Core::FILES = ( $config_file );
	use warnings;
	require QVD::Config::Core;
	QVD::Config::Core->import('set_core_cfg', 'save_core_cfg', 'core_cfg');
	
	print "Preparing wrapper directory...\n";
	mkdir($win_wrapper_path);
	copy_files("$win_out_root\\qvd-slaveserver-wrapper\\qvd-slaveserver-wrapper.exe", $win_wrapper_path);
	copy_files("$win_cygwin\\bin\\cygwin1.dll", $win_wrapper_path);
	
	open(SLAVE_SCRIPT, ">", "$win_wrapper_path\\slaveserver.bat") or die "Can't create file: $!";
	print SLAVE_SCRIPT "\@echo off\n";
	print SLAVE_SCRIPT "perl -Mlib::glob=c:/qvd-src/ext/*/lib c:/qvd-src/ext/QVD-Client/bin/qvd-client-slaveserver\n";
	close SLAVE_SCRIPT;
	
	print "Setting up configuration\n";
	set_conf_exe('command.windows.win-sftp-server', "$win_out_root\\win-sftp-server\\win-sftp-server.exe");
	set_conf_exe('command.windows.pulseaudio'     , "$win_out_root\\pulseaudio\\bin\\pulseaudio.exe");	
	set_conf_exe('command.windows.vcxsrv'         , "$win_vcxsrv_path\\vcxsrv.exe");
	set_conf_exe('command.windows.nxproxy'        , "$win_nxproxy_path\\nxproxy.exe");
	set_conf_exe('client.slave.wrapper'           , "$win_wrapper_path\\qvd-slaveserver-wrapper.exe");
	set_conf_exe('client.slave.command'           , "$win_wrapper_path\\slaveserver.bat");
	
	save_core_cfg($config_file);	
}

sub set_conf_exe {
	my ($conf, $exe) = @_;
	
	if ( core_cfg($conf) eq $exe ) {
		dbg "Setting $conf already set\n";
		return;
	}
	
	print "\tSetting $conf to '$exe' ";
	
	if (! -f $exe ) {
		print " [not found!]\n";
	} else {
		print "\n";
	}
	
	set_core_cfg($conf, $exe);
}

sub copy_files {
	my ($source, $dest, $regex) = @_;
	
	if ( -f $source ) {
		if ( -d $dest ) {
			$dest .= "\\" . basename($source);
		}
		
		if (!-f $source) {
			die "Failed to find $source";
		}
		
		my @stat_a = stat($source);
		my @stat_b = stat($dest);
		if (!stat_equal(\@stat_a, \@stat_b)) {
			print "\tCopying $source to $dest\n";
			File::Copy::syscopy($source, $dest);
		}
	} elsif ( -d $source ) { 
		print "\tCopying: $source => $dest\n";
		
		opendir(DIR, $source) or die "Can't opendir $source: $!";
		while(my $f = readdir(DIR)) {
			my $file_a = "$source\\$f";
			my $file_b = "$dest\\$f";
			my @stat_a = stat($file_a);
			my @stat_b = stat($file_b);
			
			if ( -f $file_a && $f =~ /$regex/ && !stat_equal(\@stat_a, \@stat_b)) {
				print "\t\t$file_a => $file_b\n";
				File::Copy::syscopy($file_a, $file_b);
			}
		}
		closedir(DIR);
	} else {
		die "$source is neither a file nor a directory!";
	}
}


sub stat_equal {
	my ($a, $b) = @_;
	if (!@$b) {
		print "CMP: destination doesn't exist\n" if ($DEBUG);
		return 0;
	}
	
	my $ret = ($a->[7] == $b->[7]) && ($a->[9] == $b->[9]);
	if ($DEBUG) {
		print "CMP: SRC vs DST: " . ($ret ? "same" : "different") . "\n";
		print "\tSize : $a->[7] / $b->[7]\n";
		print "\tMtime: $a->[9] / $b->[9]\n";
		
	}
	
	return $ret;
}
