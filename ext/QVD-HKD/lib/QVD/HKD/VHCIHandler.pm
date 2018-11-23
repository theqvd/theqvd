package QVD::HKD::VHCIHandler;

use strict;
use warnings;

use AnyEvent;
use AnyEvent::Util;
use File::Path;
use Carp;

use Data::Dumper;

use QVD::Log;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__  => {},

    new      => { transitions => { _on_run      => 'running'  } },

    running  => { transitions => { on_hkd_stop => 'stopping' } },

    stopping => { jump => 'stopped',
                  transitions => { _on_done => 'stopped' },
                  ignore => [qw(on_hkd_stop)] },

    stopped  => { enter => '_on_stopped' };

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);

    my $sysfs_root = delete $opts{sysfs_root} // '/sys';
    $sysfs_root =~ s|(?<=.)/+||; # remove any trailing slashes
    DEBUG "sysfs_root = ".$sysfs_root;
    $sysfs_root =~ /^\// or croak "sysfs_root must point to an absolute directory";
  
    my $platform_path = "$sysfs_root/devices/platform";

    opendir my $vhci , $platform_path or croak "Can't open vhci_hcd platform directory";
    my %hubs = map { $_ => -1 } grep { /vhci_hcd.(\d+)/ } readdir( $vhci );

    DEBUG "VHCI Handler launched with: " . ( keys %hubs ) . " hubs";
    $self->{hubs} = \%hubs;

    $self;
}

sub reserve_vhci_hub {
    my ($self, $vm_id ) = @_;
    my $dir = $self->_cfg('path.storage.devicefs') . "/QVD-$vm_id";
    my $pick;

    # find free port
    foreach my $hub ( keys %{$self->{hubs}} ){
        if ($self->{hubs}->{$hub} == -1){
            $pick = $hub;
            last;
        }
    }

    # Assign port to vm
    $self->{hubs}->{$pick} = $vm_id;
    DEBUG "Assigned $pick to vm $vm_id";
    
    # Clean just in case
    if (-e $dir and -d $dir) {
        rmtree $dir or croak "Can't clean directory structure: $dir";
    }

    # Create directory
    mkdir $dir or croak "Can't create directory structure: $dir";
    mkdir $dir."/".$pick or croak "Can't create directory structure: $dir/$pick";
    
    return $dir;
}

sub release_vhci_hub {
    my ($self, $vm_id) = @_;
    my $dir = $self->_cfg('path.storage.devicefs') . "/QVD-$vm_id";
    my $pick;

    # Cleanup
    rmtree $dir or croak "Can't clean directory structure: $dir";

    # Find assigned hub
    foreach my $hub ( keys %{$self->{hubs}} ){
        if ($self->{hubs}->{$hub} == $vm_id){
            $pick = $hub;
            last;
        }
    }
    
    # Release hub
    $self->{hubs}->{$pick} = -1;
    DEBUG "Released $pick from vm $vm_id";

    return 1;

}

1;
