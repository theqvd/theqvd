#!/bin/sh
#
### BEGIN INIT INFO
# Provides:          qvd-hkd
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $null
# Should-Start:      $named
# Should-Stop:       $null
# Default-Start:     2 3 5
# Default-Stop:      0 1 6
# Short-Description: QVD Layer7 Router
# Description:       QVD L7R service
### END INIT INFO

PATH=/usr/lib/qvd/bin:/bin:/usr/bin

DAEMON=/usr/lib/qvd/bin/qvd-hkd
PERL=/usr/lib/qvd/bin/perl
NAME=qvd-hkd
DESC="QVD HKD"

PIDFILE=/var/run/qvd/$NAME.pid

test -x $DAEMON || exit 5

. /etc/rc.status
rc_reset

DIETIME=10              # Time to wait for the server to die, in seconds
                        # If this value is set too low you might not
                        # let some servers to die gracefully and
                        # 'restart' will not work

#STARTTIME=2             # Time to wait for the server to start, in seconds
                        # If this value is set each time the server is
                        # started (on start or restart) the script will
                        # stall to try to determine if it is running
                        # If it is not set and the server takes time
                        # to setup a pid file the log message might
                        # be a false positive (says it did not start
                        # when it actually did)

#DAEMONUSER=test   # Users to run the daemons as. If this value
                        # is set start-stop-daemon will chuid the server

CONFIG=/etc/qvd/node.conf
if [ ! -f "$CONFIG" ]; then
        echo "Configuration directory $CONFIG doesn't exist."
        echo "Create it with 'cp -R /usr/share/qvd/config/sample-node.conf $CONFIG' and edit node.conf."
        exit 0
fi

# Default options, these can be overriden by the information
# at /etc/default/$NAME
PORT=3000
# Include defaults if available
if [ -f /etc/sysconfig/$NAME ] ; then
    . /etc/sysconfig/$NAME
fi
DAEMON_OPTS=""

# Use this if you want the user to explicitly set 'RUN' in
# /etc/default/
#if [ "x$RUN" != "xyes" ] ; then
#    log_failure_msg "$NAME disabled, please adjust the configuration to your needs "
#    log_failure_msg "and then set RUN to 'yes' in /etc/default/$NAME to enable it."
#    exit 1
#fi

# Check that the user exists (if we set a user)
# Does the user exist?
if [ -n "$DAEMONUSER" ] ; then
    if getent passwd | grep -q "^$DAEMONUSER:"; then
        # Obtain the uid and gid
        DAEMONUID=`getent passwd |grep "^$DAEMONUSER:" | awk -F : '{print $3}'`
        DAEMONGID=`getent passwd |grep "^$DAEMONUSER:" | awk -F : '{print $4}'`
    else
        echo "The user $DAEMONUSER, required to run $NAME does not exist."
        exit 1
    fi
fi


set -e

running_pid() {
# Check if a given process pid's cmdline matches a given name
    pid=$1
    name=$2
    [ -z "$pid" ] && return 1
    [ ! -d /proc/$pid ] &&  return 1
    # The first entry in cmdline is perl, the second one the name of the script
    cmd=`cat /proc/$pid/cmdline | tr '\000' '' | cut -d '' -f 2`
    # Is this the expected server
    [ "$cmd" != "$name" ] &&  return 1
    return 0
}

running() {
# Check if the process is running looking at /proc
# (works for all users)

    # No pidfile, probably no daemon present
    [ ! -f "$PIDFILE" ] && return 1
    pid=`cat $PIDFILE`
    running_pid $pid $DAEMON || return 1
    return 0
}

kill_dnsmasq() {
	#Function added to kill dnsmasq 	
	pkill dnsmasq 
}


start_server() {
	# Check for dnsmasq and kill it
	kill_dnsmasq
# Start the process using the wrapper
        if [ -z "$DAEMONUSER" ] ; then
            start_daemon -p $PIDFILE $DAEMON $DAEMON_OPTS
            errcode=$?
        else
# if we are using a daemonuser then change the user id
            start-stop-daemon --start --quiet --pidfile $PIDFILE \
                        --chuid $DAEMONUSER \
                        --exec $DAEMON -- $DAEMON_OPTS
            errcode=$?
        fi
        return $errcode
}

stop_server() {
# Stop the process using the wrapper
	userarg=""

        if [ -z "$DAEMONUSER" ] ; then
            killproc -p $PIDFILE $DAEMON
            errcode=$?
        else
		start-stop-daemon --stop --quiet --pidfile $PIDFILE \
				  $userarg \
				  --exec $PERL
		errcode=$?
	fi
	
	kill_dnsmasq
        return $errcode
}

reload_server() {
    [ ! -f "$PIDFILE" ] && return 1
    pid=pidofproc $PIDFILE # This is the daemon's pid
    # Send a SIGHUP
    kill -1 $pid
    return $?
}

force_stop() {
# Force the process to die killing it manually
    [ ! -e "$PIDFILE" ] && return
    if running ; then
        kill -15 $pid
        # Is it really dead?
        sleep "$DIETIME"s
        if running ; then
            kill -9 $pid
            sleep "$DIETIME"s
            if running ; then
                echo "Cannot kill $NAME (pid=$pid)!"
                exit 1
            fi
        fi
    fi

    kill_dnsmasq
    rm -f $PIDFILE
}


case "$1" in
  start)
        echo "Starting $DESC " "$NAME"
        # Check if it's running first
        if running ;  then
            echo "apparently already running"
            exit 0
        fi
        if start_server ; then
            # NOTE: Some servers might die some time after they start,
            # this code will detect this issue if STARTTIME is set
            # to a reasonable value
            [ -n "$STARTTIME" ] && sleep $STARTTIME # Wait some time 
            if  running ;  then
                # It's ok, the server started and is running
                exit 0
            else
                # It is not running after we did start
                exit 1
            fi
        else
            # Either we could not start it
            exit 1
        fi
        ;;
  stop)
        echo "Stopping $DESC" "$NAME"
        if running ; then
            # Only stop the server if we see it running
            errcode=0
            stop_server || errcode=$?
            exit $errcode
        else
            # If it's not running don't do anything
            echo "apparently not running"
            exit 0
        fi
        ;;
  force-stop)
        # First try to stop gracefully the program
        $0 stop
        if running; then
            # If it's still running try to kill it more forcefully
            echo "Stopping (force) $DESC" "$NAME"
            errcode=0
            force_stop || errcode=$?
            exit $errcode
        fi
        ;;
  restart|force-reload)
        echo "Restarting $DESC" "$NAME"
        errcode=0
        stop_server || errcode=$?
        # Wait some sensible amount, some server need this
        [ -n "$DIETIME" ] && sleep $DIETIME
        start_server || errcode=$?
        [ -n "$STARTTIME" ] && sleep $STARTTIME
        running || errcode=$?
        exit $errcode
        ;;
  status)

        echo "Checking status of $DESC" "$NAME"
        if running ;  then
            echo "running"
            exit 0
        else
            echo "apparently not running"
            exit 1
        fi
        ;;
  # Use this if the daemon cannot reload
  reload)
        echo "Reloading $NAME daemon: not implemented, as the daemon"
        echo "cannot re-read the config file (use restart)."
        ;;
  # And this if it cann
  #reload)
          #
          # If the daemon can reload its config files on the fly
          # for example by sending it SIGHUP, do it here.
          #
          # If the daemon responds to changes in its config file
          # directly anyway, make this a do-nothing entry.
          #
          # log_daemon_msg "Reloading $DESC configuration files" "$NAME"
          # if running ; then
          #    reload_server
          #    if ! running ;  then
          # Process died after we tried to reload
          #       log_progress_msg "died on reload"
          #       log_end_msg 1
          #       exit 1
          #    fi
          # else
          #    log_progress_msg "server is not running"
          #    log_end_msg 1
          #    exit 1
          # fi
                                                                                    #;;

  *)
        echo "Usage: $0 {start|stop|force-stop|restart|force-reload|status}" >&2
        exit 1
        ;;
esac

exit 0

