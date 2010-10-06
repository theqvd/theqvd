package QVD::Node;

our $VERSION = '0.01';

use strict;
use warnings;

BEGIN { $QVD::Config::USE_DB = 0 }

use QVD::Config;
use QVD::Log;

use POSIX;
use Socket;
use JSON qw(to_json from_json);
use Linux::Proc::Net::TCP;

my $database_timeout = core_cfg('internal.hkd.database.timeout');
my $cluster_node_timeout   = cfg('internal.hkd.cluster.node.timeout');


sub new {
    my $class = shift;
    my $noded = { vm_pids          => {},
		  vm_taps          => {},
		  # killed         => undef,
		  stopping         => undef,
		  hkd_time_limit_1 => undef,
		  hkd_time_limit_2 => undef,
		  hkd_pid          => undef,
		  hkd_socket       => undef,
		  l7r_pid          => undef,
		  dhcpd_pid        => undef,
		  dhcpd_cmd        => undef };
    bless $noded, $class;
    $noded;
}

sub _min {
    my $min;
    for (@_) { $min = $_ if (!defined $min or $min > $_) }
    $min;
}

sub run {
    my $noded = shift;

    $SIG{$_} = sub { $noded->{killed} = 1 }
	for (qw(INT TERM HUP));

    while (1) {

	$noded->_shutdown if ($noded->{stopping} and !%{$noded->{vm_pids}});

	my $hkd_pid = $noded->_fork_hkd;
	unless ($hkd_pid) {
	    sleep 5;
	    my $tl2 = $noded->{hkd_time_limit_2};
	    if ($tl2 and $tl2 < time) {
		INFO "timeout2 expired, shutting down (a)";
		$noded->_shutdown;
	    }
	    next;
	}
	my $rv = '';
	my $fn = fileno $noded->{hkd_socket};
	vec($rv, $fn, 1) = 1;
	while (1) {

	    $noded->_fork_l7r unless $noded->{l7r_pid};
	    $noded->_fork_dhcpd unless $noded->{dhcpd_pid};

	    my $tl1 = $noded->{hkd_time_limit_1};
	    my $tl2 = $noded->{hkd_time_limit_2};
	    my $time = time;
	    my $timeout = _min($tl1, $tl2, $time + 5) - $time;
	    my $rv1 = $rv;

	    select ($rv1, undef, undef, $timeout);

	    if (vec($rv1, $fn, 1)) {
		if (defined recv($noded->{hkd_socket}, my $msg, 4096, 0)) {
		    DEBUG "message received: $msg";
		    my ($cmd, @args) = @{from_json($msg)};
		    my @result;
		    if (my $method = $noded->can("_rpc_$cmd")) {
			eval { @result = (ok =>  $method->($noded, @args)) };
			@result = (error => $@) unless @result;
		    }
		    else {
			@result = (error => "method for $cmd not implemented");
		    }
		    my $response = to_json(\@result);
		    send($noded->{hkd_socket}, $response, 0);
		    DEBUG "message response: $response";
		}
	    }

	    if (delete $noded->{killed}) {
		print "killed!\n";
		$noded->{stopping} = 1;
		kill HUP => $hkd_pid;
	    }

	    $time = time;
	    if ($tl2 and $tl2 < $time) {
		INFO "timeout2 expired, shutting down (b)";
		$noded->_shutdown;
	    }
	    if ($tl1 and $tl1 < $time) {
		kill KILL => $hkd_pid;
	    }

	    if (waitpid($noded->{l7r_pid}, WNOHANG) > 0) {
		delete $noded->{l7r_pid}
	    }

	    if (waitpid($hkd_pid, WNOHANG) > 0) {
		delete $noded->{hkd_pid};
		$noded->{hkd_time_limit_1} = time + $database_timeout * 2;
		last; # we go to the outer loop
	    }
	}
    }
}

sub _fork_hkd {
    my $noded = shift;
    my ($master, $slave);
    unless (socketpair($master, $slave, AF_UNIX, SOCK_DGRAM, PF_UNSPEC)) {
	ERROR "unable to fork HKD, socketpair failed: $!";
	return undef;
    }
    my $pid = fork;
    unless ($pid) {
	unless (defined $pid) {
	    ERROR "unable to fork HKD: $!";
	    return undef;
	}
	eval {
	    setpgrp;
	    close $master;
	    $QVD::Config::USE_DB = 1;
	    QVD::Config::reload();
	    require QVD::HKD;
	    my $hkd = QVD::HKD->new($slave);
	    $hkd->run(vm_pids => $noded->{vm_pids}, stopping => $noded->{stopping});

	};
	$@ and ERROR $@;
	POSIX::_exit(0);
    }
    $noded->{hkd_pid} = $pid;
    $noded->{hkd_socket} = $master;
    close $slave;
    $pid;
}

sub _fork_l7r {
    my $noded = shift;
    my $pid = fork;
    if (!$pid) {
	unless (defined $pid) {
	    ERROR "unable to fork L7R: $!";
	    return undef;
	}
	eval {
	    setpgrp;
	    $QVD::Config::USE_DB = 1;
	    QVD::Config::reload();
	    require QVD::L7R;
	    my $l7r = QVD::L7R->new();
	    $l7r->run;
	};
	$@ and ERROR $@;
	POSIX::_exit(0);
    }
    $noded->{l7r_pid} = $pid;
}

sub _fork_dhcpd {
    my $noded = shift;
    my $cmd = $noded->{dhcpd_cmd} or return;
    my $pid = fork;
    if (!$pid) {
	unless (defined $pid) {
	    ERROR "unable to fork dhcp server";
	    return undef;
	}
	eval {
	    setpgrp;
	    exec @$cmd;
	};
	$@ and ERROR $@;
	POSIX::_exit(0);
    }
    $noded->{dhcpd_pid} = $pid;
}

sub _shutdown {
    my $noded = shift;
    my @pids = ( $noded->{hkd_pid},
		 $noded->{l7r_pid},
		 $noded->{dhcpd_pid},
		 values %{$noded->{hkd_pids}} );

    for my $sig (qw(TERM TERM KILL KILL KILL KILL)) {
	@pids = grep $_, @pids;
	@pids or last;
	for my $pid (@pids) {
	    DEBUG "shutdown: kill $sig, $pid";
	    kill $sig, $pid;
	}
	sleep 1;
	for my $pid (@pids) {
	    waitpid($pid, WNOHANG) > 0
		and undef $pid;
	}
    }
    exit(0);
}

sub _rpc_set_timeouts {
    my ($noded, $time) = @_;
    $noded->{hkd_time_limit_1} = $time + $database_timeout;
    $noded->{hkd_time_limit_2} = $time + $cluster_node_timeout unless $noded->{stopping};
    DEBUG "hkd time limits set to $noded->{hkd_time_limit_1} and $noded->{hkd_time_limit_2}";
}

sub _rpc_fork_vm {
    my ($noded, $id, $bridge, @cmd) = @_;
    my ($tap_fh, $tap_if) = $noded->_open_tap($bridge);

    system(brctl => 'addif', $bridge, $tap_if)
        and die "brctl addif $bridge $tap_if failed for VM $id\n";

    DEBUG "forking kvm for VM $id: @cmd";
    my $pid = fork;
    unless ($pid) {
 	$pid // die "unable to fork virtual machine process: $!";
	eval {
 	    setpgrp; # do not kill kvm when HKD runs on terminal and user CTRL-C's it
            if (fileno $tap_fh == 3) {
                fcntl($tap_fh, F_SETFD, fcntl($tap_fh, F_GETFD, 0) & ~FD_CLOEXEC)
                    or die "fcntl failed: $!";
            }
            else {
                POSIX::dup2(fileno $tap_fh, 3) or die "dup2 failed: $!";
            }
	    open STDIN, '<', '/dev/null' or die "can't open /dev/null\n";
	    open STDOUT, '>', '/dev/null' or die "can't redirect STDOUT to /dev/null\n";
	    POSIX::dup2(1, 2) or die "dup2 failed (2): $!";
	    exec @cmd or die "exec failed\n";
	};
 	ERROR "Unable to start VM: $@";
 	POSIX::_exit(1);
    }
    DEBUG "kvm pid: $pid\n";
    close $tap_fh;
    $noded->{vm_pids}{$id} = $pid;
    $noded->{vm_taps}{$id} = $tap_if;
    ($pid, $tap_if);
}

sub _open_tap {
    use constant TUNNEL_DEV => '/dev/net/tun';
    use constant STRUCT_IFREQ => "Z16 s";
    use constant IFF_NO_PI => 0x1000;
    use constant IFF_TAP => 2;
    use constant TUNSETIFF => 0x400454ca;

    open my $tap_fh, '+<', TUNNEL_DEV or die "Can't open ".TUNNEL_DEV.": $!";

    my $ifreq = pack(STRUCT_IFREQ, 'qvdtap%d', IFF_TAP|IFF_NO_PI);
    ioctl $tap_fh, TUNSETIFF, $ifreq or die "Can't create tap interface: $!";

    my $tap_if = unpack STRUCT_IFREQ, $ifreq;

    return ($tap_fh, $tap_if);
}

sub _rpc_check_vm_process {
    my ($noded, $id) = @_;
    my $pid = $noded->{vm_pids}{$id};
    if (defined $pid) {
	return 1 if waitpid($pid, WNOHANG) != $pid;
	delete $noded->{vm_pids}{$id};
    }
    return 0;
}

sub _rpc_kill_vm_process {
    my ($noded, $id, $signal) = @_;
    my $pid = $noded->{vm_pids}{$id} or return;
    kill $signal, $pid;
}

my $off = 0;
sub _rpc_allocate_tcp_port {
    my ($noded, $base) = @_;
    $base ||= 2000;
    my $tcp = Linux::Proc::Net::TCP->read;
    my %used = map { $_ => 1 } $tcp->listener_ports;
    while (1) {
	$off++;
	my $port = $base + $off;
	return $port unless $used{$port};
    }
}

sub _rpc_start_dhcpd {
    my ($noded, @cmd) = @_;
    $noded->{dhcpd_cmd} = \@cmd;
    kill TERM => $noded->{dhcpd_pid} if $noded->{dhcpd_pid};
    1;
}

sub _rpc_reload_dhcpd {
    my ($noded, @cmd) = @_;
    $noded->{dhcpd_cmd} = \@cmd;
    kill HUP => $noded->{dhcpd_pid};
}

1;

__END__

=head1 NAME

QVD::Node - Perl extension for blah blah blah

=head1 SYNOPSIS

  use QVD::Node;
  my $node = QVD::Node->new('name');
  $node->run;

=head1 DESCRIPTION

...

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Qindel Formación y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut
