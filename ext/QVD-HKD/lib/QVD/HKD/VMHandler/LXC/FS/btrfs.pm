package QVD::HKD::VMHandler::LXC::FS::btrfs;

use strict;
use warnings;

use parent qw(QVD::HKD::VMHandler::LXC::FS);

sub _make_tmp_dir_for_os_image {
    my $self = shift;
    my $tmp = $self->{os_basefs_tmp};

    $self->_run_cmd({ log_error => "Unable to create btrfs subvolume at '$tmp'" },
                    btrfs => 'subvolume', 'create', $tmp)) {
}

sub _remove_overlay_dir {
    my ($self, $dir) = @_;
    $self->_run_cmd({log_error => "Unable to remove Btrfs volumen '$dir'"},
                    btrfs => 'subvolume', 'delete', $dir);
}

sub _make_overlay_dir {
    my ($self, $dir, $basefs) = @_;
    $self->_run_cmd({log_error => "Unable to create Btrfs volumen '$dir' as a snapshot of '$basefs'"},
                    btrfs => 'subvolume', 'snapshot', $basefs, $dir);
}

sub _mount_root {
    my ($self, $rootfs, undef, $overlayfs, $subdir) = @_;
    $overlayfs = File::Spec->join($overlayfs, $subdir) if defined $subdir;
    $self->_run_cmd({log_error => "Unable to mount bind btrfs volume '$overlayfs' on '$rootfs'"},
                    mount => '--bind', $overlayfs, $rootfs);
}

1;
