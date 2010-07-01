/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * dev.c
 * Unix Pty Device routines
 *
 * History
 * 12/22/1999 V.1.0.0 Initial revision
 *
 */

/* Open / stat includes */
# include <sys/types.h>
# include <sys/stat.h>
# include <fcntl.h>

/* Errno */
# include <errno.h>

/* ptsname */
# include <stdlib.h>

/* Termio */
# ifdef USE_TERMIO
# include <termio.h>
# endif

/* Termios */
# include <termios.h>

/* STREAMS ioctl */
# include <sys/types.h>
# include <stropts.h>
# include <sys/stream.h>

/* Tiocsignal */
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
 * Streams message routines
 */

void parse_message(unsigned char type, char *buf, int size);
void parse_msgflush(int queues);

/*
 * Termio / Termios routines 
 */

void parse_ioctl(int ioctype, void *iocdata);
void parse_break(int *interval);
void parse_iocflush(int *queues);

void parse_termios(int mode, struct termios *tp);
int termios_to_portmodes(struct termios *tp);
void termios_to_portconfig(struct termios *tp, struct portconfig *pcp);
void portconfig_to_termios(struct portconfig *pcp, struct termios *tp);

# ifdef USE_TERMIO
void parse_termio(int mode, struct termio *tp);
int termio_to_portmodes(struct termio *tp);
void termio_to_portconfig(struct termio *tp, struct portconfig *pcp);
# endif

/*
 * Debug routines
 */

void print_msg(int type, unsigned char *buf, int size);
char *ioctl_name(int type, void *arg);

/*
 * Internal Variables
 */

char P_sname[NAMESIZE];

int Lasttype;
char Ctlbuf[16], Databuf[DEV_MAXIOSZ];

struct strpeek Message;

/*
 * STREAMS Pseudo-TTY Device Stuff
 */

# define PTY_DEVICE 		"/dev/ptmx"

int
dev_getaddr(char *dname)
{

    int fd;
    int mode;
    char *stty;
    int found;
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

    if ((fd = open(PTY_DEVICE, mode)) < 0) {
	sysmessage(MSG_ERR, "Can't open ptmx : %s\n", strerror(errno));
	return (E_FILEIO);
    }

# ifdef USE_FIONBIO
    mode = 1;
    if (ioctl(fd, FIONBIO, &mode) == -1) {
	sysmessage(MSG_ERR,
		   "Can't set non-block on maste: pty : %s\n",
		   strerror(errno));
	close(fd);
	return (E_FILEIO);
    }
# endif
    if (ioctl(fd, I_PUSH, "pckt") == -1) {
	sysmessage(MSG_ERR, "Can't push module: %s\n", strerror(errno));
	(void) close(fd);
	return (E_FILEIO);
    }

    found = FALSE;

    if ((stty = ptsname(fd)) != (char *) NULL) {
	if (unlockpt(fd) >= 0) {
	    if (link(stty, dname) == 0) {
		found = TRUE;
		sysmessage(MSG_NOTICE, "Using %s pseudo-tty \n", stty);
	    }
	    else {
		sysmessage(MSG_ERR, "Can't link dev : %s\n", strerror(errno));
	    }
	}
	else {
	    sysmessage(MSG_ERR, "Can't unlock ptmx : %s\n", strerror(errno));
	}
    }
    else {
	sysmessage(MSG_ERR, "Can't get ptmx ptsname\n");
    }

    if (found == FALSE) {
	(void) close(fd);
	return (E_FILEIO);
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
    struct strbuf *ctlmsg = &Message.ctlbuf;
    struct strbuf *datamsg = &Message.databuf;
    int flags = 0;

    sysmessage(MSG_NOTICE, "Opening %s pseudo-tty\n", P_sname);
    if ((sfd = open(P_sname, O_RDWR | O_NOCTTY)) == -1) {
	sysmessage(MSG_ERR, "Can't open slave device : %s\n",
		   strerror(errno));
	return (E_FILEIO);
    }

    if (ioctl(sfd, I_PUSH, "ptem") == -1) {
	sysmessage(MSG_ERR, "Can't ioctl tcgeta: %s\n", strerror(errno));
	(void) close(sfd);
	return (E_FILEIO);
    }

    if (ioctl(sfd, I_PUSH, "ldterm") == -1) {
	sysmessage(MSG_ERR, "Can't push ldterm : %s\n", strerror(errno));
	(void) close(sfd);
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

    ctlmsg->buf = Ctlbuf;
    ctlmsg->maxlen = 16;

    datamsg->buf = Databuf;
    datamsg->maxlen = Pty.iosize;

    (void) getmsg(P_mfd, ctlmsg, datamsg, &flags);

    if (Debug > 2) {
	sysmessage(MSG_DEBUG,
		   "  CFG: Ctl: %d bytes, Type: %d, Data: %d bytes, flags: %08X\n",
		   ctlmsg->len, Ctlbuf[ctlmsg->len > 0 ? ctlmsg->len - 1 : 0],
		   datamsg->len, flags);
    }

    return (E_NORMAL);
}

int
dev_closeslave(void)
{
    if (Pty.state == PTY_OPER && P_sfd != -1) {
	sysmessage(MSG_NOTICE, "Closing %s pseudo-tty \n", P_sname);
	(void) close(P_sfd);
	P_sfd = -1;
    }

    return (E_NORMAL);
}

int
dev_probe(void)
{
    int ctllen, datalen;
    int retc;
    int clocal = 0;
    int retmsg;

    int type;
    struct strbuf *ctlmsg = &Message.ctlbuf;
    struct strbuf *datamsg = &Message.databuf;

    struct iocblk *iocp;
    int ioctype;
    unsigned char *iocdata;

    struct termio *tio;
    struct termios *tios;

    ctlmsg->buf = Ctlbuf;
    ctlmsg->maxlen = 16;

    datamsg->buf = Databuf;
    datamsg->maxlen = Pty.iosize;

    Message.flags = 0;

    if ((retc = ioctl(P_mfd, I_PEEK, (void *) &Message)) == -1) {
	sysmessage(MSG_ERR,
		   "Can't get a message from master pty: %s\n",
		   strerror(errno));
	return (retc);
    }
    ctllen = ctlmsg->len;
    datalen = datamsg->len;
    if (ctllen == 4) {
	type = GET_VALUE_4(&ctlmsg->buf[0]);
    }
    else {
	sysmessage(MSG_ERR,
		   "PROBE: Undesired control message size: %d\n", ctllen);
	return;
    }

    if (Debug > 2) {
	sysmessage(MSG_DEBUG,
		   "PROBE: Ctl: %d bytes, Type: %d, Data: %d bytes, flags: %08X\n",
		   ctllen, type, datalen, Message.flags);
    }
    if (Debug > 2) {
	int i;
	char debbuf[128];
	char oct[8];
	sprintf(debbuf, "CTL: ");
	for (i = 0; i < ctllen && i < 8; i++) {
	    sprintf(oct, "%02X ", (unsigned char) ctlmsg->buf[i]);
	    strcat(debbuf, oct);
	}
	sysmessage(MSG_DEBUG, "%s\n", debbuf);

	sprintf(debbuf, "DAT: ");
	for (i = 0; i < datalen && i < 8; i++) {
	    sprintf(oct, "%02X ", (unsigned char) datamsg->buf[i]);
	    strcat(debbuf, oct);
	}
	sysmessage(MSG_DEBUG, "%s\n", debbuf);
    }

    if (datalen == -1) {
	sysmessage(MSG_ERR,
		   "PROBE: Undesired data message size: %d\n", datalen);
	return;
    }

    switch (type) {
    case M_DATA:
	if (datalen > 0) {
	    retmsg = PROBE_DATA;	/* M_DATA > 0 */
	}
	else {
	    retmsg = PROBE_EOF;	/* M_DATA == 0 */
	}
	break;
    case M_FLUSH:
	retmsg = PROBE_FLUSH;	/* M_FLUSH */
	break;
    case M_IOCTL:
	retmsg = PROBE_GENERIC;	/* Generic M_IOCTL */
	iocp = (struct iocblk *) &datamsg->buf[0];
	ioctype = iocp->ioc_cmd;
	iocdata = (unsigned char *) iocp + sizeof(struct iocblk);
	switch (ioctype) {
# ifdef USE_TERMIO
	case TCSETA:
	case TCSETAW:
	case TCSETAF:
	    tio = (struct termio *) iocdata;
	    if (tio->c_cflag & CLOCAL) {
		retmsg = PROBE_CLOCAL;	/* CLOCAL ON */
	    }
	    break;
# endif
	case TCSETS:
	case TCSETSW:
	case TCSETSF:
	    tios = (struct termios *) iocdata;
	    if (tios->c_cflag & CLOCAL) {
		retmsg = PROBE_CLOCAL;	/* CLOCAL ON */
	    }
	    break;
	default:
	    break;
	}

    }
    if (Debug > 1) {
	sysmessage(MSG_DEBUG, "PROBE: msg %d\n", retmsg);
    }
    return (retmsg);
}

int
dev_getdata(void)
{

    int ctllen, datalen;
    int retc;
    int flags = 0;
    struct strbuf *ctlmsg = &Message.ctlbuf;
    struct strbuf *datamsg = &Message.databuf;

    unsigned char type;

    ctlmsg->buf = Ctlbuf;
    ctlmsg->maxlen = 16;

    datamsg->buf = Databuf;
    datamsg->maxlen = Pty.iosize;

    if ((retc = getmsg(P_mfd, ctlmsg, datamsg, &flags)) == -1) {
	sysmessage(MSG_ERR,
		   "Can't get a message from master pty: %s\n",
		   strerror(errno));
# ifdef TSR_MEASURE
	devnreads++;
# endif
	return (retc);
    }
    ctllen = ctlmsg->len;
    datalen = datamsg->len;
    if (ctllen == -1) {
	type = Lasttype;
    }
    else if (ctllen == 4) {
	type = GET_VALUE_4(&ctlmsg->buf[0]);
	Lasttype = type;
    }
    else {
	sysmessage(MSG_ERR, "Undesired control message size: %d\n", ctllen);
	return (-1);
    }

    if (datalen == -1) {
	sysmessage(MSG_ERR,
		   " DATA: Undesired data message size: %d\n", datalen);
	return (-1);
    }

    if (Debug > 2) {
	sysmessage(MSG_DEBUG,
		   " DATA: Ctl: %d bytes, Type: %d, Data: %d bytes, flags: %08X\n",
		   ctllen, type, datalen, flags);
    }
    if (Debug > 2) {
	int i;
	char debbuf[128];
	char oct[8];
	sprintf(debbuf, "CTL: ");
	for (i = 0; i < ctllen && i < 8; i++) {
	    sprintf(oct, "%02X ", (unsigned char) ctlmsg->buf[i]);
	    strcat(debbuf, oct);
	}
	sysmessage(MSG_DEBUG, "%s\n", debbuf);

	sprintf(debbuf, "DAT: ");
	for (i = 0; i < datalen && i < 8; i++) {
	    sprintf(oct, "%02X ", (unsigned char) datamsg->buf[i]);
	    strcat(debbuf, oct);
	}
	sysmessage(MSG_DEBUG, "%s\n", debbuf);
    }

    parse_message(type, datamsg->buf, datalen);

    return (0);
}

int
dev_putdata(struct buffer *bp)
{

    struct pty *pty = &Pty;
    int ret;
    int size;
    int frombuf;


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
    struct strbuf *ctlmsg = &Message.ctlbuf;
    struct strbuf *datamsg = &Message.databuf;
    ctlmsg->len = 4;
    SET_VALUE_4(&ctlmsg->buf[0], M_SIG);

    datamsg->len = 4;
    SET_VALUE_4(&datamsg->buf[0], SIGINT);

    if (putmsg(P_mfd, ctlmsg, datamsg, RS_HIPRI) == -1) {
	sysmessage(MSG_ERR,
		   "Can't send SIGINT to slave device : %s\n",
		   strerror(errno));
    }
}

void
dev_hangup(void)
{
    struct strbuf *ctlmsg = &Message.ctlbuf;
    struct strbuf *datamsg = &Message.databuf;

    ctlmsg->len = 4;
    SET_VALUE_4(&ctlmsg->buf[0], M_SIG);

    datamsg->len = 4;
    SET_VALUE_4(&datamsg->buf[0], SIGHUP);

    if (putmsg(P_mfd, ctlmsg, datamsg, RS_HIPRI) == -1) {
	sysmessage(MSG_ERR,
		   "Can't send SIGHUP to slave device : %s\n",
		   strerror(errno));
    }
}

/*
 * Streams message routines
 */


void
parse_message(unsigned char type, char *buf, int size)
{
    char *msgt;
    int i;
    struct iocblk *iocp;
    struct buffer *bp = Pty.inbuff;


    print_msg(type, (unsigned char *) buf, size);

    if (size > 0) {
	switch (Pty.state) {
	case PTY_CLOSED:
	case PTY_OPERRONLY:
	    SET_EVENT(EV_UP, EV_UPOPEN, 0, 0);
	    break;
	}
    }
    else if (size == -1) {
	sysmessage(MSG_WARNING, "PARSE: Message data size == -1 \n");
	return;
    }

    switch (type) {
    case M_DATA:
# ifdef TSR_MEASURE
	devreads++;
	devrbytes += size;
# endif
	if (size == 0) {
	    SET_EVENT(EV_UP, EV_UPCLOSE, 0, 0);
	}
	else {
	    COPY_TO_BUFFER(bp, buf, size);
	    SET_EVENT(EV_UP, EV_UPDATA, 0, 0);
	}
	break;

    case M_IOCTL:
	iocp = (struct iocblk *) &buf[0];
	parse_ioctl(iocp->ioc_cmd, (void *) &buf[sizeof(struct iocblk)]);
	break;

    case M_FLUSH:
	parse_msgflush((int) buf[0]);
	break;

    default:
	sysmessage(MSG_DEBUG, "Unsupported stream message: %d\n", type);
	print_msg(type, (unsigned char *) buf, size);
	break;
    }
}

void
parse_msgflush(int queues)
{
    int mode;

    switch (queues) {
    case FLUSHR:
	mode = OPFLUSH_IN;
	break;
    case FLUSHW:
	mode = OPFLUSH_OUT;
	break;
    case FLUSHRW:
    default:
	mode = OPFLUSH_IO;
	break;
    }

    SET_EVENT(EV_UP, EV_UPFLUSH, (void *) &mode, sizeof(int));
}

/*
 * Termio / Termios routines 
 */

void
parse_ioctl(int ioctype, void *iocdata)
{

    switch (ioctype) {
# ifdef USE_TERMIO
    case TCSETA:
	parse_termio(ioctype, (struct termio *) iocdata);
	break;
    case TCSETAW:
	parse_termio(ioctype, (struct termio *) iocdata);
	break;
    case TCSETAF:
	parse_termio(ioctype, (struct termio *) iocdata);
	break;
# endif
    case TCSBRK:
	parse_break((int *) iocdata);
	break;
    case TCFLSH:
	parse_iocflush((int *) iocdata);
	break;
    case TCSETS:
	parse_termios(ioctype, (struct termios *) iocdata);
	break;
    case TCSETSW:
	parse_termios(ioctype, (struct termios *) iocdata);
	break;
    case TCSETSF:
	parse_termios(ioctype, (struct termios *) iocdata);
	break;
    default:
	sysmessage(MSG_DEBUG, "Unsupported ioctl: %c %d\n",
		   (ioctype & IOCTYPE) >> 8, ioctype & 0xFF);
    }

}


# ifdef USE_TERMIO
void
parse_termio(int mode, struct termio *tp)
{
    struct iocontrol *iocp = &Pty.iocontrol;
    struct portconfig *pcp = &iocp->io_portconfig;

    switch (mode) {
    case TCSETA:
	iocp->io_oper = OP_SETNOW;
	break;
    case TCSETAW:
	iocp->io_oper = OP_SETWAIT;
	break;
    case TCSETAF:
	iocp->io_oper = OP_SETFLUSH;
	break;
    }

    Pty.portmodes = termio_to_portmodes(tp);

    memset((void *) pcp, 0, sizeof(struct portconfig));

    termio_to_portconfig(tp, pcp);

    SET_EVENT(EV_UP, EV_UPCONTROL, 0, 0);
}
# endif

void
parse_termios(int mode, struct termios *tp)
{
    struct iocontrol *iocp = &Pty.iocontrol;
    struct portconfig *pcp = &iocp->io_portconfig;

    switch (mode) {
    case TCSETS:
	iocp->io_oper = OP_SETNOW;
	break;
    case TCSETSW:
	iocp->io_oper = OP_SETWAIT;
	break;
    case TCSETSF:
	iocp->io_oper = OP_SETFLUSH;
	break;
    }

    Pty.portmodes = termios_to_portmodes(tp);

    memset((void *) pcp, 0, sizeof(struct portconfig));

    termios_to_portconfig(tp, pcp);

    SET_EVENT(EV_UP, EV_UPCONTROL, 0, 0);
}

void
parse_break(int *interval)
{
    struct iocontrol *iocp = &Pty.iocontrol;

    iocp->io_oper = OP_SENDBREAK;
    iocp->io_arg = *interval;
    SET_EVENT(EV_UP, EV_UPCONTROL, 0, 0);
}

void
parse_iocflush(int *queues)
{
    struct iocontrol *iocp = &Pty.iocontrol;

    iocp->io_oper = OP_FLUSH;

    switch (*queues) {
    case TCIFLUSH:
	iocp->io_arg = OPFLUSH_IN;
	break;
    case TCOFLUSH:
	iocp->io_arg = OPFLUSH_OUT;
	break;
    case TCIOFLUSH:
	iocp->io_arg = OPFLUSH_IO;
	break;
    }
    SET_EVENT(EV_UP, EV_UPCONTROL, 0, 0);
}

# ifdef USE_TERMIO
int
termio_to_portmodes(struct termio *tp)
{
    int portmodes;

    if (tp->c_iflag & IGNBRK) {
	portmodes |= PORT_IGNBRK;
    }
    else {
	portmodes &= ~PORT_IGNBRK;
    }

    if (tp->c_iflag & BRKINT) {
	portmodes |= PORT_BRKINT;
    }
    else {
	portmodes &= ~PORT_BRKINT;
    }

    if (tp->c_iflag & IGNPAR) {
	portmodes |= PORT_IGNPAR;
    }
    else {
	portmodes &= ~PORT_IGNPAR;
    }

    if (tp->c_iflag & PARMRK) {
	portmodes |= PORT_PARMRK;
    }
    else {
	portmodes &= ~PORT_PARMRK;
    }

    if (tp->c_cflag & CLOCAL) {
	portmodes |= PORT_CLOCAL;
    }
    else {
	portmodes &= ~PORT_CLOCAL;
    }

    if (tp->c_cflag & HUPCL) {
	portmodes |= PORT_HUPCL;
    }
    else {
	portmodes &= ~PORT_HUPCL;
    }

    return (portmodes);
}

void
termio_to_portconfig(struct termio *tp, struct portconfig *pcp)
{

/* Speed */
    pcp->speed = baud_index_to_int(tp->c_cflag & CBAUD);

/* Datasize */

    switch (tp->c_cflag & CSIZE) {
    case CS5:
	pcp->datasize = 5;
	break;
    case CS6:
	pcp->datasize = 6;
	break;
    case CS7:
	pcp->datasize = 7;
	break;
    case CS8:
    default:
	pcp->datasize = 8;
	break;
    }

/* Stopsize */
    if (tp->c_cflag & CSTOPB) {
	pcp->stopsize = COM_SSIZE_TWO;
    }
    else {
	pcp->stopsize = COM_SSIZE_ONE;
    }

/* Parity */
    if (tp->c_cflag & PARENB) {
	if (tp->c_cflag & PARODD) {
	    pcp->parity = COM_PARITY_ODD;
	}
	else {
	    pcp->parity = COM_PARITY_EVEN;
	}
    }
    else {
	pcp->parity = COM_PARITY_NONE;
    }

/* Flow Control */
    if (tp->c_iflag & IXON) {
	pcp->flowc = COM_FLOW_SOFT;
    }
    else {			/* Warning, assumes hardware flow control */
	pcp->flowc = COM_FLOW_HARD;
    }

}
# endif

int
termios_to_portmodes(struct termios *tp)
{
    int portmodes;

    if (tp->c_iflag & IGNBRK) {
	portmodes |= PORT_IGNBRK;
    }
    else {
	portmodes &= ~PORT_IGNBRK;
    }

    if (tp->c_iflag & BRKINT) {
	portmodes |= PORT_BRKINT;
    }
    else {
	portmodes &= ~PORT_BRKINT;
    }

    if (tp->c_iflag & IGNPAR) {
	portmodes |= PORT_IGNPAR;
    }
    else {
	portmodes &= ~PORT_IGNPAR;
    }

    if (tp->c_iflag & PARMRK) {
	portmodes |= PORT_PARMRK;
    }
    else {
	portmodes &= ~PORT_PARMRK;
    }

    if (tp->c_cflag & CLOCAL) {
	portmodes |= PORT_CLOCAL;
    }
    else {
	portmodes &= ~PORT_CLOCAL;
    }

    if (tp->c_cflag & HUPCL) {
	portmodes |= PORT_HUPCL;
    }
    else {
	portmodes &= ~PORT_HUPCL;
    }

    return (portmodes);
}

void
termios_to_portconfig(struct termios *tp, struct portconfig *pcp)
{

/* Speed */
    speed_t speed = cfgetospeed(tp);
    pcp->speed = baud_index_to_int(speed);

    if (pcp->speed == -1) {
	sysmessage(MSG_DEBUG, "Unsupported speed: %d\n", speed);
	pcp->speed = 115200;
    }

/* Datasize */
    switch (tp->c_cflag & CSIZE) {
    case CS5:
	pcp->datasize = 5;
	break;
    case CS6:
	pcp->datasize = 6;
	break;
    case CS7:
	pcp->datasize = 7;
	break;
    case CS8:
    default:
	pcp->datasize = 8;
	break;
    }

/* Stopsize */
    if (tp->c_cflag & CSTOPB) {
	pcp->stopsize = COM_SSIZE_TWO;
    }
    else {
	pcp->stopsize = COM_SSIZE_ONE;
    }

/* Parity */
    if (tp->c_cflag & PARENB) {
	if (tp->c_cflag & PARODD) {
	    pcp->parity = COM_PARITY_ODD;
	}
	else {
	    pcp->parity = COM_PARITY_EVEN;
	}
    }
    else {
	pcp->parity = COM_PARITY_NONE;
    }

/* Flow Control */
    if (tp->c_iflag & IXON) {
	pcp->flowc = COM_FLOW_SOFT;
    }
    else {			/* Warning, assumes hardware flow control */
	pcp->flowc = COM_FLOW_HARD;
    }
}

/* Termios must be clean */

void
portconfig_to_termios(struct portconfig *pcp, struct termios *tp)
{

/* Speed */
    speed_t speed = int_to_baud_index(pcp->speed);
    if (speed == B0 && pcp->speed != 0) {
	sysmessage(MSG_DEBUG, "Unsupported speed: %d\n", pcp->speed);
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
 * Debug routines
 */

void
print_msg(int type, unsigned char *buf, int size)
{
    char *msgt;
    struct iocblk *iocp;
    int ioctype;
    unsigned char *iocdata;
    char dbuf[64];

    if (Debug > 2) {
	switch (type) {

	case M_IOCTL:
	    iocp = (struct iocblk *) &buf[0];
	    ioctype = iocp->ioc_cmd;
	    iocdata = (unsigned char *) iocp + sizeof(struct iocblk);
	    sprintf(dbuf, "M_IOCTL (Ioctl %c %d), %d bytes: %s\n",
		    (ioctype & IOCTYPE) >> 8, ioctype & 0xFF,
		    iocp->ioc_count, ioctl_name(ioctype, iocdata));
	    break;

	case M_DATA:
	    msgt = "M_DATA (Regular data): ";
	    sprintf(dbuf, "%s, %d bytes\n", msgt, size);
	    break;

	case M_FLUSH:
	    msgt = "M_FLUSH (flush your queues)";
	    sprintf(dbuf, "%s: queue %d", msgt, buf[0]);
	    break;

	case M_PROTO:
	    msgt = "M_PROTO (protocol control)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;

	case M_BREAK:
	    msgt = "M_BREAK (line break)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_PASSFP:
	    msgt = "M_PASSFP (pass file pointer)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_SIG:
	    msgt = "M_SIG (generate process signal)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_DELAY:
	    msgt = "M_DELAY (real-time xmit delay (1 param))";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_CTL:
	    msgt = "M_CTL (device-specific control message)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_SETOPTS:
	    msgt = "M_SETOPT S(set various stream head options)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_RSE:
	    msgt = "M_RSE (reserved for RSE use only)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_IOCACK:
	    msgt = "M_IOCACK (acknowledge ioctl)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_IOCNAK:
	    msgt = "M_IOCNAK (negative ioctl acknowledge)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_PCPROTO:
	    msgt = "M_PCPROTO (priority proto message)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_PCSIG:
	    msgt = "M_PCSIG (generate process signal)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_READ:
	    msgt = "M_READ (generate read notification)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_STOP:
	    msgt = "M_STOP (stop transmission immediately)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_START:
	    msgt = "M_START (restart transmission after stop)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_HANGUP:
	    msgt = "M_HANGUP (line disconnect)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_ERROR:
	    msgt = "M_ERROR (fatal error used to set u.u_error)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_COPYIN:
	    msgt = "M_COPYIN (request to copyin data)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_COPYOUT:
	    msgt = "M_COPYOUT (request to copyout data)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_IOCDATA:
	    msgt = "M_IOCDATA (response to M_COPYIN and M_COPYOUT)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_PCRSE:
	    msgt = "M_PCRSE (reserved for RSE use only)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_STOPI:
	    msgt = "M_STOPI (stop reception immediately)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_STARTI:
	    msgt = "M_STARTI (restart reception after stop)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_HPDATA:
	    msgt = "M_HPDATA (PSE-private: high priority data)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	case M_NOTIFY:
	    msgt = "M_NOTIFY (Reports result of read at stream head)";
	    sprintf(dbuf, "%s\n", msgt);
	    break;
	}
	sysmessage(MSG_DEBUG, "%s", dbuf);
    }
}

char ioctlbuf[32];

char *
ioctl_name(int type, void *arg)
{
    char *msgt;

    if (Debug > 2) {
	switch (type) {
# ifdef USE_TERMIO
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
# endif
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
