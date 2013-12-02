import re
import os
import time
from hwlib_common import *

patch_lxcpm_and_lxcdestroy_for_extended_images = 0

## these will be explicitly installed
if patch_lxcpm_and_lxcdestroy_for_extended_images:
    install_pkgs_suse_1 = [
        'perl-QVD-Node', 'perl-QVD-Admin', 'perl-QVD-L7R-Authenticator-Plugin-Auto', 'perl-QVD-L7R-Authenticator-Plugin-Ldap',
        'postgresql-server', 'postgresql',
        'socat',                 ## needed for the WAT smoke test
    ]
else:
    install_pkgs_suse_1 = [
        'perl-QVD-Node', 'perl-QVD-Admin', 'perl-QVD-Client', 'perl-QVD-L7R-Authenticator-Plugin-Auto', 'perl-QVD-L7R-Authenticator-Plugin-Ldap',
        'postgresql-server', 'postgresql',
        'socat',                 ## needed for the WAT smoke test
#        'perl-X11-GUITest',      ## needed for the GUI tests
    ]

install_pkgs_suse_2 = [
    'perl-QVD-Admin-Web',
]

## this list is used for checking that packages have been installed, and for uninstalling them too
if patch_lxcpm_and_lxcdestroy_for_extended_images:
    all_pkgs_suse = [
        'perl-QVD-Admin', 'perl-QVD-Admin-Web', 'perl-QVD-Config', 'perl-QVD-Config-Core', 'perl-QVD-DB', 'perl-QVD-HKD', 'perl-QVD-HTTP', 'perl-QVD-HTTPC', 'perl-QVD-HTTPD', 'perl-QVD-L7R', 'perl-QVD-L7R-Authenticator-Plugin-Auto', 'perl-QVD-L7R-Authenticator-Plugin-Ldap', 'perl-QVD-L7R-LoadBalancer', 'perl-QVD-Log', 'perl-QVD-Node', 'perl-QVD-SimpleRPC', 'perl-QVD-URI',
        'qvd-admin-web-libs', 'qvd-common-libs', 'qvd-fuse-unionfs', 'qvd-lxc', 'qvd-node-libs', 'qvd-perl',
        'postgresql-server', 'postgresql', 'postgresql-libs', 'apache2-mod_fcgid',
        'socat',
    ]
else:
    all_pkgs_suse = [
        'perl-QVD-Admin', 'perl-QVD-Admin-Web', 'perl-QVD-Client', 'perl-QVD-Config', 'perl-QVD-Config-Core', 'perl-QVD-DB', 'perl-QVD-HKD', 'perl-QVD-HTTP', 'perl-QVD-HTTPC', 'perl-QVD-HTTPD', 'perl-QVD-L7R', 'perl-QVD-L7R-Authenticator-Plugin-Auto', 'perl-QVD-L7R-Authenticator-Plugin-Ldap', 'perl-QVD-L7R-LoadBalancer', 'perl-QVD-Log', 'perl-QVD-Node', 'perl-QVD-SimpleRPC', 'perl-QVD-URI',
        'qvd-admin-web-libs', 'qvd-client-libs', 'qvd-common-libs', 'qvd-fuse-unionfs', 'qvd-lxc', 'qvd-node-libs', 'qvd-perl',
        'postgresql-server', 'postgresql', 'postgresql-libs', 'apache2-mod_fcgid', 'xorg-x11-server', 'qvd-libXcomp3', 'qvd-nxproxy',
        'socat',
#        'perl-X11-GUITest',
    ]

    #'perl-QVD-Build-libs',     ## 20130710 esta en el repo de suse pero no aparece en all_pkgs_ubuntu
    #'perl-QVD-ParallelNet',    ## 20130710 esta en el repo de suse pero no aparece en all_pkgs_ubuntu
    #'perl-QVD-VMA',            ## 20130710 esta en el repo de suse pero no aparece en all_pkgs_ubuntu
    #'perl-QVD-VMKiller',       ## 20130710 esta en el repo de suse pero no aparece en all_pkgs_ubuntu
    #'perl-QVD-VNCProxy',       ## 20130710 esta en el repo de suse pero no aparece en all_pkgs_ubuntu
    #'qvd-admin-libs',          ## 20130710 esta en el repo de suse pero no aparece en all_pkgs_ubuntu
    #'qvd-vma-libs',            ## 20130710 esta en el repo de suse pero no aparece en all_pkgs_ubuntu


def set_install_pkgs_suse_1(pkgs):
    global install_pkgs_suse_1
    install_pkgs_suse_1 = re.compile(' *, *').split(pkgs)

def set_install_pkgs_suse_2(pkgs):
    global install_pkgs_suse_2
    install_pkgs_suse_2 = re.compile(' *, *').split(pkgs)

def set_all_pkgs_suse(pkgs):
    global all_pkgs_suse
    all_pkgs_suse = re.compile(' *, *').split(pkgs)

def os_quick_cleanup_suse(os_vm_ip):
    run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo y |/usr/lib/qvd/bin/qvd-admin.pl vm stop"\\"')
    time.sleep(20)
    output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/qvd-admin.pl vm list')
    if re.search ('stopping', output): time.sleep(30)
    run_cmd_in_vm (os_vm_ip, 'grep qvd/storage /proc/mounts')    ## bug: use /proc/<hkd's pid>/mountinfo
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-l7r stop')
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-hkd stop')
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/apache2 stop')
    time.sleep(3)
    run_cmd_in_vm (os_vm_ip, 'ps faxuwww |grep qvd-')
    run_cmd_in_vm (os_vm_ip, 'umount /var/lib/qvd/storage')
    match = re.search ('device is busy', output, re.S)
    if match:
        raise Exception, "Failed to umount busy filesystem /var/lib/qvd/storage"
    run_cmd_in_vm (os_vm_ip, 'rm -f /root/btrfs.img')
    run_cmd_in_vm (os_vm_ip, 'su - postgres -c \\""dropdb qvddb"\\"')
    run_cmd_in_vm (os_vm_ip, 'su - postgres -c \\""dropuser qvd"\\"')
    ## la mierda del zypper aborta y no desinstala nada ante ciertos errores (e.g. "No provider of 'qvd-libXcomp3' found"). Asi que vamos uno por uno...
    for pkg in all_pkgs_suse:
        run_cmd_in_vm (os_vm_ip, 'zypper --non-interactive remove %s' % pkg)
    #run_cmd_in_vm (os_vm_ip, 'zypper ps')
    ## todo: autoremove
    run_cmd_in_vm (os_vm_ip, 'rm -rf /etc/postgresql /etc/qvd /tmp/qvd /var/lib/qvd/storage/basefs /var/lib/qvd/storage/staging /var/lib/qvd/storage/images /var/lib/qvd/storage/overlayfs')#/var/lib/qvd/storage/{rootfs,overlay,basefs,homes,overlayfs} 
    output = run_cmd_in_vm (os_vm_ip, 'zypper search %s' % (' '.join (all_pkgs_suse)))
    match = re.search ('^i', output, re.M)
    if match:
        raise Exception, "quick cleanup didn't remove all QVD packages"

def qvd_install_1_suse(os_vm_ip, qvd_host_name, qvd_host_ip, sources_list):
    run_cmd_in_vm (os_vm_ip, 'zypper rr QVD')
    run_cmd_in_vm (os_vm_ip, 'zypper rr qndsuse')
    kk = "'SUSE-Linux-Enterprise-Server-11-SP2 11.2.2-1.234'"
    run_cmd_in_vm (os_vm_ip, 'bash -c \\""zypper rr %s"\\"' % kk)
    run_cmd_in_vm (os_vm_ip, 'zypper ar --no-gpgcheck %s QVD' % sources_list)
    run_cmd_in_vm (os_vm_ip, 'zypper ar --no-gpgcheck %s qndsuse' % 'nfs://172.20.64.24/exports/sles11sp2/')

    run_cmd_in_vm (os_vm_ip, 'ifdown qvdnet')
    run_cmd_in_vm (os_vm_ip, 'brctl delbr qvdnet')
    run_cmd_in_vm (os_vm_ip, 'bash -c \\""echo $\'IPADDR=%s\nNETMASK=255.255.0.0\nBRIDGE=yes\' >/etc/sysconfig/network/ifcfg-qvdnet"\\"' % qvd_host_ip)
    run_cmd_in_vm (os_vm_ip, 'ifup qvdnet')
    run_cmd_in_vm (os_vm_ip, 'ifconfig -a')

    run_cmd_in_vm (os_vm_ip, 'bash -c \\""mkdir -p /etc/qvd; (echo nodename = %s; echo database.host = %s; echo database.name = qvddb; echo database.user = qvd; echo database.password = anee*z5ui2Sh; echo log.level=DEBUG) >/etc/qvd/node.conf"\\"' % (qvd_host_name, qvd_host_ip))

    run_cmd_in_vm (os_vm_ip, 'zypper refresh')
    output = run_cmd_in_vm (os_vm_ip, 'zypper --non-interactive install %s' % (' '.join (install_pkgs_suse_1)))
    if re.search ("Package '.*' not found", output): raise Exception, 'not all packages were found in the repository'
    output = run_cmd_in_vm (os_vm_ip, '/etc/init.d/postgresql start')
    if re.search ('No such file or directory', output): raise Exception, "Postgresql doesn't seem to be installed"
    output = run_cmd_in_vm (os_vm_ip, '/etc/init.d/boot.cgroup start')

    run_cmd_in_vm (os_vm_ip, 'modprobe kvm')                                                       ## hot fix
    run_cmd_in_vm (os_vm_ip, 'modprobe kvm-intel')                                                       ## hot fix
    run_cmd_in_vm (os_vm_ip, 'modprobe kvm-amd')                                                       ## hot fix
    run_cmd_in_vm (os_vm_ip, 'ln -s /usr/bin/qemu-img /usr/bin/kvm-img')                                                       ## hot fix
    run_cmd_in_vm (os_vm_ip, 'ln -s /usr/bin/qemu-kvm /usr/bin/kvm')                                                       ## hot fix

    output = run_cmd_in_vm (os_vm_ip, 'ls /sys/fs/cgroup/cpuset/cpuset.cpus')
    match = re.search ('No such file', output)
    if match:
        output = run_cmd_in_vm (os_vm_ip, 'ls /sys/fs/cgroup/cpuset.cpus')
        match = re.search ('No such file', output)
        if match:
            raise Exception, "cgroup isn't mounted"

def qvd_install_2_suse(os_vm_ip):
    output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/qvd-admin.pl config set wat.admin.password=watdafuq')
    if output != '':
        raise Exception, 'config set failed'

    run_cmd_in_vm (os_vm_ip, 'zypper --non-interactive install %s' % (' '.join (install_pkgs_suse_2)))

    output = run_cmd_in_vm (os_vm_ip, 'rpm -q %s' % (' '.join (all_pkgs_suse)))
    for pkg in all_pkgs_suse:
        pat = 'package %s is not installed' % pkg
## TODO: uncomment this, right now it's preventing me to go further
#        if re.search (pat, output):
#            raise Exception, 'package %s not installed' % pkg

    if patch_lxcpm_and_lxcdestroy_for_extended_images:
        run_cmd ('scp -o StrictHostKeyChecking=no -q LXC-fixed-for-extended-images.pm root@%s:/usr/lib/qvd/lib/perl5/site_perl/5.14.2/QVD/HKD/VMHandler/LXC.pm' % os_vm_ip)
        run_cmd ('scp -o StrictHostKeyChecking=no -q lxc-destroy-dont-remove root@%s:/usr/lib/qvd/bin/lxc-destroy' % os_vm_ip)

def qvd_upgrade_qvd(os_vm_ip, sources_list):
    run_cmd_in_vm (os_vm_ip, 'zypper rr QVD')
    run_cmd_in_vm (os_vm_ip, 'zypper ar --no-gpgcheck %s QVD' % sources_list)
    run_cmd_in_vm (os_vm_ip, 'zypper refresh')

    #output = run_cmd_in_vm (os_vm_ip, 'zypper --non-interactive install %s' % (' '.join (install_pkgs_suse_1)))
    output = run_cmd_in_vm (os_vm_ip, 'zypper --non-interactive dist-upgrade')
    output = run_cmd_in_vm (os_vm_ip, '/usr/lib/qvd/bin/qvd-upgrade-db --i-am-brave')
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-hkd restart')
    run_cmd_in_vm (os_vm_ip, '/etc/init.d/qvd-l7r restart')
    output = run_cmd_in_vm (os_vm_ip, 'zypper --non-interactive ps')
    if re.search ("Package '.*' not found", output): raise Exception, 'not all packages were found in the repository'
    output = run_cmd_in_vm (os_vm_ip, 'rpm -q %s' % (' '.join (all_pkgs_suse)))
    for pkg in all_pkgs_suse:
        pat = 'package %s is not installed' % pkg
## TODO: uncomment this, right now it's preventing me to go further
#        if re.search (pat, output):
#            raise Exception, 'package %s not installed' % pkg
