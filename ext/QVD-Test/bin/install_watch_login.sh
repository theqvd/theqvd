#!/bin/bash 
set -x

HOST=$1

ssh -o "StrictHostKeyChecking no" -o  "PasswordAuthentication yes" -o "UserKnownHostsFile /dev/null" root@$HOST 'ls -l' &> /dev/null
while [ $? -ne 0  ]
do
        sleep 10
	ssh -o "StrictHostKeyChecking no" -o  "PasswordAuthentication yes" -o "UserKnownHostsFile /dev/null" root@$HOST 'ls -l' &> /dev/null
done

echo login
exit 0

