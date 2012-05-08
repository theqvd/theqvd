#!/bin/bash 

echo "LpwdeQND"  | ssh -o "StrictHostKeyChecking no" -o  "PasswordAuthentication yes" -o "UserKnownHostsFile /dev/null" root@qvd-test2 'ls -l' &> /dev/null
while [ $? -ne 0  ]
do
        sleep 10
        echo "LpwdeQND" | ssh -o "StrictHostKeyChecking no" -o  "PasswordAuthentication yes" -o "UserKnownHostsFile /dev/null" root@qvd-test2 'ls -l' &> /dev/null
done

echo login
exit 0

