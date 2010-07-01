/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * misc.c
 * Miscelaneous system-dependent routines
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 * Oct-27-2001 V.1.0.1 Hangup messages now are of Warning type
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/time.h>
#ifndef HPUX
#include <sys/select.h>
#endif

#define _TSR_MISC_
#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrio.h"
#include "inc/telnet.h"
#include "inc/sock.h"
#include "inc/dev.h"
#include <string.h>
#include <sys/param.h>
#include <unistd.h>
#include <fcntl.h>

#ifdef TSR_MEASURE
#include <tsrmeasure.h>
#endif

#include <netinet/in.h>
#include "inc/control.h"

#ifndef MAX
#define MAX(a,b) (((a)>(b))?(a):(b))
#endif
#ifndef MIN
#define MIN(a,b) (((a)<(b))?(a):(b))
#endif

int
external_poll(int eventmask, int timeout)
{
    fd_set readmask, writemask, exceptmask;
    struct timeval tv;
    int ret, maxfd, msgtype, i, j;

    FD_ZERO(&readmask);
    FD_ZERO(&writemask);
    FD_ZERO(&exceptmask);

    maxfd = MAX(S_fd, P_mfd);
    if (Nvt.servertype == SRV_RTELNET) {
	for (i = 0; i < MAX_CONTROL_SOCKS && P_contr[i] != -1; i++) {
	    maxfd = MAX(maxfd, P_contr[i]);
	    FD_SET(P_contr[i], &readmask);
	}
	maxfd = MAX(maxfd, P_contr_listen);
	FD_SET(P_contr_listen, &readmask);
    }
    maxfd++;

    if (eventmask & (DEV_READ | DEV_PROBE))
	FD_SET(P_mfd, &readmask);
    if (eventmask & (DEV_EXCEPT))
	FD_SET(P_mfd, &exceptmask);
    if (eventmask & DEV_WRITE)
	FD_SET(P_mfd, &writemask);
    if (eventmask & (SOCK_READ | SOCK_PROBE))
	FD_SET(S_fd, &readmask);
    if (eventmask & SOCK_WRITE)
	FD_SET(S_fd, &writemask);

    tv.tv_sec = timeout / 1000;
    tv.tv_usec = (timeout % 1000) * 1000;

    ret = select(maxfd, &readmask, &writemask, &exceptmask, &tv);

    if (Nvt.servertype == SRV_RTELNET && FD_ISSET(P_contr_listen, &readmask)) {
	int flags;

	sysmessage(MSG_WARNING, "Receiving control connection from FD %d\n",
		   P_contr_listen);
	if (P_contr[MAX_CONTROL_SOCKS - 1] != -1) {
	    close(P_contr[0]);
	    FD_CLR(P_contr[0], &readmask);	/* just in case */
	    for (i = 0; i < (MAX_CONTROL_SOCKS - 1); i++)
		P_contr[i] = P_contr[i + 1];
	    P_contr[MAX_CONTROL_SOCKS - 1] = -1;
	}
	for (i = 0; P_contr[i] != -1; i++);

	if (fcntl(P_contr_listen, F_SETFL, O_NONBLOCK) == -1) {
	    sysmessage(MSG_ERR, "Can't set non-blocking IO.\n");
	    _exit(1);
	}

	P_contr[i] = accept(P_contr_listen, NULL, NULL);
	if (P_contr[i] == -1) {
	    sysmessage(MSG_ERR, "Error in accept on control socket.\n");
	}
	else {
	    if (((flags = fcntl(P_contr[i], F_GETFL)) == -1)
		|| fcntl(P_contr[i], F_SETFL, flags & O_NONBLOCK))
		sysmessage(MSG_ERR,
			   "Can't set non-blocking IO on control socket!\n");
	    else
		sysmessage(MSG_WARNING, "New control socket FD=%d\n",
			   P_contr[i]);
	}
    }
    if (FD_ISSET(P_mfd, &readmask) || FD_ISSET(P_mfd, &exceptmask)) {
	if (Debug > 2) {
	    if (FD_ISSET(P_mfd, &exceptmask))
		sysmessage(MSG_WARNING, "Pty exception\n");
	}
	if (eventmask & DEV_PROBE) {
	    if ((msgtype = dev_probe()) == -1) {
		sysmessage(MSG_WARNING, "Hang up PTY PROBE\n");
		Hang_up = TRUE;
		return -1;
	    }
	    imminent_event(msgtype);
	}
	else {
	    if (dev_getdata() == -1) {
		sysmessage(MSG_WARNING, "Hang up PTY GETDATA\n");
		Hang_up = TRUE;
		return (-1);
	    }
	}
    }
    else {
	if (eventmask & DEV_READ) {	/* pause, check slave status */
	    dev_closeslave();
	}
    }
    if (FD_ISSET(P_mfd, &writemask)) {
	SET_EVENT(EV_UP, EV_UPWROK, 0, 0);
    }
    if (FD_ISSET(S_fd, &readmask)) {
	if (tel_getdata() == -1) {
	    sysmessage(MSG_WARNING, "Hang up NVT GETDATA\n");
	    Hang_up = TRUE;
	    return -1;
	}
    }
    if (FD_ISSET(S_fd, &writemask)) {
	SET_EVENT(EV_RN, EV_RNWROK, 0, 0);
    }
    if (Nvt.servertype == SRV_RTELNET) {
	for (i = 0; i < MAX_CONTROL_SOCKS && P_contr[i] != -1; i++) {
	    if (FD_ISSET(P_contr[i], &readmask)) {
		s_control s;
		if (recv(P_contr[i], &s, sizeof(s), MSG_WAITALL) != sizeof(s)
		    || s.size != sizeof(s)) {
		    sysmessage(MSG_WARNING, "Closing control connection.\n");
		    close(P_contr[i]);
		    for (j = i; j < (MAX_CONTROL_SOCKS - 1); j++)
			P_contr[j] = P_contr[j + 1];
		    P_contr[MAX_CONTROL_SOCKS - 1] = -1;
		}
		else {
		    switch (s.oper) {
		    case eSET_SPEED:
			sync_comport_command(USR_COM_SET_BAUDRATE, s.val);
			s.val = Comport.portconfig.speed;
			break;
		    case eSEND_BREAK:
			if (s.val == 0) {
			    tv.tv_sec = 0;
			    tv.tv_usec = 250000;
			}
			else {
			    tv.tv_sec = s.val / 4;
			    tv.tv_usec = (s.val % 4) * 250000;
			}
			sync_comport_command(USR_COM_SET_CONTROL,
					     COM_BREAK_ON);
			select(0, NULL, NULL, NULL, &tv);
			sync_comport_command(USR_COM_SET_CONTROL,
					     COM_BREAK_OFF);
			break;
		    case eSET_CSIZE:
			sync_comport_command(USR_COM_SET_DATASIZE, s.val);
			s.val = Comport.portconfig.datasize;
			break;
		    case eSET_PARITY:
			sync_comport_command(USR_COM_SET_PARITY, s.val);
			s.val = Comport.portconfig.parity;
			break;
		    case eSET_STOPSIZE:
			sync_comport_command(USR_COM_SET_STOPSIZE, s.val);
			s.val = Comport.portconfig.stopsize;
			break;
		    case eSET_CONTROL:
			sync_comport_command(USR_COM_SET_CONTROL, s.val);
/* BUG we need to maintain com port state here as well because one field is
 * used for several things in the protocol
 *          s.val = Comport.portconfig.flowc; */
			break;
		    }		/* end switch */
		    if (send(P_contr[i], &s, sizeof(s), 0) != sizeof(s)) {
			sysmessage(MSG_WARNING,
				   "Lost control connection to client.\n");
			close(P_contr[i]);
			for (j = i; j < (MAX_CONTROL_SOCKS - 1); j++)
			    P_contr[j] = P_contr[j + 1];
			P_contr[MAX_CONTROL_SOCKS - 1] = -1;
			i--;
		    }
		}
	    }
	}
    }

# ifdef TSR_MEASURE
    ioscheds++;
# endif
    return (ret);
}
