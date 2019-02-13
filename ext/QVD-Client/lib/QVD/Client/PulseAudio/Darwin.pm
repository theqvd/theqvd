package QVD::Client::PulseAudio::Darwin;
use base 'QVD::Client::PulseAudio::Unix';
use QVD::Log;
use QVD::Config::Core;

use IO::Socket::UNIX;
use Proc::Background;
use Time::HiRes qw(sleep);
use Mac::NSGetExecutablePath;
use Cwd;
use File::Spec;



sub new {
    my ($class, %params) = @_;
    my $self = $class->SUPER::new(%params);

    $self->{pa_path} = delete $params{pa_path} or die "pa_path must be set on Darwin, as there is no system PulseAudio";

    if ( scalar keys %params ) {
        die "Unknown arguments: " . join(', ', keys %params);
    }
    return $self;
}


sub get_pulse_module_path {
    my ($self) = @_;
    my $exe_path = Cwd::abs_path(Mac::NSGetExecutablePath::NSGetExecutablePath());
    my @dirs = File::Spec::splitdir(@exe_path);

    while( $dirs[-1] ne "Resources" && $dirs[-2] ne "Contents" ) {
        shift @dirs;
    }

    my $root_path = File::Spec::catdir(@dirs);

    $root_path .= core_cfg("path.pulseaudio.modules.base");
    my $pulse_dirname;

    # Pulseaudio lib dir includes a version number ( pulse-12.0 )
    # Find the first thing that matches
    opendir(my $dir, $rootpath) or die "Can't find pulseaudio path $rootpath";
    while(my $d = readdir($dir)) {
        if ( $d =~ /^pulse-/) {
            $pulse_dirname = $d;
            last;
        }
    }
    closedir $dir;


    my $module_path = $root_path . "/$pulse_dirname";

    DEBUG "Detected pulseaudio module path: $module_path";

    return $module_path;
}

sub is_running {
    my ($self) = @_;
    my $pidfile = $self->{pa_path} . "/pid";
    my $pid;

    $self->_dbg("Checking if PulseAudio is running with PID file '$pidfile'");

    if ( open(my $ph, '<', $pidfile) ) {
        $pid = <$ph>;
        chomp $pid;
        close $ph;
    } else {
        $self->_dbg("Failed to find pidfile '$pidfile'\n");
        return undef;
    }

    $self->_dbg("PID file contains PID $pid");
    if ( open(my $fh, "-|", "ps", "-ho", $pid) ) {
        my $exe = <$fh>;
        chomp $exe;

        if ( $exe && $exe =~ /pulseaudio/ ) {
            $self->_dbg("Process $pid is running, and the binary is PulseAudio. All good.");
            return $pid;
        } else {
            $self->_dbg("Executable '$exe' for pid $pid isn't PA\n");
            return undef;
        }
    } else {
        $self->_dbg("Failed to execute 'ps -ho $pid': $!");
        return $pid;
    }

}

sub get_pulse_module_extension {
    my ($self) = @_;
    return ".so";
}

1;


