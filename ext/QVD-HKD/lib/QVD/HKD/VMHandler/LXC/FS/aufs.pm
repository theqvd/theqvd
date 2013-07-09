package QVD::HKD::VMHandler::LXC::FS::aufs;

use strict;
use warnings;

use parent qw(QVD::HKD::VMHandler::LXC::FS);

sub _init_backend {
    my $self = shift;
    $self->_run_cmd({log_error => 'Unable to load kernel module aufs'},
                    modprobe => 'overlayfs')
}

sub _mount_root {
    my ($self, $rootfs, $basefs, $overlayfs, $subdir) = @_;
    $basefs = File::Spec->join($basefs, $subdir) if defined $subdir;
    $self->_run_cmd({log_error => "Unable to mount aufs mix of '$basefs' (ro) and '$overlayfs' (rw) into '$rootfs'"},
                    'mount',
                    -t => 'aufs',
                    -o => "br:$overlayfs:$basefs=ro", "aufs", $rootfs);
}

1;
