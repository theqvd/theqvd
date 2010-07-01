/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * system.c
 * Unix system-dependent routines
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 * Oct-27-2001 V.1.0.1
 *	Debug messages are only sent if debug is on 
 *	SIGCLD may occur when syslogd is too busy
 */

# include <sys/types.h>
# include <sys/stat.h>
# include <sys/param.h>
# include <sys/times.h>
# include <unistd.h>
# include <sys/time.h>
# include <syslog.h>
# include <errno.h>
# include <string.h>
# include <signal.h>
# include <stdlib.h>

# include <stdarg.h>
# include <stdio.h>

# define _TSR_SYSTEM_

#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrio.h"
#include "inc/sock.h"
#include "inc/dev.h"
/*
 * Internal Variables
 */

static int Start_time;
static int End_time;
static struct tms Timest;

/*
 * Internal Functions
 */

static void sysc_tout(int sig);
static void rot(int sig);
static void user_hangup(int sig);
static void sys_times(char *buf);

void
init_system(void)
{
    int sig;

    (void) setpgrp();		/* Detach from tty */
    (void) umask(0);		/* File creation mask */

    Start_time = times(&Timest);

    openlog(Pgname, LOG_PID | LOG_CONS, LOG_LOCAL2);

# ifdef TSR_MEASURE
    start_measure();
# endif
    (void) setbuf(stdout, NULL);	/* Real time messages */
    (void) setbuf(stderr, NULL);

    for (sig = 1; sig < NSIG; sig++) {
	switch (sig) {
	case SIGPIPE:
	case SIGCONT:		/* Close pty bug */
	case SIGHUP:
	    (void) signal(sig, SIG_IGN);
	    break;
	case SIGBUS:
	case SIGSEGV:
	    break;
	case SIGALRM:
	    (void) signal(sig, sysc_tout);
	    break;
	case SIGUSR1:
	    (void) signal(sig, user_hangup);
	    break;
	default:
	    (void) signal(sig, rot);
	    break;
	}
    }
}


void
sysdelay(int msecs)
{
    struct timeval tv;

    tv.tv_sec = msecs / 1000;
    tv.tv_usec = (msecs % 1000) * 1000;
    (void) select(0, 0, 0, 0, &tv);
}

void
sysmessage(int type, const char *const format, ...)
{
    char buf[512];
    va_list args;
    const char *pritext;
    int priority;
    static FILE *fp = NULL;

    if (LogFile && !fp) {
	fp = fopen(LogFile, "w");
	if (!fp) {
	    fprintf(stderr, "%s: Failed to open %s. Exiting.\n", Pgname,
		    LogFile);
	    exit(1);
	}
    }

    va_start(args, format);

    vsprintf(buf, format, args);

    if (Console || LogFile) {
	switch (type) {
	case MSG_DEBUG:
	    pritext = "DEBUG";
	    break;
	case MSG_INFO:
	    pritext = "INFO";
	    break;
	case MSG_NOTICE:
	    pritext = "NOTICE";
	    break;
	case MSG_WARNING:
	    pritext = "WARNING";
	    break;
	case MSG_ERR:
	default:
	    pritext = "ERR";
	    break;
	}
	if (Console)
	    fprintf(stderr, "%s: %s: %s", Idmsg, pritext, buf);
	else {
	    fprintf(fp, "%s: %s: %s", Idmsg, pritext, buf);
	    fflush(fp);
	    if (ftell(fp) > MAX_LOG_FILE_SIZE) {
		fclose(fp);
		fp = NULL;
	    }
	}

    }
    else {
	switch (type) {
	case MSG_DEBUG:
	    priority = LOG_DEBUG;
	    break;
	case MSG_INFO:
	    priority = LOG_INFO;
	    break;
	case MSG_NOTICE:
	    priority = LOG_NOTICE;
	    break;
	case MSG_WARNING:
	    priority = LOG_WARNING;
	    break;
	case MSG_ERR:
	default:
	    priority = LOG_ERR;
	    break;
	}
	if (priority != LOG_DEBUG || Debug > 0)
	    syslog(priority, "%s: %s", Idmsg, buf);
    }
    va_end(args);
}



void
mindelay(void)
{
    struct timeval tv;
    int usecs;

    usecs = 1000000 / HZ;	/* one CPU tick */

    tv.tv_sec = 0;
    tv.tv_usec = usecs;
    (void) select(0, 0, 0, 0, &tv);
}

void
doexit(int val)
{

    char timbuf[64];

# ifdef TSR_MEASURE
    cpu_measure();
# endif

    dev_unlink();
    sock_unlink();

    End_time = times(&Timest);

    sys_times(timbuf);

    if (val) {
	sysmessage(MSG_ERR, "Exiting with %d code (%s)\n", val, timbuf);
    }
    else {
	sysmessage(MSG_NOTICE, "Exiting with %d code (%s)\n", val, timbuf);
    }
    exit(val);
}

void
dev_unlink(void)
{
    close(P_sfd);
    P_sfd = -1;
    close(P_mfd);
    P_mfd = -1;
    unlink(P_devname);		/* remove old link */
    if (P_contrname[0])
	unlink(P_contrname);	/* remove old control socket */
}

static void
rot(int sig)
{

    char timbuf[64];

# ifdef TSR_MEASURE
    cpu_measure(1);
# endif

    dev_unlink();
    sock_unlink();

    End_time = times(&Timest);

    sys_times(timbuf);

    if (sig == SIGTERM) {
	sysmessage(MSG_INFO, "Normal shutdown (SIGTERM) (%s)\n", timbuf);
	exit(E_NORMAL);
    }
    else {
	sysmessage(MSG_ERR, "signal %d received (%s)\n\n", sig, timbuf);
	exit(E_SIGNAL);
    }
}

unsigned char *
mem_get(int size)
{
    return ((unsigned char *) malloc(size));
}

void
mem_free(void *ptr)
{
    free(ptr);
}

static void
sysc_tout(int sig)
{
    alarm(0);
    (void) signal(sig, sysc_tout);
}

static void
user_hangup(int sig)
{
    Hang_up = TRUE;
    (void) signal(sig, user_hangup);
}

static void
sys_times(char *buf)
{

    int usr, sys, tot, pru, prs, prt, secs;

    tot = End_time - Start_time;
    usr = (int) Timest.tms_utime;
    sys = (int) Timest.tms_stime;

    if (tot == 0)
	tot = 1;
    pru = usr * 100 / tot;
    prs = sys * 100 / tot;
    prt = pru + prs;

    secs = tot / HZ;

    sprintf(buf, "%6d, %3d%%, %3d%%, %3d%%", secs, pru, prs, prt);
}
