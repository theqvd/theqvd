/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * dev.c
 * Unix Pty Device routines
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 * 12/17/1999 V.1.0.1
 *	Fixes: a copy in parse_message () now uses the correct data pointer
 *	
 */

/* Open / stat includes */
# include <sys/types.h>
# include <sys/stat.h>
# include <fcntl.h>
# include <unistd.h>
# include <stdlib.h>

/* Errno */
# include <stdio.h>
# include <errno.h>
# include <string.h>

/* Termio */
# ifdef USE_TERMIO
# include <termio.h>
# endif

/* Termios */
# ifdef USE_TERMIOS
# include <termios.h>
# endif

/* Get process group id of controlling pty */
# include <dirent.h>

/* Signalling slave (kill) */
# include <signal.h>

# define _TSR_DEV_

#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrio.h"
#include "inc/telnet.h"
#include "inc/dev.h"
#include "inc/misc.h"
#include "inc/port_speed.h"

#ifdef UNIX98
#include <pty.h>		/* for openpty and forkpty */
#include <utmp.h>
#endif

#ifdef TSR_MEASURE
#include "inc/tsrmeasure.h"
#endif

/*
 * Packet mode routines
 */

void parse_message(unsigned char type, char *buf, int size);
void parse_packet(int type);

/*
 * Termio / Termios routines 
 */

void portconfig_to_termios(struct portconfig *pcp, struct termios *tp);

/*
 * Argh => Get the process group id associated with slave pty
 */

int get_slave_controlling(dev_t device);

/*
 * Debug routines
 */

void print_msg(int type, unsigned char *buf, int size);
#if 0
char *ioctl_name(int type, void *unused);
#endif

/*
 * Internal Variables
 */

char P_sname[NAMESIZE];
dev_t P_devnumber;

char Databuf[DEV_MAXIOSZ];


# define NTRIES	10
# define PTYDELAY	600	/* one minute */

#ifndef UNIX98
# define CONTROL_PREFIX	"/dev/pty"
# define SLAVE_PREFIX	"/dev/tty"

const char *const letters = "pqrstuvwxyzabcde";
const char *const ports = "0123456789abcdef";
#endif

int
dev_getaddr(char *dname)
{

    int fd = -1;
#ifndef UNIX98
    int found;
    char ctty[16];
    int i, j;
    int tries;
#else
    int slave_fd;
#endif
    int mode;
    char stty[16];
    struct stat statb;


    if (lstat(dname, &statb) >= 0) {	/* File exists */
	if (S_ISLNK(statb.st_mode)) {
	    sysmessage(MSG_WARNING, "Removing old sym-link \"%s\".\n", dname);
	    unlink(dname);

	}
	else if (!S_ISCHR(statb.st_mode)) {
	    sysmessage(MSG_ERR, "%s already exists\n", dname);
	    return (E_PARMINVAL);
	}
    }
    else if (errno != ENOENT) {	/* generic stat error */
	sysmessage(MSG_ERR, "Can't lstat %s : %s\n", dname, strerror(errno));
	return (E_FILEIO);
    }

#ifndef UNIX98
    mode = O_RDWR;
# ifdef USE_POSIX_NONBLOCK
    mode |= O_NONBLOCK;
# elif defined USE_STD_NDELAY
    mode |= O_NDELAY;
# endif

/*
 * Warning: most PTY implementation puts master side as controlling terminal if
 * O_NOCTTY is not set !!!
 */

    mode |= O_NOCTTY;

    found = FALSE;
    for (tries = 0; tries < NTRIES; tries++) {
	for (i = 0; i < 16; i++) {
	    for (j = 0; j < 16; j++) {
		sprintf(ctty, "%s%c%c", CONTROL_PREFIX, letters[i], ports[j]);
		if ((fd = open(ctty, mode)) >= 0) {
		    sysmessage(MSG_NOTICE, "open %s pseudo-tty\n", ctty);
		    found = TRUE;
		    goto out;
		}
	    }
	}
	sysdelay(PTYDELAY);
    }
  out:
    if (found == FALSE) {
	sysmessage(MSG_ERR, "Can't get a free pseudo-tty :\n");
	(void) close(fd);
	return (E_FILEIO);
    }
#else
    if (openpty(&fd, &slave_fd, stty, NULL, NULL)) {
	sysmessage(MSG_ERR, "Can't get a free pseudo-tty :\n");
	return (E_FILEIO);
    }
#endif

# ifdef USE_FIONBIO
    mode = 1;
    if (ioctl(fd, FIONBIO, &mode) == -1) {
	sysmessage(MSG_ERR,
		   "Can't set non-block on master pty : %s\n",
		   strerror(errno));
	close(fd);
	return (E_FILEIO);
    }
# endif
    mode = 1;
    if (ioctl(fd, TIOCPKT, &mode) == -1) {
	sysmessage(MSG_ERR,
		   "Can't put master pty in packet mode: %s\n",
		   strerror(errno));
	close(fd);
	return (E_FILEIO);
    }

#ifndef UNIX98
    sprintf(stty, "%s%c%c", SLAVE_PREFIX, letters[i], ports[j]);
#endif
    if (lstat(stty, &statb) == -1) {	/* File does not exists */
	sysmessage(MSG_ERR, "Can't stat slave pty: %s\n", strerror(errno));
	close(fd);
	return (E_FILEIO);
    }

    P_devnumber = statb.st_rdev;

    if (symlink(stty, dname) == -1) {
	sysmessage(MSG_ERR, "Can't link dev : %s\n", strerror(errno));
	return (E_FILEIO);
    }
    else {
	sysmessage(MSG_NOTICE, "Using %s pseudo-tty\n", stty);
    }


    P_mfd = fd;
    strcpy(P_sname, stty);
    strcpy(P_devname, dname);

    return (E_NORMAL);

}

void
dev_free(void)
{
    (void) close(P_sfd);
    P_sfd = -1;
    return;
}


int
dev_init(int iosize, int devmodem, int closemode, struct buffer *ibp,
	 struct buffer *obp, struct comport *cp)
{
    Pty.portmodes = 0;
    if (devmodem == DEV_LOCAL) {
	Pty.portmodes = PORT_CLOCAL;
    }

    if (closemode == CLOSE_HANG) {
	Pty.portmodes |= PORT_HUPCL;
    }

    Pty.portmodes |= PORT_IGNBRK | PORT_IGNPAR;

    Pty.iosize = iosize;
    Pty.inbuff = ibp;
    Pty.outbuff = obp;
    Pty.comport = cp;

    return (E_NORMAL);

}

int
dev_config(void)
{
    int sfd;
    struct termios tios;
    struct portconfig *pcp = &Pty.comport->portconfig;
    int modes = Pty.portmodes;

    sysmessage(MSG_NOTICE, "Opening %s pseudo-tty\n", P_sname);
    if ((sfd = open(P_sname, O_RDWR | O_NOCTTY)) == -1) {
	sysmessage(MSG_ERR, "Can't open slave device : %s\n",
		   strerror(errno));
	return (E_FILEIO);
    }

    memset((void *) &tios, 0, sizeof(struct termios));

    portconfig_to_termios(pcp, &tios);

    tios.c_cflag |= CREAD;
    tios.c_lflag |= NOFLSH;

/* PTY modes */
    if (modes & PORT_HUPCL)
	tios.c_cflag |= HUPCL;

    if (modes & PORT_CLOCAL)
	tios.c_cflag |= CLOCAL;

    if (modes & PORT_IGNBRK)
	tios.c_iflag |= IGNBRK;

    if (modes & PORT_IGNPAR)
	tios.c_iflag |= IGNPAR;

    tios.c_iflag &= !IXOFF;	/* turn off ixon */

    tios.c_cc[VMIN] = 1;

    if (tcsetattr(sfd, TCSANOW, &tios) == -1) {
	sysmessage(MSG_ERR, "Can't set termios : %s\n", strerror(errno));
	(void) close(sfd);
	return (E_FILEIO);
    }

    P_sfd = sfd;

    return (E_NORMAL);
}

int
dev_closeslave(void)
{
    int mode;

    if (Pty.state == PTY_OPER && P_sfd != -1) {
	if (Debug > 1) {
	    sysmessage(MSG_DEBUG, "Closing %s pseudo-tty \n", P_sname);
	}
	sysmessage(MSG_NOTICE, "Closing %s pseudo-tty \n", P_sname);
	(void) close(P_sfd);
	P_sfd = -1;
	mode = 1;
	if (ioctl(P_mfd, TIOCPKT, &mode) == -1) {
	    sysmessage(MSG_ERR,
		       "Can't put master pty in packet mode: %s\n",
		       strerror(errno));
	    return (E_FILEIO);
	}
    }

    return (E_NORMAL);
}


unsigned char Holdbuf[4];
int Hold = FALSE;

int
dev_probe(void)
{
    int retc;
    int retmsg;
    unsigned char type;

    if ((retc = read(P_mfd, Holdbuf, 1)) == -1) {
	if (errno == EIO) {	/* PTY WAS CLOSED */
	    retc = 0;
	}
	else {
	    sysmessage(MSG_ERR,
		       "Can't read from master pty: %s\n", strerror(errno));
	    return (retc);
	}
    }

    if (Debug > 2) {
	sysmessage(MSG_DEBUG, "PROBE: %d bytes: %d", retc, Holdbuf[0]);
    }
    if (retc != 0) {
	type = Holdbuf[0];
	if (type == TIOCPKT_DATA) {
	    retmsg = PROBE_DATA;
	}
	else if (type & (TIOCPKT_FLUSHREAD | TIOCPKT_FLUSHWRITE)) {
	    retmsg = PROBE_FLUSH;
	}
	else {
	    retmsg = PROBE_GENERIC;
	}
	Hold = TRUE;
    }
    else {
	retmsg = PROBE_EOF;
    }
    if (Debug > 1) {
	sysmessage(MSG_DEBUG, "PROBE: msg %d\n", retmsg);
    }
    return (retmsg);
}

int
dev_getdata(void)
{
    int retc;
    int size;
    int mode;
    unsigned char type;

    size = Pty.iosize;

    if (Hold == TRUE) {
	Hold = FALSE;
	retc = 1;
	Databuf[0] = Holdbuf[0];
    }
    else {
	if ((retc = read(P_mfd, Databuf, size)) == -1) {
	    if (errno == EIO) {	/* PTY WAS CLOSED */
		retc = 0;
	    }
	    else {
		sysmessage(MSG_ERR,
			   "Can't read from master pty: %s\n",
			   strerror(errno));
# ifdef TSR_MEASURE
		devnreads++;
# endif
		return (retc);
	    }
	}
    }

    if (Debug > 2) {
	sysmessage(MSG_DEBUG, " DATA: %d bytes: ", retc);
    }
    if (Debug > 2) {
	int i;
	char debbuf[128];
	char oct[8];

	sprintf(debbuf, "DAT: ");
	for (i = 0; i < retc && i < 8; i++) {
	    sprintf(oct, "%02X ", (unsigned char) Databuf[i]);
	    strcat(debbuf, oct);
	}
	sysmessage(MSG_DEBUG, "%s\n", debbuf);
    }
/*
 * Kernel 2.2.x => Closing slave also disables packet mode.
 * Not all closes are detected, thus I restore packet mode at all events
 */

    mode = 1;
    if (ioctl(P_mfd, TIOCPKT, &mode) == -1) {
	sysmessage(MSG_ERR,
		   "Can't put master pty in packet mode: %s\n",
		   strerror(errno));
	return (-1);
    }

    type = Databuf[0];

    parse_message(type, Databuf, retc);

    return (0);
}

/*
 * Packet mode routines
 */

void
parse_message(unsigned char type, char *buf, int size)
{

    struct buffer *bp = Pty.inbuff;

    if (size != 0) {
	switch (Pty.state) {
	case PTY_CLOSED:
	case PTY_OPERRONLY:
	    SET_EVENT(EV_UP, EV_UPOPEN, 0, 0);
	    break;
	}
    }
    else {
	SET_EVENT(EV_UP, EV_UPCLOSE, 0, 0);
	return;
    }

# ifdef TSR_MEASURE
    devreads++;
    devrbytes += retc;
# endif
    if (type == TIOCPKT_DATA) {
	if (size == 0) {
	    SET_EVENT(EV_UP, EV_UPCLOSE, 0, 0);
	}
	else {
	    buf++;
	    size--;
/* V.1.0.1 fix: use buf instead of Dataptr */
	    COPY_TO_BUFFER(bp, buf, size);
	    SET_EVENT(EV_UP, EV_UPDATA, 0, 0);
	}
    }
    else {
	parse_packet((int) type);
    }
}

int
dev_putdata(struct buffer *bp)
{

    struct pty *pty = &Pty;
    int ret;
    int size;

/* XXXX TSR_MEASURES */
    while (bp->b_hold) {
	size = min(bp->b_hold, pty->iosize);
	if ((ret = write(P_mfd, bp->b_rem, size)) == -1) {
	    if (errno == EAGAIN) {
		ret = 0;
	    }
	    else {
		sysmessage(MSG_ERR,
			   "Can't write on master pty: %s\n",
			   strerror(errno));
	    }
# ifdef TSR_MEASURE
	    devnwrites++;
# endif
	    return (ret);
	}
# ifdef TSR_MEASURE
	devwrites++;
	devwbytes += ret;
# endif
	FORWARD_BUFFER(bp, ret);
    }
    if (bp->b_hold == 0) {
	RESET_BUFFER(bp);
    }
    return (0);
}

void
dev_interrupt(void)
{
    int procid;
    if ((procid = get_slave_controlling(P_devnumber)) > 0) {
	(void) kill((pid_t) - procid, SIGINT);
    }
}

void
dev_hangup(void)
{
    int procid;
    if ((procid = get_slave_controlling(P_devnumber)) > 0) {
	(void) kill((pid_t) - procid, SIGHUP);
    }
}

void
parse_packet(int type)
{
    int flushbits;
    int flushmode;
    flushbits = type & (TIOCPKT_FLUSHREAD | TIOCPKT_FLUSHWRITE);
    if (flushbits) {
	switch (flushbits) {
	case TIOCPKT_FLUSHREAD:
	    flushmode = OPFLUSH_IN;
	    break;
	case TIOCPKT_FLUSHWRITE:
	    flushmode = OPFLUSH_OUT;
	    break;
	default:
	    flushmode = OPFLUSH_IO;
	    break;
	}
	SET_EVENT(EV_UP, EV_UPFLUSH, (void *) &flushmode, sizeof(int));
    }
}

/*
 * Termio / Termios routines
 */

/* Termios must be clean */

void
portconfig_to_termios(struct portconfig *pcp, struct termios *tp)
{

/* Speed */
    speed_t speed;
    speed = int_to_baud_index(pcp->speed);
    if (speed == B0)
	speed = B115200;
    cfsetospeed(tp, (speed_t) speed);
    cfsetispeed(tp, (speed_t) B0);

/* Datasize */
    switch (pcp->datasize) {
    case 5:
	tp->c_cflag |= CS5;
	break;
    case 6:
	tp->c_cflag |= CS6;
	break;
    case 7:
	tp->c_cflag |= CS7;
	break;
    case 8:
	tp->c_cflag |= CS8;
	break;
    }

/* Stopsize */
    if (pcp->stopsize == COM_SSIZE_TWO) {
	tp->c_cflag |= CSTOPB;
    }				/* else one stop bit */

/* Parity */
    switch (pcp->parity) {
    case COM_PARITY_EVEN:
	tp->c_cflag |= PARENB;
	break;
    case COM_PARITY_ODD:
	tp->c_cflag |= PARENB | PARODD;
	break;
    case COM_PARITY_NONE:
    default:
	break;
    }

/* Flow Control */
    switch (pcp->flowc) {
    case COM_FLOW_SOFT:
	tp->c_iflag |= IXON;
	break;
    default:
	break;
    }

}

/*
 * Argh => Get the process group id associated with slave pty
 */

int
get_slave_controlling(dev_t device)
{
    DIR *dip;
    struct dirent *dep;
    int process;
    char procfile[128];
    char procbuf[512];
    int procfd;
    char dummybuf[512];
    int dummyint;
    int tty;
    gid_t tpgid;

    if ((dip = opendir("/proc")) == (DIR *) 0) {
	sysmessage(MSG_ERR, "Can't open /proc: %s", strerror(errno));
	exit(1);
    }

    while ((dep = readdir(dip)) != (struct dirent *) 0) {
	process = atoi(dep->d_name);
	if (process > 0) {
	    sprintf(procfile, "/proc/%d/stat", process);
	    if ((procfd = open(procfile, 0)) == -1) {
		sysmessage(MSG_ERR, "Can't open %s:%s\n",
			   procfile, strerror(errno));
		break;
	    }
	    if (read(procfd, procbuf, 512) <= 0) {
		sysmessage(MSG_ERR, "Can't read %s:%s",
			   procfile, strerror(errno));
		break;
	    }
	    (void) close(procfd);
	    if (sscanf(procbuf, "%d %s %c %d %d %d %d %u %s",
		       &dummyint, &dummybuf[0], (char *) &dummyint, &dummyint,
		       &dummyint, &dummyint, &tty, &tpgid,
		       &dummybuf[0]) != 0) {
		if ((dev_t) tty == device) {
		    break;
		}
	    }
	    tpgid = 0;		/* not found */
	}
    }

    (void) closedir(dip);
    return (tpgid);
}

/*
 * Debug routines
 */

char ioctlbuf[32];

#if 0
char *
ioctl_name(int type, void *unused)
{
    const char *msgt;

    if (Debug > 2) {
	switch (type) {
	case TCGETA:
	    msgt = "TCGETA";
	    break;
	case TCSETA:
	    msgt = "TCSETA";
	    break;
	case TCSETAW:
	    msgt = "TCSETAW";
	    break;
	case TCSETAF:
	    msgt = "TCSETAF";
	    break;
	case TCSBRK:
	    msgt = "TCSBRK";
	    break;
	case TCXONC:
	    msgt = "TCXONC";
	    break;
	case TCFLSH:
	    msgt = "TCFLSH";
	    break;
	case TCGETS:
	    msgt = "TCGETS";
	    break;
	case TCSETS:
	    msgt = "TCSETS";
	    break;
	case TCSETSW:
	    msgt = "TCSETSW";
	    break;
	case TCSETSF:
	    msgt = "TCSETSF";
	    break;
	default:
	    msgt = "UNKNOWN";
	    break;
	}
	sprintf(ioctlbuf, "%s", msgt);
	return (ioctlbuf);
    }
    else {
	return ((char *) 0);
    }
}
#endif
