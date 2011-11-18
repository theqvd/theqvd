#!/bin/sh

export PERL5OPT='-Mlib::glob=*/lib -Mlib::glob=/home/salva/g/perl/p5-*/{lib,blib/arch}'

for i in */bin; do PATH=$i:$PATH; done
export PATH

set -x

# clean directories:
rm -Rf /var/lib/qvd/storage/*fs/*

mkdir -p /var/lib/qvd/storage
mkdir -p /var/lib/qvd/storage/basefs/

mkdir -p /var/log/qvd
mkdir -p /etc/qvd

mkdir -p /tmp/qvd/run
mkdir -p /tmp/qvd/log
mkdir -p /tmp/qvd/tmp

qvd-deploy-db.pl --force >/tmp/sample-init.log 2>&1|| exit 1;

qvd-admin.pl config ssl key=sample-config/certs/server-key.pem cert=sample-config/certs/server-cert.pem
qvd-admin.pl config set vm.network.ip.start=10.1.0.30
qvd-admin.pl config set vm.hypervisor=lxc

qvd-admin.pl host add name=node1 address=127.0.0.1

qvd-admin.pl osf  add name=foo1
qvd-admin.pl di   add osf_id=1 path=/var/lib/qvd/storage/staging/container-good.tgz
qvd-admin.pl user add login=salva password=foo
qvd-admin.pl vm   add name=salva-1 user=salva osf=foo1

