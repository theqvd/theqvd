package QVD::HKD::VMHandler::LXC::FS::btrfs;

use strict;
use warnings;

use QVD::Log;

use parent qw(QVD::HKD::VMHandler::LXC::FS);
use Method::WeakCallback qw(weak_method_callback);

sub init_backend {
    my ($hkd, $on_done, $on_error) = @_;
    my $fn = $hkd->_cfg('path.storage.btrfs.root') . '/qvd_btrfs_lock';
    my $fh;
    unless (open $fh, '>>', $fn) {
        ERROR "Unable to create or open file $fn to work around LXC make-btrfs-ro-on-exit bug: $!";
        return $hkd->$on_error
    }
    DEBUG "$fn opened";
    $hkd->{btrfs_lock} = $fh;
    $hkd->$on_done;
}

sub _make_tmp_dir_for_os_image {
    my $self = shift;
    if (defined (my $tmp = $self->{basefs_tmp})) {
        DEBUG "creating btrfs subvolume '$tmp'";
        $self->_run_cmd({ log_error => "Unable to create btrfs subvolume at '$tmp'" },
                        btrfs => 'subvolume', 'create', $tmp);
    }
    else {
        ERROR "internal error: basefs_tmp is undefined for VM $self->{vm_id}";
        $self->_on_error;
    }
}

sub _remove_overlay_dir {
    my ($self, $dir, $move_to) = @_;
    DEBUG "deleting btrfs subvolume '$dir'";
    $self->_run_cmd({log_error => "Unable to remove Btrfs volumen '$dir'",
		     on_error => weak_method_callback($self, '_remove_overlay_dir__btrfs_check', $dir, $move_to)},
                    btrfs => 'subvolume', 'delete', $dir);
}

sub _remove_overlay_dir__btrfs_check {
    my ($self, $dir, $move_to) = @_;
    # If the administrator changed the driver from something else to
    # btrfs, $dir may be not a btrfs subvolume but a regular dir.

    INFO "checking if $dir is not a btrfs subvolume but something else";
    $self->_run_cmd({log_error => "But $dir is a btrfs subvolume",
		     non_zero_rc_expected => 1,
		     on_done => weak_method_callback($self, '_remove_overlay_dir__rmdir', $dir, $move_to),
		     '2>' => '/dev/null',
		     '1>' => '/dev/null' },
		    btrfs => 'subvolume', 'show', $dir);
}

sub _remove_overlay_dir__rmdir {
    my ($self, $dir, $move_to) = @_;
    INFO "Deleting regular directory '$dir'";
    # fallback to default
    $self->SUPER::_remove_overlay_dir($dir, $move_to);
}

sub _make_overlay_dir {
    my ($self, $dir, $basefs) = @_;
    DEBUG "creating btrfs subvolume '$dir' as a snapshot of '$basefs'";
    $self->_run_cmd({log_error => "Unable to create btrfs volumen '$dir' as a snapshot of '$basefs'"},
                    btrfs => 'subvolume', 'snapshot', $basefs, $dir);
}

sub _mount_root {
    my ($self, $rootfs, undef, $overlayfs, $subdir) = @_;
    $overlayfs = File::Spec->join($overlayfs, $subdir) if defined $subdir;
    DEBUG "mounting btrfs subvolume '$overlayfs' as rootfs '$rootfs'";
    $self->_run_cmd({log_error => "Unable to mount bind btrfs volume '$overlayfs' on '$rootfs'"},
                    mount => '--bind', $overlayfs, $rootfs);
}

sub _delete_tmp_dir {
    my ($self, $dir) = @_;
    DEBUG "deleting dangling tmp btrfs subvolume '$dir'";
    $self->_run_cmd({log_error => "Unable to delete btrfs volume '$dir'"},
                    btrfs => 'subvolume', 'delete', $dir);
}

1;
