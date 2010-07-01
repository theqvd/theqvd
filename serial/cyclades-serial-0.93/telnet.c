/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * telnet.c
 * Telnet Network Virtual Terminal routines
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 * History
 * 22/12/1999 V.1.0.1 Some debug enhancements
 *
 */

#include <sys/types.h>
#include <stdio.h>
#include <string.h>

#define _TSR_TELNET_

#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrio.h"
#include "inc/telnet.h"
#include "inc/sock.h"

/*
 * Telnet Protocol Internal Routines
 */

void do_option(int option);
void dont_option(int option);
void will_option(int option);
void wont_option(int option);
void send_option(int type, int option);
void handle_suboption(unsigned char *suboptp, int subsize);

/*
 * RFC 2217 Com Port Routines
 */

void comport_config(void);
void comport_default(void);
int sync_comport_command(int command, int arg);
int comport_command(int command, int arg);
void handle_com_port_command(unsigned char *buf);

/*
 * Debug Routines
 */

void print_all(void);
void print_option(unsigned char c);
void print_control(unsigned char c);

void print_linestate(int state);
void print_modemstate(int state);
void print_speed(int speed);
void print_datasize(int datasize);
void print_stopsize(int stopsize);
void print_parity(int parity);
void print_setcontrol(int control);
void print_purge(int purge);
void print_command(int cmdidx);

/*
 * Internal Variables
 */

struct comport Comport;

# define SUBOPT_MAXSIZE	64

unsigned char Suboptbuf[SUBOPT_MAXSIZE];
int Suboptsize;

unsigned char Comibuf[SOCK_MAXIOSZ];
unsigned char Comobuf[SOCK_MAXIOSZ];

/*
 *	Telnet Protocol Access Routines	
 */

int
tel_init(int netsize, struct buffer *ibp, struct buffer *obp)
{
    int retries = 0;

    Nvt.iosize = netsize;
    Nvt.inbuff = ibp;
    Nvt.outbuff = obp;
    Nvt.comport = &Comport;

    comport_default();		/* Initialize with default values */

    if (Nvt.servertype == SRV_SOCKET)
	return (E_NORMAL);

    sysdelay(SERVER_DELAY);	/* Wait telnet startup */

    SET_I_WANT_TO_SUPPORT(NVT_BINARY);
    SET_HE_MAY_SUPPORT(NVT_BINARY);

    SET_I_WANT_TO_SUPPORT(NVT_COM_PORT_OPTION);
    SEND_WILL(NVT_COM_PORT_OPTION);
    SET_I_SENT_IT(NVT_COM_PORT_OPTION);

    SET_HE_MAY_SUPPORT(NVT_SUPP_GO_AHEAD);
    SEND_DO(NVT_SUPP_GO_AHEAD);
    SET_HE_RECV_IT(NVT_SUPP_GO_AHEAD);

    tel_getdata();

    do {
	sysdelay(OPTION_DELAY);
	tel_getdata();
    } while (!I_DO_SUPPORT(NVT_COM_PORT_OPTION) && retries++ < 2);

    if (I_DO_SUPPORT(NVT_COM_PORT_OPTION)) {
	comport_config();
    }

    return (E_NORMAL);
}


/*
 * Telnet Protocol state
 */

int S_state = S_DATA;

int
tel_getdata(void)
{
    int i;
    int ret;

    struct buffer *bp = Nvt.inbuff;

    unsigned char c;

    if ((ret = sock_read(Comibuf, Nvt.iosize)) <= 0)
	return -1;
    if (Debug > 2) {
	sysmessage(MSG_DEBUG,
		   "Sock_read, %d bytes: %02X %02X %02X %02X %02X %02X %02X %02X\n",
		   ret, Comibuf[0], Comibuf[1], Comibuf[2], Comibuf[3],
		   Comibuf[4], Comibuf[5], Comibuf[6], Comibuf[7]);
    }

    if (Nvt.servertype == SRV_SOCKET) {
	COPY_TO_BUFFER(bp, Comibuf, ret);
	SET_EVENT(EV_RN, EV_RNDATA, 0, 0);
	return (0);
    }

    for (i = 0; i < ret; i++) {
	c = Comibuf[i];
	switch (S_state) {
	case S_DATA:
	    if (c == IAC) {
		S_state = S_IAC;
		print_control(c);
	    }
	    else {
		PUT_BUFFER(bp, c);
/* Event EV_RNDATA will be set at end */
	    }
	    break;
	case S_IAC:
	    switch (c) {
	    case DO:
		S_state = S_DO;
		print_control(c);
		break;
	    case DONT:
		S_state = S_DONT;
		print_control(c);
		break;
	    case WILL:
		S_state = S_WILL;
		print_control(c);
		break;
	    case WONT:
		S_state = S_WONT;
		print_control(c);
		break;
	    case SB:
		S_state = S_SB;
		print_control(c);
		Suboptsize = 0;
		break;
	    case IAC:
	    default:
		S_state = S_DATA;
		PUT_BUFFER(bp, c);
		break;
	    }
	    break;
	case S_DO:
	    print_option(c);
	    S_state = S_DATA;
	    do_option(c);
	    break;
	case S_DONT:
	    print_option(c);
	    S_state = S_DATA;
	    dont_option(c);
	    break;
	case S_WILL:
	    print_option(c);
	    S_state = S_DATA;
	    will_option(c);
	    break;
	case S_WONT:
	    print_option(c);
	    S_state = S_DATA;
	    wont_option(c);
	    break;
	case S_SB:
	    if (c == IAC) {
		S_state = S_SE;
		print_control(c);
	    }
	    else {
		if (Suboptsize > SUBOPT_MAXSIZE) {
		    sysmessage(MSG_WARNING, "Suboption too large\n");
		}
		else {
		    Suboptbuf[Suboptsize++] = c;
		}
	    }
	    break;
	case S_SE:
	    if (c == SE) {
		S_state = S_DATA;
		print_control(c);
		handle_suboption(Suboptbuf, Suboptsize);
		Suboptsize = 0;
	    }
	    else {
		S_state = S_DATA;
		sysmessage(MSG_WARNING, "Suboption not terminated: %d", c);
	    }
	    break;
	}
    }
    if (bp->b_hold) {
	SET_EVENT(EV_RN, EV_RNDATA, 0, 0);
    }

    print_all();
    return (0);
}

int
tel_putdata(struct buffer *bp)
{
    unsigned char c;
    int ret;
    int size;
    int frombuf;

    while (bp->b_hold) {
	if (Nvt.servertype == SRV_SOCKET) {
	    size = min(bp->b_hold, Nvt.iosize);
	    COPY_FROM_BUFFER(bp, Comobuf, size);
	    if ((ret = sock_write(Comobuf, size)) != size) {
		if (ret < 0) {
		    return (ret);
		}
		else {
		    frombuf = size - ret;
		    REWIND_BUFFER(bp, frombuf);
		}
		break;
	    }
	}
	else {			/* OH OH -> Handling IAC */
	    frombuf = min(bp->b_hold, Nvt.iosize);
	    size = 0;
	    while (frombuf--) {
		c = GET_BUFFER(bp);
		if (c == IAC) {
		    if (size == Nvt.iosize - 1) {
			/* avoid break IAC mapping */
			REWIND_BUFFER(bp, 1);
			frombuf++;
			break;
		    }
		    Comobuf[size++] = IAC;
		}
		Comobuf[size++] = c;
		if (size == Nvt.iosize) {
		    break;
		}
	    }
/* the following used to be #if 1 in the linux tree and not included for HPUX */
#ifdef __linux__
	    frombuf = 0;
	    while (size > 0) {
		if ((ret = sock_write(&Comobuf[frombuf], size)) == size) {
		    break;
		}
		if (Debug > 2) {
		    sysmessage(MSG_DEBUG, "Sock write: %d of %d\n", ret,
			       size);
		}
		if (ret < 0) {
		    return (ret);
		}
		frombuf += ret;
		size -= ret;
	    }
#else
	    if ((ret = sock_write(Comobuf, size)) != size) {
		if (Debug > 2) {
		    sysmessage(MSG_DEBUG, "Sock write: %d\n", ret);
		}
		if (ret < 0) {
		    return (ret);
		}
		else {
		    frombuf = 0;
		    while (size-- > ret) {
			if ((c = Comobuf[size - 1])
			    == IAC) {
			    continue;
			}
			frombuf++;
		    }
		}
		if (Debug > 2) {
		    sysmessage(MSG_DEBUG, "Buffer rewind %d\n", frombuf);
		}
		REWIND_BUFFER(bp, frombuf);
		break;
	    }
#endif
	}

    }
    if (bp->b_hold == 0) {
	RESET_BUFFER(bp);
    }
    return (0);
}

int
tel_putcmd(int command, int arg)
{
    return (comport_command(command, arg));
}

void
tel_free(void)
{
    int opt;
    /* Set Telnet protocol in a initial state */

    S_state = S_DATA;
    Suboptsize = 0;

    for (opt = 0; opt < NVT_NUMOPTS; opt++) {
	CLR_I_WANT_TO_SUPPORT(opt);
    }

    (void) sock_unlink();
}

/*
 * Telnet Protocol Internal Routines
 */

void
do_option(int opt)
{
    if (I_WANT_TO_SUPPORT(opt)) {
	SET_I_DO_SUPPORT(opt);
	if (!I_SENT_IT(opt)) {
	    SEND_WILL(opt);
	    SET_I_SENT_IT(opt);
	}
    }
    else {
	SEND_WONT(opt);
    }
}

void
dont_option(int opt)
{
    CLR_I_DO_SUPPORT(opt);
}

void
will_option(int opt)
{
    if (HE_MAY_SUPPORT(opt)) {
	SET_HE_DOES_SUPPORT(opt);
	if (!HE_RECV_IT(opt)) {
	    SEND_DO(opt);
	    SET_HE_RECV_IT(opt);
	}
    }
    else {
	SEND_DONT(opt);
    }
}

void
wont_option(int opt)
{
    CLR_HE_DOES_SUPPORT(opt);
}


void
send_option(int type, int opt)
{
    int ret;
    int size;
    unsigned char *obp;

    obp = &Comobuf[0];

    *obp++ = IAC;
    *obp++ = type;
    *obp++ = opt;

    size = 3;
    obp = &Comobuf[0];

    if (Debug > 2) {
	sysmessage(MSG_DEBUG, "Sock_write, 3 bytes: %02X %02X %02X\n",
		   Comobuf[0], Comobuf[1], Comobuf[2]);
    }

    while (size) {
	if ((ret = sock_write(obp, size)) == -1) {
	    SET_EVENT(EV_RN, EV_RNHANG, 0, 0);
	    break;
	}
	else if (ret != size) {
	    sysmessage(MSG_NOTICE,
		       "Partial write in send_option: %d/%d\n", ret, size);
	    sysdelay(ROOM_DELAY);	/* Wait for room */
	}
	size -= ret;
	obp += ret;
    }
}

void
handle_suboption(unsigned char *suboptp, int subsize)
{
    unsigned char subopt = *suboptp;

    print_option(subopt);

    switch (subopt) {
    case NVT_COM_PORT_OPTION:
	handle_com_port_command(++suboptp);
	subsize--;
	break;
    default:
	sysmessage(MSG_WARNING, "suboption not supported: %d\n", subopt);
	break;
    }
}


/*
 * RFC 2217 Com Port Routines
 */

void
comport_config(void)
{
    int mask;

    Comport.support = TRUE;

    /* Get configuration values */
    sync_comport_command(USR_COM_SET_BAUDRATE, COM_BAUD_REQ);
    sync_comport_command(USR_COM_SET_DATASIZE, COM_DSIZE_REQ);
    sync_comport_command(USR_COM_SET_PARITY, COM_PARITY_REQ);
    sync_comport_command(USR_COM_SET_STOPSIZE, COM_SSIZE_REQ);
    sync_comport_command(USR_COM_SET_CONTROL, COM_FLOW_REQ);

    /* Set port events mask */
    mask = MODEM_DCD;
    sync_comport_command(USR_COM_SET_MODEMSTATE_MASK, mask);
    mask = LINE_BREAK_ERROR | LINE_PARITY_ERROR;
    sync_comport_command(USR_COM_SET_LINESTATE_MASK, mask);

    sysdelay(NOTIFY_DELAY);	/* Wait for notifications */

    tel_getdata();

}

void
comport_default(void)
{

    Comport.support = FALSE;

/*96008N1, No flow , aLL signals ON, noerrors  */

    Comport.portconfig.speed = 9600;
    Comport.portconfig.datasize = 8;
    Comport.portconfig.stopsize = COM_SSIZE_ONE;
    Comport.portconfig.parity = COM_PARITY_NONE;
    Comport.portconfig.flowc = COM_FLOW_NONE;

    Comport.portstate.modemstate = MODEM_DCD | MODEM_DSR | MODEM_CTS;
    Comport.portstate.linestate = 0;
}

int
sync_comport_command(int command, int arg)
{

    if (comport_command(command, arg) == -1)
	return -1;

    SET_CMD_ACTIVE(command);

    do {
	sysdelay(COMPORT_DELAY);
	tel_getdata();
    } while (IS_CMD_ACTIVE(command));
    return 0;
}

int
comport_command(int command, int arg)
{
    int size;
    int ret;
    unsigned char *obp;

    if (Nvt.comport->support == FALSE) {
	CLR_CMD_ACTIVE(command);	/* Synchronous operation */
	SET_EVENT(EV_RN, EV_RNCMDOK, 0, 0);
	return (0);
    }

    obp = &Comobuf[0];

    *obp++ = IAC;
    *obp++ = SB;
    *obp++ = NVT_COM_PORT_OPTION;
    *obp++ = (unsigned char) command;
    switch (command) {
    case USR_COM_SET_BAUDRATE:
	SET_VALUE_4(obp, arg);
	obp += 4;
	break;
    default:
	SET_VALUE_1(obp, arg);
	obp += 1;
	break;
    }
    *obp++ = IAC;
    *obp++ = SE;

    size = (int) (obp - &Comobuf[0]);
    obp = &Comobuf[0];

    if (Debug > 2) {
	sysmessage(MSG_DEBUG,
		   "Sock_write, %d bytes: %02X %02X %02X %02X %02X %02X %02X %02X\n",
		   size, Comobuf[0], Comobuf[1], Comobuf[2], Comobuf[3],
		   Comobuf[4], Comobuf[5], Comobuf[6], Comobuf[7]);
    }
    while (size) {
	if ((ret = sock_write(obp, size)) == -1) {
	    SET_EVENT(EV_RN, EV_RNHANG, 0, 0);
	    return (-1);
	}
	else if (ret != size) {
	    sysmessage(MSG_NOTICE,
		       "Partial write in send_comport: %d/%d\n", ret, size);
	    sysdelay(ROOM_DELAY);	/* Wait for room */
	}
	size -= ret;
	obp += ret;
    }
    return (0);
}

void
handle_com_port_command(unsigned char *buf)
{
    unsigned char cmd = *buf++;
    int cmdarg;
    int cmdidx;
    int is_notify = 0;
    int notify;

    cmdidx = (int) cmd;

    if (cmd >= RAS_COM_START && cmd <= RAS_COM_END) {
	cmdidx -= RAS_COM_START;
    }

    print_command(cmdidx);

    switch (cmd) {
    case RAS_COM_SIGNATURE:
    case RAS_COM_FLOWCONTROL_SUSPEND:
    case RAS_COM_FLOWCONTROL_RESUME:
	break;
    case RAS_COM_SET_BAUDRATE:
	Comport.portconfig.speed = GET_VALUE_4(buf);
	print_speed(Comport.portconfig.speed);
	break;
    case RAS_COM_SET_DATASIZE:
	Comport.portconfig.datasize = GET_VALUE_1(buf);
	print_datasize(Comport.portconfig.datasize);
	break;
    case RAS_COM_SET_PARITY:
	Comport.portconfig.parity = GET_VALUE_1(buf);
	print_parity(Comport.portconfig.parity);
	break;

    case RAS_COM_SET_STOPSIZE:
	Comport.portconfig.stopsize = GET_VALUE_1(buf);
	print_stopsize(Comport.portconfig.stopsize);
	break;

    case RAS_COM_SET_CONTROL:
	cmdarg = GET_VALUE_1(buf);
	print_setcontrol(cmdarg);
	switch (cmdarg) {
	case COM_OFLOW_NONE:
	case COM_OFLOW_SOFT:
	case COM_OFLOW_HARD:
	    Comport.portconfig.flowc = cmdarg;
	    break;
	default:
	    break;
	}

	break;

    case RAS_COM_NOTIFY_LINESTATE:
	is_notify = 1;
	cmdarg = GET_VALUE_1(buf);
	print_linestate(cmdarg);
	Comport.portstate.linestate = cmdarg;
	if (cmdarg & LINE_BREAK_ERROR) {
	    notify = NT_BREAK;
	    SET_EVENT(EV_RN, EV_RNNTFY, &notify, sizeof(int));
	}
	if (cmdarg & LINE_PARITY_ERROR) {
	    notify = NT_PARITY;
	    SET_EVENT(EV_RN, EV_RNNTFY, &notify, sizeof(int));
	}
	break;

    case RAS_COM_SET_LINESTATE_MASK:
	cmdarg = GET_VALUE_1(buf);
	print_linestate(cmdarg);
	break;

    case RAS_COM_NOTIFY_MODEMSTATE:
	is_notify = 1;
	cmdarg = GET_VALUE_1(buf);
	if ((cmdarg ^ Comport.portstate.modemstate) & MODEM_DCD) {
	    if (Comport.portstate.modemstate & MODEM_DCD) {
		notify = NT_DCDOFF;
		SET_EVENT(EV_RN, EV_RNNTFY, &notify, sizeof(int));
	    }
	    else {
		notify = NT_DCDON;
		SET_EVENT(EV_RN, EV_RNNTFY, &notify, sizeof(int));
	    }
	}
	Comport.portstate.modemstate = cmdarg;
	print_modemstate(cmdarg);
	break;

    case RAS_COM_SET_MODEMSTATE_MASK:
	cmdarg = GET_VALUE_1(buf);
	print_modemstate(cmdarg);
	break;
    case RAS_COM_PURGE_DATA:
	cmdarg = GET_VALUE_1(buf);
	print_purge(cmdarg);
	break;
    default:
	sysmessage(MSG_NOTICE, "Unnimplemented command: %d\n", cmd);
	break;
    }

    if (!is_notify) {
	if (IS_CMD_ACTIVE(cmdidx)) {
	    CLR_CMD_ACTIVE(cmdidx);	/* Synchronous operation */
	}
	else {
	    SET_EVENT(EV_RN, EV_RNCMDOK, 0, 0);
	}
    }
    print_all();
}

/*
 * Debug Routines
 */

char Debugbuf[512];

void
print_all(void)
{
    if (Debugbuf[0] != 0) {
	sysmessage(MSG_DEBUG, "%s\n", Debugbuf);
    }
    Debugbuf[0] = 0;
}

/*
 * Telnet Protocol Debug
 */

void
print_control(unsigned char c)
{
    if (Debug > 2) {
	char msgbuf[32];

	switch (c) {
	case DO:
	    sprintf(msgbuf, "DO ");
	    break;
	case DONT:
	    sprintf(msgbuf, "DONT ");
	    break;
	case WILL:
	    sprintf(msgbuf, "WILL ");
	    break;
	case WONT:
	    sprintf(msgbuf, "WONT ");
	    break;
	case IAC:
	    sprintf(msgbuf, "IAC ");
	    break;
	case SE:
	    sprintf(msgbuf, "SE ");
	    break;
	case SB:
	    sprintf(msgbuf, "SB ");
	    break;
	default:
	    sprintf(msgbuf, "Ctl %02X ", c);
	    break;
	}
	strcat(Debugbuf, msgbuf);
    }
}


void
print_option(unsigned char c)
{
    if (Debug > 2) {
	char msgbuf[32];
	switch (c) {
	case NVT_BINARY:
	    sprintf(msgbuf, "BINARY ");
	    break;
	case NVT_ECHO:
	    sprintf(msgbuf, "ECHO ");
	    break;
	case NVT_SUPP_GO_AHEAD:
	    sprintf(msgbuf, "SUPPRESS GO AHEAD ");
	    break;
	case NVT_COM_PORT_OPTION:
	    sprintf(msgbuf, "COMM PORT OPTION ");
	    break;
	default:
	    sprintf(msgbuf, "Cmd %3d ", c);
	    break;
	}
	strcat(Debugbuf, msgbuf);
    }
}

/*
 * Com Port Option Debug
 */

const char *const Command_names[] = {
    "COM_SIGNATURE",
    "COM_SET_BAUDRATE",
    "COM_SET_DATASIZE",
    "COM_SET_PARITY",
    "COM_SET_STOPSIZE",
    "COM_SET_CONTROL",
    "COM_NOTIFY_LINESTATE",
    "COM_NOTIFY_MODEMSTATE",
    "COM_FLOWCONTROL_SUSPEND",
    "COM_FLOWCONTROL_RESUME",
    "COM_SET_LINESTATE_MASK",
    "COM_SET_MODEMSTATE_MASK",
    "COM_PURGE_DATA"
};

const char *const Parity_names[] = {
    "PARITY_REQ",
    "PARITY_NONE",
    "PARITY_ODD",
    "PARITY_EVEN",
    "PARITY_MARK",
    "PARITY_SPACE",
};

const char *const Stop_names[] = {
    "SSIZE_REQ",
    "SSIZE_ONE",
    "SSIZE_TWO",
    "SSIZE_1DOT5",
};

const char *const Control_names[] = {
    "OFLOW_REQ",
    "OFLOW_NONE",
    "OFLOW_SOFT",
    "OFLOW_HARD",
    "BREAK_REQ",
    "BREAK_ON",
    "BREAK_OFF",
    "DTR_REQ",
    "DTR_ON",
    "DTR_OFF",
    "RTS_REQ",
    "RTS_ON",
    "RTS_OFF",
    "IFLOW_REQ",
    "IFLOW_NONE",
    "IFLOW_SOFT",
    "IFLOW_HARD",
    "DCD_FLOW",
    "DTR_FLOW",
    "DSR_FLOW",
};

const char *const Purge_names[] = {
    "What??",
    "COM_PURGE_RECV",
    "COM_PURGE_XMIT",
    "COM_PURGE_BOTH",
};


void
print_linestate(int state)
{
    if (Debug > 2) {
	char linestates[256];
	linestates[0] = 0;

	if (state & LINE_TIMEOUT_ERROR) {
	    strcat(linestates, "LINE_TIMEOUT_ERROR ");
	}
	if (state & LINE_SHIFTREG_EMPTY) {
	    strcat(linestates, "LINE_SHIFTREG_EMPTY ");
	}
	if (state & LINE_HOLDREG_EMPTY) {
	    strcat(linestates, "LINE_HOLDREG_EMPTY ");
	}
	if (state & LINE_BREAK_ERROR) {
	    strcat(linestates, "LINE_BREAK_ERROR ");
	}
	if (state & LINE_FRAME_ERROR) {
	    strcat(linestates, "LINE_FRAME_ERROR ");
	}
	if (state & LINE_PARITY_ERROR) {
	    strcat(linestates, "LINE_PARITY_ERROR ");
	}
	if (state & LINE_OVERRUN_ERROR) {
	    strcat(linestates, "LINE_OVERRUN_ERROR ");
	}
	if (state & LINE_DATA_READY) {
	    strcat(linestates, "LINE_DATA_READY ");
	}
	strcat(Debugbuf, linestates);
    }
}

void
print_modemstate(int state)
{
    if (Debug > 2) {

	char modemstates[256];
	modemstates[0] = 0;

	if (state & MODEM_DCD) {
	    strcat(modemstates, "MODEM_DCD ");
	}
	if (state & MODEM_RI) {
	    strcat(modemstates, "MODEM_RI ");
	}
	if (state & MODEM_DSR) {
	    strcat(modemstates, "MODEM_DSR ");
	}
	if (state & MODEM_CTS) {
	    strcat(modemstates, "MODEM_CTS ");
	}
	if (state & MODEM_DELTA_DCD) {
	    strcat(modemstates, "MODEM_DELTA_DCD ");
	}
	if (state & MODEM_TRAIL_RI) {
	    strcat(modemstates, "MODEM_TRAIL_RI ");
	}
	if (state & MODEM_DELTA_DSR) {
	    strcat(modemstates, "MODEM_DELTA_DSR ");
	}
	if (state & MODEM_DELTA_CTS) {
	    strcat(modemstates, "MODEM_DELTA_CTS ");
	}

	strcat(Debugbuf, modemstates);
    }
}

void
print_speed(int speed)
{
    if (Debug > 2) {
	char buf[32];
	sprintf(buf, "Speed: %d bps ", speed);
	strcat(Debugbuf, buf);
    }
}

void
print_datasize(int datasize)
{
    if (Debug > 2) {
	char buf[32];
	sprintf(buf, "Datasize: %d bits ", datasize);
	strcat(Debugbuf, buf);
    }
}

void
print_stopsize(int stopsize)
{
    if (Debug > 2) {
	char buf[32];
	sprintf(buf, "%s ", Stop_names[stopsize]);
	strcat(Debugbuf, buf);
    }
}

void
print_parity(int parity)
{
    if (Debug > 2) {
	char buf[32];
	sprintf(buf, "%s ", Parity_names[parity]);
	strcat(Debugbuf, buf);
    }
}

void
print_setcontrol(int control)
{
    if (Debug > 2) {
	char buf[32];
	sprintf(buf, "%s ", Control_names[control]);
	strcat(Debugbuf, buf);
    }
}

void
print_purge(int purge)
{
    if (Debug > 2) {
	char buf[32];
	sprintf(buf, "%s ", Purge_names[purge]);
	strcat(Debugbuf, buf);
    }
}

void
print_command(int cmdidx)
{
    if (Debug > 2) {
	char buf[32];
	sprintf(buf, "%s: ", Command_names[cmdidx]);
	strcat(Debugbuf, buf);
    }
}
