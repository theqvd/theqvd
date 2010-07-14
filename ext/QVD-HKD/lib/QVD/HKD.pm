package QVD::HKD;

use warnings;
use strict;

use feature 'switch';
use QVD::Config;
use QVD::DB::Simple;
use QVD::ParallelNet;
use QVD::SimpleRPC::Client;
use QVD::SimpleRPC::Client::Parallel;
use QVD::L7R;

use Sys::Hostname;
use POSIX qw(:sys_wait_h SIGTERM SIGKILL);
use List::Util qw(max);
use POSIX;
use QVD::Log;

my %cmd = ( kvm     => cfg('command.kvm'),
	    kvm_img => cfg('command.kvm-img') );

my %timeout = ( starting    => cfg('internal.hkd.timeout.vm.state.starting'),
	        stopping_1  => cfg('internal.hkd.timeout.vm.state.stopping_1'),
		stopping_2  => cfg('internal.hkd.timeout.vm.state.stopping_2'),
		zombie_1    => cfg('internal.hkd.timeout.vm.state.zombie_1'),
		vma         => cfg('internal.hkd.timeout.vm.state.running') );

my $parallel_net_timeout   = cfg('internal.hkd.timeout.vm.vma');

my $pool_time              = cfg('internal.hkd.poll_time');
my $pool_all_mod           = cfg('internal.hkd.poll_all_mod');

my $images_path            = cfg('path.storage.images');
my $overlays_path          = cfg('path.storage.overlays');
my $homes_path             = cfg('path.storage.homes');
my $captures_path          = cfg('path.serial.captures');

my $vm_port_x              = cfg('internal.nxagent.display') + 4000;
my $vm_port_vma            = cfg('internal.vm.port.vma');

my $vnc_redirect           = cfg('vm.vnc.redirect');
my $vnc_opts               = cfg('vm.vnc.opts');

my $vm_virtio              = cfg('vm.kvm.virtio');
my $hdb_index              = cfg('vm.kvm.home.drive.index');
my $mon_redirect           = cfg('internal.vm.monitor.redirect');
my $serial_redirect        = cfg('vm.serial.redirect');
my $serial_capture         = cfg('vm.serial.capture');

my $network_bridge	   = cfg('vm.network.bridge');
my $dhcp_range	  	   = cfg('vm.network.dhcp-range');
my $dhcp_hostsfile	   = cfg('internal.vm.network.dhcp-hostsfile');

my $persistent_overlay     = cfg('vm.overlay.persistent');

my $database_timeout       = core_cfg('internal.hkd.database.timeout');
my $database_delay         = core_cfg('internal.hkd.database.retry_delay');

my $cluster_check_interval = cfg('internal.hkd.cluster.check.interval');
my $cluster_node_timeout   = cfg('internal.hkd.cluster.node.timeout');

sub new {
    my $class = shift;
    my $self = { killed       => undef,
		 stopping     => undef,
                 aborting     => undef,
		 start_time   => undef,
		 host         => undef,
		 host_runtime => undef,
		 frontend     => undef,
		 backend      => undef,
		 db_ok_ts     => undef,
		 round        => 0,
		 my_pid       => $$,
	         vm_pids      => {} # VM pids are also stored locally so that
                                    # in case the database becomes
                                    # inaccesible we would still be
                                    # able to kill the processes
	       };
    bless $self, $class;
}

sub _on_fork {
    my $hkd = shift;
    $hkd->{vm_pids} = {}
}

DESTROY {
    local ($?, $!, $@);
    shift->_shutdown
}

sub run {
    my $hkd = shift;

    $SIG{$_} =  sub { $hkd->{killed}++ }
	for (qw(INT TERM HUP));

    $hkd->_startup or die "HKD startup failed";
    my $hrt = $hkd->{host_runtime};

    while (1) {
	DEBUG "HKD run, round: $hkd->{round}";
	if (eval { $hkd->_check_db(1) }) {
	    $hkd->{round}++;
	    $hkd->{start_time} //= $hkd->{db_ok_ts};

	    $hkd->_on_killed if $hkd->{killed};

	    if ($hkd->{stopping}) {
		kill INT => $hkd->{l7r_pid}   # kill L7R early
		    if $hkd->{l7r_pid};

                if (eval { rs(VM_Runtime)->search({host_id => this_host_id})->count == 0 }) {
		    INFO "HKD exiting";
		    return 1;
		}
		DEBUG($@ || "Can't exit yet: there are VMs running");
	    }
	    eval {
		$hkd->_check_vms;
		$hkd->_check_l7rs;
		$hkd->_check_dhcp;
                $hkd->_check_hkd_cluster;
	    };
	    sleep $pool_time;
	}
        elsif ($hkd->{aborting}) { # database timeout has expired or
                                   # other critical error happened
            ERROR "HKD can not connect to database, aborting: $@";
            return undef;
        }
        else {
            INFO "HKD can not connect to database, retrying: $@";
            sleep $database_delay;
            undef $hkd->{start_time};
        }
    }
}

sub _check_db {
    my ($hkd, $always) = @_;
    my $time = time;
    $hkd->{aborting} and die "Already aborting";
    if ($hkd->{db_ok_ts} + $database_timeout < $time) {
        $hkd->{aborting} = 1;
        die "Database timeout expired";
    }
    if ($always or ($hkd->{db_ok_ts} + 0.3 * $database_timeout) < $time) {
	my $hrt = $hkd->{host_runtime};
	for (1, 2) {
	    eval {
                alarm 5;
		txn_eval {
                    $hrt->discard_changes;
                    if ($hrt->state eq 'blocked') {
                        $hkd->{aborting} = 1;
                        die "Host is blocked";
                    }
                    $time = time;
                    $hrt->update_ok_ts($time);
                };
		alarm 0;
                $@ and die $@;
	    };
	    unless ($@) {
		$hkd->{db_ok_ts} = $time;
		return 1;
	    }
	}
	die "Database check failed: $@";
    }
    1;
}

sub _on_killed {
    my $hkd = shift;
    DEBUG "HKD killed";
    if ($hkd->{stopping}) {
	DEBUG "HKD is already stopping";
	undef $hkd->{killed};
    }
    else {
	eval {
	    my $hrt = $hkd->{host_runtime};
	    $hrt->set_state('stopping');
            $hkd->{stopping}++;
            undef $hkd->{killed};
            DEBUG "HKD stopping";
        };
    }
}

sub _startup {
    my $hkd = shift;
    my $retries = 10;
    while (1) {
	eval {
	    my $host = $hkd->{host} = this_host;
	    $hkd->{frontend} = $host->frontend;
	    $hkd->{backend}  = $host->backend;
	    my $hrt = $hkd->{host_runtime} = $host->runtime;
	    $hrt->set_state('starting');
	    $hkd->{id} = $hrt->id;
	    $hkd->_dirty_startup;
	    die "Bridge '$network_bridge' not found" 
		unless -e "/sys/devices/virtual/net/$network_bridge";
	    my $time = time;
	    $hrt->set_state('running', $time);
	    $hkd->{db_ok_ts} = $time;
	};
	return 1 unless $@;
	if (--$retries) {
	    ERROR "HKD initialization failed, retrying: $@";
	    sleep 3;
	}
	else {
	    ERROR "HKD initialization failed, aborting: $@";
	    return;
	}
    }
}

sub _dirty_startup {
    # just in case the last run of the HKD run on this host ended
    # abruptly, without closing some running VM and releasing it in
    # the database, we clean everything related to this host.
    my $hkd = shift;
    my $host_id = $hkd->{id};
    for my $vm (rs(VM_Runtime)->search({host_id => $host_id})) {
	INFO "Releasing VM " . $vm->id;
	txn_do {
	    $vm->discard_changes;
	    if ($vm->host_id == $host_id) {
		my $pid = $vm->vm_pid;
		if (defined $pid) {
		    # we are conservative here: if there are some process
		    # with the same pid as the one registered in the
		    # database for the given VM we just abort
		    kill 0, $pid and
			die "VM ".$vm->id." may still be running as process $pid\n";
		}
		$vm->set_vm_state('stopped');
		$vm->block;
		$vm->unassign;
	    }
	};
    }
}

sub _shutdown {
    my $hkd = shift;
    if ($hkd->{my_pid} == $$) {
	$hkd->_shutdown_l7r;
	$hkd->_shutdown_dhcp;
	$hkd->_dirty_shutdown;
        $hkd->{host_runtime}->set_state('stopped') unless $hkd->{aborting};
    }
}

sub _dirty_shutdown {
    my $hkd = shift;
    my $vm_pids = $hkd->{vm_pids};
    for my $sig (qw(TERM TERM KILL KILL KILL KILL KILL)) {
	last unless %$vm_pids;
	for my $id (keys %$vm_pids) {
	    $hkd->_signal_vm_by_id($id => $sig);
	}
	sleep 1;
	while (my ($id, $pid) = each %$vm_pids) {
	    waitpid($pid, WNOHANG) == $pid
		and delete $vm_pids->{$id};
	}
    }
}

sub _check_hkd_cluster {
    my $hkd = shift;
    my $time = time;
    my $next = ( $hkd->{next_cluster_check} //= $time + (0.5 + rand) * $cluster_check_interval );
    if ($time > $next) {
        undef $hkd->{next_cluster_check};
        for my $chrt (rs(Host_Runtime)->search({state => 'running'})) {
            next if $chrt->host_id == this_host_id;
            if ($chrt->ok_ts + $cluster_node_timeout < $time) {
                txn_eval {
                    for my $vm (rs(VM_Runtime)->search({ host_id => $chrt->host_id })) {
                        $vm->set_vm_state('stopped');
                        $vm->block;
                        $vm->unassing;
                    }
                    $chrt->set_state('blocked');
                };
            }
        }
    }
}

sub _check_vms {
    my $hkd = shift;

    $hkd->_check_db;

    my (@active_vms, @vmas);
    my $par = QVD::ParallelNet->new;

    for my $vm (rs(VM_Runtime)->search({host_id => this_host_id})) {
	my $id = $vm->id;
	my $start;
	if ($hkd->{stopping}) {
	    # on clean exit, shutdown virtual machines gracefully
	    if ($vm->vm_state eq 'running') {
		DEBUG "stopping VM because HKD is shutting down";
		$hkd->_move_vm_to_state(stopping_1 => $vm);
	    }
	    if ($vm->vm_cmd) {
		txn_eval {
		    $vm->discard_changes;
		    if ($vm->vm_cmd eq 'start' and $vm->vm_state eq 'stopped') {
			$vm->unassign;
		    }
		    DEBUG "VM command " . $vm->vm_cmd . " aborted because HKD is shutting down";
		    $vm->clear_vm_cmd;
		}
	    }
	}
	else {
	    # Command processing...
	    if (defined $vm->vm_cmd) {
		txn_eval {
		    $vm->discard_changes;
		    given($vm->vm_cmd) {
			when('start') {
			    given($vm->vm_state) {
				when ('stopped') {
				    $hkd->_assign_vm_ports($vm);
				    $hkd->_move_vm_to_state(starting => $vm);
				    $vm->clear_vm_cmd;
				    $start = 1;
				}
				default {
				    ERROR "unexpected VM command start received in state $_";
				    $vm->clear_vm_cmd;
				}
			    }
			}
			when('stop') {
			    given($vm->vm_state) {
				when ('running')  {
				    $hkd->_move_vm_to_state(stopping_1 => $vm);
				    $vm->clear_vm_cmd;
				}
				when ('starting') { } # stop is delayed!
				default {
				    ERROR "unexpected VM command stop received in state $_";
				    $vm->clear_vm_cmd;
				}
			    }
			}
			when(undef) {
			    DEBUG "command dissapeared";
			}
			default {
			    ERROR "unexpected VM command $_ received in state " . $vm->vm_state;
			    $vm->clear_vm_cmd;
			}
		    }
		};
		$@ and ERROR "vm_cmd processing failed: $@";
	    }
	}

	# no error checking is performed here, failed virtual
	# machines startings are captured later or on the next
	# run:
	if ($start) {
	    eval { $hkd->_start_vm($vm) };
	    $@ and ERROR "Unable to start VM: $@";
	}

	next if $vm->vm_state eq 'stopped';

	my $vm_pid = $hkd->{vm_pids}{$id};
	if (!defined($vm_pid) or waitpid($vm_pid, WNOHANG) == $vm_pid) {
	    DEBUG "kvm process $vm_pid reaped, \$?: $?";
	    delete $hkd->{vm_pids}{$id};
	    given ($vm->vm_state) {
		when ('stopping_1') {
		    WARN "vm process exited without passing through stopping_2"
		}
		when ('stopping_2') {}
		default {
		    ERROR "vm process has disappeared!, id: $id";
		    $vm->block;
		}
	    }
	    txn_eval { $hkd->_move_vm_to_state(stopped => $vm) };
	    $@ and ERROR "unable to move VM $id to state stopped";
	    next;
	}

	my $vma_method;
	given ($vm->vm_state) {
	    when('running') {
		no warnings 'uninitialized';
		if ($vm->user_cmd eq 'abort' and $vm->user_state eq 'connected') {
		    # HKD does this on behalf of the contending L7R to
		    # handle the case where the abort is sent using
		    # the administration tools.
		    #
		    # There is a race condition here: if the former
		    # connection closes and the new is stablished
		    # before the message is delivered the new one will
		    # be aborted. This is very unlikely and mostly
		    # harmless, so we didn't care!
		    $vma_method = 'x_suspend';
		}
		elsif (($hkd->{round} + $id) % $pool_all_mod == 0) {
		    # this pings a few VMs on every round
		    $vma_method = 'ping';
		}
	    }
	    when('starting'  ) { $vma_method = 'ping' }
	    when('stopping_1') { $vma_method = 'poweroff' }
	    when('zombie_1'  ) { $hkd->_signal_vm_by_id($id => SIGTERM) }
	    when('zombie_2'  ) { $hkd->_signal_vm_by_id($id => SIGKILL) }
	}

	if (defined $vma_method) {
	    my $vma = QVD::SimpleRPC::Client::Parallel->new($vm->vma_url);
	    $vma->queue_request($vma_method);
	    $par->register($vma);
	    push @vmas, $vma;
	    push @active_vms, $vm;
	}
	else {
	    $hkd->_vm_goes_zombie_on_timeout($vm);
	}
    }

    $hkd->_check_db;

    $par->run(time => $parallel_net_timeout) if @active_vms;

    while (@active_vms) {
	my $vm = shift @active_vms;
	my $vma = shift @vmas;
	my $id = $vm->id;
	eval { $vma->unqueue_response };
	if ($@) {
	    DEBUG "VMA call in VM $id failed: $@";
	    given ($vm->vm_state) {
		when('running') {
		    my $vma_ok_ts = $vm->vma_ok_ts;
		    DEBUG "vma_timeout $timeout{vma}, elapsed " . (time - $vma_ok_ts);
		    if (max($hkd->{start_time}, $vma_ok_ts) + $timeout{vma} < time) {
			# FIXME: check also that the number of consecutive
			# failed checks goes over some threshold
			ERROR "machine has not responded for a long time (" .
			    (time - $vma_ok_ts) . " seconds), going zombie!" .
				" id: $id, vma_ok_ts: $vma_ok_ts, time: " . time;
			txn_eval { $hkd->_move_vm_to_state(zombie_1 => $vm) };
			$@ and ERROR "unable to move VM to state zombie_1";
		    }
		}
		default {
		    $hkd->_vm_goes_zombie_on_timeout($vm);
		}
	    }
	}
	else {
	    $vm->update_vma_ok_ts;
	    my $new_state;
	    given ($vm->vm_state) {
		when ('starting')   { $new_state = 'running' }
		when ('stopping_1') { $new_state = 'stopping_2' }
	    }
	    if (defined $new_state) {
		txn_eval { $hkd->_move_vm_to_state($new_state => $vm) };
		$@ and ERROR "Unable to move VM $id to state $new_state: $@";
	    }
	}
    }
}

sub _vm_goes_zombie_on_timeout {
    my ($hkd, $vm) = @_;
    my $vm_state = $vm->vm_state;
    my $id = $vm->id;
    my $timeout = $timeout{$vm_state};
    if (defined $timeout) {
	my $vm_state_ts = $vm->vm_state_ts;
	DEBUG "timeout in state $vm_state is $timeout, elapsed "
	    . (time - $vm_state_ts);
	if (max($hkd->{start_time}, $vm_state_ts) + $timeout < time) {
	    ERROR "vm staled in state $vm_state,".
		" id: $id, state_ts: $vm_state_ts, time: ".time;
	    my $new_state = ($vm_state eq 'zombie_1' ? 'zombie_2' : 'zombie_1');
	    eval { $hkd->_move_vm_to_state($new_state => $vm) };
	    $@ and ERROR "Unable to move VM $id to state $new_state: $@";
	}
    }
}

# FIXME: implement a better port allocation strategy
my $port = 2000;
sub _allocate_port { $port++ }

sub _assign_vm_ports {
    my ($hkd, $vm) = @_;

    my @ports = ( vm_vma_port => $vm_port_vma,
		  vm_x_port   => $vm_port_x);

    push @ports, vm_vnc_port    => $hkd->_allocate_port if $vnc_redirect;
    push @ports, vm_serial_port => $hkd->_allocate_port if $serial_redirect;
    push @ports, vm_mon_port    => $hkd->_allocate_port if $mon_redirect;
    $vm->update({vm_address => $vm->rel_vm_id->ip, @ports });
}

# this method must always be called from inside a txn_eval block!!!
sub _move_vm_to_state {
    my ($hkd, $vm_state, $vm) = @_;
    my $old_vm_state = $vm->vm_state;
    my $id = $vm->id;
    DEBUG "move VM $id from state $old_vm_state to $vm_state";

    my $leave = $hkd->can("_leave_vm_state_$old_vm_state");
    # or DEBUG "method _leave_vm_state_$old_vm_state does not exist";
    my $enter = $hkd->can("_enter_vm_state_$vm_state");
    # or DEBUG "method _enter_vm_state_$vm_state does not exist";

    $leave->($hkd, $vm) if $leave;
    $enter->($hkd, $vm) if $enter;
    $vm->set_vm_state($vm_state);
}

sub _leave_vm_state_running {
    my ($hkd, $vm) = @_;
    $vm->clear_vma_ok_ts;
}

sub _enter_vm_state_stopping_1 {
    my ($hkd, $vm) = @_;
    $vm->send_user_abort if $vm->user_state eq 'connecting';
}

sub _enter_vm_state_stopped {
    my ($hkd, $vm) = @_;
    $vm->unassign;
}

sub _enter_vm_state_zombie_1 {
    my ($hkd, $vm) = @_;
    $vm->send_user_abort if $vm->user_state eq 'connecting';
}

sub _start_vm {
    my ($hkd, $vm) = @_;
    my $id = $vm->vm_id;
    my $vma_port = $vm->vm_vma_port;
    my $x_port = $vm->vm_x_port;
    my $vnc_port = $vm->vm_vnc_port;
    my $serial_port = $vm->vm_serial_port;
    my $mon_port = $vm->vm_mon_port;
    my $osi = $vm->rel_vm_id->osi;
    my $address = $vm->vm_address;
    my $name = rs(VM)->find($vm->vm_id)->name;

    INFO "starting VM $id";
    my $mac = $hkd->_ip_to_mac($address);

    my @cmd = ($cmd{kvm},
               -m => $osi->memory.'M',
	       -name => $name);

    my $nic = 'nic,macaddr='.$mac;
    $nic .= ',model=virtio' if $vm_virtio;
    push @cmd, (-net => $nic, -net => 'tap,fd=3');

    my $redirect_io = $serial_capture;
    if (defined $serial_port) {
        push @cmd, -serial => "telnet::$serial_port,server,nowait,nodelay";
        undef $redirect_io;
    }

    if ($redirect_io) {
        mkdir $captures_path, 0700;
        -d $captures_path or die "directory $captures_path does not exist\n";
        my @t = gmtime; $t[5] += 1900; $t[4] += 1;
        my $ts = sprintf("%04d-%02d-%02d-%02d:%02d:%2d-GMT0", @t[5,4,3,2,1,0]);
        push @cmd, -serial => "file:$captures_path/capture-$name-$ts.txt";
    }

    if ($vnc_port) {
        my $vnc_display = $vnc_port - 5900;
        $vnc_display .= ",$vnc_opts" if $vnc_opts =~ /\S/;
        push @cmd, -vnc => ":$vnc_display";
    }
    else {
        push @cmd, '-nographic';
    }

    if ($mon_port) {
	push @cmd, -monitor, "telnet::$mon_port,server,nowait,nodelay";
    }

    my $image = $hkd->_vm_image_path($vm) //
	die "no disk image for vm $id";

    my $hda = "file=$image,index=0,media=disk";
    $hda .= ',if=virtio,boot=on' if $vm_virtio;
    push @cmd, -drive => $hda;
    DEBUG "Using image $image ($hda) for VM $id ";

    if (defined $osi->user_storage_size) {
        my $user_storage = $hkd->_vm_user_storage_path($vm) //
            die "no user storage for vm $id";
	my $hdb = "file=$user_storage,index=$hdb_index,media=disk";
	$hdb .= ',if=virtio' if $vm_virtio;
	DEBUG "Using user storage $user_storage ($hdb) for VM $id";
        push @cmd, -drive => $hdb;
    }

    my $tap_fh = $hkd->_open_tap;

    DEBUG "running @cmd";
    my $pid = fork;
    unless ($pid) {
	$pid // die "unable to fork virtual machine process";
        eval {
	    setpgrp; # do not kill kvm when HKD runs on terminal and user CTRL-C's it
            open STDOUT, '>', '/dev/null' or die "can't redirect STDOUT to /dev/null\n";
            open STDERR, '>&', STDOUT or die "can't redirect STDERR to STDOUT\n";
            open STDIN, '<', '/dev/null' or die "can't open /dev/null\n";
	    $^F = 3;
	    POSIX::dup2(fileno $tap_fh, 3) or die "Can't dup tap file descriptor";
            exec @cmd or die "exec failed\n";
        };
	ERROR "Unable to start VM: $@";
	POSIX::_exit(1);
    }
    close $tap_fh;
    DEBUG "kvm pid: $pid\n";
    if (defined $pid) {
	$hkd->{vm_pids}{$id} = $pid;
	$vm->set_vm_pid($pid);
    }
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

    # TODO Do "ifconfig" and "brctl addif" in Perl
    system (ifconfig => ($tap_if, '0.0.0.0', 'up')) and die "ifconfig $tap_if failed: $!";
    system (brctl => ('addif', $network_bridge, $tap_if)) and die "brctl addif br0 $tap_if failed: $!";
    return $tap_fh;
}

sub _ip_to_mac {
    my ($hkd, $ip) = @_;
    my @hexip = map {sprintf '%02x', $_} (split /\./, $ip);
    my $mac = '54:52:00:'.join(':', @hexip[1,2,3]);
    $mac
}

sub _vm_image_path {
    my ($hkd, $vm) = @_;
    my $id = $vm->id;
    my $osi = $vm->rel_vm_id->osi;
    my $osiid = $osi->id;
    my $image = "$images_path/".$osi->disk_image;

    unless (-f $image) {
	ERROR "Image $image attached to VM $id does not exist on disk";
	return undef;
    }
    return $image unless $osi->use_overlay;

    # FIXME: use a better policy for overlay allocation
    my $overlay = "$overlays_path/$osiid-$id-overlay.qcow2";
    if (-f $overlay) {
        return $overlay if ($persistent_overlay);
        # FIXME: save old overlay for later inspection
        unlink $overlay;
    }

    mkdir $overlays_path, 0755;
    unless (-d $overlays_path) {
	ERROR "Overlays directory $overlays_path does not exist";
	return undef;
    }

    # FIXME: use a relative path to the base image?
    #my $image_relative = File::Spec->abs2rel($image, $overlays_path);
    my @cmd = ($cmd{kvm_img}, 'create',
               -f => 'qcow2',
               -b => $image,
               $overlay);

    DEBUG "Running @cmd";
    system(@cmd) == 0 and -f $overlay and return $overlay;
    ERROR "Unable to create overlay image $overlay for VM $id ($?)";
    return undef;
}

sub _vm_user_storage_path {
    my ($hkd, $vm) = @_;
    my $id = $vm->id;
    my $osi = $vm->rel_vm_id->osi;
    my $size = $osi->user_storage_size // return undef;

    my $image = "$homes_path/$id-data.qcow2";
    return $image if -f $image;

    mkdir $homes_path, 0755;
    unless (-d $homes_path) {
	ERROR "Homes directory $homes_path does not exist";
	return undef;
    }

    my @cmd = ($cmd{kvm_img}, 'create',
               -f => 'qcow2',
               $image, "${size}M");
    system(@cmd) == 0 and -f $image and return $image;

    ERROR "Unable to create user storage $image for VM $id";
    return undef;
}

sub _signal_vm_by_id {
    my ($hkd, $id, $signal) = @_;
    my $pid = $hkd->{vm_pids}{$id};
    unless ($pid) {
	DEBUG "later detection of failed VM execution";
	return;
    }
    DEBUG "kill VM process $pid with signal $signal" if $signal;
    kill($signal, $pid);
}

sub _check_dhcp {
    my $hkd = shift;
    if ($hkd->{backend}) {
	my $dhcp_pid = $hkd->{dhcp_pid};
	if (!defined $dhcp_pid or waitpid($dhcp_pid, WNOHANG) == $dhcp_pid) {
	    delete $hkd->{dhcp_pid};
	    unless ($hkd->{stopping}) {
		eval { 
		    $hkd->_regenerate_dhcp_configuration;
		    $hkd->_start_dhcp;
		};
		ERROR $@ if $@;
	    }
	}
	# FIXME when new vms are added we need to regenerate the config and
	# send HUP to dnsmasq
    }
}

sub _start_dhcp {
    my $hkd = shift;
    my ($f, $l) = split /,/, $dhcp_range;
    my @cmd = (dnsmasq => (-p => 0, '-k', 
	    -F => "$f,static", 
	    '--dhcp-hostsfile' => $dhcp_hostsfile));
    my $pid = fork;
    if (!$pid) {
	defined $pid or die "Unable to fork DHCP server: $!";
	eval {
	    DEBUG "DHCP server forked";
	    exec @cmd or die "exec @cmd failed\n";
	};
	ERROR "Unable to start DHCP server: $@";
	POSIX::_exit(1);
    }
    $hkd->{dhcp_pid} = $pid;
}

sub _regenerate_dhcp_configuration {
    my ($hkd) = @_;
    eval {
        open my $fh, '>', $dhcp_hostsfile or die $!;
	foreach my $vm (rs(VM)->all) {
	    my $ip = $vm->ip;
	    my $mac = $hkd->_ip_to_mac($ip);
	    print $fh "$mac,$ip\n";
	}
        close $fh or die $!;
    };
    die "Can't update dhcp configuration: $@" if $@;
}

sub _shutdown_dhcp {
    my $hkd = shift;
    if ($hkd->{backend}) {
	for my $sig (qw(TERM KILL)) {
	    my $dhcp_pid = $hkd->{dhcp_pid};
	    kill $sig, $dhcp_pid;
	    sleep 1;
	    if (waitpid($dhcp_pid, WNOHANG) == $dhcp_pid) {
		delete $hkd->{dhcp_pid};
		last;
	    }
	}
    }
}

sub _check_l7rs {
    my $hkd = shift;
    if ($hkd->{frontend}) {
        $hkd->_check_db;
	# check for dissapearing L7Rs processes
	for my $vm (rs(VM_Runtime)->search({l7r_host => this_host_id})) {
	    my $l7r_worker_pid = $vm->l7r_pid;
	    unless (defined $l7r_worker_pid and kill 0, $l7r_worker_pid) {
		WARN "clean dead L7R process for VM " . $vm->id;
		$vm->clear_l7r_all;
	    }
	}
	# check for the main L7R process
	my $l7r_pid = $hkd->{l7r_pid};
	if (!defined $l7r_pid or waitpid($l7r_pid, WNOHANG) == $l7r_pid) {
	    delete $hkd->{l7r_pid};
	    unless ($hkd->{stopping}) {
		eval { $hkd->_start_l7r };
		ERROR $@ if $@;
	    }
	}
    }
}

sub _shutdown_l7r {
    my $hkd = shift;
    if ($hkd->{frontend}) {
	for my $sig (qw(INT INT INT INT KILL KILL KILL)) {
	    my $l7r_pid = $hkd->{l7r_pid} // last;
	    kill $sig => $l7r_pid;
	    sleep 1;
	    if (waitpid($l7r_pid, WNOHANG) == $l7r_pid) {
		delete $hkd->{l7r_pid};
		last;
	    }
	}
    }
}

sub _start_l7r {
    my $hkd = shift;
    my @args = ( host => cfg('l7r.address'),
		 port => cfg('l7r.port') );
    my $ssl = cfg('l7r.use_ssl');
    if ($ssl) {
	my $l7r_certs_path  = cfg('path.ssl.certs');
	my $l7r_ssl_key     = cfg('l7r.ssl.key');
	my $l7r_ssl_cert    = cfg('l7r.ssl.cert');
	my $l7r_ssl_cert_fn = "$l7r_certs_path/l7r-cert.pem";
	my $l7r_ssl_key_fn  = "$l7r_certs_path/l7r-key.pem";
	# copy the SSL certificate and key from the database to local
	# files
	mkdir $l7r_certs_path, 0700;
	-d $l7r_certs_path or die "unable to create directory $l7r_certs_path\n";
	my ($mode, $uid) = (stat $l7r_certs_path)[2, 4];
	$uid == $> or $uid == 0 or die "bad owner for directory $l7r_certs_path\n";
	$mode & 0077 and die "bad permissions for directory $l7r_certs_path\n";
	_write_to_file($l7r_ssl_cert_fn, $l7r_ssl_cert);
	_write_to_file($l7r_ssl_key_fn,  $l7r_ssl_key);
	push @args, ( SSL           => 1,
		      SSL_key_file  => $l7r_ssl_key_fn,
		      SSL_cert_file => $l7r_ssl_cert_fn );
    }
    my $pid = fork;
    if (!$pid) {
	defined $pid or die "Unable to fork L7R: $!\n";
	eval {
	    db_release; # having two processes using the same DB handler
	                # is definitively not a good idea!
	    DEBUG "L7R process forked, SSL: $ssl";
	    setpgrp;
	    my $l7r = QVD::L7R->new(@args);
	    $l7r->run;
	};
	ERROR $@ if $@;
	exit (0);
    }
    $hkd->{l7r_pid} = $pid;
}

sub _write_to_file {
    my ($fn, $data) = @_;
    my $fh;
    DEBUG "writting data to $fn";
    unless ( open $fh, '>', $fn  and
	     binmode $fh         and
	     print $fh $data     and
	     close $fh ) {
	die "Unable to write $fn";
    }
}

1;

__END__

=head1 NAME

QVD::HKD - The QVD house keeping daemon

=head1 SYNOPSIS

The HKD is the daemon that keeps QVD up and running

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
