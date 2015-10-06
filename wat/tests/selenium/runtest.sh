#!/bin/bash

if [ -z "$1" ]
    then
        echo ""
        echo "[ERROR] Missing parameter for: ./runtest.sh [suite_file]"
        echo ""
        echo "Example:"
        echo "           ./runtest.sh suites/test1.suite"
        echo ""
        exit
fi

if [ ! -f $1 ] 
    then
        echo ""
        echo "[ERROR] Suite file not found"
        echo ""
	exit
fi

if [ -f .temp-test.pl ] 
    then
        rm .temp-test.pl 
fi

# Create a temporary perl script with built suite
touch .temp-test.pl

perl lib/buildtestsuite.pl $1 > .temp-test.pl

# Execute suite
perl .temp-test.pl

# Remove temporary file
rm .temp-test.pl
