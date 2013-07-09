package QVD::HKD::VMHandler::LXC::FS::btrfs;

use strict;
use warnings;

use QVD::HKD::Helpers qw(mkpath);

use Class::StateMachine::Declarative

    __any__  => { transitions => { _on_error => 'aborting' } },

    new      => { transitions => { _on_run => 'init' } },

    init     => { enter => '_init_backend' },

    base     => { substates => [ locking       => { enter => '_lock_os_image' },
                                 checking_dir  => { enter => '_check_dir',
                                                    transitions => { _on_error => 'unpacking' } },
                                 '(unpacking)' => { substates => [ finding_tmp_dir => { enter => '_find_tmp_dir' },
                                                                   making_tmp_dir  => { enter => '_make_tmp_dir' },
                                                                   untaring        => { enter => '_untar_os_image' },
                                                                   placing         => { enter => '_place_os_image' } ] },
                                 analyze       => { enter => '_analyze_os_image' },
                                 unlocking     => { enter => '_unlock_os_image' } ] },

    overlay  => { },

    root     => { },

    running  => { enter => '_tell_parent_done' },

    stopping => { },

    stopped  => { enter => '_tell_parent_stop' },


use parent qw(QVD::HKD::Agent);

sub new {
    my ($class, %opts) = @_;
    my $vmhandler = delete $opts{vmhandler};
    my $self = $class->SUPER::new(%opts);
    $self->{vmhandler} = $vmhandler;
    $self
}

sub run {
    my $self = shift;
    $self->_on_run;
}

sub _init_backend {
    shift->_on_done;
}

sub _tell_parent_done {
    my $self = shift;
    $self->{vmhandler}->_on_done;
}

sub _tell_parent_stop {
    my $self = shift;
    $self->{vmhandler}->_on_done;
}

sub _find_tmp_dir_for_os_image {
    my $self = shift;
    my $tmp;
    do {
        $tmp = $self->_cfg('path.storage.basefs') . join('-', "/untar", $$, time, rand(10000))
    } while -e $tmp;
    $self->{os_basefs_tmp} = $tmp;
    $self->_on_done;
}

sub _untar_os_image {
    my $self = shift;
    my $image_path = $self->{os_image_path};
    my $tmp = $self->{os_basefs_tmp};

    INFO "Untarring image to '$tmp'";
    my @args = ( 'x', -f => $image_path, -C => $tmp );
    push @args, '-z' if $image_path =~ /\.(?:tgz|gz)$/;
    push @args, '-j' if $image_path =~ /\.(?:tbz|bz2)$/;
    push @args, '-J' if $image_path =~ /\.(?:txz|xz)$/;

    $self->_run_cmd({log_error => "command (tar @args) failed", tar => @args);
}

sub _place_os_image {
    my $self = shift;
    my $vmhandler = $self->{vmhandler};
    my $basefs = $vmhandler->{os_basefs};
    my $tmp = $self->{os_basefs_tmp};

    if (-d $basefs) {
         INFO "Internal error: image already on place, locking failed";
         return $self->_on_done;
    }

    INFO "Renaming '$tmp' to '$basefs'";
    rename $tmp, $basefs
        or ERROR "Rename of '$tmp' to '$basefs' failed: $!";
    unless (-d $basefs) {
        ERROR "'$basefs' does not exist or is not a directory";
        return $self->_on_error;
    }
    DEBUG "OS placement done, releasing untar lock";
    delete $self->{untar_lock};
    $self->_on_done;
}

sub _analyze_os_image {
    my $self = shift;
    my $vmhandler = $self->{vmhandler};
    my $basefs = $vmhandler->{os_basefs};
    if (-d "$basefs/sbin/") {
        DEBUG 'OS image is of type basic';
    }
    elsif (-d "$basefs/rootfs/sbin/") {
        $vmhandler->{os_meta} = $basefs;
        $vmhandler->{os_base_subdir} = 'rootfs';
        DEBUG 'OS image is of type extended';
    }
    else {
        ERROR "sbin not found at $basefs/sbin or at $basefs/rootfs/sbin";
        return $self->_on_error;
    }
    $self->_on_done;
}

sub _make_tmp_dir_for_os_image {
    my $self = shift;
    my $tmp = $self->{os_basefs_tmp};
    mkpath $tmp and return $self->_on_done;

    ERROR "Unable to create directory '$tmp': $!";
    $self->_on_error;
}

sub _remove_old_overlay {
    my $self = shift;
    my $vmhandler = $self->{vmhandler};
    my $overlayfs = $vmhandler->{os_overlayfs};
    if (-d $overlayfs) {
        if (defined (my $overlayfs_old =  $vmhandler->{os_overlayfs_old})) {
            return $self->_remove_overlay_dir($overlayfs, $overlayfs_old);
        }
        else {
            DEBUG "Reusing existing overlay directory '$overlayfs'";
        }
    }
    $self->_on_done;
}

sub _remove_overlay_dir {
    my ($self, $dir, $move_to) = @_;
    unless (rename $overlayfs, $overlayfs_old) {
        ERROR "Unable to move old '$dir' out of the way to '$move_to'";
        return $self->_on_error;
    }
    DEBUG "old overlay directory '$dir' moved to '$move_to'";
    $self->_on_done;
}

sub _make_overlay {
    my $self = shift;
    my $vmhandler = $self->{vmhandler};
    my $overlayfs = $vmhandler->{os_overlayfs};
    if (-d $overlayfs) {
        if (defined (my $overlayfs_old =  $vmhandler->{os_overlayfs_old})) {
            ERROR "Overlay directory still exists at '$overlayfs'";
            return $self->_on_error;
        }
        $self->_on_done;
    }

    my $basefs = $vmhandler->{os_basefs};
    $self->_make_overlay_dir($overlayfs, $basefs);
}

sub _make_overlay_dir {
    my ($self, $dir) = @_;
    unless (_mkpath($dir)) {
        ERROR "Unable to create overlay file system '$dir': $!";
        return $self->_on_error;
    }
    DEBUG "overlay directory $dir created";
    $self->_on_done
}

sub _make_root {
    my $self = shift;
    my $vmhandler = $self->{vmhandler};
    my $rootfs = $vmhandler->{os_rootfs};

    unless (mkpath($rootfs)) {
        ERROR "Unable to create directory '$rootfs'";
        return $self->_on_error;
    }

    my $basefs = $vmhandler->{os_basefs};
    my $overlayfs = $vmhandler->{os_overlayfs};
    my $subdir = $vmhandler->{os_base_subdir};

    $self->_mount_root($rootfs, $basefs, $overlayfs, $subdir);
}

sub _mount_root {
    croak "internal error: unimplemented virtual function called";
}

1;
