#!/bin/sh

cd $(dirname $0)

DEBUG="${DEBUG:+gdb --args}"

$DEBUG exec /usr/lib/qvd/bin/perl -Mlib::glob=*/lib QVD-Client/bin/qvd-gui-client.pl
