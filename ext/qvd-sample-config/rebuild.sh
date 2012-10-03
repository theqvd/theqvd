#!/bin/bash
svnrev=`svnversion .`

if ( echo "$svnrev" | grep -q -E '[A-Z:]+' ) ; then
	echo SVN tree not fully committed or in conflict, please commit/update
	exit 1
fi


rpmbuild --define "_svn_rev $svnrev" -ba qvd-sample-config.spec

