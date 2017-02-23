package QVD::HKD::VMHandler::LXC::FS::zfs;

use strict;
use warnings;
use File::Basename;

use Linux::Proc::Mountinfo;

use QVD::Log;

use parent qw(QVD::HKD::VMHandler::LXC::FS);
use Method::WeakCallback qw(weak_method_callback);

my %dataset;
my $snapshot_name = 'me';

sub init_backend {
    my ($hkd, $on_done, $on_error) = @_;

    my $mi = Linux::Proc::Mountinfo->read;
    my $zfs_pool;
    for my $fs (qw(overlayfs basefs)) {
        my $path = $hkd->_cfg("path.storage.$fs");
        $path =~ s|/+$||;
        my $mp = $mi->at($path);
        unless ($mp and $mp->fs_type eq 'zfs') {
            ERROR "$fs path '$path' does not point to a ZFS dataset";
            return $hkd->$on_error;
        }
        my $dataset = $dataset{$path} = $mp->mount_source;
        DEBUG "zfs dataset for $fs is $dataset";

        # Ensure all the datasets hang from the same pool:
        my $pool = $dataset;
        $pool =~ s|/.*||;
        if (defined $zfs_pool) {
            if ($zfs_pool ne $pool) {
                ERROR "$fs ZFS dataset at $path is in the wrong pool ($pool, expected: $zfs_pool)";
                return $hkd->$on_error;
            }
        }
        else {
            $zfs_pool = $pool;
            if (system($hkd->_cfg('command.zpool'), 'status', '-x', $pool)) {
                ERROR "ZFS status check failed for pool $pool";
                return $hkd->$on_error;
            }
        }
    }
    $hkd->$on_done;
}

sub _resolve_path_to_dataset {
    my ($self, $dir) = @_;
    my (undef, $parent, $last) = File::Spec->splitpath($dir);
    $parent =~ s|/+$||;
    if (defined(my $dataset = $dataset{$parent})) {
        return "$dataset/$last";
    }
    ERROR "Unable to resolve dataset for directory $dir";
    DEBUG Data::Dumper::Dumper([\%dataset, $dir, $parent, $last]);
    ()
}

sub _place_os_image {
    my $self = shift;
    my $basefs = $self->{basefs};
    -d $basefs and LOGDIE "Internal error, image already on place at $basefs, locking failed";

    my $basefs_dataset = $self->_resolve_path_to_dataset($basefs) // return $self->_on_error;
    my $tmp = delete $self->{basefs_tmp};
    my $tmp_dataset = $self->_resolve_path_to_dataset($tmp) // return $self->_on_error;

    DEBUG "Creating snapshot for ZFS dataset '$tmp_dataset'";
    $self->_run_cmd({log_error => "Unable to create ZFS snapshot for dataset '$tmp_dataset'",
                     on_done => weak_method_callback($self, '_place_os_image__run_zfs_rename',
                                                     $tmp_dataset, $basefs_dataset)},
                    'zfs', 'snapshot', "$tmp_dataset\@$snapshot_name");
}

sub _place_os_image__run_zfs_rename {
    my ($self, $from, $to) = @_;
    DEBUG "Renaming ZFS dataset '$from' to '$to'";
    $self->_run_cmd({log_error => "Unable to rename ZFS dataset '$from' to '$to'"},
                    'zfs', 'rename', $from, $to);
}

sub _make_tmp_dir_for_os_image {
    my $self = shift;
    my $tmp = $self->{basefs_tmp} // LOGDIE "Internal error: basefs_tmp missing";
    my $dataset = $self->_resolve_path_to_dataset($tmp) // return $self->_on_error;
    DEBUG "creating zfs dataset '$tmp'";
    $self->_run_cmd({log_error => "Unable to create ZFS dataset '$dataset'" },
                    'zfs', 'create', $dataset);
}

sub _move_dir {
    my ($self, $from, $to) = @_;
    my $from_dataset = $self->_resolve_path_to_dataset($from) // return $self->_on_error;
    my $to_dataset = $self->_resolve_path_to_dataset($to) // return $self->_on_error;
    $self->_run_cmd({log_error => "Unable to rename ZFS dataset '$from_dataset' to '$to_dataset'",
		     on_error => weak_method_callback($self, '_move_dir__regular_rename', $from, $to),
                     on_done  => weak_method_callback($self, '_touch_dir', $to)},
                    'zfs', 'rename', $from_dataset, $to_dataset);
}

sub _touch_dir {
    my ($self, $dir) = @_;
    utime undef, undef, $dir;
    $self->_on_done;
}

sub _move_dir__regular_rename {
    my ($self, $from, $to) = @_;
    # If the administrator changed the driver from something else to
    # ZFS, $from may be not a ZFS dataset but a regular dir.
    unless (rename $from, $to) {
        ERROR "Unable to move '$from' to '$to': $!";
        return $self->_on_error;
    }
    return $self->_on_done;
}

sub _make_overlay_dir {
    my ($self, $dir, $basefs) = @_;
    my $basefs_dataset = $self->_resolve_path_to_dataset($basefs) // return $self->_on_error;
    my $snapshot = $basefs_dataset . '@' . $snapshot_name;
    my $clone = $self->_resolve_path_to_dataset($dir) // return $self->_on_error;
    DEBUG "Cloning ZFS snapshot '$snapshot' into '$clone'";
    $self->_run_cmd({log_error => "Cloning ZFS snapshot 'snapshot' into '$clone' failed",
                     on_done => weak_method_callback($self, '_touch_dir', $dir)},
                    'zfs', 'clone', $snapshot, $clone);
}

sub _mount_root {
    my ($self, $rootfs, undef, $overlayfs, $subdir) = @_;
    $overlayfs = File::Spec->join($overlayfs, $subdir) if defined $subdir;
    DEBUG "mounting ZFS dataset '$overlayfs' as rootfs '$rootfs'";
    $self->_run_cmd({log_error => "Unable to mount bind zfs volume '$overlayfs' on '$rootfs'"},
                    mount => '--bind', $overlayfs, $rootfs);
}

sub _delete_tmp_dir {
    my ($self, $dir) = @_;
    my $dataset = $self->_resolve_path_to_dataset($dir) // return $self->_on_error;
    DEBUG "Destroying dangling tmp ZFS dataset '$dataset'";
    $self->_run_cmd({log_error => "Unable to destroy ZFS dataset '$dataset'"},
                    'zfs', 'destroy', $dataset);
}

1;

__END__

=head1 NAME

QVD::HKD::VMHandler::LXC::FS::zfs - Zettabyte File System backend.

=head1 DESCRIPTION

This module allows one to use a ZFS filesystem as the storage layer
for LXC containers.

Obviously, it requires a Linux system with ZFS support.

=head1 CONFIGURATION

The following configuration entries should be file system paths
pointing to ZFS datasets under a common pool.

  path.storage.basefs
  path.storage.overlayfs

Changing those values requires restarting the HKD.

=head1 AUTHORS

Cristian Villegas (cvillegas@qindel.com).

Salvador Fandiño.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Qindel Formación y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut
