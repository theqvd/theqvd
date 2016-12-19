package QVD::HKD::VMHandler::LXC::FS;

use strict;
use warnings;

use QVD::HKD::Helpers qw(mkpath);
use QVD::Log;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__  => { advance => '_on_done',
                  transitions => { _on_error => 'aborting' } },

    new      => { transitions => { _on_run => 'base' } },

    base     => { substates => [ locking       => { enter => '_lock_os_image' },
                                 checking_dir  => { enter => '_check_base_dir',
                                                    transitions => { _on_error => 'unpacking' } },
                                 '(unpacking)' => { substates => [ finding_tmp_dir => { enter => '_find_tmp_dir_for_os_image' },
                                                                   making_tmp_dir  => { enter => '_make_tmp_dir_for_os_image' },
                                                                   untaring        => { enter => '_untar_os_image' },
                                                                   placing         => { enter => '_place_os_image' } ] },
                                 analyze       => { enter => '_analyze_os_image' },
                                 unlocking     => { enter => '_unlock_os_image' } ] },

    workdir  => { substates => [ removing_old => { enter => '_remove_old_workdir' },
                                 making       => { enter => '_make_workdir' } ] },


    overlay  => { substates => [ removing_old => { enter => '_remove_old_overlay' },
                                 making       => { enter => '_make_overlay' } ] },

    root     => { enter => '_make_root' },

    running  => { enter => '_tell_running' },

    aborting => { on => { _on_error => '_on_done' },
                  substates => [ unlocking        => { enter => '_unlock_os_image' },
                                 deleting_tmp_dir => { enter => '_delete_tmp' } ] },

    aborted  => { enter => '_tell_error' };

sub new {
    my ($class, %opts) = @_;

    my %mine = map { $_ => delete $opts{$_} }
        qw(vm_id image_path
           basefs basefs_lockfn
           overlayfs overlayfs_old
           workdir workdir_old rootfs
           on_running on_stopped on_error);

    my $self = $class->SUPER::new(%opts);

    $self->{$_} = $mine{$_} for keys %mine;

    my $driver = $self->_cfg('vm.lxc.unionfs.type');
    $driver =~ s/-/_/g;
    $class .= "::$driver";
    eval {
        $self->bless($class);
        DEBUG "FS object is $self";
    };
    $@ and DEBUG "blessing $self to $class failed: $@";
    $self
}

sub init_backend {
    my ($hkd, $on_done) = @_;
    $hkd->$on_done;
}

sub _tell_running { shift->_maybe_callback('on_running') }
sub _tell_stopped { shift->_maybe_callback('on_stopped') }
sub _tell_error   { shift->_maybe_callback('on_error')   }

sub _lock_os_image {
    my $self = shift;

    $self->_flock({save_to => 'untar_lock'},
                  $self->{basefs_lockfn});
}

sub _unlock_os_image {
    my $self = shift;
    if ($self->{untar_lock}) {
        DEBUG "Releasing untar lock";
        delete $self->{untar_lock};
    }
    return $self->_on_done
}

sub _check_base_dir {
    my $self = shift;
    my $basefs = $self->{basefs};
    unless (-d $basefs) {
        DEBUG "OS image for DI $self->{di_id} used by VM $self->{vm_id} has not been unpacked yet into $basefs";
        return $self->_on_error
    }
    $self->_on_done;
}

sub _find_tmp_dir_for_os_image {
    my $self = shift;
    my $tmp;
    do {
        $tmp = $self->_cfg('path.storage.basefs') . join('-', "/untar", $$, time, rand(10000))
    } while -e $tmp;
    $self->{basefs_tmp} = $tmp;
    $self->_on_done;
}

sub _untar_os_image {
    my $self = shift;
    my $image_path = $self->{image_path};
    my $tmp = $self->{basefs_tmp};

    unless (-f $image_path) {
        ERROR "OS image $image_path for VM $self->{vm_id} not found on filesystem";
        return $self->_on_error;
    }

    INFO "Untarring image to '$tmp'";
    my @args = ( 'x', -f => $image_path, -C => $tmp, '--numeric-owner' );
    push @args, '-z' if $image_path =~ /\.(?:tgz|gz)$/;
    push @args, '-j' if $image_path =~ /\.(?:tbz|bz2)$/;
    push @args, '-J' if $image_path =~ /\.(?:txz|xz)$/;

    $self->_run_cmd({log_error => "command (tar @args) failed"},
                    tar => @args);
}

sub _place_os_image {
    my $self = shift;
    my $basefs = $self->{basefs};
    my $tmp = $self->{basefs_tmp};

    if (-d $basefs) {
         INFO "Internal error: image already on place, locking failed";
         return $self->_on_done;
    }

    INFO "Renaming '$tmp' to '$basefs'";
    rename $tmp, $basefs
        or ERROR "Rename of '$tmp' to '$basefs' for VM $self->{vm_id} failed: $!";

    unless (-d $basefs) {
        ERROR "basefs '$basefs' for VM $self->{vm_id} does not exist or is not a directory";
        return $self->_on_error;
    }
    delete $self->{basefs_tmp};
    $self->_on_done;
}

sub _analyze_os_image {
    my $self = shift;
    for my $follow (1, 0) {
    my $basefs = $self->{basefs};
    if (-d "$basefs/sbin/") {
        DEBUG 'OS image is of type basic';
            return $self->_on_done;
        }
        elsif (defined (my $redirect = readlink "$basefs/redirect")) {
            if ($self->_cfg("vm.lxc.redirect.allow")) {
                if ($follow) {
                    $self->{basefs} = $redirect;
                    next;
                }
                else {
                    ERROR "Too many redirects for base filesystem";
                }
            }
            else {
                ERROR "DI redirection administratively forbidden";
            }
    }
    elsif (-d "$basefs/rootfs/sbin/") {
        if (-l "$basefs/rootfs") {
            ERROR "rootfs inside DI is a symbolic link";
        }
        else {
        $self->{meta} = $basefs;
        $self->{basefs_subdir} = 'rootfs';
        DEBUG 'OS image is of type extended';
                return $self->_on_done;
    }
    }
    else {
        ERROR "sbin not found at $basefs/sbin or at $basefs/rootfs/sbin for VM $self->{vm_id}";
        }
        return $self->_on_error;
    }
}

sub image_metadata_dir { shift->{meta} }

sub _make_tmp_dir_for_os_image {
    my $self = shift;
    my $tmp = $self->{basefs_tmp};
    mkpath $tmp and return $self->_on_done;

    ERROR "Unable to create directory '$tmp' for VM $self->{vm_id}: $!";
    $self->_on_error;
}

sub _remove_old_overlay {
    my $self = shift;
    my $overlayfs = $self->{overlayfs};
    if (-e $overlayfs) {
        if (defined (my $overlayfs_old =  $self->{overlayfs_old})) {
            return $self->_move_dir($overlayfs, $overlayfs_old);
        }
        else {
            DEBUG "Reusing existing overlay directory '$overlayfs'";
        }
    }
    $self->_on_done;
}

sub _move_dir {
    my ($self, $dir, $move_to) = @_;
    unless (rename $dir, $move_to) {
        ERROR "Unable to move old '$dir' out of the way to '$move_to' for VM $self->{vm_id}";
        return $self->_on_error;
    }
    DEBUG "old directory '$dir' moved to '$move_to'";
    $self->_on_done;
}

sub _make_overlay {
    my $self = shift;
    my $overlayfs = $self->{overlayfs};
    if (-d $overlayfs) {
        if (defined (my $overlayfs_old =  $self->{overlayfs_old})) {
            ERROR "Overlay directory still exists at '$overlayfs' for VM $self->{vm_id}";
            return $self->_on_error;
        }
        return $self->_on_done;
    }

    $self->_make_overlay_dir($overlayfs, $self->{basefs});
}

sub _make_overlay_dir {
    my $self = shift;
    $self->_make_dir(@_);
}

sub _make_dir {
    my ($self, $dir) = @_;
    unless (mkpath($dir)) {
        ERROR "Unable to create directory '$dir' for VM $self->{vm_id}: $!";
        return $self->_on_error;
    }
    DEBUG "directory $dir created";
    $self->_on_done
}

sub _remove_old_workdir {
    my $self = shift;
    DEBUG "skipping old workdir removing";
    $self->_on_done;
}

sub _make_workdir {
    my $self = shift;
    DEBUG "skipping workdir creation";
    $self->_on_done;
}

sub _make_root {
    my $self = shift;
    my $rootfs = $self->{rootfs};

    unless (mkpath($rootfs)) {
        ERROR "Unable to create root directory '$rootfs' for VM $self->{vm_id}";
        return $self->_on_error;
    }

    $self->_mount_root($rootfs, @{$self}{qw(basefs overlayfs basefs_subdir workdir)});
}
# _mount_root is a virtual function that must be implemented by all the subclasses

sub _delete_tmp {
    my $self = shift;
    my $tmp = $self->{basefs_tmp};

    if (defined $tmp and -e $tmp) {
        DEBUG "deleting temporary directory '$tmp' for VM $self->{vm_id}";
        return $self->_delete_tmp_dir($tmp);
    }
    $self->_on_done;
}

sub _delete_tmp_dir {
    my ($self, $dir) = @_;
    $self->_run_cmd({log_error => "deleting temporal directory $dir for VM $self->{vm_id} failed"},
                    'rm', '-Rf', $dir);
}

1;
