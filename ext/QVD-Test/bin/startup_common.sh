#!/bin/bash

set -x

NODENAME=${NODE_NAME:-altar}
NODEADDRESS=${NODEADDRESS:-172.20.64.23}
DATABASE_HOST=${DATABASE_HOST:-localhost}
DATABASE_NAME=${DATABASE_NAME:-qvd}
DATABASE_USER=${DATABASE_USER:-qvd}
DATABASE_PASSWORD=${DATABASE_PASSWORD:-passw0rd}
IMAGE=${IMAGE:-/var/lib/qvd/storage/staging/ubuntu-10.04-i386.qcow2}

rm -f /etc/qvd/node.conf

# Install node. "Using force-yes can potentially destroy your system!" :)
apt-get update
apt-get install --yes --force-yes qvd-node qvd-admin
/etc/init.d/qvd-node stop
/etc/init.d/dnsmasq stop
sed -i -e 's/^ENABLED=1/ENABLED=0/' /etc/default/dnsmasq

mkdir -p /etc/qvd

cat <<NODECONF >/etc/qvd/node.conf
nodename: $NODENAME
database.host: $DATABASE_HOST
database.name: $DATABASE_NAME
database.user: $DATABASE_USER
database.password: $DATABASE_PASSWORD
wat.admin.login: admin
wat.admin.password: admin
l7r.as_user: root
hkd.as_user: root
log.level: DEBUG
vm.network.netmask: 18
vm.network.dhcp-range: 172.20.125.150,172.20.125.254
vm.network.dns_server: 172.26.0.21
vm.network.gateway: 172.20.68.1
NODECONF

if [ "$DATABASE_HOST" = localhost ]; then
    # Set up database user + schema
    apt-get install --yes --force-yes qvd-db  
    sudo -u postgres createuser -SDR $DATABASE_USER
    sudo -u postgres createdb -O $DATABASE_USER $DATABASE_NAME
    sudo -u postgres psql -c "ALTER ROLE $DATABASE_USER PASSWORD '$DATABASE_PASSWORD';"
    qvd-deploy-db.pl
    
    # Set up l7r certificates
    openssl req -new -x509 -nodes -sha1 -days 1 -newkey rsa:1024 -subj "/O=Qindel Group/OU=QVD Team/CN=hudson" > cert.pem
    qvd-admin.pl config ssl key=privkey.pem cert=cert.pem
    rm privkey.pem cert.pem
    
    # Set up a crash test dummy
    qvd-admin.pl user add login=qvd password=qvd
    qvd-admin.pl osi add name=osi-1 disk_image="$IMAGE"
    qvd-admin.pl vm add name=qvd-1 user=qvd osi=osi-1
fi

qvd-admin.pl host add name=$NODENAME address=$NODEADDRESS
