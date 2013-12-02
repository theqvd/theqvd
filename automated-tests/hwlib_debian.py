import re
import os
import time
from hwlib_common import *

## these will be explicitly installed
install_pkgs_ubuntu_1 = [
    'perl-qvd-node', 'perl-qvd-admin', 'perl-qvd-client', 'perl-qvd-l7r-authenticator-plugin-auto', 'perl-qvd-l7r-authenticator-plugin-ldap',
    'postgresql-9.1', 'postgresql-client-9.1',
    'socat',                 ## needed for the WAT smoke test
    'libx11-guitest-perl',   ## needed for the GUI tests
    'cgroup-lite',           ## TODO: this is a workaround, it should be automatically selected from dependencies
]
install_pkgs_ubuntu_2 = [
    'perl-qvd-admin-web',
]
## this list is used for checking that packages have been installed, and for uninstalling them too
all_pkgs_ubuntu = [
    'perl-qvd-admin', 'perl-qvd-admin-web', 'perl-qvd-client', 'perl-qvd-config', 'perl-qvd-config-core', 'perl-qvd-db', 'perl-qvd-hkd', 'perl-qvd-http', 'perl-qvd-httpc', 'perl-qvd-httpd', 'perl-qvd-l7r', 'perl-qvd-l7r-authenticator-plugin-auto', 'perl-qvd-l7r-authenticator-plugin-ldap', 'perl-qvd-l7r-loadbalancer', 'perl-qvd-log', 'perl-qvd-node', 'perl-qvd-simplerpc', 'perl-qvd-uri',
    'qvd-admin-web-libs', 'qvd-client-libs', 'qvd-common-libs', 'qvd-fuse-unionfs', 'qvd-lxc', 'qvd-node-libs', 'qvd-perl',
    'postgresql-9.1', 'postgresql-client-9.1', 'libapache2-mod-fastcgi', 'xserver-xorg', 'qvd-libxcomp3', 'qvd-nxproxy',
    'socat', 'cgroup-lite',
]


def set_install_pkgs_ubuntu_1(pkgs):
    global install_pkgs_ubuntu_1
    install_pkgs_ubuntu_1 = re.compile(' *, *').split(pkgs)

def set_install_pkgs_ubuntu_2(pkgs):
    global install_pkgs_ubuntu_2
    install_pkgs_ubuntu_2 = re.compile(' *, *').split(pkgs)

def set_all_pkgs_ubuntu(pkgs):
    global all_pkgs_ubuntu
    all_pkgs_ubuntu = re.compile(' *, *').split(pkgs)

def os_quick_cleanup_debian(os_vm_ip):
    run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo y |/usr/lib/qvd/bin/qvd-admin.pl vm stop"\\"')
    time.sleep(20)
    output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/qvd-admin.pl vm list')
    if re.search ('stopping', output): time.sleep(30)
    run_cmd_in_vm (os_vm_ip, 'grep qvd/storage /proc/mounts')    ## bug: use /proc/<hkd's pid>/mountinfo
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-l7r stop')
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-hkd stop')
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/apache2 stop')
    time.sleep(3)
    output = run_cmd_in_vm (os_vm_ip, 'umount /var/lib/qvd/storage')
    match = re.search ('device is busy', output, re.S)
    if match:
        raise Exception, "Failed to umount busy filesystem /var/lib/qvd/storage"
    run_cmd_in_vm (os_vm_ip, 'rm -f /root/btrfs.img')
    run_cmd_in_vm (os_vm_ip, 'su - postgres -c \\""dropdb qvddb"\\"')
    run_cmd_in_vm (os_vm_ip, 'su - postgres -c \\""dropuser qvd"\\"')
    run_cmd_in_vm (os_vm_ip, 'apt-get -y --purge remove %s' % (' '.join (all_pkgs_ubuntu)))
    run_cmd_in_vm (os_vm_ip, 'apt-get -y autoremove')
    run_cmd_in_vm (os_vm_ip, 'rm -rf /etc/postgresql /var/lib/postgresql /etc/qvd /tmp/qvd /var/lib/qvd/storage/basefs /var/lib/qvd/storage/staging /var/lib/qvd/storage/images /var/lib/qvd/storage/overlayfs')#/var/lib/qvd/storage/{rootfs,overlay,basefs,homes,overlayfs} 
    output = run_cmd_in_vm (os_vm_ip, 'dpkg -l %s' % (' '.join (all_pkgs_ubuntu)))
    match = re.search ('^i', output, re.M)
    if match:
        raise Exception, "quick cleanup didn't remove all QVD packages"

def qvd_install_1_debian(os_vm_ip, qvd_host_name, qvd_host_ip, sources_list):
    run_cmd_in_vm (os_vm_ip, 'apt-get install bridge-utils')
    run_cmd_in_vm (os_vm_ip, 'bash -c \\""find /etc/apt |grep -i qvd |xargs rm -vf"\\"')
    run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo %s >/etc/apt/sources.list.d/qvd.list"\\"' % sources_list)

    run_cmd_in_vm (os_vm_ip, 'ifdown qvdnet')
    run_cmd_in_vm (os_vm_ip, 'brctl delbr qvdnet')
    run_cmd_in_vm (os_vm_ip, 'sed -ie s/10.69.0.1/%s/ /etc/network/interfaces' % qvd_host_ip)
    run_cmd_in_vm (os_vm_ip, 'ifup qvdnet')
    run_cmd_in_vm (os_vm_ip, 'ifconfig -a')

    run_cmd_in_vm (os_vm_ip, 'bash -c \\""mkdir -p /etc/qvd; (echo nodename = %s; echo database.host = %s; echo database.name = qvddb; echo database.user = qvd; echo database.password = anee*z5ui2Sh; echo log.level=DEBUG) >/etc/qvd/node.conf"\\"' % (qvd_host_name, qvd_host_ip))

    run_cmd_in_vm (os_vm_ip, 'apt-get update')
    run_cmd_in_vm (os_vm_ip, 'apt-get install -y --force-yes %s' % (' '.join (install_pkgs_ubuntu_1)))
    #run_cmd_in_vm (os_vm_ip, 'sed -i -e /ERR_remove_thread_state/d /usr/lib/qvd/lib/perl5/site_perl/5.14.2/QVD/Client/Proxy.pm')        ## hot fix
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/apparmor teardown')
    run_cmd_in_vm (os_vm_ip, 'update-rc.d apparmor disable')
    run_cmd_in_vm (os_vm_ip, 'cp -f /root/qvd-client.pl /usr/lib/qvd/bin/')            ## hot fix

    output = run_cmd_in_vm (os_vm_ip, 'ls /sys/fs/cgroup/cpuset/cpuset.cpus')
    match = re.search ('No such file', output)
    if match:
        raise Exception, "cgroup isn't mounted"

def qvd_install_2_debian(os_vm_ip):
    output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/qvd-admin.pl config set wat.admin.password=watdafuq')
    if output != '':
        raise Exception, 'config set failed'

    run_cmd_in_vm (os_vm_ip, 'apt-get install -y --force-yes %s' % (' '.join (install_pkgs_ubuntu_2)))

    output = run_cmd_in_vm (os_vm_ip, 'dpkg -l %s' % (' '.join (all_pkgs_ubuntu)))
    for pkg in all_pkgs_ubuntu:
        pat = 'ii  %s ' % pkg
        if not re.search (pat, output):
            raise Exception, 'package %s not installed' % pkg
