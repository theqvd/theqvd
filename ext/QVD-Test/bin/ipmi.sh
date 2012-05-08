#!/bin/sh 

set -x 

ipmi_user=root
ipmi_pass=LpwdeQND

ACTION=console

while getopts "a:h:u:p:" opt
do

	case $opt in
	 a)
	  case $OPTARG in
	   reinstall)
	    ACTION=reinstall
	  ;;
	   console)
            ACTION=console
	  ;; 
	   *) 
            echo "Usage ipmi.sh -a [reinstall|console] -h HOST  -u USER  -p PASSWORD"
	  ;;
	 esac
	 ;;

	 h)
	   host=$OPTARG
	 ;;
	 u)
	   ipmi_user=$OPTARG
   	 ;; 
	 p)
	   ipmi_pass=$OPTARG
	 ;;
	esac
done 

case $ACTION in 
 reinstall)
  	   ipmitool -I lanplus -H $host -U $ipmi_user -P $ipmi_pass chassis bootdev pxe
      	   ipmitool -I lanplus -H $host -U $ipmi_user -P $ipmi_pass chassis power reset
	   sleep 20 
	   ipmitool -I lanplus -H $host -U $ipmi_user -P $ipmi_pass sol activate
 ;;
 console) 
   ipmitool -I lanplus -H $host -U $ipmi_user -P $ipmi_pass sol activate
 ;; 
esac
