#
# Regular cron jobs for the qvd-wat package
#
0 4	* * *	root	[ -x /usr/bin/qvd-wat_maintenance ] && /usr/bin/qvd-wat_maintenance
