#!/bin/bash
mydir=$(dirname $0)
export LD_LIBRARY_PATH=$mydir/../../c
echo $LD_LIBRARY_PATH
export MOZ_PLUGIN_PATH=$mydir/../build/bin/npqvd
echo $MOZ_PLUGIN_PATH
export QVD_DEBUG=1
export QVD_DEBUG_FILE=/tmp/mydebug

firefox $@