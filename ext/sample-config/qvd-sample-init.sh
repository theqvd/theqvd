#!/bin/bash

hypervisor=$1

if [ -z "$hypervisor" ] ; then
	hypervisor=lxc
fi

if [ "$hypervisor" != "lxc" -a "$hypervisor" != "kvm" ] ; then
	echo "Syntax: $0 [lxc|kvm]"
	exit 1
fi


trap "" HUP

export PATH=/usr/lib/qvd/bin:$PATH
export PATH=/usr/lib/qvd/bin:/bin:/usr/bin:/sbin:/usr/sbin

host=`hostname`
hostname=`hostname`

set -x -e

# Paths
staging=/var/lib/qvd/storage/staging/

# System config
gateway=`ip -o route | grep '^default' | awk '{print $3}'`


if [ "$hypervisor" == "lxc" ] ; then
	image=ubuntu-12.04-desktop.i386.tar.gz
	url=http://s3.amazonaws.com/QVD_Images/3.1/lxc/$image
elif [ "$hypervisor" == "kvm" ] ; then
	image=ubuntu-12.04-desktop.i386.tar.gz
	url=http://s3.amazonaws.com/QVD_Images/3.1/kvm/$image
else
	echo Bad hypervisor: $hypervisor
	exit 1
fi





mkdir -p /var/log/qvd/

if [ ! -f /etc/qvd/server-private-key.pem -o ! -f /etc/qvd/server-certificate.pem ] ; then
	openssl genrsa 1024 > /etc/qvd/server-private-key.pem

	cat >/etc/qvd/server-certificate.cnf <<SSL_CONF
RANDFILE               = $ENV{HOME}/.rnd
[ req ]
default_bits           = 1024
default_keyfile        = /etc/qvd/server-private-key.pem
distinguished_name     = req_distinguished_name
attributes             = req_attributes
prompt                 = no
output_password        =

[ req_distinguished_name ]
C                      = ES
ST                     = Madrid
L                      = Madrid
O                      = QVD Test
OU                     = QVD
CN                     = QVD Test
emailAddress           = test@example.com
[ req_attributes ]
challengePassword      =

SSL_CONF

	openssl req -new -x509 -nodes -sha1 -days 60 -key /etc/qvd/server-private-key.pem -config /etc/qvd/server-certificate.cnf -out /etc/qvd/server-certificate.pem

	set_cert=1
fi

### Edit config
sed -i "s/^nodename =.*/nodename = $hostname/g" "/etc/qvd/node.conf"
sed -i "s/^vm.network.gateway =.*/vm.network.gateway = $gateway/g" "/etc/qvd/node.conf"

### Start postgres
if ( ! /etc/init.d/postgresql status ) ; then
	/etc/init.d/postgresql start
fi

### Edit config if needed
if [ -f "/var/lib/pgsql/data/pg_hba.conf" ] ; then
	psql_config=/var/lib/pgsql/data/pg_hba.conf
	psql_auth="ident sameuser"
elif [ -f "/etc/postgresql/9.1/main/pg_hba.conf" ] ; then
	psql_config=/etc/postgresql/9.1/main/pg_hba.conf
	psql_auth="ident"
else
	echo Failed to find postgresql config file
	exit 1
fi

### Edit config if needed
if ( ! grep -q '^# QVD Settings' $psql_config )  ; then

	cat >$psql_config <<CONF
# database or username with that name.
#
# This file is read on server startup and when the postmaster receives
# a SIGHUP signal.  If you edit the file on a running system, you have
# to SIGHUP the postmaster for the changes to take effect.  You can use
# "pg_ctl reload" to do that.

# Put your actual configuration here
# ----------------------------------
#
# If you want to allow non-local connections, you need to add more
# "host" records. In that case you will also need to make PostgreSQL listen
# on a non-local interface via the listen_addresses configuration parameter,
# or via the -i or -h command line switches.
#



# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD

# QVD Settings - do not remove or change this line
host    qvd         qvd         ::1/128               md5
host    qvd         qvd         127.0.0.1/32          md5

# "local" is for Unix domain socket connections only
local   all         all                               $psql_auth
# IPv4 local connections:
host    all         all         127.0.0.1/32          $psql_auth
# IPv6 local connections:
host    all         all         ::1/128               $psql_auth

CONF

	/etc/init.d/postgresql restart
fi

# Create DB
if ( ! su - postgres -c "psql -l" | grep -E -q '^\s+qvd ' ) ; then
	echo -e "qvd\nqvd" | su -  postgres -c "createuser -e -S -D -R -E -P qvd"
	su -  postgres -c "createdb -E UTF8 -O qvd qvd"
	db_created=1
fi

if [ ! -f "$staging/$image" ] ; then
	mkdir -p "$staging"
	compressed="$staging/$image"

	wget "$url" -c -O "$compressed" || rm -f "$compressed"

	if [ ! -f "$staging/$image" ] ; then
		echo "Failed to download demo image, aborting"
		exit 1
	fi
fi


# Cgroups
mkdir -p /cgroup

if ( ! grep -q '/cgroup' /etc/fstab ) ; then
	cp -f /etc/fstab /etc/fstab.bak
	echo "cgroup               /cgroup              cgroup     defaults              0 0" >> /etc/fstab
fi

if ( ! grep -q '/cgroup' /proc/mounts ) ; then
	mount /cgroup
fi



if [ -f "/etc/SuSE-release" ] ; then
	#########################################################################
	# SuSE
	#########################################################################

	if [ ! -f /etc/sysconfig/network/ifcfg-qvdnet ] ; then
		if [ ! -f /etc/sysconfig/network/ifcfg-eth0 ] ; then
			echo "Can't open network configuration for eth0, aborting"
			exit 1
		fi

		. /etc/sysconfig/network/ifcfg-eth1

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
	#########################################################################
	# Debian
	#########################################################################

	if ( ! grep -q '### QVD START' /etc/network/interfaces ) ; then
		cat >>/etc/network/interfaces <<NETCONFIG
### QVD START - do not delete this line

auto qvdhost
iface qvdhost inet static
	pre-up tunctl -t qvdhost

auto qvdnet
iface qvdnet inet static
        bridge_ports qvdhost
        bridge_stp on
	address 192.168.81.1
	netmask 255.255.255.0
	broadcast 192.168.81.255

### QVD END
NETCONFIG

		/etc/init.d/networking restart
	fi
else
	echo "Can't configure network, unknown distribution"
fi


ip_address=`ip -o addr show qvdnet  | awk '/inet / { print $4}' | awk -F/ '{print $1}'`

qvd-deploy-db.pl --force 2>&1 | tee /tmp/sample-init.log || exit 1;



qvd-admin.pl config ssl key=/etc/qvd/server-private-key.pem cert=/etc/qvd/server-certificate.pem
qvd-admin.pl config set vm.network.ip.start=192.168.81.10
qvd-admin.pl config set vm.network.netmask=255.255.255.0
qvd-admin.pl config set vm.network.gateway=192.168.81.1

qvd-admin.pl config set vm.hypervisor=$hypervisor
qvd-admin.pl config set vm.lxc.unionfs.type=unionfs-fuse

qvd-admin.pl host add name=$host address=$ip_address

qvd-admin.pl osf  add name=sample
qvd-admin.pl di   add osf_id=1 path=$staging/$image
qvd-admin.pl user add login=qvd password=qvd
qvd-admin.pl vm   add name=sample_vm user=qvd osf=sample

