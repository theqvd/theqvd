lxc.autodev=1
lxc.hook.autodev=<%= $lxc_hook_autodev %>
lxc.init.cmd = /sbin/init systemd.unified_cgroup_hierarchy

% if ( $lxc_version < '2.1'){
lxc.kmsg=0
lxc.utsname=<%= $lxc_utsname %>
lxc.network.type=veth
lxc.network.veth.pair=<%= $lxc_network_veth_pair %>
lxc.network.name=eth0
lxc.network.flags=up
lxc.network.hwaddr=<%= $lxc_network_hwaddr %>
lxc.network.link=<%= $lxc_network_link %>
lxc.console=<%= $lxc_console %>
lxc.tty=3
lxc.pts=1024
lxc.rootfs=<%= $lxc_rootfs %>
lxc.pivotdir=qvd-pivot
% } else {
lxc.uts.name=<%= $lxc_utsname %>
lxc.net.0.type=veth
lxc.net.0.veth.pair=<%= $lxc_network_veth_pair %>
lxc.net.0.name=eth0
lxc.net.0.flags=up
lxc.net.0.hwaddr=<%= $lxc_network_hwaddr %>
lxc.net.0.link=<%= $lxc_network_link %>
lxc.console.path=<%= $lxc_console %>
lxc.tty.max=3
lxc.pty.max=1024
lxc.rootfs.path=<%= $lxc_rootfs %>
% }

lxc.mount.entry=<%= $lxc_mount_entry %>
lxc.cgroup.cpu.shares=1024
lxc.cgroup.cpuset.cpus=<%= $lxc_cgroup_cpuset_cpus %>
<%= $memory_limits %>
#lxc.cap.drop=sys_module audit_control audit_write linux_immutable mknod net_admin net_raw sys_admin sys_boot sys_resource sys_time

% if ( defined $extra->{vhci} ){
lxc.mount.entry=/sys sys none defaults,bind
lxc.mount.entry=<%= $extra->{vhci}->{directory} %> sys/devices/platform none defaults,bind
lxc.mount.entry=/sys/devices/platform/<%= $extra->{vhci}->{hub} %> sys/devices/platform/<%= $extra->{vhci}->{hub} %> none defaults,bind
% }

% if ( $lxc_version == '0.9' ){
lxc.aa_profile = unconfined
% } elsif ( $lxc_version < '2.1' ) {
lxc.aa_profile = lxc-container-qvd
% } else {
lxc.apparmor.profile = lxc-container-qvd
% }

# Deny access to all devices, except...
lxc.cgroup.devices.deny = a

# Allow any mknod (but not using the node)
lxc.cgroup.devices.allow = c *:* m
lxc.cgroup.devices.allow = b *:* m
# /dev/null and zero
lxc.cgroup.devices.allow = c 1:3 rwm
lxc.cgroup.devices.allow = c 1:5 rwm
# consoles /dev/tty, /dev/console
lxc.cgroup.devices.allow = c 5:1 rwm
lxc.cgroup.devices.allow = c 5:0 rwm
# /dev/{,u}random
lxc.cgroup.devices.allow = c 1:9 rwm
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 136:* rwm
lxc.cgroup.devices.allow = c 5:2 rwm
# rtc
lxc.cgroup.devices.allow = c 254:0 rwm
#fuse
lxc.cgroup.devices.allow = c 10:229 rwm
#tun
lxc.cgroup.devices.allow = c 10:200 rwm
#full
lxc.cgroup.devices.allow = c 1:7 rwm
#hpet
lxc.cgroup.devices.allow = c 10:228 rwm
#kvm
lxc.cgroup.devices.allow = c 10:232 rwm

### USB sharing
# /dev/video*
lxc.cgroup.devices.allow = c 81:* rwm

% if ( defined $extra->{lines} ){
<%= $extra->{lines} %>
% }
