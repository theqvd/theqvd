package QVD::Config;

use Config::Properties;

our $defaults = Config::Properties->new;
$defaults->load(*DATA);

1;

__DATA__

## name of this machine
# nodename =

## database connection details
database.host = localhost
database.user = qvd
database.name = qvd
# database.password =

## directory where several configuration, state, pid and certificate files are stored
path.run = /var/run/qvd
## where QVD logs are stored
path.log = /var/log
## temporary files
path.tmp = /var/tmp
## main storage location for OS images (both KVM and LXC)
path.storage.root = /var/lib/qvd/storage
## OS images ready to be used
path.storage.staging = ${path.storage.root}/staging
## OS images in use by some VM
path.storage.images = ${path.storage.root}/images

# storage directories for KVM
path.storage.overlays = ${path.storage.root}/overlays
path.storage.homes = ${path.storage.root}/homes
path.storage.check = ${path.storage.homes}/.rw_check

# storage directories for LXC
path.storage.basefs = ${path.storage.root}/basefs
path.storage.overlayfs = ${path.storage.root}/overlayfs
path.storage.rootfs = ${path.storage.root}/rootfs
path.storage.homefs = ${path.storage.root}/homefs

## paths for SSL certificates and CAs
path.ssl.certs = ${path.run}/ssl
path.ssl.ca.system = /etc/ssl/certs
path.ssl.ca.personal = .qvd/certs
## KVM serial port captures or LXC console output
path.serial.captures = ${path.tmp}/qvd

path.cgroup = /cgroup

## paths to external executables
command.kvm = kvm
command.kvm-img = kvm-img
command.nxagent = /usr/bin/nxagent
command.nxdiag = /usr/bin/nxdiag.pl
command.x-session = /etc/X11/Xsession
command.brctl = /sbin/brctl
command.ifconfig = /sbin/ifconfig
command.dhcpd = /usr/sbin/dnsmasq
command.useradd = /usr/sbin/useradd
command.userdel = /usr/sbin/userdel
command.groupadd = /usr/sbin/groupadd
command.groupdel = /usr/sbin/groupdel
command.tar = tar
command.umount = umount
command.mount = mount
command.unionfs-fuse = /usr/bin/unionfs-fuse
command.lxc-destroy = lxc-destroy
command.lxc-create = lxc-create
command.lxc-start = lxc-start
command.lxc-stop = lxc-stop
command.lxc-wait = lxc-wait
command.ebtables = ebtables

## nxproxy's link parameter, can be: modem, isdn, adsl, wan, lan, local or a bandwidth specification (56k, 1m, 100m...)
client.link = adsl
## nxproxy's geometry parameter
client.geometry = 1024x768
## nxproxy's fullscreen parameter
client.fullscreen =
## enable the Pulse audio server in the client
client.audio.enable =
## something regarding an NX channel
client.printing.enable =
## L7R port the client should connect to
client.host.port = 8443
## L7R host the client should connect to
client.host.name =
## user name for client authentication
client.user.name =
## whether to use SSL in the client↔server communication or not
client.use_ssl = 1

## whether L7R accepts SSL incoming connections or not
l7r.use_ssl = 1
## port the L7R should listen to
l7r.port = 8443
## IP addresses L7R should bind to/listen at
l7r.address = *
## actually usused in the code
# l7r.as_user = root
## unused!
l7r.pid_file = ${path.run}/l7r.pid
## authentication plugins to use. Comma-separated list of alphanumeric words. Example: "ldap, foo_43,default"
l7r.auth.plugins = default
## load balancing plugins to use. Similar to auth plugins
l7r.loadbalancer.plugin = default
## each plugin should document its own parameters
l7r.loadbalancer.plugin.default.weight.ram = 1
l7r.loadbalancer.plugin.default.weight.cpu = 1
l7r.loadbalancer.plugin.default.weight.random = 1

## user to run hkd as
hkd.as_user = root
## path to the hkd PID file
hkd.pid_file = ${path.run}/qvd-hkd.pid

## user to run l7r as
l7r.as_user = root
## path to the l7r PID file
l7r.pid_file = ${path.run}/qvd-l7r.pid


## username of the WAT administrator
wat.admin.login = admin
# wat.admin.password =

## path to the log file
log.filename = ${path.log}/qvd.log
## log verbosity (FATAL, ERROR, WARN, INFO, DEBUG or TRACE)
log.level = INFO

## these two seem to be unused
admin.ssh.opt.StrictHostKeyChecking = no
admin.ssh.opt.UserKnownHostsFile = /dev/null

## virtualization engine to use, either kvm or lxc
vm.hypervisor = kvm

## COW fs to use with LXC
vm.lxc.unionfs.type = aufs

## whether to keep overlay images from one session to the next
vm.overlay.persistent = 0
## use KVM's virtio capabilities
vm.kvm.virtio = 1

## these two specify the VNC availability and options for KVM's VNC support
vm.vnc.redirect = 0
vm.vnc.opts =
## whether to use KVM's serial support or not
vm.serial.redirect = 1
## capture serial port traffic to a file
## - in KVM it is ignored if serial port is redirected (ie if vm.serial.redirect is set to 1)
## - in LXC it saves the capture under the directory specified in path.serial.captures
vm.serial.capture = 0

## all VMs will be attached to this interface, which must be a bridge
## the DHCP server uses this setting too
vm.network.bridge = qvdnet

## for LXC's lxc.network.veth.pair parameter
internal.vm.network.device.prefix = qvd
## start of DHCP range. There's no sensible default value
# vm.network.ip.start=10.0.0.100

## file to pass to dnsmasq at its --dhcp-hostsfile parameter
internal.vm.network.dhcp-hostsfile=${path.run}/dhcp-hostsfile

# enable firewall rules
internal.vm.network.firewall.enable = 1

## not sure about this one
internal.vm.debug.enable = 0


## default values for newly created OSFs
osf.default.memory = 256
osf.default.overlay = 1

## so that the VMA exports PULSE_SERVER before xinit invocation and passes the 'media=1' parameter to nxagent
vma.audio.enable = 0
## enables the printing channel in nxagent
vma.printing.enable = 0
## path to the VMA PID file
vma.pid_file = /var/run/qvd/vma.pid

## KVM: disk drive will be visible as: 0=hda, 1=hdb, 2=hdc... (parameter 'index' within -drive in KVM)
vm.kvm.home.drive.index = 1
## optional: device that contains the homes, as seen from within the VM
vma.user.home.drive = /dev/vdb
## when autoprovisioning homes, filesystem type to create in the device
vma.user.home.fs = ext4
## where to mount the homes device
vma.user.home.path = /home
## default user name and groups it will belong to
vma.user.default.name = qvd
vma.user.default.groups =

vma.user.umask = 0022

## external executables the VMA calls when some events happen
vma.on_action.pre-connect =
vma.on_action.connect =
vma.on_action.stop =
vma.on_action.disconnect =
vma.on_action.suspend =
vma.on_action.poweroff =

## external executables the VMA calls just before some states are entered
vma.on_state.connected =
vma.on_state.suspended =
vma.on_state.disconnected =

## external executables the VMA calls during user provisioning
vma.on_provisioning.mount_home =
vma.on_provisioning.add_user =
vma.on_provisioning.after_add_user =

## both unused
vma.default.client.keyboard = pc105/en
vma.default.client.link = adsl

## unused
hkd.vm.starting.max = 6

# internal parameters, do not change!!!
internal.l7r.timeout.vm_start = 270
internal.l7r.timeout.x_start = 10
internal.l7r.timeout.vma = 4
internal.l7r.timeout.takeover = 30
internal.l7r.retry.x_start = 5
internal.l7r.poll_time.vm = 3
internal.l7r.poll_time.x = 1
internal.l7r.short_session = 120

internal.hkd.timeout.vm.state.starting_2 = 240
internal.hkd.timeout.vm.state.stopping_1 = 30
internal.hkd.timeout.vm.state.stopping_2 = 240
internal.hkd.timeout.vm.state.zombie_1 = 30
internal.hkd.timeout.vm.state.running = 120
internal.hkd.timeout.vm.vma = 4
internal.hkd.poll_time = 2
internal.hkd.poll_all_mod = 10

internal.hkd.database.retry_delay = 5
internal.hkd.database.timeout = 20
internal.hkd.cluster.check.interval = 30
internal.hkd.cluster.node.timeout = 80

internal.vm.port.x = 5000
internal.vm.port.vma = 3030
internal.vm.port.ssh = 22

internal.vm.monitor.redirect = 0
internal.vm.reserved_cpu = 1000

internal.nxagent.display = 100

internal.nxagent.timeout.initiating = 20
internal.nxagent.timeout.listening = 10
internal.nxagent.timeout.suspending = 20
internal.nxagent.timeout.stopping = 20

internal.vma.on_printing.connected = /usr/bin/qvd-printing
internal.vma.on_printing.suspended = /usr/bin/qvd-printing
internal.vma.on_printing.stopped = /usr/bin/qvd-printing

internal.vma.printing.config = ${path.run}/printing.conf
internal.vma.nxagent.config = ${path.run}/nxagent.conf

internal.database.client.connect.timeout = 20
internal.database.client.socket.keepidle = 20
internal.database.client.socket.keepintvl = 5
internal.database.client.socket.keepcnt = 4

internal.hkd.killing.vms.timeout = 120

internal.hkd.agent.ticker.delay = 60
internal.hkd.agent.command_handler.delay = 10
internal.hkd.agent.vm_command_handler.delay = 11

internal.hkd.agent.cluster_monitor.delay = 60

internal.hkd.agent.rpc.retry.count = 3
internal.hkd.agent.rpc.retry.delay = 5
internal.hkd.agent.rpc.timeout = 3

internal.hkd.vmhandler.killer.delay = 10
internal.hkd.vmhandler.timeout.on_state.stopping = 200
internal.hkd.vmhandler.timeout.on_state.zombie = 200

internal.hkd.vmhandler.vma.failed.max_count.on.starting = 20
internal.hkd.vmhandler.vma.failed.max_count.on.running = 10

internal.hkd.vmhandler.vma.failed.max_time.on.starting = 180
internal.hkd.vmhandler.vma.failed.max_time.on.running = 60
internal.hkd.vmhandler.vma_monitor.delay = 10
internal.hkd.lxc.does.not.cleanup = 0
internal.hkd.lxc.killer.retries = 10
internal.hkd.lxc.killer.destroy_lxc.timeout = 100
internal.hkd.lxc.killer.umount.timeout = 100

internal.hkd.debugger.run = 0
internal.hkd.debugger.socket = /root/hkd-debug

