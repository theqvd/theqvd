package QVD::HKD::VHCIHandler;

use strict;
use warnings;

use AnyEvent;
use AnyEvent::Util;

use Data::Dumper;

use QVD::Log;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__  => {},

    new      => { transitions => { _on_run      => 'running'  } },

    running  => { transitions => { on_hkd_stop => 'stopping' } },

    stopping => { enter => '_kill_cmd',
                  transitions => { _on_done => 'stopped' },
                  ignore => [qw(on_hkd_stop)] },

    stopped  => { enter => '_on_stopped' };

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);

    my $sysfs_root = delete $opts{sysfs_root} // '/sys';
    $sysfs_root =~ s|(?<=.)/+||; # remove any trailing slashes
    DEBUG "sysfs_root = ".$sysfs_root;
    $sysfs_root =~ /^\// or die "sysfs_root must point to an absolute directory";
  
    my $platform_path = "$sysfs_root/devices/platform";

    opendir my $vhci , $platform_path or die "Can't open vhci_hcd platform directory";
    my %hubs = map { $_ => 0 } grep { /vhci_hcd.(\d+)/ } readdir( $vhci );

    DEBUG "VHCI Handler launched with: " . ( keys %hubs ) . " hubs";
    $self->{hubs} = \%hubs;

    $self;
}

sub reserve_vhci_hub {
    my ($self, $vm_id ) = @_;
    my $pick;

    # find free port
    foreach my $hub ( keys %{$self->{hubs}} ){
        if ($self->{hubs}->{$hub} == 0){
            $pick = $hub;
            last;
        }
    }

    # Assign port to vm
    $self->{hubs}->{$pick} = $vm_id;
    DEBUG "Assigned $pick to vm $vm_id";
    
    # Make dark magic
    
    
    return;
}

sub release_vhci_hub {
    my ($self, $vm_id) = @_;
    my $pick;

    # Undo dark magic

    # Find assigned hub
    foreach my $hub ( keys %{$self->{hubs}} ){
        if ($self->{hubs}->{$hub} == $vm_id){
            $pick = $hub;
            last;
        }
    }
    
    # Release hub
    $self->{hubs}->{$pick} = 0;
    DEBUG "Released $pick from vm $vm_id";

    return;

}


1;
