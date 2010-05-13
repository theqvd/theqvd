package QVD::Config;

use Config::Properties;

our $defaults = Config::Properties->new;
$defaults->load(*DATA);

1;

__DATA__

# nodename = blas

database.host = localhost
database.user = qvd
database.name = qvd
# database.password = passw0rd

path.run = /var/run/qvd
path.log = /var/log
path.storage.root = /var/lib/qvd/storage
path.storage.staging = ${path.storage.root}/staging
path.storage.images = ${path.storage.root}/images
path.storage.overlays = ${path.storage.root}/overlays
path.storage.homes = ${path.storage.root}/homes
path.ssl.certs = ${path.run}/ssl

command.kvm = kvm
command.kvm-img = kvm-img

l7r.as_user = qvd
l7r.pid_file = ${path.run}/l7r.pid
l7r.auth.mode = basic

# l7r.auth.mode = ldap
# l7r.auth.ldap.host =
# l7r.auth.ldap.base =

hkd.as_user = qvd
hkd.pid_file = ${path.run}/hkd.pid

wat.admin.login = admin
# wat.admin.password = foobar

log.filename = ${path.log}/qvd.log
log.level = INFO

# internal parameters, do not change!!!
internal.l7r.timeout.vm_start = 270
internal.l7r.timeout.x_start = 10
internal.l7r.timeout.vma = 4
internal.l7r.timeout.takeover = 30
internal.l7r.retry.x_start = 5
internal.l7r.poll_time = 2

internal.hkd.timeout.state.starting = 240
internal.hkd.timeout.state.stopping_1 = 30
internal.hkd.timeout.state.stopping_2 = 240
internal.hkd.timeout.state.zombie_1 = 30
internal.hkd.timeout.state.running = 120
internal.hkd.timeout.vma = 4
internal.hkd.poll_time = 2
internal.hkd.poll_all_mod = 10
