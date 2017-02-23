package QVD::HKD::VMHandler::LXC::FS::zfs;

use strict;
use warnings;
use File::Basename;

use QVD::Log;

use parent qw(QVD::HKD::VMHandler::LXC::FS);
use Method::WeakCallback qw(weak_method_callback);

sub init_backend {
    my ($hkd, $on_done, $on_error) = @_;
    
    if (system($hkd->_cfg('command.modprobe'), 'zfs')) {
        ERROR "Unable to load kernel module for zfs";
        return $hkd->$on_error;
    }    

    my $pool = $hkd->_cfg('storage.zpool.name');

    if (system($hkd->_cfg('command.zpool'), 'status', '-x', $pool)) {
        ERROR "zfs status check failed for pool $pool";
        return $hkd->$on_error;
    }

    $hkd->$on_done;
}

sub _dir_to_dataset {
    my ($self, $dir) = @_;
    my $pool = $self->_cfg('storage.zpool.name');
    $pool =~ s|/*$|/|;
    my $parent_dataset = basename(dirname($dir));
    $parent_dataset =~ s|/*$|/|;
    my $dataset = $pool . $parent_dataset . basename($dir);
    DEBUG "Changing $dir to zfs dataset -> '$dataset'";
    return $dataset;  
}

sub _place_os_image {
    my $self = shift;
    my $basefs = $self->{basefs};
    my $tmp = $self->{basefs_tmp};
    my $basefs_dataset = $self->_dir_to_dataset($basefs);
    my $tmp_dataset = $self->_dir_to_dataset($tmp);
   
    if ( -d $basefs ) {
       INFO "$basefs_dataset Internal error: image already on place, locking failed";
       return $self->_on_done;
    }

    INFO "Renaming zfs dataset '$tmp_dataset' to '$basefs_dataset'";
    system($self->_cfg('command.zfs'), 'rename', $tmp_dataset, $basefs_dataset);

    delete $self->{basefs_tmp};
    $self->_on_done;  
}

sub _make_tmp_dir_for_os_image {
    my $self = shift;
    if (defined (my $tmp = $self->{basefs_tmp})) {
        $tmp = $self->_dir_to_dataset($tmp);
        DEBUG "creating zfs dataset '$tmp'";
        $self->_run_cmd({ log_error => "Unable to create zfs dataset '$tmp'" },
                        zfs => 'create', $tmp);
    }
    else {
        ERROR "internal error: basefs_tmp is undefined for VM $self->{vm_id}";
        $self->_on_error;
    }
}

sub _move_dir {
    my ($self, $dir, $move_to) = @_;
    my $overlay = basename($dir);
    my $basefs = $self->{basefs};
    $basefs = $self->_dir_to_dataset($basefs);
    my $dataset = $basefs . '@' . $overlay;
    DEBUG "destroy zfs overlay dataset '$dataset'";
    $self->_run_cmd({log_error => "Unable to remove zfs overlay dataset '$dataset'",
		     on_error => weak_method_callback($self, '_remove_overlay_dir__zfs_check', $dir, $move_to)},
                    zfs => 'destroy', '-R', $dataset);
}

sub _remove_overlay_dir__zfs_check {
    my ($self, $dir, $move_to) = @_;
    # If the administrator changed the driver from something else to
    # zfs, $dir may be not a zfs dataset but a regular dir.

    my $dataset = $self->_dir_to_dataset($dir);
    INFO "checking if $dir is not a mount point of a zfs dataset but something else";
    $self->_run_cmd({log_error => "Directory $dir is not a mount point of a zfs dataset",
		     non_zero_rc_expected => 1,
		     on_error => weak_method_callback($self, '_remove_overlay_dir__rmdir', $dir, $move_to),
		     '2>' => '/dev/null',
		     '1>' => '/dev/null' },
		    zfs => 'list', '-Hp', $dataset);
}

sub _remove_overlay_dir__rmdir {
    my ($self, $dir, $move_to) = @_;
    INFO "Deleting regular directory '$dir'";
    # fallback to default
    $self->SUPER::_remove_overlay_dir($dir, $move_to);
}

sub _make_overlay_dir {
    my ($self, $dir, $basefs) = @_;
    $basefs = $self->_dir_to_dataset($basefs);
    my $overlay = basename($dir);
    DEBUG "creating zfs dataset '$basefs\@$overlay' as a snapshot of '$basefs'";
    $self->_run_cmd({log_error => "Unable to create zfs dataset '$basefs\@$overlay' as a snapshot of '$basefs'",
                     on_done => weak_method_callback($self, '_make_snapshot_clone', $dir, $overlay, $basefs)},
                    zfs => 'snapshot', $basefs . '@' . $overlay);
}

sub _make_snapshot_clone {
    my ($self, $dir, $overlay, $basefs) = @_;
    my $clone = $self->_dir_to_dataset($dir);
    my $overlay = basename($dir);
    DEBUG "creating zfs dataset '$clone' as a clone of '$basefs\@$overlay'";
    $self->_run_cmd({log_error => "Unable to create zfs dataset '$clone' as a clone of '$basefs\@$overlay'"},
                    zfs => 'clone', $basefs . '@' . $overlay, $clone);
}

sub _mount_root {
    my ($self, $rootfs, undef, $overlayfs, $subdir) = @_;
    $overlayfs = File::Spec->join($overlayfs, $subdir) if defined $subdir;
    DEBUG "mounting zfs dataset '$overlayfs' as rootfs '$rootfs'";
    $self->_run_cmd({log_error => "Unable to mount bind zfs volume '$overlayfs' on '$rootfs'"},
                    mount => '--bind', $overlayfs, $rootfs);
}

sub _delete_tmp_dir {
    my ($self, $dir) = @_;
    my $tmp_dataset = $self->_dir_to_dataset($dir);
    DEBUG "destroy dangling tmp zfs dataset '$tmp_dataset'";
    $self->_run_cmd({log_error => "Unable to destroy zfs dataset '$tmp_dataset'"},
                    zfs => 'destroy', $tmp_dataset);
}

1;

__END__

=head1 NAME

QVD::HKD::VMHandler::LXC::FS::zfs - Zettabyte File System Backend.

=head1 DESCRIPTION

This module implements the file system backend for ZFS and is based on QVD::HKD::VMHandler::LXC::FS::btrfs module.

=head1 DEPENDENCIES

This module depend of this package: Filesys::ZFS 

=head1 EXAMPLES

To install zfs on GNU/Linux look at http://zfsonlinux.org/

Then you need to create a zfs pool and set the pool mount point; the pool mount point should be the path defined on the database key path.storage.root (# qa config get | grep path.storage.root):

# zpool create -m /var/lib/qvd/storage qvd-zfs sda

After creating your zfs pool, you need to configure the following database parameters in QVD:

# qa config set vm.lxc.unionfs.type=zfs (Set the zfs filesystem in QVD)
# qa config set storage.zpool.name=qvd-zfs (Set the name of the zfs pool that will use QVD)
# qa config set path.storage.zfs.root=${path.storage.root}

If this is an upgrade of a previous install, you will need to restart the QVD House Keeping Daemon:

# systemctl restart qvd-hkd.service

=head1 AUTHOR

Cristian Villegas - cvillegas@qindel.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 by Qindel Formación y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut
