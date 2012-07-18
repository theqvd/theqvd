#!/bin/sh

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


qvd-deploy-db.pl --force 2>&1 | tee /tmp/sample-init.log || exit 1;

qvd-admin.pl config ssl key=/etc/qvd/server-private-key.pem cert=/etc/qvd/server-certificate.pem
qvd-admin.pl config set vm.network.ip.start=10.1.0.30

qvd-admin.pl host add name=$host address=127.0.0.1

qvd-admin.pl osf  add name=sample
qvd-admin.pl di   add osf_id=1 path=/var/lib/qvd/storage/staging/demo-ubuntu-kde.img
qvd-admin.pl user add login=qvd password=qvd
qvd-admin.pl vm   add name=sample_vm user=qvd osf=sample

