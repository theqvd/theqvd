#!/bin/bash
# Script from running QVD GUI Client from the repository, using the
# SVN versions of the various components.

root=`pwd`
includes=""
perl="/usr/lib/qvd/bin/perl"

for dir in `find ext -maxdepth 1 -mindepth 1 -type d | grep -v '.svn'` ; do
	if [ -d "$dir/lib" ] ; then
		includes="$includes -I$root/$dir/lib"
	fi
done

#cd ext/QVD-Client && $perl $includes bin/qvd-gui-client.pl
echo
echo "cd ext/QVD-Client && $perl $includes bin/qvd-gui-client.pl"
echo

cd ext/QVD-Client

if [ "$1" == "gdb" ] ; then
	gdb --args $perl $includes bin/qvd-gui-client.pl
else
	$perl -w $includes bin/qvd-gui-client.pl
fi



#cd ext/QVD-Client && /usr/lib/qvd/bin/perl $includes bin/qvd-client.pl
