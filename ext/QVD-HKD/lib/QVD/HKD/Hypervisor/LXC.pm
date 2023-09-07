package QVD::HKD::Hypervisor::LXC;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use strict;
use warnings;

use Linux::Proc::Mountinfo;
use Cwd qw(realpath);

use QVD::Log;
use QVD::HKD::VMHandler::LXC;

use parent qw(QVD::HKD::Hypervisor);

sub new_vm_handler {
    my $self = shift;
    QVD::HKD::VMHandler::LXC->new(@_, hypervisor => $self);
}

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    my $cgroups_version = $self->_cgroups_version;
    ($cgroups_version eq "cgroup2") ? $self->_config_cgroups : LOGDIE "Wrong cgroup2 configuration detected";
    INFO "Detected cgroups version: $cgroups_version";
    $self
}

sub on_config_changed {
    my $self = shift;
    my $cgroups_version = $self->_cgroups_version;
    ($cgroups_version eq "cgroup2") ? $self->_config_cgroups : LOGDIE "Wrong cgroup2 configuration detected"; 
}

sub cgroup_control_path {
    my ($self, $control) = @_;
    my $paths = $self->{cgroup_control_paths} // return;
    $paths->{$control};
}

#sub swapcount_enabled { shift->{swapcount} }

sub ok {
    my $self = shift;
    $self->{cgroup_control_paths} and $self->SUPER::ok
}

sub _recreate_lxc_cpuset_cpus {
    my $self = shift;
    DEBUG "checking lxc cpuset.cpus";

    my $cpuset_path = $self->{cgroup_control_paths}{cpuset};
    my $available = $self->_cfg_optional('vm.lxc.cpuset.available');
    my $fn = "$cpuset_path/cpuset.cpus.effective"; 

    unless (defined $available) {
        # Workaround for SLES not filling /sys/fs/cgroup/cpuset/lxc/cpuset.cpus correctly:
        if (open my $fh, '<', $fn) {
            DEBUG "cpuset.cpus fileno: ".fileno($fh);
            while (<$fh>) {
                # If a specific set of cpus has not been given an the file /is not empty we don't touch it!
                if (/\d/) {
                    close $fh;
                    return;
                }
            }
        }
        INFO "$fn was empty, recreating it!";
        $available = join(",", sort { $a <=> $b } keys %{$self->{cpus}});
    }

    if (open my $fh, '>', $fn) {
        DEBUG "cpuset.cpus fileno: ".fileno($fh);
        print $fh "$available\n";
        close $fh and return;
    }
    ERROR "Unable to recreate $fn: $!";
}

sub _cgroups_version {
    my $self = shift;
    my $mnts = Linux::Proc::Mountinfo->read;
    my $cgroups_path = $self->_cfg("path.cgroup");
    my $cgroups_mnt = $mnts->at($cgroups_path);
    my $cgroups_version = $cgroups_mnt->fs_type;

    INFO $cgroups_mnt->mount_source . " is mounted at " . $cgroups_mnt->mount_point . " as " . $cgroups_mnt->fs_type;

    return $cgroups_version;
}

sub _config_cgroups {
    my $self = shift;
    my %path;
    my $path = $self->_cfg("path.cgroup");

    delete $self->{cgroup_control_paths};

    my $lxc_conf_file = $self->_cfg("lxc.conf.file");
    open (my $lxc_conf, "<", $lxc_conf_file) or die "Couldn't open $lxc_conf_file file: $!";
   
    my %conf;
    my ($pattern);
    while (<$lxc_conf>) {
        chomp;
        if ($_ =~ /^lxc.cgroup.pattern/) {
            my ($key, $value) = split(/=/, $_);
	    $value =~ s/ //g;
            DEBUG "Load from lxc config: $key= $value";
	    ($pattern) = $value =~ /(.*)?\//;
        }
    }
    close $lxc_conf;

    if (! -d "$path/$pattern") { 
        mkdir("$path/$pattern") or die "Unable to create cgroup subcontrol $pattern: $!";
	DEBUG "Cgroup subcontrol $pattern created.";
    }

    INFO "Searching cgroup controllers...";
    my $loaded_controllers = "$path/cgroup.controllers";
    open (my $fh, $loaded_controllers) or die "Couldn't open file: $loaded_controllers: $!";
    my @controllers = <$fh>;
    close $fh;
    
    my $loaded_subcontrollers = "$path/$pattern/cgroup.controllers";
    open (my $fi, $loaded_subcontrollers) or die "Couldn't open file: $loaded_subcontrollers: $!";
    my @subcontrollers = <$fi>;
    close $fi;

    for my $control (qw(memory cpu cpuset)) {
        if (/$control/ ~~ @controllers) {
            INFO "Controller $control is loaded into cgroup filesystem.";
	    if (/$control/ ~~ @subcontrollers) {
               INFO "Controller $control is loaded for $pattern subcontrol.";
	    } else {   
               INFO "Controller $control is not loaded for $pattern subcontrol, loading...";
	       open(FH, '>', "$path/cgroup.subtree_control") or die $!;
               say FH "+$control";
	       close(FH);
	    } 
        } else {
            die "Controller $control is not loaded into cgroup filesystem.";
        }

	$path{$control} = "$path/$pattern";
    }

    $self->{cgroup_control_paths} = \%path;
    $self->_load_lxc_cpuset_cpus;

    1;
}

sub _load_lxc_cpuset_cpus {
    my $self = shift;
    my $path = $self->cgroup_control_path('cpuset');

    DEBUG "Using cgroup path: $path to manage cpuset control.";

    $self->{cpus} //= do {
        my %cpu;
        my $fn;
        my $custom_cpuset_range = $self->_cfg_optional("vm.lxc.cpuset.range");

        if (defined $custom_cpuset_range) {
            $fn = "$path/cpuset.cpus";
            if (open my $fh, '>', $fn) {
                DEBUG "set custom cpuset range: $custom_cpuset_range to $fn";
                say $fh $_ for "$custom_cpuset_range";
                close $fh;
            }
        } else {
            $fn = "$path/../cpuset.cpus.effective";
            DEBUG "Loading all available vCPUs from $fn";		
        }       

	open my $fh, '<', $fn or LOGDIE "Unable to open '$fn'";
        my $line = <$fh> // LOGDIE "Unable to read cpuset from '$fn'";
        for my $range (split /\s*,\s*/, $line) {
            my ($a, $b) = $range =~ /^(\d+)(?:-(\d+))?$/ or LOGDIE "Invalid cpuset range '$range' found";
            $b //= $a;
	    DEBUG "vCPUs range: $range";
            $cpu{$_} = 0 for $a..$b;
        }
        \%cpu;
    };
    $self->_recreate_lxc_cpuset_cpus;

    1;
}

sub _debug_cpus {
    if ($debug) {
        my $self = shift;
        my $header = shift;
        my $cpus = $self->{cpus};
        my %changed = map { $_ => 1 } @_;
        my $list =
            join ', ',
            map { sprintf "%s: %d%s", $_, $cpus->{$_}, ($changed{$_} ? '*' : '') }
            sort {$a <=> $b}
            keys %$cpus;
        $self->_debug("$header: $list");
    }
}

sub reserve_cpuset {
    my ($self, $n) = @_;
    my $cpus = $self->{cpus};
    my @best = (sort { $cpus->{$a} <=> $cpus->{$b} or $a <=> $b } keys %$cpus)[0..$n-1];
    $debug and $self->_debug_cpus("Assigned CPUs", @best);
    $cpus->{$_}++ for @best;
    DEBUG "CPUs assigned: @best";
    @best
}

sub release_cpuset {
    my $self = shift;
    my $cpus = $self->{cpus};
    $debug and $self->_debug_cpus("Released CPUs", @_);
    for (@_) {
        $cpus->{$_}--;
        if ($cpus->{$_} < 0) {
            ERROR "Internal error: cpuset count for CPU $_ became negative!";
            $cpus->{$_} = 0;
        }
    }
    1;
}

1;
