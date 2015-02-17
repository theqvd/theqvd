QVD_CONFIG_HELP = {
    'auth.ldap.host':  '(Required). Can be a host or an LDAP uri as specified in Net::LDAP',
    'auth.ldap.base':  '(Required). The search base where to find the users with the auth.ldap.filter (see below)',
    'auth.ldap.filter':  '(Optional by default (uid=%u)). The string %u will be substituted with the login name',
    'auth.ldap.binddn':  '(Optional by default empty). The initial bind to find the users. By default the initial bind is done as anonymous unless this parameter is specified. If it contains the string %u, that is substituted with the login',
    'auth.ldap.bindpass':  '(Optional by default empty). The password for the binddn',
    'auth.ldap.scope':  '(Optional by default base). See the Net::LDAP scope attribute in the search operation. If this is empty the password provided in during the authentication is used',
    'auth.ldap.userbindpattern':  '(Optional by default empty). If specified an initial bind with this string is attempted. The login attribute is substituted with %u.',
    'auth.ldap.deref':  '(Optional by default never). How aliases are dereferenced, the accepted values are never, search, find and always. See Net::LDAP for more info.',
    'auth.ldap.racf_allowregex':  '(Optional by default not set). This is a regex to allow to authenticate some RACF error codes. An example setting would be "^R004109 ". One of the common cases is R004109 which returns an ldap code 49 (invalid credentials) and a text message such as "R004109 The password has expired (srv_authenticate_native_password))". If you don’t have RACF this is probably not for you. Example RACF errors:<br><br>R004107 The password function failed; not loaded from a program controlled library.<br>R004108 TDBM backend password API resulted in an internal error.<br>R004109 The password has expired.<br>R004110 The userid has been revoked.<br>R004128 Native authentication password change failed. The new password is not valid or does not meet requirements.<br>R004111 The password is not correct.<br>R004112 A bind argument is not valid.<br>R004118 Entry native user ID (ibm-nativeId,uid) is not defined to the Security Server.',
    'client.link': 'Can be: modem, isdn, adsl, wan, lan, local or a bandwidth specification (56k, 1m, 100m…)',
    'client.geometry': 'Used to report the size and the depth of the client display, if unset use full screen',
    'client.fullscreen': 'Used to run the client in fullscreen mode',
    'client.slave.enable': 'Whether or not to enable the slave channel, used by the shared folder feature. Enabled by default',
    'client.slave.command': 'Point the QVD client machine to the slave client binary or an alternative',
    'client.audio.enable': 'Used to enable the PulseAudio server in the client. Can also be configured in the OSF',
    'client.printing.enable': 'Used to enable Printer sharing with the client. Can also be configured in the OSF',
    'client.host.port': 'The L7R port the client should connect to (this setting relates to the l7r.port setting configured for your server nodes)',
    'client.host.name': 'The L7R host the client should connect to (usually the frontend IP address of a loadbalancer)',
    'client.user.name': 'The user name for client authentication',
    'client.use_ssl': 'Whether or to use SSL in client-server communications. Enabled by default',
    'client.force.host.name': 'Forces the hostname available to the client, so that it is only able to connect to this host',
    'client.force.link': 'Forces the client link parameter, so that it is not possible to select an alternative option within the GUI.',
    'client.remember_password': 'Controls whether or not the client remembers the password used for the previous connection',
    'client.show.remember_password': 'Controls whether or not the option to Remember Password is displayed within the GUI.',
    'client.show.settings': 'Shows the settings tab on the client',
    'database.host': 'Where the QVD database is found',
    'database.name': 'The name of the QVD database',
    'database.user': 'The user account needed to connect',
    'database.password': 'The password needed to connect',
    'l7r.auth.plugins': '(Required). Set to "ldap" to enable.',
    'nodename': 'Name of this node in QVD. Usually the machine\'s hostname.',
    'path.run': 'Directory where several configuration, state, pid and certificate files are stored',
    'path.log': 'Where QVD logs are stored',
    'path.tmp': 'Temporary files',
    'path.storage.root': 'Main storage location for OS images (both KVM and LXC)',
    'path.storage.staging': 'OS images ready to be used',
    'path.storage.images': 'OS images in use by some VM',
    'client.remember_password': 'Whether to remember password after successful connection',
    'client.remember_username': 'Whether to remember the username after a successful connection',
    'client.show.remember_password': 'Whether to show the previous checkbox or not',
    'client.show.settings': 'Whether to show the settings tab',
    'client.link': 'Nxproxy\'s link parameter, can be: modem, isdn, adsl, wan, lan, local or a bandwidth specification (56k, 1m, 100m...)',
    'client.nxproxy.extra_args': 'Extra arguments to nxproxy.',
    'client.nxagent.extra_args': 'Extra arguments to nxagent. Allows non-standard configurations, like defining custom link types. Sent to the VM side and applied there.',
    'client.sshfs.extra_args': 'Extra arguments for sshfs. These have been determined as reasonable defaults.',
    'client.geometry': 'Nxproxy\'s geometry parameter',
    'client.fullscreen': 'Nxproxy\'s fullscreen parameter',
    'client.audio.enable': 'Enable the Pulse audio server in the client',
    'client.printing.enable': 'Something regarding an NX channel',
    'client.host.port': 'L7R port the client should connect to',
    'client.host.name': 'L7R host the client should connect to',
    'client.user.name': 'User name for client authentication',
    'client.use_ssl': 'Whether to use SSL in the client↔server communication or not',
    'client.ssl.use_cert': 'Whether to use SSL certificate in the client↔server communication or not',
    'client.slave.command': 'Slave shell command',
    'client.slave.client': 'Slave shell client path',
    'client.slave.enable': 'Enable making slave connections to VM',
    'client.locale': 'Force locale, ignoring system LC_* and LANG environment variables',
    'client.darwin.screen_resolution.verified': 'Check whether we should default to a lower window size on OSX.',
}

/*
## On OSX the window is hard to resize if it's too large, so
## we check whether we should default to a lower window size

## Only do the check on the first start, and don't mess
## with it afterwards. Also saves startup time.
client.darwin.screen_resolution.verified = 0
## When the screen resolution is this or less, use the low geometry setting
client.darwin.screen_resolution.min=1440x900
## Geometry to use when the screen is low resolution
client.darwin.screen_resolution.low_res_geometry=800x600

# Enable USB sharing
client.usb.enable = 0

# Share all USB devices automatically (most of the time not a good idea)
client.usb.share_all = 0

# List of USB devices to share with the VM. 
# Syntax: VID:PID, comma separated. Spaces are allowed. For example:
# 0441:0012, 1234:5678
client.usb.share_list =


## umask for the L7R process
l7r.user.umask = 0022
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
l7r.auth.plugin.default.salt=qvd1234

## load balancing plugins to use. Similar to auth plugins
l7r.loadbalancer.plugin = default
## each plugin should document its own parameters
l7r.loadbalancer.plugin.default.weight.ram = 1
l7r.loadbalancer.plugin.default.weight.cpu = 1
l7r.loadbalancer.plugin.default.weight.random = 1

l7r.client.cert.require = 0

*/


/*

# storage directories for KVM
path.storage.overlays = ${path.storage.root}/overlays
path.storage.homes = ${path.storage.root}/homes
path.storage.check = ${path.storage.homes}/.rw_check

# storage directories for LXC
path.storage.basefs = ${path.storage.root}/basefs
path.storage.homefs = ${path.storage.root}/homefs
path.storage.btrfs.root = ${path.storage.root}

path.run.lxc = ${path.run}/lxc

path.storage.overlayfs = ${path.storage.btrfs.root}/overlayfs
path.storage.rootfs = ${path.storage.btrfs.root}/rootfs

## paths for SSL certificates and CAs
path.l7r.ssl = ${path.run}/l7r/ssl
path.l7r.ssl.key = ${path.l7r.ssl}/key.pem
path.l7r.ssl.cert = ${path.l7r.ssl}/cert.pem
path.l7r.ssl.ca = ${path.l7r.ssl}/ca.pem
path.l7r.ssl.crl = ${path.l7r.ssl}/crl.pem

path.ssl.ca.system = /etc/ssl/certs
path.ssl.ca.personal = certs

path.darwin.ssl.ca.system = /System/Library/OpenSSL/certs/

## KVM serial port captures or LXC console output
path.serial.captures = ${path.tmp}/qvd
path.hypervisor.captures = ${path.tmp}/qvd

path.cgroup = /sys/fs/cgroup
path.cgroup.cpu.lxc = ${path.cgroup}/cpu/lxc

path.client.pixmaps = pixmaps
path.client.pixmaps.alt = /usr/share/pixmaps

path.qvd.bin = /usr/lib/qvd/bin

*/
