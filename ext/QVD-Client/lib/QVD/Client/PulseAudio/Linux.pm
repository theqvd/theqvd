package QVD::Client::PulseAudio::Linux;
use base 'QVD::Client::PulseAudio::Base';
use QVD::Log;
use QVD::Config::Core;

use IO::Socket::UNIX;
use Proc::Background;
use Time::HiRes qw(sleep);

my $BLACKHOLE_IP="240.0.0.1";


sub new {
	my ($class, %params) = @_;
	my $self = {};
	bless $self, $class;

	$self->{pa_path} = delete $params{pa_path} // "$ENV{XDG_RUNTIME_DIR}/pulse";
	$self->{debug}   = delete $params{debug};
	$self->{proc}    = delete $params{proc};
	$self->{envfunc} = delete $params{env_func};

	$self->{debug} = 1;
	if ( scalar keys %params ) {
		die "Unknown arguments: " . join(', ', keys %params);
	}
	return $self;
}

sub _setenv {
	my ($self, %args) = @_;
	if ( $self->{envfunc} ) {
		DEBUG "Calling setenv function";
		$self->{envfunc}->(%args);
	} else {
		DEBUG "Using internal setenv code";
		foreach my $k (keys %args) {
			$ENV{$k} = $args{$k};
		}
	}
}

sub is_qvd_pulseaudio_installed {
	my ($self) = @_;
	my $cmd = core_cfg('command.qvd-pulseaudio');

	DEBUG "Checking if qvd-pulseaudio is installed at $cmd";
	my $ret = -x $cmd;

	DEBUG "Result: qvd-pulseaudio " . ($ret ? "is" : "is not") . " installed";
	return $ret;
}

sub start {
	my ($self) = @_;

	my $pulsehome = "$ENV{HOME}/.qvd/pulse";
	my @args = (core_cfg('command.qvd-pulseaudio'),
	            "-n",
	            "-F", "/usr/lib/qvd/etc/pulse/default.pa",
	            "-v",
	            "--exit-idle-time=36000",
	            "--log-target=file:$pulsehome/pa.log");

	$self->_setenv( PULSE_RUNTIME_PATH => $pulsehome );
	DEBUG "PA home: $pulsehome";
	mkdir $pulsehome;

	INFO "Starting PulseAudio: " . join(' ', @args);
	my $proc = Proc::Background->new({ die_upon_destroy => 1}, @args);

	if ( $proc && $proc->alive ) {
		$self->{proc} = $proc;
		$self->{pa_path} = $pulsehome;
		my $connected;
		my $tries = 100;
		DEBUG "PA running, pid " . $self->{proc}->pid;

		DEBUG "Waiting for PA to create the PID file";
		while($tries > 0 && $self->{proc}->alive) {
			last if ( $self->is_running );
			$tries--;
			sleep 0.1;
		}

		DEBUG "Waiting for PA to start accepting connections";
		while(!$connected && $tries > 0 && $self->{proc}->alive) {
			DEBUG "Waiting for PA to come online";
			eval { $self->_connect; };
			if ( $@ ) {
				my $err = $@;
				DEBUG "Connect error: $err, $tries tries left.";
				unless ( $err =~ /Failed to connect/ ) {
					die "Forwarding error: $err";
				}

				$tries--;
				sleep 0.1;
			} else {
				INFO "Connection successful";
				$connected = 1;
			}
		}

		if (!$connected) {
			my $reason = "";
			if ( $tries <= 0 ) {
				$reason = "daemon didn't start listening on the socket";
			} elsif ( !$self->{proc}->{alive}) {
				$reason = "daemon exited with code " . ($self->{proc}->wait >> 8);
			}

			ERROR "Failed to start PA, giving up";
			die "Failed to connect to PA: $reason";
		}
	} else {
		die "Failed to start PA: $!";
	}
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

	my $exe = readlink("/proc/$pid/exe");
	if ( $exe && $exe =~ /pulseaudio/ ) {
		$self->_dbg("Process $pid is running, and the binary is PulseAudio. All good.");
		return $pid;
	}

	$self->_dbg("Executable '$exe' for pid $pid isn't PA\n");
	return undef;
}

sub stop {
	my ($self) = @_;
	if ( $self->{proc} && $self->{proc}->alive ) {
		$self->{proc}->die;
		return $self->{proc}->wait;
	}
}

sub _connect {
	my ($self, $depth) = @_;
	my $path = $self->{pa_path} . "/cli";
	my $tries = 20;

	if ( !$self->{socket} || !$self->{socket}->connected() ) {

		while( !$self->{socket} ) {
			$self->{socket} = IO::Socket::UNIX->new( Type  => SOCK_STREAM(),
			                                         Peer  => $path );

			if ( !$self->{socket} ) {
				if ( $!{ECONNREFUSED} || $!{ENOENT} ) {
					my $pid = $self->is_running;

					if ( $pid ) {
						$self->_dbg("PulseAudio is running, but socket '$path' is not open. Signalling pid $pid to open it");
						kill 'USR2', $pid;
						sleep(0.1);
						$tries--;
					} else {
						$self->_dbg("PulseAudio is not running, connection is not possible");
						die "PulseAudio is not running";
					}
				} else {
					die "Failed to connect to PA UNIX socket '$path': $!";
				}
			}
		}

		$self->{socket}->send("hello\n");
		my $greeting = $self->_read_output();

		if ( $greeting =~ /^Welcome to PulseAudio ([.0-9]+)/ ) {
			$self->{version} = $1;
		}
	}
}

sub _dbg {
	my ($self, $text) = @_;
#	print STDERR $text; #if ($self->{debug});
	warn $text;
}

sub _send {
	my ($self, $data) = @_;
	$self->_connect;
	$self->_dbg("SEND: $data\n");
	$self->{socket}->send($data);
}

sub _read_output {
	my ($self) = @_;
	my $buf = "";
	my $tmp;
	while ( $buf !~ />>> /ms ) {
		$self->{socket}->recv($tmp, 4096);
		$buf .= $tmp;
	}

	$buf =~ s/>>> $//ms;
	return $buf;
}

sub cmd {
	my ($self, @data) = @_;
	my $str = join(" ", @data);
	DEBUG "Command: $str\n";

	$self->_send("$str\n");

	my $ret = $self->_read_output;
	$self->_dbg("RECV: $ret\n");

	return $ret;
}

sub version {
	my ($self) = @_;
	$self->_connect;
	return $self->{version};
}

1;

sub is_opus_supported {
	my ($self) = @_;
	my $retval;

	my $ret = $self->cmd("load-module",
	                      "module-tunnel-sink-new",
	                      "sink_name=paopustest",
	                      "server=tcp:$BLACKHOLE_IP:4713",
	                      "sink=paopustestsink",
	                      "compression=opus");
	if ( $ret eq "" ) {
		$ret = $self->cmd("list-sinks");
		$retval = 1 if ( $ret =~ /^\s+compression\.opus\.complexity\s+=/m );

		$self->cmd("unload-module", "module-tunnel-sink-new");
	} elsif ( $ret !~ /Module load failed/ ) {
		die "Unrecognized error from PA: $ret"
	}

	return $retval;
}
