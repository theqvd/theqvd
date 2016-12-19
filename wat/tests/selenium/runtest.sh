#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
    then
        echo ""
        echo "[ERROR] Missing parameter for: ./runtest.sh [suite_file] [selenium_server_address] [wat_url]"
        echo ""
        echo "Example:"
        echo "           ./runtest.sh suites/test1.suite 172.20.126.53 http://myurl.com/wat"
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
perl .temp-test.pl $2 $3

# Remove temporary file
rm .temp-test.pl
