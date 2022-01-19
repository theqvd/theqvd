package QVD::HKD::VMHandler::LXC::FS::xfs;

use strict;
use warnings;

use QVD::Log;

use parent qw(QVD::HKD::VMHandler::LXC::FS);
use Method::WeakCallback qw(weak_method_callback);
use Linux::Proc::Mountinfo;

sub init_backend {
    my ($hkd, $on_done, $on_error) = @_;

    my $mi = Linux::Proc::Mountinfo->read;
    my $storage_path = $hkd->_cfg('path.storage.xfs.root');
    my $storage = $mi->at($storage_path);

    if ($storage) {
        my $storage_type = $storage->fs_type;
	my $xfs_reflink = `xfs_info $storage_path | grep reflink`;
        $storage_type eq "xfs" and $xfs_reflink =~ /reflink=1/ ? $hkd->$on_done : $hkd->$on_error;
    } elsif (-d $storage_path) {
        my $root = $mi->root;
        my $root_type = $root->fs_type;	    
	my $xfs_reflink = `xfs_info / | grep reflink`;
	$root_type eq "xfs" and $xfs_reflink =~ /reflink=1/ ? $hkd->$on_done : $hkd->$on_error;
    } else {
        DEBUG "Error, there isn't any xfs filesystem mounted at $storage_path";
	return $hkd->$on_error;
    }
}

sub _make_tmp_dir_for_os_image {
    my $self = shift;
    if (defined (my $tmp = $self->{basefs_tmp})) {
        DEBUG "XFS: creating temporary directory '$tmp'";
        $self->_run_cmd({ log_error => "XFS: Unable to create directory at '$tmp'" },
                        mkdir => $tmp);
    }
    else {
        ERROR "internal error: basefs_tmp is undefined for VM $self->{vm_id}";
        $self->_on_error;
    }
}

sub _make_overlay_dir {
    my ($self, $dir, $basefs) = @_;
    DEBUG "Creating directory '$dir' as a reflink of '$basefs'";
    $self->_run_cmd({log_error => "XFS: Unable to create directory '$dir' as a reflink of '$basefs'"},
                    cp => '-r', '-d', '-p', '-u', '--reflink=always', $basefs, $dir);
}

sub _mount_root {
    my ($self, $rootfs, undef, $overlayfs, $subdir) = @_;
    $overlayfs = File::Spec->join($overlayfs, $subdir) if defined $subdir;
    DEBUG "mounting xfs reflink '$overlayfs' as rootfs '$rootfs'";
    $self->_run_cmd({log_error => "Unable to mount bind xfs reflink '$overlayfs' on '$rootfs'"},
                    mount => '--bind', $overlayfs, $rootfs);
}

sub _delete_tmp_dir {
    my ($self, $dir) = @_;
    DEBUG "deleting dangling tmp directory '$dir'";
    $self->_run_cmd({log_error => "XFS: Unable to delete directory '$dir'"},
                    rm => '-rf', $dir);
}

1;
