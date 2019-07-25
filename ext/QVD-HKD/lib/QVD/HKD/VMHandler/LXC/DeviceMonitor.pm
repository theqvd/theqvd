#!/usr/lib/qvd/bin/perl 
package QVD::HKD::VMHandler::LXC::DeviceMonitor;


use strict;
use warnings;
use utf8;
use Socket;
use Socket::Netlink qw( :DEFAULT  pack_nlmsghdr unpack_nlmsghdr );
use IO::Socket::Netlink;
use Linux::Inotify2;
use IO::Select;
use File::Spec;
use Carp;
use QVD::Log;
use Moo;
use AnyEvent;

$| =  1;


my $instance = undef;


use constant NETLINK_KOBJECT_UEVENT => 15 ;
use constant SELECT_TIMEOUT         => 1;



has qvd_devicefs_path   => ( is => 'rw', default => '/var/lib/qvd/storage/devicefs' );
has cgroup_devices_path => ( is => 'rw', default => sub { _find_cgroup_dir('devices') } );


sub get_instance {
    my ($class, @args) = @_;
    $instance = $class->new( @args ) unless ($instance);
    return $instance;
}

sub BUILD {
    my ($self) = @_;

    $self->{vhci_to_vm} = {};

    $self->{inotify}      = Linux::Inotify2->new();

    $self->{inotify}->watch($self->qvd_devicefs_path, IN_MODIFY | IN_CREATE | IN_DELETE, $self->_make_callback( \&watch_devicefs_dir ) );

    opendir(my $dir, $self->qvd_devicefs_path) or die "opendir " . $self->qvd_devicefs_path . " failed: $!";

    while(my $d = readdir($dir)) {
        my $path = $self->qvd_devicefs_path . "/$d";

        next if ( $d eq "." || $d eq ".." );

        if ( -d $path ) {
            DEBUG "Watching $d\n";
            $self->{inotify}->watch($d, IN_MODIFY | IN_CREATE | IN_DELETE, $self->_make_callback( \&watch_vm_dir ) );

            opendir(my $vm_dir, $self->qvd_devicefs_path . "/$d") or die "opendir " . $self->qvd_devicefs_path . " failed: $!";

            while(my $vd = readdir($vm_dir)) {
                next if ( $vd eq "." || $vd eq "..");
                $self->_add_vm_mapping_dir($self->qvd_devicefs_path . "/$d/$vd");
            }

            closedir $vm_dir;
        }
    }

    closedir($dir);

    $self->{netlink_sock} = IO::Socket::Netlink->new( Protocol => NETLINK_KOBJECT_UEVENT, Pid => 0, Groups => 1 );

    $self->{ev_netlink} = AnyEvent->io( fh => $self->{netlink_sock}, poll => 'r', cb => sub { $self->process_netlink() } );
    $self->{ev_inofity} = AnyEvent->io( fh => $self->{inotify}->fileno, poll => 'r', cb => sub { $self->process_inotify() } );

    INFO "Initialized device watcher, waiting for events";

}

sub process_inotify {
    my ($self) = @_;
    $self->{inotify}->poll;
}

sub process_netlink {
    my ($self) = @_;

    my $message = " " x 65536;

    my $msg;
    my $ret = $self->{netlink_sock}->recv($msg, 65536);


    my @lines = split(/\0/, $msg);
    my $event = shift @lines;
    my %kv = map { split(/=/, $_, 2) } @lines;


    DEBUG "=== $event ===\n";
    foreach my $k (keys %kv) {
        DEBUG "$k => $kv{$k}\n";
    }

    eval {
        $self->handle_new_device($event, \%kv);
    };

    ERROR "Failed to handle new device: $@" if ($@);
}

sub _get_device_type {
    my ($subsystem, $major) = @_;

    my $dev_type = "c";
    
    open(my $fh, '<', "/proc/devices") or die "Can't open /proc/devices: $!";

    while(my $line = <$fh>) {
        chomp $line;

        $line =~ s/^\s+//;

        next if ( $line eq "" );

        if ( $line =~ /^Character devices/) {
            $dev_type = "c";
            next;
        } elsif ( $line =~ /^Block devices/ ) {
            $dev_type = "b";
            next;
        }

        my ($num, $type) = split(/\s+/, $line);

        if ( $num == $major && $type eq $subsystem) {
            DEBUG "Found device type $dev_type for subsystem $subsystem, major $major";
            close $fh;
            return $dev_type;
        }

    }
    close $fh;

    # We didn't find anything -- odd. However there's no doubt there's a device of some sort.
    ERROR "Failed to find device type for subsystem $subsystem, major $major";
    return $dev_type;
}


# Deal with the issue that inotify callbacks don't allow for additional
# data to be passed like $self
sub _make_callback {
    my ( $self, $function ) = @_;

    return sub {
        $function->($self, @_);
    }
}

sub handle_new_device {
    my ($self, $event_str, $args) = @_;

    my ($event, $path) = split(/@/, $event_str);

    return unless ($event eq "bind" || $event eq "unbind" || $event eq "add" || $event eq "remove");

    if ( !exists $args->{MAJOR} ) {
        DEBUG "No MAJOR, skipping";
        return;
    }

    if ( !exists $args->{MINOR} ) {
        DEBUG "No MINOR, skipping";
        return;
    }

    if ( !exists $args->{DEVTYPE} && !exists $args->{SUBSYSTEM} ) {
        DEBUG "No DEVTYPE, skipping";
        return;
    }


    my $driver = $args->{DEVTYPE} // $args->{SUBSYSTEM};

    DEBUG "Processing event $event: path=$path; major=$args->{MAJOR}; minor=$args->{MINOR}; driver=$driver";

    my @devpath_parts = File::Spec->splitdir($args->{DEVPATH});

    my (undef, undef, undef, $vhci) = (@devpath_parts);
    my $dev_file;
    my $vm_id = $self->{vhci_to_vm}->{ $vhci };
    my $permission = "";


    if ( $event eq "bind" || $event eq "add") {
        INFO "Connecting $args->{MAJOR}:$args->{MINOR} to VM $vm_id\n";
        $permission = "allow";
    } elsif ( $event eq "unbind" || $event eq "remove" ) {
        INFO "Disconnecting $args->{MAJOR}:$args->{MINOR} from VM $vm_id\n";
        $permission = "deny";
    }

    my $dev_type = _get_device_type($driver, $args->{MAJOR});

    $self->_set_device_permission_recursive( $self->cgroup_devices_path . "/lxc/qvd-$vm_id",
                                             $permission,
                                             $dev_type, $args->{MAJOR}, $args->{MINOR} );

    DEBUG "Done.\n";
}

sub _set_device_permission_recursive {
    my ($self, $basedir, $permission, $dev_type, $major, $minor) = @_;
    DEBUG "_set_device_permission_recursive( basedir = '$basedir', permission = '$permission', dev_type = $dev_type, major = $major, minor = $minor)";

    if ($permission !~ /^(allow|deny)$/) {
        ERROR "Internal error: bad permission value";
        return;
    }

    my $filename = "$basedir/devices.$permission";
    my $rule     = "$dev_type $major:$minor rwm";

    DEBUG "Trying to set rule '$rule' in '$filename'";

    if ( open(my $dev_fh, '>', $filename) ) {
        if ( ! print $dev_fh "$rule\n" ) {
            ERROR "Failed to write rule '$rule' to '$filename': $!";
        }
        close $dev_fh;
    } else {
        ERROR "Failed to open '$filename' for writing rule '$rule': $!";
    }

    # deny permissions automatically propagate, so no need to recurse
    # in that case.
    return if ( $permission eq "deny" );

    # allow permissions only affect the direct cgroup, and allow optionally
    # to add an allow rule to its children. We want the rule to propagate
    # fully, so we recurse into any children there are.
    DEBUG "Applying allow rule recursively starting from '$basedir'";

    if ( opendir(my $dh, $basedir) ) {
        my @subdirs = grep { !/^\.{1,2}$/ && -d "$basedir/$_" } readdir( $dh );
        closedir $dh;

        foreach my $subdir ( @subdirs ) {
            DEBUG "Recursing into '$basedir/$subdir'";
            $self->_set_device_permission_recursive("$basedir/$subdir", $permission, $dev_type, $major, $minor);
        }
    } else {
        ERROR "Failed to open dir '$basedir': $!";
    }

}
sub watch_devicefs_dir {
    my ($self, $e) = @_;
    DEBUG "devicefs handler triggered";
    _dump_inotify($e);

    if ( $e->IN_CREATE ) {
        $self->{inotify}->watch($e->fullname, IN_MODIFY | IN_CREATE | IN_DELETE, $self->_make_callback( \&watch_vm_dir ) );
    }
}

sub watch_vm_dir {
    my ($self, $e) = @_;
    DEBUG "vmdir handler triggered";
    _dump_inotify($e);

    if ( $e->IN_DELETE_SELF ) {
        $e->w->cancel;
    }

    if ( $e->IN_CREATE ) {
        $self->_add_vm_mapping_dir($e->fullname);
    }

    if ( $e->IN_DELETE ) {
        $self->_del_vm_mapping_dir($e->fullname);
    }
}

sub _dump_inotify {
    my ($e) = @_;
    if ( !defined($e)) {
        confess("Argument is undefined");
        return;
    }
    
    DEBUG "Name: " . $e->fullname . ": ";
    DEBUG "accessed, "     if ( $e->IN_ACCESS );
    DEBUG "gone, "         if ( $e->IN_IGNORED );
    DEBUG "deleted, "      if ( $e->IN_DELETE );
    DEBUG "created, "      if ( $e->IN_CREATE );
    DEBUG "self-deleted, " if ( $e->IN_DELETE_SELF );
    DEBUG "attributes, "   if ( $e->IN_ATTRIB );
    DEBUG "modified, "     if ( $e->IN_MODIFY );
    DEBUG "open, "         if ( $e->IN_OPEN );
    DEBUG "close/w, "      if ( $e->IN_CLOSE_NOWRITE );
    DEBUG "close/ro, "     if ( $e->IN_CLOSE_WRITE );  
    DEBUG "moved_to, "     if ( $e->IN_MOVED_TO );
    DEBUG "moved_from, "   if ( $e->IN_MOVED_FROM );
    DEBUG "moved_self, "   if ( $e->IN_MOVE_SELF );
}

sub _get_vm_data {
    my ($dir) = @_;
    my @parts = File::Spec->splitdir($dir);

    my $vhci_dir = pop @parts;
    my $vm_dir   = pop @parts;

    my ($vm_id) = ($vm_dir =~ /^QVD-(\d+)$/);

    if ( !$vm_id ) {
        die "Bad path '$dir'";
    }

    return ($vhci_dir, $vm_id);
}

sub add_vhci_to_vm_mapping {
    my ($self, $vhci, $vm_id) = @_;
    DEBUG "Mapping $vhci => $vm_id";
    $self->{vhci_to_vm}->{ $vhci } = $vm_id;
}

sub del_vhci_to_vm_mapping {
    my ($self, $vhci) = @_;
    DEBUG "Unmapping $vhci";
    delete $self->{vhci_to_vm}->{ $vhci };
}

sub _add_vm_mapping_dir {
    my ($self, $dir) = @_;
    my ($vhci_dir, $vm_id) = _get_vm_data($dir);
    $self->add_vhci_to_vm_mapping( $vhci_dir, $vm_id );
}

sub _del_vm_mapping_dir {
    my ($self, $dir) = @_;
    my ($vhci_dir, $vm_id) = _get_vm_data($dir);
    $self->del_vhci_to_vm_mapping( $vhci_dir );
}


sub _find_cgroup_dir {
    my ($dir) = @_;
    open(my $mounts, '<', "/proc/mounts") or die "Can't read /proc/mounts: $!";
    while(my $line = <$mounts>) {
        chomp $line;
        my ($device, $mountpoint, $filesystem, $opts) = split(/\s+/, $line);
        if ( $filesystem eq "cgroup" ) {
            my @opts = split(/,/, $opts);
            if ( grep { /$dir/ } @opts ) {
                return $mountpoint;
            }
        }
    }
    close $mounts;

    die "Failed to find mountpoint for cgroups $dir";
}


1;

