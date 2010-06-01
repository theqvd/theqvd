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
path.serial.captures = ${path.tmp}/qvd

command.kvm = kvm
command.kvm-img = kvm-img
command.nxagent = /usr/bin/nxagent
command.nxdiag = /usr/bin/nxdiag.pl
command.x-session = /etc/X11/Xsession

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
l7r.ssl_port = 8443
l7r.port = 8080
l7r.address = *
l7r.as_user = qvd
l7r.pid_file = ${path.run}/l7r.pid
l7r.auth.plugins = default

auth.ldap.filter = (uid=%u)

# l7r.auth.mode = ldap
# l7r.auth.ldap.host =
# l7r.auth.ldap.base =

hkd.as_user = qvd
hkd.pid_file = ${path.run}/hkd.pid

wat.admin.login = admin
# wat.admin.password =

log.filename = ${path.log}/qvd.log
log.level = INFO

admin.ssh.opt.StrictHostKeyChecking = no
admin.ssh.opt.UserKnownHostsFile = /dev/null

vm.overlay.persistent = 0

vm.vnc.redirect = 0
vm.vnc.opts =
vm.serial.redirect = 1
vm.serial.capture = 0
vm.ssh.redirect = 1

vma.audio.enable = 0
vma.printing.enable = 0

vma.pid_file = /var/run/qvd/vma.pid
vma.printing_conf = /var/run/qvd/printing.conf
vma.nxagent.as_user = qvd

vma.x-session.env.QVD_SESSION = 1

vma.on_action.connect =
vma.on_action.disconnect =
vma.on_action.suspend =
vma.on_action.poweroff =

vma.on_state.connected =
vma.on_state.suspended =
vma.on_state.disconnected =

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

internal.hkd.timeout.state.starting = 240
internal.hkd.timeout.state.stopping_1 = 30
internal.hkd.timeout.state.stopping_2 = 240
internal.hkd.timeout.state.zombie_1 = 30
internal.hkd.timeout.state.running = 120
internal.hkd.timeout.vma = 4
internal.hkd.poll_time = 2
internal.hkd.poll_all_mod = 10

internal.vm.port.x = 5000
internal.vm.port.vma = 3030
internal.vm.port.ssh = 22

internal.nxagent.display = 100

internal.nxagent.timeout.initiating = 20
internal.nxagent.timeout.listening = 10
internal.nxagent.timeout.suspending = 20
internal.nxagent.timeout.stopping = 20

internal.vma.on_printing.connected = /usr/bin/qvd-printing
internal.vma.on_printing.suspended = /usr/bin/qvd-printin
internal.vma.on_printing.stopped = /usr/bin/qvd-printing

