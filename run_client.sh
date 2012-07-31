#!/bin/bash
# Script from running QVD GUI Client from the repository, using the
# SVN versions of the various components.

root=`pwd`

includes=""

for dir in `find ext -maxdepth 1 -mindepth 1 -type d | grep -v '.svn'` ; do
	if [ -d "$dir/lib" ] ; then
		includes="$includes -I$root/$dir/lib"
	fi
done

cd ext/QVD-Client && /usr/lib/qvd/bin/perl $includes bin/qvd-gui-client.pl
