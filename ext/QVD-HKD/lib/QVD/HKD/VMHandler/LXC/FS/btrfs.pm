package QVD::HKD::VMHandler::LXC::FS::btrfs;

use strict;
use warnings;

use QVD::Log;

use parent qw(QVD::HKD::VMHandler::LXC::FS);

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
    my $tmp = $self->{os_basefs_tmp};
    DEBUG "creating btrfs subvolume '$tmp'";
    $self->_run_cmd({ log_error => "Unable to create btrfs subvolume at '$tmp'" },
                    btrfs => 'subvolume', 'create', $tmp);
}

sub _remove_overlay_dir {
    my ($self, $dir) = @_;
    DEBUG "deleting btrfs subvolume '$dir'";
    $self->_run_cmd({log_error => "Unable to remove Btrfs volumen '$dir'"},
                    btrfs => 'subvolume', 'delete', $dir);
}

sub _make_overlay_dir {
    my ($self, $dir, $basefs) = @_;
    DEBUG "creating btrfs subvolume '$dir' as a snapshot of '$basefs'";
    $self->_run_cmd({log_error => "Unable to create Btrfs volumen '$dir' as a snapshot of '$basefs'"},
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
