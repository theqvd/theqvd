/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * dev.c
 * Unix Pty Device routines
 *
 * History
 * 01/31/2000 V.1.0.0 Initial revision
 *
 */

/* Open / stat includes */
# include <sys/types.h>
# include <sys/stat.h>
# include <fcntl.h>

/* Errno */
# include <stdio.h>
# include <errno.h>
# include <string.h>

/* Termio */
# ifdef INCLUDE_TERMIO
# include <termio.h>
# endif

/* Termios */
# include <termios.h>

/* Pseudo tty */
# include <sys/spt.h>
# ifndef TIOCPKT_DATA
# define TIOCPKT_DATA	0x00
# endif

/* Signalling slave (kill) */
# include <sys/tty.h>
# include <sys/sysmacros.h>
# include <nlist.h>
# include <signal.h>

# define _TSR_DEV_

#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrio.h"
#include "inc/telnet.h"
#include "inc/dev.h"
#include "inc/port_speed.h"

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
 * Internal Variables
 */

char P_sname[NAMESIZE];
dev_t P_devnumber;

char Databuf[DEV_MAXIOSZ];


# define NTRIES	10
# define PTYDELAY	600	/* one minute */
# define MAXPTY	512

# define CONTROL_PREFIX	"/dev/ptyp"
# define SLAVE_PREFIX	"/dev/ttyp"

int
dev_getaddr(char *dname)
{

    int fd;
    int mode;
    char stty[16], ctty[16];
    int found;
    struct stat statb;
    int tries;
    int i;

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
	for (i = 0; i < MAXPTY; i++) {
	    sprintf(ctty, "%s%d", CONTROL_PREFIX, i);
	    if ((fd = open(ctty, mode)) >= 0) {
		sysmessage(MSG_NOTICE, "open %s pseudo-tty\n", ctty);
		found = TRUE;
		goto out;
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

    mode = 1;
    if (ioctl(fd, TIOCPKT, &mode) == -1) {
	sysmessage(MSG_ERR,
		   "Can't put master pty in packet mode: %s\n",
		   strerror(errno));
	close(fd);
	return (E_FILEIO);
    }

    sprintf(stty, "%s%d", SLAVE_PREFIX, i);
    if (lstat(stty, &statb) == -1) {	/* File exists */
	sysmessage(MSG_ERR, "Can't sstat slave pty : %s\n", strerror(errno));
	close(fd);
	return (E_FILEIO);
    }

    P_devnumber = statb.st_rdev;

    if (link(stty, dname) == -1) {
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

    int ret;

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
    int mode;

    if (Debug > 1) {
	sysmessage(MSG_DEBUG, "Opening %s pseudo-tty \n", P_sname);
    }
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
    if (modes & PORT_HUPCL) {
	tios.c_cflag |= HUPCL;
    }

    if (modes & PORT_CLOCAL) {
	tios.c_cflag |= CLOCAL;
    }

    if (modes & PORT_IGNBRK) {
	tios.c_iflag |= IGNBRK;
    }

    if (modes & PORT_IGNPAR) {
	tios.c_iflag |= IGNPAR;
    }

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
    if (Pty.state == PTY_OPER && P_sfd != -1) {
	if (Debug > 1) {
	    sysmessage(MSG_DEBUG, "Closing %s pseudo-tty \n", P_sname);
	}
	sysmessage(MSG_NOTICE, "Closing %s pseudo-tty \n", P_sname);
	(void) close(P_sfd);
	P_sfd = -1;
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
    int mode;
    unsigned char type;

    if ((retc = read(P_mfd, Holdbuf, 1)) == -1) {
	if (errno == EAGAIN) {
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

    struct buffer *bp = Pty.inbuff;
    int retc;
    int size;
    unsigned char type;

    size = Pty.iosize;

    if (Hold == TRUE) {
	Hold = FALSE;
	retc = 1;
	Databuf[0] = Holdbuf[0];
    }
    else {
	if ((retc = read(P_mfd, Databuf, size)) == -1) {
	    if (errno == EAGAIN) {
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
    int frombuf;


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
    speed_t speed = int_to_baud_index(pcp->speed);
    if (speed == B0 && pcp->speed != 0) {
	sysmessage(MSG_NOTICE, "Unsupported speed: %d\n", pcp->speed);
	speed = B115200;
    }
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

# define KERNEL_NAME "/unix"
# define MEM_NAME "/dev/kmem"
# define PTY_TABLE "spt_tty"

int
get_slave_controlling(dev_t device)
{
    struct nlist nl[2];
    struct tty dummy;
    short procid;
    static int fd = -1;
    static off_t offset = 0;

    if (offset == 0) {
	if ((fd = open(MEM_NAME, O_RDONLY)) == -1) {
	    sysmessage(MSG_WARNING, "Can't open %s : %s\n",
		       MEM_NAME, strerror(errno));
	    return (0);
	}

	nl[0].n_name = PTY_TABLE;
	nl[1].n_name = (char *) NULL;
	if (nlist(KERNEL_NAME, &nl[0]) == -1) {
	    sysmessage(MSG_WARNING, "Can't nlist %s : %s\n",
		       MEM_NAME, strerror(errno));
	    return (0);
	}
	offset = nl[0].n_value;
	if (offset != 0) {
	    offset += (off_t) (minor(device) * sizeof(dummy)) +
		(off_t) & dummy.t_pgrp - (off_t) & dummy;
	}
	else {
	    sysmessage(MSG_WARNING,
		       "Kernel symbol not found : %s\n", PTY_TABLE);
	    return (0);
	}
    }
    if (lseek(fd, offset, 0) == -1) {
	printf("%s %s: mem seek error\n");
	return (0);
    }

    if (read(fd, (char *) &procid, sizeof(short)) <= 0) {
	sysmessage(MSG_WARNING, "Can't open %s : %s\n",
		   MEM_NAME, strerror(errno));
	return (0);
    }
    return ((int) procid);
}
