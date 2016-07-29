#!/bin/sh

cd $(dirname $0)

DEBUG="${DEBUG:+gdb --args}"

$DEBUG exec perl -Mlib::glob=*/lib QVD-Client/bin/qvd-gui-client.pl 
#client.use_ssl=0 client.host.name=myqvd.theqvd.com client.auto_connect.token=$1 client.auto_connect=1 client.auto_connect.vm_id=10000 
