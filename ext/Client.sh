#!/bin/sh

cd $(dirname $0)

DEBUG="${DEBUG:+gdb --args}"

$DEBUG exec perl -Mlib::glob=*/lib QVD-Client/bin/qvd-gui-client.pl
