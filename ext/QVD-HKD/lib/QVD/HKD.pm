package QVD::HKD;

use warnings;
use strict;

use feature 'switch';
use QVD::Config;
use QVD::Log;
use QVD::DB::Simple;
use QVD::ParallelNet;
use QVD::SimpleRPC::Client;
use QVD::SimpleRPC::Client::Parallel;

use Proc::ProcessTable;
use Sys::Hostname;
use POSIX qw(:sys_wait_h);
use List::Util qw(max);
use POSIX;
use JSON;

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
my $vm_netmask		   = cfg('vm.network.netmask');
my $dhcp_range	  	   = cfg('vm.network.dhcp-range');
my $dhcp_default_route	   = cfg('vm.network.gateway');
my $dhcp_hostsfile	   = cfg('internal.vm.network.dhcp-hostsfile');

my $persistent_overlay     = cfg('vm.overlay.persistent');

my $cluster_check_interval = cfg('internal.hkd.cluster.check.interval');
my $cluster_node_timeout   = cfg('internal.hkd.cluster.node.timeout');

my $database_delay         = core_cfg('internal.hkd.database.retry_delay');


sub new {
    my ($class, $socket) = @_;
    my $self = { killed       => undef,
		 stopping     => undef,
                 aborting     => undef,
		 start_time   => undef,
		 host         => undef,
		 host_runtime => undef,
		 backend      => undef,
		 db_ok_ts     => undef,
		 noded_socket => $socket,
		 round        => 0 };
    bless $self, $class;
}

sub run {
    my ($hkd, %args) = @_;

    $hkd->{stopping} = $args{stopping};

    $SIG{HUP} = sub { $hkd->{signal} = 1 }; # perform an orderly
                                            # shutdown on HUP
    $hkd->_startup($args{vm_pids});
    my $hrt = $hkd->{host_runtime};

    DEBUG "hkd up and running";

    while (1) {
	DEBUG "HKD run, round: $hkd->{round}";
	if ($hkd->_check_db) {
	    $hkd->{round}++;
	    $hkd->{start_time} //= $hkd->{db_ok_ts};

	    if (delete $hkd->{signal}) {
		if ($hkd->{stopping}) {
		    DEBUG "HKD is already stopping";
		}
		else {
		    eval {
			$hrt->set_state('stopping');
			$hkd->{stopping} = 1;
			INFO "HKD stopping";
		    };
		}
	    }
	    if ($hkd->{stopping}) {
                if (eval { rs(VM_Runtime)->search({host_id => this_host_id})->count == 0 }) {
		    $hrt->set_state('stopped');
		    INFO "HKD stopped";
		    return;
		}
		DEBUG($@ || "Can't exit yet: there are VMs running");
	    }
	    eval {
		$hkd->_check_vms;
		$hkd->_check_l7rs;
                $hkd->_check_hkd_cluster;
	    };
	    sleep $pool_time;
	}
        else {
            INFO "HKD can not connect to database, retrying: $@";
            sleep $database_delay;
            undef $hkd->{start_time};
        }
    }
}

sub _set_noded_timeouts {
    my ($hkd, $time) = @_;
    $time //= time;
    $hkd->_call_noded(set_timeouts => $time);
}

sub _check_db {
    my $hkd = shift;
    my $ok;
    my $time = time;
    eval {
	alarm 5;
	eval {
	    $hkd->{host_runtime}->update_ok_ts($time);
	    $ok = 1;
	};
	alarm 0;
    };
    $ok or return;
    $hkd->{db_ok_ts} = $time;
    $hkd->_set_noded_timeouts($time);
    return 1;
}

sub _startup {
    my ($hkd, $vm_pids) = @_;
    my $host = $hkd->{host} = this_host;
    $hkd->{frontend} = $host->frontend;
    $hkd->{backend}  = $host->backend;
    my $hrt = $hkd->{host_runtime} = $host->runtime;
    $hrt->set_state('starting');
    $hkd->{id} = $hrt->id;
    $hkd->_check_bridge;
    $hkd->_regenerate_dhcpd_config;
    $hkd->_start_dhcpd;
    $hkd->_reattach_vms($vm_pids);
    my $time = time;
    $hrt->set_state('running', $time);
    $hkd->_set_noded_timeouts($time);
}

sub _check_bridge {
    my $hkd = shift;
    -e "/sys/devices/virtual/net/$network_bridge"
	or die "$network_bridge not found\n";
}

sub _reattach_vms {
    # just in case the last run of the HKD run on this host ended
    # abruptly, without closing some running VM and releasing it in
    # the database, we clean everything related to this host but the
    # VMs we get in vm_pids that are still being managed by Noded
    my ($hkd, $vm_pids) = @_;
    my $host_id = $hkd->{id};
    for my $vm (rs(VM_Runtime)->search({host_id => $host_id})) {
	my $vm_id = $vm->id;
	my $pid_db = $vm->vm_pid;
	my $pid_noded = $vm_pids->{$vm_id};
	INFO "Releasing/reacquiring VM $vm_id (pid: " . ($pid_db // 'undef') . ")";
	if ($pid_db and $pid_noded and $pid_db == $pid_noded) {
	    # Noded is still managing it
	    delete $vm_pids->{$vm->id};
	}
	else {
	    txn_do {
		$vm->discard_changes;
		if ($vm->host_id == $host_id) {
		    $pid_db = $vm->vm_pid;
		    if ($pid_db) {
			# we are conservative here: if there are some
			# kvm process with the same pid as the one
			# registered in the database for the given VM
			# we just abort

			if (kill 0, $pid_db) {
			    my $quoted_cmd = quotemeta $cmd{kvm};
			    my $pt = Proc::ProcessTable->new;
			    for my $process (@{$pt->table}) {
				$process->pid == $pid_db and
				    $process->cmndline =~ /^$quoted_cmd\s/ and
					die "VM $vm_id may still be running as process $pid_db\n";
			    }
			    $hkd->_clean_vm_fw_rules($vm);
			}
		    }
		    $vm->set_vm_state('stopped');
		    $vm->block;
		    $vm->unassign;
		}
	    };
	}
    }

    # there may remain some VM managed by Noded but that are not
    # registered in the database, for instance if a previous HKD was
    # killed in the middle of a VM start operation. We just kill them.
    for my $sig (qw(TERM TERM KILL KILL KILL KILL KILL)) {
	last unless %$vm_pids;
	for my $vm_id (keys %$vm_pids) {
	    $hkd->_call_noded(kill_vm_process => $vm_id, $sig);
	}
	sleep 1;
	for my $vm_id (keys %$vm_pids) {
	    unless ($hkd->_call_noded(check_vm_process => $vm_id)) {
		delete $vm_pids->{$vm_id};
	    }
	}
    }
    if (%$vm_pids) {
	ERROR "Unable to kill VMs " .
	    join(", ", map "$_($vm_pids->{$_})", keys %$vm_pids);
	die "unable to kill VMs managed by Noded but not in the database\n";
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
                    $chrt->block;
                };
            }
        }
    }
}

sub _check_vms {
    my $hkd = shift;

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

	unless ($hkd->_call_noded(check_vm_process => $id)) {
	    DEBUG "kvm process for vm $id reaped";
	    delete $hkd->{vm_pids}{$id};
	    $hkd->_clean_vm_fw_rules($vm);
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
	    when('zombie_1'  ) { $hkd->_signal_vm($id => 'TERM') }
	    when('zombie_2'  ) { $hkd->_signal_vm($id => 'KILL') }
	}

	if (defined $vma_method) {
	    DEBUG "VMA URL: " . $vm->vma_url;
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

    eval {
	$par->run(time => $parallel_net_timeout) if @active_vms;
    };
    $@ and ERROR "Parallel HTTP query failed unexpectedly: $@";

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

sub _allocate_tcp_port { shift->_call_noded('allocate_tcp_port') }

sub _assign_vm_ports {
    my ($hkd, $vm) = @_;
    # FIXME: remove this ports from the database as they are fixed now:
    my @ports = ( vm_vma_port => $vm_port_vma,
		  vm_ssh_port => 22,
		  vm_x_port   => $vm_port_x);

    push @ports, vm_vnc_port    => $hkd->_allocate_tcp_port if $vnc_redirect;
    push @ports, vm_serial_port => $hkd->_allocate_tcp_port if $serial_redirect;
    push @ports, vm_mon_port    => $hkd->_allocate_tcp_port if $mon_redirect;
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

sub _signal_vm { shift->_call_noded(kill_vm_process => @_) }

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

    $hkd->_regenerate_dhcpd_config;
    $hkd->_call_noded('reload_dhcpd');

    INFO "starting VM $id";
    my $mac = $hkd->_ip_to_mac($address);

    my @cmd = ($cmd{kvm},
               -m => $osi->memory.'M',
	       -name => $name);

    my $nic = "nic,macaddr=$mac";
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

    my ($pid, $tap_if) = $hkd->_call_noded(fork_vm => $id, @cmd);
    $vm->set_vm_pid($pid);

    # TODO: Do "ifconfig" and "brctl addif" in Perl
    system (ifconfig => $tap_if, 'up') and die "ifconfig $tap_if for VM $id failed\n";
    $hkd->_set_vm_fw_rules($vm, $tap_if);
    system (brctl => 'addif', $network_bridge, $tap_if) and die "brctl addif $network_bridge $tap_if for VM $id failed\n";
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

sub _start_dhcpd {
    my $hkd = shift;
    my ($f, $l) = split /,/, $dhcp_range;
    $hkd->_call_noded(start_dhcpd => 'dnsmasq',
		                     '-k',
		                     '--dhcp-range'     => "$f,static",
		                     '--dhcp-option'    => "option:router,$dhcp_default_route",
		                     '--dhcp-hostsfile' => $dhcp_hostsfile);
}

sub _regenerate_dhcpd_config {
    my ($hkd) = @_;
    eval {
	open my $fh, '>', "$dhcp_hostsfile.tmp"
	    or die "open $dhcp_hostsfile.tmp failed: $!";
	foreach my $vm (rs(VM)->all) {
	    my $ip = $vm->ip;
	    my $mac = $hkd->_ip_to_mac($ip);
	    print $fh "$mac,$ip\n";
	}
	close $fh
	    or die "close failed: $!";
	rename "$dhcp_hostsfile.tmp", $dhcp_hostsfile
	    or die "rename failed: $!";
    };
    $@ and die "unable to regenerate DHCP configuration: $@";
}

sub _check_l7rs {
    my $hkd = shift;
    if ($hkd->{frontend}) {
	# check for dissapearing L7Rs processes
	for my $vm (rs(VM_Runtime)->search({l7r_host => this_host_id})) {
	    my $l7r_worker_pid = $vm->l7r_pid;
	    unless (defined $l7r_worker_pid and kill 0, $l7r_worker_pid) {
		WARN "clean dead L7R process for VM " . $vm->id;
		$vm->clear_l7r_all;
	    }
	}
    }
}

sub _call_noded {
    my $self = shift;
    my $noded_socket = $self->{noded_socket};
    my $msg = to_json(\@_);
    send($noded_socket, $msg, 0)
	or die "unable to send message to noded: $!\n";
    if (defined recv($noded_socket, my $buf, 4096, 0)) {
	my ($ok, @response) = eval { @{from_json($buf)} };
	given ($ok) {
	    when ('ok')    { return (wantarray ? @response : $response[0]) }
	    when (undef)   { die "rpc failed: $@" }
	    when ('error') { die $response[0] }
	    default        { die "bad response from noded: $ok" }
	}
    }
    die "rpc failed: $!\n";
}

sub _clean_vm_fw_rules {
    my ($hkd, $vm) = @_;
    my $vm_id = $vm->id;
    for (qw(INPUT OUTPUT FORWARD)) {
	my @rules = `iptables -S $_`;
	for (@rules) {
	    chomp;
	    system "iptables -D $1"
		if /^\s*-A\s+(.*--comment\s+"QVD rule for VM $vm_id".*)$/
	    }
    }
}

sub _set_vm_fw_rules {
    my ($hkd, $vm, $tap_if) = @_;
    my $vm_id = $vm->id;
    for my $rule ($hkd->_vm_fw_rules($vm, $tap_if)) {
	my @cmd = (iptables => -A => @$rule, -m => 'comment', '--comment' => "QVD rule for VM $vm_id");
	DEBUG "iptables cmd: @cmd";
	# system @cmd
	#    and ERROR "Can't configure firewall: $!";
    }
}

sub _vm_fw_rules {
    my ($hkd, $vm) = @_;
    my $tap_if = $hkd->{vm_taps}{$vm->id};
    my $vm_ip = $vm->rel_vm_id->ip;
    my $x_port = $vm->vm_x_port;
    my $ssh_port = $vm->vm_ssh_port;
    my $vma_port = $vm->vm_vma_port;

    my @rules = (
	# Drop traffic from VM if it doesn't have the correct IP or MAC
	[FORWARD => ( 
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    -m => 'mac', '!', '--mac-source' => $hkd->_ip_to_mac($vm_ip),
	    -j => 'DROP')],
	[FORWARD => ( 
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    '!', -s => $vm_ip,
	    -j => 'DROP')],

	[INPUT => (
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    -m => 'mac', '!', '--mac-source' => $hkd->_ip_to_mac($vm_ip),
	    -j => 'DROP')],
	[INPUT => ( # allow DHCP packets from any IP,
		    # FIXME: could it be limited to 0.0.0.0?
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    -p => 'udp', '--dport' => '67',
	    -j => 'ACCEPT')],
	[INPUT => (
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    '!', -s => $vm_ip,
	    -j => 'DROP')],

	#
	# TCP
	#

	# Drop TCP SYN from VM
	[FORWARD => (
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    -d => "$vm_ip/$vm_netmask",
	    -p => 'tcp', '--syn',
	    -j => 'DROP')],
	[INPUT => (
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    -d => "$vm_ip/$vm_netmask",
	    -p => 'tcp', '--syn',
	    -j => 'DROP')],

	# Accept SSH/VMA/NX to VM, drop all other TCP from LAN to VM
	[FORWARD => (
	    -m => 'physdev', '--physdev-out' => $tap_if,
	    -s => "$vm_ip/$vm_netmask", -d => $vm_ip,
	    -p => 'tcp', -m => 'multiport', '--dports' => "$ssh_port,$vma_port,$x_port",
	    -j => 'ACCEPT')],
	[OUTPUT => (
	    -s => "$vm_ip/$vm_netmask", -d => $vm_ip,
	    -p => 'tcp', -m => 'multiport', '--dports' => "$ssh_port,$vma_port,$x_port",
	    -j => 'ACCEPT')],
	[FORWARD => (
	    -s => "$vm_ip/$vm_netmask", -d => $vm_ip, # -s to allow internet
	    -p => 'tcp',
	    -j => 'DROP')],
	[OUTPUT => (
	    -d => $vm_ip,
	    -p => 'tcp',
	    -j => 'DROP')],

	#
	# UDP
	#

	# Accept DNS requests from VM to node, drop all other UDP from VM
	[INPUT => (
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    -p => 'udp', '!', '--dport' => '53',
	    -j => 'DROP')],
	[FORWARD => (
	    -m => 'physdev', '--physdev-in' => $tap_if,
	    -p => 'udp',
	    -j => 'DROP')],
    );
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
