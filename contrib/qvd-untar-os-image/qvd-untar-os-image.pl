#!/usr/lib/qvd/bin/perl

## usage: $0 /path/to/image-file

use warnings;
use strict;
use File::Spec;
use Fcntl qw/:flock/;
use File::Basename;
use QVD::Config;

my $debug = 1;

## ripped from QVD::HKD::VMHandler::LXC
sub _mkpath {
    my ($path, $mask) = @_;
    $mask ||= 0755;
    my @dirs;
    my @parts = File::Spec->splitdir(File::Spec->rel2abs($path));
    while (@parts) {
        my $dir = File::Spec->join(@parts);
        if (-d $dir) {
            -d $_ or mkdir $_, $mask or return for @dirs;
            return -d $path;
        }
        unshift @dirs, $dir;
        pop @parts;
    }
    return;
}

## ripped from QVD::HKD::VMHandler::LXC
sub _run {
	my @cmd = @_;
	my $cmd_str = join(" ", @cmd);

	$debug and warn "Running command:  $cmd_str\n";

	my $ret = system(@cmd);

	if ( $? == -1 ) {
		warn "Failed to execute '$cmd_str': $!\n";
		return undef;
	} elsif ( $? & 127 ) {
		warn sprintf("Command '$cmd_str' died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without');
		return undef;
	} elsif ( ($? >> 8) > 0 )  {
		warn sprintf("Command '$cmd_str' exited with signal %d\n", $? >> 8);
		return undef;
	} else {
		$debug and warn "Command executed successfully\n";
	}

	return $ret;
}

sub calc_paths {
    my ($di_path) = @_;

    my $basefs_parent = cfg 'path.storage.basefs';
    $basefs_parent =~ s|/*$||;

    my $basefs = "$basefs_parent/$di_path";
    my $lockfn = "$basefs_parent/lock.$di_path";
    my $tmp    = "$basefs_parent/untar-$$-" . rand 100000;
    $tmp++ while -e $tmp;

    return $basefs, $lockfn, $tmp;
}

sub get_lock {
    my ($lockfn) = @_;
    my $lock;

    unless (open $lock, '>>', $lockfn) {
        warn "Unable to create or open lock file '$lockfn': $!";
        return;
    }
    $debug and warn "lock file is $lockfn\n";
    my $retries = 1;
    while ($retries <= 3) {
        if (flock($lock, Fcntl::LOCK_EX()|Fcntl::LOCK_NB())) {
            return $lock;
        } else {
            if ($! == POSIX::EAGAIN()) {
                $debug and warn "Waiting for lock '$lockfn'...\n";
                sleep 5;
                $retries++;
                next;
            }
            warn "Unable to acquire lock for '$lockfn': $!";
            return;
        }
    }
    ## unreached
}

sub is_untarred {
    my ($basefs) = @_;

    if (-d $basefs) {
        $debug and warn "Image '$basefs' already untarred\n";
        return;
    }
    return 1;
}

sub create_btrfs_subvol {
    my ($tmp) = @_;

    if ('btrfs' eq cfg 'vm.lxc.unionfs.type') {
        if (_run cfg ('command.btrfs'), 'subvolume', 'create', $tmp) {
            warn "Unable to create btrfs subvolume at '$tmp'";
            return;
        }
    } else {
        unless (_mkpath $tmp) {
            warn "Unable to create directory '$tmp': $!";
            return;
        }
    }
    return 1;
}

sub untar_image {
    my ($image_path, $tmp) = @_;

    $debug and warn "Untarring image to '$tmp'\n";
    my @cmd = ( cfg ('command.tar'),
                'x',
                -f => $image_path,
                -C => $tmp );
    push @cmd, '-z' if $image_path =~ /\.(?:tgz|gz)$/;
    push @cmd, '-j' if $image_path =~ /\.(?:tbz|bz2)$/;

    return !_run @cmd;   ## negate return val from system
}

sub place_image {
    my ($tmp, $basefs) = @_;

    $debug and warn "Renaming '$tmp' to '$basefs'\n";
    rename $tmp, $basefs or warn "Rename of '$tmp' to '$basefs' failed: $!\n";
    unless (-d $basefs) {
        warn "'$basefs' does not exist or is not a directory";
        return;
    }
    return 1;
}

sub release_lock {
    my ($lock) = @_;
    if (!flock $lock, LOCK_UN) {
        warn "unlock failed: $!";
        return;
    }
    return 1;
}

die "No images given\nUsage: $0 <image_path> ...\n" unless @ARGV;

foreach my $image_path (@ARGV) {
    if (!-f $image_path) {
        warn "Image '$image_path' does not exist on disk";
        next;
    }

    ## we can use 'basename' which doesn't require access to the db. If
    ## access is needed for other reason, then change this to use dis.path
    my $di_path = basename $image_path;

    my ($basefs, $lockfn, $tmp) = calc_paths $di_path;
    my $lock = get_lock $lockfn;
    next unless $lock;
    next unless is_untarred $basefs;
    next unless create_btrfs_subvol $tmp;
    next unless untar_image $image_path, $tmp;
    next unless place_image $tmp, $basefs;
    next unless release_lock $lock;
}
