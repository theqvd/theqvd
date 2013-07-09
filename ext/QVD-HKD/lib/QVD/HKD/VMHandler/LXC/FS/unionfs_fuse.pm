package QVD::HKD::VMHandler::LXC::FS::unionfs_fuse;

use strict;
use warnings;

use parent qw(QVD::HKD::VMHandler::LXC::FS);

sub _init_backend {
    my $self = shift;
    $self->_run_cmd({log_error => 'Unable to load kernel module fuse'},
                    modprobe => 'fuse')
}

sub _mount_root {
    my ($self, $rootfs, $basefs, $overlayfs, $subdir) = @_;
    $basefs = File::Spec->join($basefs, $subdir) if defined $subdir;
    $self->_run_cmd({log_error => "Unable to mount unionfs-fuse mix of '$basefs' (ro) and '$overlayfs' (rw) into '$rootfs'"},
                    'unionfs-fuse',
                    -o => 'cow',
                    -o => 'max_files=32000',
                    -o => 'suid',
                    -o => 'dev',
                    -o => 'allow_other',
                    "$overlayfs=RW:$basefs=RO", $rootfs);
}

1;
