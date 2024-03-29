package QVD::Client::PulseAudio::Base;
use QVD::Log;
use warnings;
use strict;
use File::Basename;
use File::Spec;

my $BLACKHOLE_IP="240.0.0.1";

sub new {
	my ($class) = @_;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub is_running {
	return 0;
}

sub is_opus_supported {
	my ($self) = @_;
	my $retval;

    # To check if Opus is supported, we have to load the module. The problem is
    # that it needs to be given an IP address to connect to. It doesn't matter if
    # it's unable to connect anywhere, so we try to pick an invalid address.
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

sub load_module {
    my ($self, $module, @args) = @_;
    my @cmd = ("load-module", $module, @args);
    my $argstr = join(" ", @args);


    DEBUG "Loading module $module with arguments $argstr";

    my $retval = $self->cmd(@cmd);

    if ( $retval ne "" ) {
        ERROR "Failed to load module: $retval";
        return undef;
    }

    DEBUG "Retrieving module list";
    $retval = $self->cmd("list-modules");

    my $mod_num;
    my $mod_name;
    my $mod_args;

    DEBUG "Trying to find module '$module' with arguments '$argstr'";

    foreach my $line (split(/\n/, $retval)) {
        if ( $line =~ /^\s+index: (\d+)/ ) {
            $mod_num = $1;
            undef $mod_name;
            undef $mod_args;
        }

        if ( $mod_num && $line =~ /^\s+name: <(.*?)>/ ) {
            $mod_name = $1;
        }

        if ( $mod_num && $line =~ /^\s+argument: <(.*?)>/ ) {
            $mod_args = $1;
        }

        if ( $mod_num && $mod_name && $mod_args && ($mod_name eq $module) && ($mod_args eq $argstr) ) {
            DEBUG "Found with id $mod_num";
            return $mod_num;
        }
    }

    return -1;
}

sub unload_module {
    my ($self, $mod) = @_;
    $self->cmd("unload-module", $mod);
}

# Write a new config file updating the module paths.
# The function may perform any other required changes in the future
sub rewrite_config_file {
    my ($self, $source, $dest) = @_;

    my $mod_path = $self->get_pulse_module_path();
    my $mod_ext  = $self->get_pulse_module_extension();

    open(my $in_fh, '<', $source) or die "Can't open $source: $!";
    open(my $out_fh, '>', $dest) or die "Can't open $dest: $!";
    while(my $line = <$in_fh>) {
        chomp $line;

        if ( $line =~ /(load-module|\.ifexists)\s+(\S+)(.*?)$/ ) {
            my $command = $1;
            my $file    = File::Spec->catfile($mod_path, basename($2) . $mod_ext);
            my $args    = $3;

            print $out_fh "$command $file $args\n";
        } else {
            print $out_fh "$line\n";
        }
    }
    close $out_fh;
    close $in_fh;
}

sub get_pulse_module_extension {
    my ($self) = @_;
    return "";
}

sub get_pulse_module_path {
    my ($self) = @_;
}

1;
