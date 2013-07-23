package QVD::HKD::VMHandler::LXC::FS::bind;

use strict;
use warnings;

use parent qw(QVD::HKD::VMHandler::LXC::FS);

sub _mount_root {
    my ($self, $rootfs, $basefs, $overlayfs, $subdir) = @_;
    $basefs = File::Spec->join($basefs, $subdir) if defined $subdir;
    $self->{rootfs} = $rootfs;
    $self->_run_cmd({log_error => "Unable to mount bind mix of '$basefs' into '$rootfs'",
                     _on_done => '_remount_root_ro'},
                    'mount',
                    '--bind', $basefs, $rootfs);
}

sub _remount_root_ro {
    my $self = shift;

    return $self->_on_done
        unless $self->_cfg('vm.lxc.unionfs.bind.ro')

    my $rootfs = $self->{rootfs};
    $self->_run_cmd({log_error => "Unable to remount root fs '$rootfs' as ro"},
                    'mount',
                    -o => 'remount,ro', $rootfs);
}

1;
