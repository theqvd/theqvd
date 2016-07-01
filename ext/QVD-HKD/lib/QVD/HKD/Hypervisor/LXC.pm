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
    $self->_config_cgroups or LOGDIE "Wrong cgroup configuration detected";
    $self
}

sub on_config_changed {
    my $self = shift;
    $self->_config_cgroups;
}

sub cgroup_control_path {
    my ($self, $control) = @_;
    my $paths = $self->{cgroup_control_paths} // return;
    $paths->{$control};
}

sub swapcount_enabled { shift->{swapcount} }

sub ok {
    my $self = shift;
    $self->{cgroup_control_paths} and $self->SUPER::ok
}


sub _check_cgroup_fs {
    my ($self, $path) = @_;
    my $mi = Linux::Proc::Mountinfo->read;
    my @parts = File::Spec->splitdir(File::Spec->rel2abs($path));
    while (1) {
        my $dir = realpath(File::Spec->join(@parts) // '') // next;
        DEBUG("looking for a cgroup filesystem at $dir");
        if (defined(my $mie = $mi->at($dir))) {
            if ($mie->fs_type eq 'cgroup') {
                return 1;
            }
        }
        pop(@parts) // return;
    }
}

sub _search_cgroup_control {
    my ($self, $control) = @_;
    my $base = $self->_cfg("path.cgroup");
    if (opendir my $dh, $base) {
        while (defined (my $entry = readdir $dh)) {
            if ($entry =~ /(?:^|,)\Q$control\E(?:,|$)/) {
                my $path = "$base/$entry/lxc";
                if ($self->_check_cgroup_fs($path)) {
                    DEBUG "cgroups $control path found at '$path'";
                    return $path;
                }
            }
        }
    }
    else {
        ERROR "Can't open directory '$base'";
    }

    ERROR "Unable to find cgroup control $control";
    ()
}

sub _config_cgroups {
    my $self = shift;

    delete $self->{cgroup_control_paths};

    my %path;
    for my $control (qw(memory cpu cpuset)) {
        my $path = $self->_cfg_optional("path.cgroup.$control.lxc");
        if (defined $path) {
            $self->_check_cgroup_fs($path)
                or LOGDIE "'$path' does not lay inside a cgroup filesystem";
        }
        else {
            $path = $self->_search_cgroup_control($control) // return;
        }

        # the 'lxc' part of the path may not exist yet, so we create it here:
        unless (-d $path or mkdir $path) {
            ERROR "Directory $path does not exist and cannot be created either: $!";
            return;
        }

        $path{$control} = $path;
    }

    $self->{cgroup_control_paths} = \%path;

    # swapcount is not checked on config reloads
    $self->{swapcount} //= do {
        my $on = -f "$path{memory}/memory.memsw.limit_in_bytes";
        $on or WARN "Memory limits can not be set. The argument 'swapaccount=1' must be passed to the kernel at boot time";
        $on
    };

    $self->{cpus} //= do {
        my %cpu;
        my $fn = "$path{cpuset}/cpuset.cpus";
        open my $fh, '<', $fn or LOGDIE "Unable to open '$fn'";
        my $line = <$fh> // LOGDIE "Unable to read cpuset from '$fn'";
        for my $range (split /\s*,\s*/, $line) {
            my ($a, $b) = $range =~ /^(\d+)(?:-(\d+))?$/ or LOGDIE "Invalid cpuset range '$range' found";
            $b //= $a;
            $cpu{$_} = 0 for $a..$b;
        }
        \%cpu;
    };

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

