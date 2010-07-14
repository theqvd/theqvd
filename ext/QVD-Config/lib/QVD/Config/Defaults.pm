package QVD::Config;

use Config::Properties;

our $defaults = Config::Properties->new;
$defaults->load(*DATA);

1;

__DATA__

# nodename =

database.host = localhost
database.user = qvd
database.name = qvd
# database.password =

path.run = /var/run/qvd
path.log = /var/log
path.tmp = /var/tmp
path.storage.root = /var/lib/qvd/storage
path.storage.staging = ${path.storage.root}/staging
path.storage.images = ${path.storage.root}/images
path.storage.overlays = ${path.storage.root}/overlays
path.storage.homes = ${path.storage.root}/homes
path.ssl.certs = ${path.run}/ssl
path.ssl.ca.system = /etc/ssl/certs
path.ssl.ca.personal = .qvd/certs
path.serial.captures = ${path.tmp}/qvd

command.kvm = kvm
command.kvm-img = kvm-img
command.nxagent = /usr/bin/nxagent
command.nxdiag = /usr/bin/nxdiag.pl
command.x-session = /etc/X11/Xsession

command.useradd = /usr/sbin/useradd
command.userdel = /usr/sbin/userdel

client.link = adsl
client.geometry = 1024x768
client.fullscreen =
client.audio.enable =
client.printing.enable =
client.host.port = 8443
client.host.name =
client.user.name =
client.use_ssl = 1

l7r.use_ssl = 1
l7r.port = 8443
l7r.address = *
l7r.as_user = qvd
l7r.pid_file = ${path.run}/l7r.pid
l7r.auth.plugins = default

hkd.as_user = qvd
hkd.pid_file = ${path.run}/hkd.pid

wat.admin.login = admin
# wat.admin.password =

log.filename = ${path.log}/qvd.log
log.level = INFO

admin.ssh.opt.StrictHostKeyChecking = no
admin.ssh.opt.UserKnownHostsFile = /dev/null

vm.overlay.persistent = 0
vm.kvm.virtio = 1

vm.vnc.redirect = 0
vm.vnc.opts =
vm.serial.redirect = 1
vm.serial.capture = 0

vm.network.bridge = qvdnet0
# No sensible default value is possible for dhcp-range!
# vm.network.dhcp-range=127.0.0.1,127.255.255.254
internal.vm.network.dhcp-hostsfile=${path.run}/dhcp-hostsfile

osi.default.memory = 256
osi.default.overlay = 1

vma.audio.enable = 0
vma.printing.enable = 0
vma.pid_file = /var/run/qvd/vma.pid

vm.kvm.home.drive.index = 1
vma.user.home.drive = /dev/vdb
vma.user.home.fs = ext4
vma.user.home.path = /home
vma.user.default.name = qvd
vma.user.default.groups =

vma.on_action.pre-connect =
vma.on_action.connect =
vma.on_action.disconnect =
vma.on_action.suspend =
vma.on_action.poweroff =

vma.on_state.connected =
vma.on_state.suspended =
vma.on_state.disconnected =

vma.on_provisioning.mount_home =
vma.on_provisioning.add_user =
vma.on_provisioning.after_add_user =

vma.default.client.keyboard = pc105/en
vma.default.client.link = adsl

# internal parameters, do not change!!!
internal.l7r.timeout.vm_start = 270
internal.l7r.timeout.x_start = 10
internal.l7r.timeout.vma = 4
internal.l7r.timeout.takeover = 30
internal.l7r.retry.x_start = 5
internal.l7r.poll_time.vm = 3
internal.l7r.poll_time.x = 1

internal.hkd.timeout.vm.state.starting = 240
internal.hkd.timeout.vm.state.stopping_1 = 30
internal.hkd.timeout.vm.state.stopping_2 = 240
internal.hkd.timeout.vm.state.zombie_1 = 30
internal.hkd.timeout.vm.state.running = 120
internal.hkd.timeout.vm.vma = 4
internal.hkd.poll_time = 2
internal.hkd.poll_all_mod = 10

internal.hkd.database.retry_delay = 15
internal.hkd.database.timeout = 150
internal.hkd.cluster.check.interval = 300
internal.hkd.cluster.node.timeout = 600

internal.vm.port.x = 5000
internal.vm.port.vma = 3030
internal.vm.monitor.redirect = 0

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
