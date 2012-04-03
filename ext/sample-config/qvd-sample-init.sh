#!/bin/sh

export PATH=/usr/lib/qvd/bin:$PATH
host=`hostname`

set -x

qvd-deploy-db.pl --force >/tmp/sample-init.log 2>&1|| exit 1;

qvd-admin.pl config ssl key=sample-config/certs/server-key.pem cert=sample-config/certs/server-cert.pem
qvd-admin.pl config set vm.network.ip.start=10.1.0.30

qvd-admin.pl host add name=$host address=127.0.0.1

qvd-admin.pl osf  add name=sample
qvd-admin.pl di   add osf_id=1 path=/var/lib/qvd/storage/staging/good.qcow2
qvd-admin.pl di   add osf_id=1 path=/var/lib/qvd/storage/staging/good.qcow2
qvd-admin.pl di   add osf_id=1 path=/var/lib/qvd/storage/staging/ptem.qcow2
qvd-admin.pl user add login=qvd password=qvd
qvd-admin.pl vm   add name=sample_vm user=qvd osf=sample

