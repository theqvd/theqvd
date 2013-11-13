package QVD::HKD::VMHandler::LXC::FS::aufs;

use strict;
use warnings;

use parent qw(QVD::HKD::VMHandler::LXC::FS);

sub _init_backend {
    my ($hkd, $on_done, $on_error) = @_;
    $hkd->_run_cmd({log_error => 'Unable to load kernel module aufs',
                    on_done => sub { $hkd->$on_done }, on_error => sub { $hkd->$on_error } },
                   modprobe => 'aufs')
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
