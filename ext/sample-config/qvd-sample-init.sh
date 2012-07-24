#!/bin/sh


trap "" HUP

export PATH=/usr/lib/qvd/bin:$PATH
host=`hostname`

set -x

if [ ! -f /var/lib/qvd/storage/staging/demo-ubuntu-kde.img ] ; then
	mkdir -p /var/lib/qvd/storage/staging/
	file=/var/lib/qvd/storage/staging/demo-ubuntu-kde.img.gz
	wget http://theqvd.com/downloads/demo/demo-ubuntu-kde.img.gz -c -O "$file" || rm -f "$file"
	gunzip "$file" || rm -f /var/lib/qvd/storage/staging/*

	if [ ! -f /var/lib/qvd/storage/staging/demo-ubuntu-kde.img ] ; then
		echo "Failed to download demo image, aborting"
		exit 1
	fi
fi

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


qvd-deploy-db.pl --force 2>&1 | tee /tmp/sample-init.log || exit 1;

qvd-admin.pl config ssl key=/etc/qvd/server-private-key.pem cert=/etc/qvd/server-certificate.pem
qvd-admin.pl config set vm.network.ip.start=10.1.0.30

qvd-admin.pl host add name=$host address=127.0.0.1

qvd-admin.pl osf  add name=sample
qvd-admin.pl di   add osf_id=1 path=/var/lib/qvd/storage/staging/demo-ubuntu-kde.img
qvd-admin.pl user add login=qvd password=qvd
qvd-admin.pl vm   add name=sample_vm user=qvd osf=sample

