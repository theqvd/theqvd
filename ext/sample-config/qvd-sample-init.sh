#!/bin/sh


trap "" HUP

export PATH=/usr/lib/qvd/bin:$PATH
host=`hostname`

set -x


staging=/var/lib/qvd/storage/staging/
image=ubuntu-12.04-desktop.i386.tar.gz
url=http://theqvd.com/downloads/qvd3/images/lxc/$image

if [ ! -f "$staging/$image" ] ; then
	mkdir -p "$staging"
	compressed="$staging/$image"

	wget "$url" -c -O "$compressed" || rm -f "$compressed"

	if [ ! -f "$staging/$image" ] ; then
		echo "Failed to download demo image, aborting"
		exit 1
	fi
fi

if [ -f "/etc/SuSE-release" ] ; then

	mkdir -p /cgroup

	if ( ! grep -q '/cgroup' /etc/fstab ) ; then
		cp -f /etc/fstab /etc/fstab.bak
		echo "cgroup               /cgroup              cgroup     defaults              0 0" >> /etc/fstab
	fi

	mount /cgroup

	if [ ! -f /etc/sysconfig/network/ifcfg-qvdnet ] ; then
		if [ ! -f /etc/sysconfig/network/ifcfg-eth0 ] ; then
			echo "Can't open network configuration for eth0, aborting"
			exit 1
		fi

		. /etc/sysconfig/network/ifcfg-eth0

		# Backup original config file only once -- this backs up the system default file
		if [ ! -f /etc/sysconfig/network/ifcfg-eth0.orig ] ; then
			cp -f /etc/sysconfig/network/ifcfg-eth0 /etc/sysconfig/network/ifcfg-eth0.orig
		fi

		# Backup previous config file.
		cp -f /etc/sysconfig/network/ifcfg-eth0 /etc/sysconfig/network/ifcfg-eth0.bak

		if [ -f /etc/sysconfig/network/ifcfg-qvdnet ] ; then
			cp -f /etc/sysconfig/network/ifcfg-qvdnet /etc/sysconfig/network/ifcfg-qvdnet.bak
		fi

		# Generate new network config
		
		cat >/etc/sysconfig/network/ifcfg-qvdnet <<CONF
BOOTPROTO='$BOOTPROTO'
GATEWAY='$GATEWAY'
IPADDR='$IPADDR'
PREFIXLEN='$PREFIXLEN'
STARTMODE='$STARTMODE'
USERCONTROL='no'
BRIDGE='yes'
BRIDGE_PORTS='eth0'
BRIDGE_STP='on'
NAME='QVD Network'
CONF

		cat >/etc/sysconfig/network/ifcfg-eth0 <<CONF2
BOOTPROTO='static'
BROADCAST=''
IPADDR='0.0.0.0'
NAME='$NAME'
NETMASK=''
NETWORK=''
USERCONTROL='no'
CONF2

		service network restart
	fi
elif [ -f /etc/debian_version ] ; then
	echo "Debian support not yet complete"
else
	echo "Can't configure network, unknown distribution"
fi

qvd-deploy-db.pl --force 2>&1 | tee /tmp/sample-init.log || exit 1;

qvd-admin.pl config ssl key=/etc/qvd/server-private-key.pem cert=/etc/qvd/server-certificate.pem
qvd-admin.pl config set vm.network.ip.start=10.1.0.30
qvd-admin.pl config set vm.hypervisor=lxc
qvd-admin.pl config set vm.lxc.unionfs.type=unionfs-fuse

qvd-admin.pl host add name=$host address=127.0.0.1

qvd-admin.pl osf  add name=sample
qvd-admin.pl di   add osf_id=1 path=$staging/$image
qvd-admin.pl user add login=qvd password=qvd
qvd-admin.pl vm   add name=sample_vm user=qvd osf=sample

