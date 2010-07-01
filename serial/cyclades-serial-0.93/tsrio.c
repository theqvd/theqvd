/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * tsrio.c
 * Tsrsock I/O Scheduler
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 * Oct-27-2001 V.1.0.1
 *	Read is now allowed when PTY is on WAITUSRWR* states
 *	Less syslog activity on unexpected events
 *	Hangup message is now of Warning type
 */

#include <sys/types.h>
#include <stdio.h>

#define _TSR_TSRIO_

#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrio.h"
#include "inc/telnet.h"
#include "inc/misc.h"
#include "inc/dev.h"
#include <string.h>


/*
 * Internal Variables
 */

struct buffer Inbuf;		/* Buffer RAS => USER */

struct buffer Outbuf;		/* Buffer USER => RAS */

int Hang_up = FALSE;

struct statenames
{
    const char *const stname;
    char **subnames;
};

struct statenames Pty_states[] = {
    {"PTY_INITIAL", 0},
    {"PTY_CLOSING", 0},
    {"PTY_CLOSED", 0},
    {"PTY_OPENING", 0},
    {"PTY_WAITDCD", 0},
    {"PTY_OPER", 0},
    {"PTY_CONFIG", 0},
    {"PTY_WAITNVTWR", 0},
    {"PTY_WAITUSRWR", 0},
    {"PTY_WAITNRUW", 0},
    {"PTY_WAITNVTCM", 0},
    {"PTY_WAITCLOCAL", 0},
    {"PTY_WAITCLOSE", 0},
    {"PTY_OPERRONLY", 0},
    {"PTY_WAITUSRWR0", 0},
    {"PTY_WAITUSRWR2", 0},
};

struct statenames Nvt_states[] = {
    {"NVT_INITIAL", 0},
    {"NVT_OPER", 0},
    {"NVT_WAITPTYWR", 0},
    {"NVT_WAITRASWR", 0},
    {"NVT_WAITRWPW", 0},
    {"NVT_WAITRASCM", 0},
    {"NVT_WAITRCPW", 0},
};

const char *const Pty_events[] = {
    "EV_UPOPEN",
    "EV_UPCLOSE",
    "EV_UPDATA",
    "EV_UPCONTROL",
    "EV_UPFLUSH",
    "EV_UPWROK",
};

const char *const Nvt_events[] = {
    "EV_RNDNTFY",
    "EV_RNDATA",
    "EV_RNHANG",
    "EV_RNCMOK",
    "EV_RNWROK",
};

/*
 * Main Scheduler Routines
 */

void all_hangup();
int check_states(void);
void all_wakeup(void);
void all_readonly(void);

/*
 * PTY External events handlers (up_*)
 */

void up_nop(struct event *evp);

void up_open(struct event *unused);
void up_op01(struct event *unused);
void up_close(struct event *unused);
void up_data(struct event *evp);
void up_ioctl(struct event *unused);
void up_flush(struct event *evp);
void up_wrok(struct event *unused);

/*
 * PTY Internal events handlers (np_*)
 */

void np_nop(const char *const hand);

void np_wrok(void);
void np_wok01(void);
void np_wok02(void);
void np_woker(void);

void np_cmdok(void);
void np_cok01(void);
void np_cok02(void);
void np_cok03(void);
void np_cok04(void);
void np_coker(void);

void np_dcdon(void);
void np_don01(void);
void np_don02(void);
void np_doner(void);

void np_dcdoff(void);
void np_dof01(void);
void np_dof02(void);
void np_dofer(void);

void np_parity(void);
void np_par01(void);
void np_parer(void);

void np_break(void);
void np_brk01(void);
void np_brker(void);

/*
 * PTY Operations (do_pty*)
 */

void do_ptyerr(char *action);
int do_ptydata(void);
void do_ptyopen(void);
void do_ptyopen1(void);
void do_ptyclose(void);
void do_ptyclose1(void);
void do_ptywrite(void);
void do_ptyioctl(void);
void do_ptyconfig(int mode, struct portconfig *pcp);
void do_ptyconfig1(void);
void do_ptysendbreak(int interval);
void do_ptyflush(int mode);
void do_ptyhangup(void);
void do_ptyinterrupt(void);

/*
 * NVT External events handlers (rn_*)
 */

void rn_nop(struct event *evp);

void rn_ntfy(struct event *evp);
void rn_data(struct event *unused);
void rn_cmdok(struct event *unused);
void rn_wrok(struct event *unused);

/*
 * NVT Internal events handlers (pn_*)
 */

void pn_nop(const char *const hand);

void pn_wrok(void);
void pn_wok01(void);
void pn_wok02(void);
void pn_woker(void);

/*
 * NVT Operations (do_nvt*)
 */

void do_nvterror(const char *const action);
int do_nvtdata(void);
void do_nvtdtron(void);
void do_nvtdtroff(void);
void do_nvtconfig(struct portconfig *pcp);
void do_nvtsendbreak(int interval);
void do_nvtflush(int mode);

/*
 * Debug routines
 */

char *tsr_states(const char *const unused);
void print_ptystate(const char *const hand);
void print_nvtstate(const char *const hand);
void print_action(const char *const hand);
void print_event(struct event *evp);


/*
 * Matrix for PTY External events 
 */

void (*(Pty_upevents[PTY_STATES][EV_UPEVENTS])) (struct event * evp) = {

/*{UPOPEN  ,UPCLOSE ,UPDATA  ,UPCONTROL,UPFLUSH ,UPWROK  } */

    {
    up_nop, up_nop, up_nop, up_nop, up_nop, up_nop},	/* INITIAL */
    {
    up_nop, up_nop, up_nop, up_nop, up_nop, up_nop},	/* CLOSING */
    {
    up_open, up_nop, up_nop, up_nop, up_nop, up_nop},	/* CLOSED */
    {
    up_nop, up_nop, up_nop, up_nop, up_nop, up_nop},	/* OPENING */
    {
    up_nop, up_nop, up_nop, up_nop, up_nop, up_nop},	/* WAITDCD */
    {
    up_nop, up_close, up_data, up_ioctl, up_flush, up_nop},	/* OPER */
    {
    up_nop, up_nop, up_nop, up_nop, up_nop, up_nop},	/* CONFIG */
    {
    up_nop, up_nop, up_nop, up_nop, up_nop, up_nop},	/* WAITNVTWR */
    {
    up_nop, up_close, up_data, up_nop, up_nop, up_wrok},	/* WAITUSRWR */
    {
    up_nop, up_nop, up_nop, up_nop, up_nop, up_wrok},	/* WAITNWUW */
    {
    up_nop, up_nop, up_nop, up_nop, up_nop, up_nop},	/* WAITNVTCM */
    {
    up_nop, up_close, up_nop, up_nop, up_nop, up_nop},	/* WAITCLOCAL */
    {
    up_nop, up_close, up_nop, up_nop, up_nop, up_nop},	/* WAITCLOSE */
    {
    up_op01, up_nop, up_nop, up_nop, up_nop, up_nop},	/* OPERRONLY */
    {
    up_nop, up_close, up_nop, up_nop, up_nop, up_wrok},	/* WAITUSRWR0 */
    {
    up_nop, up_close, up_nop, up_nop, up_nop, up_wrok},	/* WAITUSRWR2 */
};

/*
 * Matrix for PTY Internal events 
 */

void (*(Pty_npevents[PTY_STATES][EV_NPEVENTS])) (void) = {
/*{NPWROK  ,NPCMDOK ,NPDCDON ,NPDCDOFF,NPPARITY,NPBREAK } */
    {
    np_woker, np_coker, np_doner, np_dofer, np_parer, np_brker},	/* INITIAL */
    {
    np_woker, np_cok01, np_doner, np_dofer, np_parer, np_brker},	/* CLOSING */
    {
    np_woker, np_coker, np_doner, np_dofer, np_parer, np_brker},	/* CLOSED */
    {
    np_woker, np_cok02, np_doner, np_dofer, np_parer, np_brker},	/* OPENING */
    {
    np_woker, np_coker, np_don01, np_dofer, np_parer, np_brker},	/* WAITDCD */
    {
    np_woker, np_coker, np_doner, np_dof01, np_par01, np_brk01},	/* OPER */
    {
    np_woker, np_cok03, np_doner, np_dofer, np_parer, np_brker},	/* CONFIG */
    {
    np_wok01, np_coker, np_doner, np_dofer, np_par01, np_brk01},	/* WAITNVTWR */
    {
    np_woker, np_coker, np_doner, np_dofer, np_parer, np_brker},	/* WAITUSRWR */
    {
    np_wok02, np_coker, np_doner, np_dofer, np_parer, np_brker},	/* WAITNWUW */
    {
    np_woker, np_cok04, np_doner, np_dofer, np_parer, np_brker},	/* WAITNVTCM */
    {
    np_woker, np_coker, np_don02, np_dofer, np_parer, np_brker},	/* WAITCLOCAL */
    {
    np_woker, np_coker, np_don01, np_dofer, np_parer, np_brker},	/* WAITCLOSE */
    {
    np_woker, np_coker, np_doner, np_dof02, np_parer, np_brk01},	/* OPERRONLY */
    {
    np_woker, np_coker, np_doner, np_dofer, np_parer, np_brker},	/* WAITUSRWR0 */
    {
    np_woker, np_coker, np_doner, np_dofer, np_parer, np_brker},	/* WAITUSRWR2 */
};

/*
 * Matrix for NVT External events 
 */

void (*(Nvt_rnevents[NVT_STATES][EV_RNEVENTS])) (struct event * evp) = {
/*{RNNTFY  ,RNDATA  ,RNHANG  ,RNCMDOK ,RNWROK  } */

    {
    rn_ntfy, rn_nop, rn_nop, rn_nop, rn_nop},	/* INITIAL */
    {
    rn_ntfy, rn_data, rn_nop, rn_nop, rn_nop},	/* OPER */
    {
    rn_nop, rn_nop, rn_nop, rn_nop, rn_nop},	/* WAITPTYWR */
    {
    rn_ntfy, rn_data, rn_nop, rn_nop, rn_wrok},	/* WAITRASWR */
    {
    rn_nop, rn_nop, rn_nop, rn_nop, rn_wrok},	/* WAITRWPW */
    {
    rn_ntfy, rn_nop, rn_nop, rn_cmdok, rn_nop},	/* WAITRASCM */
    {
    rn_nop, rn_nop, rn_nop, rn_cmdok, rn_nop},	/* WAITRCPW */
};

/*
 * Matrix for NVT Internal events 
 */

void (*(Nvt_pnevents[NVT_STATES][EV_PNEVENTS])) (void) = {
/*{PNWROK   } */

    {
    pn_woker},			/* INITIAL */
    {
    pn_woker},			/* OPER */
    {
    pn_wok01},			/* WAITPTYWR */
    {
    pn_woker},			/* WAITRASWR */
    {
    pn_wok02},			/* WAITRWPW */
    {
    pn_woker},			/* WAITRASCM */
    {
    pn_woker},			/* WAITRCPW */
};

/*
 * Startup
 */

int
tsr_init(int netsize, int devsize, int devmodem, int closemode)
{
    int ret;

/* Initialize buffers (warn: these macros can return) */

    INIT_BUFFER(Inbuf, 2 * netsize);

    INIT_BUFFER(Outbuf, 2 * devsize);

/* Initialize event queue */

    INIT_EVENTS();

/* Connection status */

    Hang_up = FALSE;

/* Initialize NVT */

    if ((ret = tel_init(netsize, &Inbuf, &Outbuf)) != E_NORMAL)
	return (ret);

    NVT_SETSTATE("tsr_init", NVT_OPER);	/* NVT starts at operational state */

/* Initialize PTY */

    if ((ret = dev_init(devsize, devmodem, closemode, &Outbuf, &Inbuf,
			Nvt.comport)) == E_NORMAL) {
	PTY_SETSTATE("tsr_init", PTY_INITIAL);
	do_ptyclose();		/* PTY starts at closed state */
    }

    return (ret);

}


/*
 * Main Scheduler Routines
 */

void
tsr_io(void)
{

    struct event *ev;
    int mask;

    while (Hang_up == FALSE) {
	mask = check_states();
	external_poll(mask, SCHED_DELAY);
	while (Hang_up == FALSE) {
	    ev = GET_EVENT();
	    if (!ev)
		break;

	    print_event(ev);

	    switch (ev->ev_type) {
	    case EV_UP:
		(*Pty_upevents[Pty.state][ev->ev_code]) (ev);
		break;

	    case EV_RN:
		(*Nvt_rnevents[Nvt.state][ev->ev_code]) (ev);
		break;
	    }
	    CLR_EVENT(ev);
	}
    }
    all_hangup();
}

void
all_hangup()
{

    dev_hangup();

    tel_free();

    dev_free();

    FREE_BUFFER(Inbuf);

    FREE_BUFFER(Outbuf);

    FREE_EVENTS();

    Hang_up = FALSE;

}

int
check_states(void)
{
    int mask = 0;

    switch (Pty.state) {
    case PTY_OPER:
    case PTY_OPERRONLY:
	mask = DEV_READ | DEV_EXCEPT;
	break;
    case PTY_WAITCLOCAL:
    case PTY_WAITCLOSE:
	mask = DEV_PROBE | DEV_EXCEPT;
	break;
    case PTY_WAITUSRWR0:
	mask = DEV_READ | DEV_EXCEPT | DEV_WRITE;
	break;
    case PTY_WAITUSRWR:
	mask = DEV_READ | DEV_EXCEPT | DEV_WRITE;
	break;
    case PTY_WAITNWUW:		/* don't read pty */
    case PTY_WAITUSRWR2:
	mask = DEV_WRITE;
	break;
    }

    switch (Nvt.state) {
    case NVT_OPER:
    case NVT_WAITRASCM:
    case NVT_WAITRCPW:		/*WARN Pty Blocked, buffer may overrun */
	mask |= SOCK_READ;
	break;
    case NVT_WAITRASWR:
	mask |= SOCK_READ | SOCK_WRITE;
	break;
    case NVT_WAITRWPW:		/* don't read socket */
	mask |= SOCK_WRITE;
	break;
    }

    return (mask);
}

void
imminent_event(int msgtype)
{
    switch (Pty.state) {
    case PTY_WAITCLOSE:
	if (msgtype != PROBE_EOF) {	/* ! MDATA == 0 =>any except CLOSE, BLOCK */
	    PTY_SETSTATE("probe", PTY_WAITDCD);
	}
	else {
	    dev_getdata();	/* CLOSE, GET IT */
	}
	break;
    case PTY_WAITUSRWR0:
	PTY_SETSTATE("probe", PTY_WAITUSRWR);
	if (msgtype != PROBE_EOF && msgtype != PROBE_DATA) {	/* ! MDATA, BLOCK */
	    PTY_SETSTATE("probe", PTY_WAITUSRWR2);
	}
	else {			/*  MDATA/CLOSE  =>  GET IT */
	    dev_getdata();
	}
	break;
    case PTY_WAITUSRWR:
	if (msgtype != PROBE_EOF && msgtype != PROBE_DATA) {	/* ! MDATA, BLOCK */
	    PTY_SETSTATE("probe", PTY_WAITUSRWR2);
	}
	else {			/*  MDATA/CLOSE  =>  GET IT */
	    dev_getdata();
	}
	break;
    case PTY_WAITCLOCAL:
	if (msgtype == PROBE_CLOCAL) {
	    PTY_SETSTATE("probe", PTY_OPER);
	    Pty.portmodes |= PORT_CLOCAL;
	    dev_getdata();
	}
	else if (msgtype == PROBE_EOF) {	/* CLOSE ?? */
	    PTY_SETSTATE("probe", PTY_OPER);
	    dev_getdata();
	}
	else {
	    PTY_SETSTATE("probe", PTY_WAITDCD);
	}
	break;
    }
}

/* GAMB => Invoked in Pty.state == OPER, check for missed events */

void
all_wakeup(void)
{

    /* First check for NP_DCDOFF */

    if (!(Pty.portmodes & PORT_CLOCAL) &&
	!(Pty.comport->portstate.modemstate & MODEM_DCD)) {
	PTY_SETSTATE("all_wakeup", PTY_WAITCLOSE);
	do_ptyhangup();
	return;
    }

/* Check for NVT data */
    if (Pty.outbuff->b_hold) {
	if (do_ptydata() != E_NORMAL) {	/* local action */
	    return;
	}
	pn_wrok();		/* Notify NVT */
    }

/* Finally, check for user data */
    if (Pty.inbuff->b_hold) {
	do_ptywrite();
    }
}

void
all_readonly(void)
{
    /* First check for NP_DCDOFF */

    if (!(Pty.portmodes & PORT_CLOCAL) &&
	!(Pty.comport->portstate.modemstate & MODEM_DCD)) {
	PTY_SETSTATE("all_readonly", PTY_WAITCLOCAL);
	do_ptyhangup();
	return;
    }

/* Check for NVT data */
    if (Pty.outbuff->b_hold) {
	if (do_ptydata() != E_NORMAL) {	/* local action */
	    return;
	}
	pn_wrok();		/* Notify NVT */
    }
}

/*
 * PTY External events handlers (up_*)
 */

void
up_nop(struct event *evp)
{
    const char *const event = Pty_events[evp->ev_code];
    sysmessage(MSG_DEBUG, "PTY state (EVENT %s): %s\n", event,
	       tsr_states(event));
}

void
up_open(struct event *unused)
{
    unused = unused;
    do_ptyopen();
}


void
up_op01(struct event *unused)
{
    unused = unused;
    /* Port already open (read_only) => only change to read-write states */
    switch (Pty.state) {
    case PTY_OPERRONLY:
	PTY_SETSTATE("up_op01", PTY_OPER);
	all_wakeup();		/* XXXX */
	break;
    case PTY_WAITUSRWR0:
	PTY_SETSTATE("up_op01", PTY_WAITUSRWR);
	break;
    }
}

void
up_close(struct event *unused)
{
    unused = unused;
    do_ptyclose();
}

void
up_ioctl(struct event *unused)
{
    unused = unused;
    do_ptyioctl();
}

void
up_flush(struct event *evp)
{

    int mode = *(int *) evp->ev_param;

    do_ptyflush(mode);
}

void
up_data(struct event *unused)
{
    unused = unused;
    do_ptywrite();
}

void
up_wrok(struct event *unused)
{
    unused = unused;
    switch (Pty.state) {
    case PTY_WAITUSRWR0:
	PTY_SETSTATE("up_wrok", PTY_OPERRONLY);
	break;
    case PTY_WAITUSRWR:
    case PTY_WAITUSRWR2:
	PTY_SETSTATE("up_wrok", PTY_OPER);
	break;
    case PTY_WAITNWUW:
	PTY_SETSTATE("up_wrok", PTY_WAITNVTWR);
	break;
    }

    if (do_ptydata() == E_NORMAL) {	/* XXXX local action */
	pn_wrok();
    }
}

/*
 * PTY Internal events handlers (np_*)
 */

void
np_nop(const char *const evhand)
{
    sysmessage(MSG_DEBUG, "PTY state (INT EVENT %s): %s\n", evhand,
	       tsr_states(evhand));
}

/* EV_NPWROK */
void
np_wrok(void)
{
    (*Pty_npevents[Pty.state][EV_NPWROK]) ();
}

void
np_wok01(void)
{
    PTY_SETSTATE("np_wrok", PTY_OPER);
    all_wakeup();		/* XXXX */
}

void
np_wok02(void)
{
    PTY_SETSTATE("np_wrok", PTY_WAITUSRWR);
}

void
np_woker(void)
{
    np_nop("np_wrok");
}


/* EV_NPCMDOK */

void
np_cmdok(void)
{
    (*Pty_npevents[Pty.state][EV_NPCMDOK]) ();
}

void
np_cok01(void)
{
    do_ptyclose1();
}

void
np_cok02(void)
{
    do_ptyopen1();
}

void
np_cok03(void)
{
    do_ptyconfig1();
}

void
np_cok04(void)
{
    PTY_SETSTATE("np_cmdok", PTY_OPER);
    all_wakeup();		/* XXXX */
}

void
np_coker(void)
{
    np_nop("np_cmdok");
}


/* EV_NPDCDON */

void
np_dcdon(void)
{
    (*Pty_npevents[Pty.state][EV_NPDCDON]) ();
}

void
np_don01(void)
{
    PTY_SETSTATE("np_dcdon", PTY_OPER);
    all_wakeup();		/* XXXX */
}

void
np_don02(void)
{
    PTY_SETSTATE("np_dcdon", PTY_OPERRONLY);
    all_readonly();
}

void
np_doner(void)
{
    np_nop("ev_npdcdon");
}

/* EV_NPDCDOFF */

void
np_dcdoff(void)
{
    (*Pty_npevents[Pty.state][EV_NPDCDOFF]) ();
}

void
np_dof01(void)
{
    if (!(Pty.portmodes & PORT_CLOCAL)) {
	PTY_SETSTATE("np_dcdoff", PTY_WAITCLOSE);
	do_ptyhangup();
    }
}

void
np_dof02(void)
{
    if (!(Pty.portmodes & PORT_CLOCAL)) {
	PTY_SETSTATE("np_dcdoff", PTY_WAITCLOCAL);
	do_ptyhangup();
    }
}

void
np_dofer(void)
{
    np_nop("np_dcdoff");
}

/* EV_NPPARITY */

void
np_parity(void)
{
    (*Pty_npevents[Pty.state][EV_NPPARITY]) ();
}

void
np_par01(void)
{
    int portmodes;
    struct buffer *bp;

    portmodes = Pty.portmodes;
    bp = Pty.outbuff;
    if (!(portmodes & PORT_IGNPAR)) {
	if (portmodes & PORT_PARMRK) {
	    PUT_BUFFER(bp, 0xff);
	    PUT_BUFFER(bp, 0x00);
	}
	else {
	    PUT_BUFFER(bp, 0x00);
	}
    }
}

void
np_parer(void)
{
    np_nop("np_parity");
}

/* EV_NPBREAK */

void
np_break(void)
{
    (*Pty_npevents[Pty.state][EV_NPBREAK]) ();
}

void
np_brk01(void)
{
    int portmodes;
    struct buffer *bp1, *bp2;

    portmodes = Pty.portmodes;
    bp1 = Pty.outbuff;
    bp2 = Pty.inbuff;
    if (!(portmodes & PORT_IGNBRK)) {
	if (portmodes & PORT_BRKINT) {
	    RESET_BUFFER(bp1);
	    RESET_BUFFER(bp2);
	    do_ptyinterrupt();
	}
	else if (portmodes & PORT_PARMRK) {
	    PUT_BUFFER(bp1, 0xff);
	    PUT_BUFFER(bp1, 0x00);
	}
	else {
	    PUT_BUFFER(bp1, 0x00);
	}
    }
}

void
np_brker(void)
{
    np_nop("np_break");
}

/*
 * PTY Operations (do_pty*)
 */

void
do_ptyerror(const char *const action)
{
    sysmessage(MSG_ERR, "Undesirable PTY state for ACTION %s: %s\n",
	       action, tsr_states(action));
}

int
do_ptydata()
{
    int ret;
    struct buffer *bp = Pty.outbuff;

    print_action("do_ptydata");
    switch (Pty.state) {
    case PTY_OPER:
    case PTY_OPERRONLY:
    case PTY_WAITNVTWR:
	if ((ret = dev_putdata(bp)) == 0) {
	    if (bp->b_hold != 0) {
		switch (Pty.state) {
		case PTY_OPER:
		    PTY_SETSTATE("do_ptydata", PTY_WAITUSRWR);
		    break;
		case PTY_WAITNVTWR:
		    PTY_SETSTATE("do_ptydata", PTY_WAITNWUW);
		    break;
		case PTY_OPERRONLY:
		    PTY_SETSTATE("do_ptydata", PTY_WAITUSRWR0);
		    break;
		}
		ret = E_BLOCKED;
	    }
	    else {
		ret = E_NORMAL;
	    }
	}
	else {
	    Hang_up = TRUE;
	    if (Debug > 0) {
		sysmessage(MSG_DEBUG, "HANGUP DO_PTYDATA\n");
	    }
	    ret = E_FILEIO;
	}
	break;
    case PTY_WAITCLOSE:
    case PTY_CLOSING:
    case PTY_CLOSED:
    case PTY_OPENING:
    case PTY_WAITCLOCAL:
    case PTY_WAITDCD:
	RESET_BUFFER(Pty.outbuff);	/* Discard it */
	pn_wrok();		/* Notify NVT */
	ret = E_NORMAL;
	break;

    default:
	do_ptyerror("do_ptydata");
	ret = E_BLOCKED;	/* Transition to PTY_OPER must wakeup NVT */
	break;

    }
    return (ret);
}

void
do_ptyclose(void)
{

    print_action("do_ptyclose");

/* Wait output data to drain */
    if (Pty.inbuff->b_hold) {
	if (do_nvtdata() != E_NORMAL) {
	    sysmessage(MSG_WARNING,
		       "Can't flush output buffer before close\n");
	}
    }

/* Flush input data */
    if (Pty.outbuff->b_hold) {
	RESET_BUFFER(Pty.outbuff);
	pn_wrok();		/* Notify NVT */
    }

/* Set DTR off if applicable */

    if (Pty.portmodes & PORT_HUPCL) {
	PTY_SETSTATE("do_ptyclose", PTY_CLOSING);
	do_nvtdtroff();		/* Sched */
    }
    else {
	do_ptyclose1();
    }
}

void
do_ptyclose1(void)
{
    print_action("do_ptyclose1");
    dev_config();
    PTY_SETSTATE("do_ptyclose1", PTY_CLOSED);

/* Simulate a user open */

    /* DO a DTR OFF->ON delay */
    sysdelay(1000);
    do_ptyopen();
}

void
do_ptyopen(void)
{
    print_action("do_ptyopen");
    PTY_SETSTATE("do_ptyopen", PTY_OPENING);
    do_nvtdtron();		/* Sched */
}

void
do_ptyopen1(void)
{
    print_action("do_ptyopen1");
    if (!(Pty.portmodes & PORT_CLOCAL) &&
	!(Pty.comport->portstate.modemstate & MODEM_DCD)) {
/* Ignore input data */
	if (Pty.outbuff->b_hold) {
	    RESET_BUFFER(Pty.outbuff);
	    pn_wrok();		/* Notify NVT */
	}
	PTY_SETSTATE("do_ptyopen1", PTY_WAITCLOCAL);
    }
    else {
	PTY_SETSTATE("do_ptyopen1", PTY_OPERRONLY);
	all_readonly();		/* XXXX */
    }
}

void
do_ptywrite()
{
    int ret;
    print_action("do_ptywrite");
    if ((ret = do_nvtdata()) != E_NORMAL) {
	if (ret == E_BLOCKED) {
	    switch (Pty.state) {
	    case PTY_OPER:
		PTY_SETSTATE("do_ptywrite", PTY_WAITNVTWR);
		break;
	    case PTY_WAITUSRWR:
		PTY_SETSTATE("do_ptywrite", PTY_WAITNWUW);
		break;
	    }
	}			/* ELSE ERROR */

    }
}

void
do_ptyioctl(void)
{
    struct iocontrol *iocp = &Pty.iocontrol;
    int oper = iocp->io_oper;
    struct portconfig *pconfig;
    int param;

    print_action("do_ptyioctl");
    switch (oper) {
    case OP_SETNOW:
    case OP_SETWAIT:
    case OP_SETFLUSH:
	pconfig = &iocp->io_portconfig;
	do_ptyconfig(oper, pconfig);	/* Activity */
	break;
    case OP_SENDBREAK:
	param = iocp->io_arg;
	do_ptysendbreak(param);
	break;
    case OP_FLUSH:
	param = iocp->io_arg;
	do_ptyflush(param);
	break;
    }

    iocp->io_oper = OP_NONE;	/* cleanup */
}

void
do_ptyconfig(int mode, struct portconfig *pcp)
{
    struct portconfig *cur;

    print_action("do_ptyconfig");
    if (mode != OP_SETNOW) {	/* Wait output to drain */
	if (do_nvtdata() != E_NORMAL) {
	    sysmessage(MSG_WARNING,
		       "Can't flush output buffer before configure\n");
	}
    }

    if (mode == OP_SETFLUSH) {
/* Flush input data */
	if (Pty.outbuff->b_hold) {
	    RESET_BUFFER(Pty.outbuff);
	    pn_wrok();		/* Notify NVT */
	}
    }

    /* Send config */

    cur = &Pty.comport->portconfig;

    if (memcmp((void *) cur, (void *) pcp, sizeof(struct portconfig))
	!= 0) {
	if (!pcp->speed) {	/* HANG UP */
	    PTY_SETSTATE("do_ptyconfig", PTY_WAITNVTCM);
	    do_nvtdtroff();	/* Sched */
	}
	else {
	    PTY_SETSTATE("do_ptyconfig", PTY_CONFIG);
	    do_nvtconfig(pcp);	/* Sched */
	}
    }
    else {
	do_ptyconfig1();
    }

}

void
do_ptyconfig1()
{
    /* Only check for EVENT CLOCALOFF */
    print_action("do_ptyconfig1");
    if (!(Pty.portmodes & PORT_CLOCAL) &&
	!(Pty.comport->portstate.modemstate & MODEM_DCD)) {
	PTY_SETSTATE("do_ptyconfig1", PTY_WAITDCD);
    }
    else {
	PTY_SETSTATE("do_ptyconfig1", PTY_OPER);
	all_wakeup();		/* XXXX */
    }

}

void
do_ptysendbreak(int interval)
{
    /* Wait output to drain */
    print_action("do_ptysendbreak");
    if (do_nvtdata() != E_NORMAL) {
	sysmessage(MSG_WARNING,
		   "Can't flush output buffer before send break\n");
    }
    PTY_SETSTATE("do_ptysendbreak", PTY_WAITNVTCM);
    do_nvtsendbreak(interval);
}

void
do_ptyflush(int mode)
{
    print_action("do_ptyflush");
    switch (mode) {
    case OPFLUSH_IN:
	if (Pty.outbuff->b_hold) {
	    RESET_BUFFER(Pty.outbuff);
	    pn_wrok();		/* Notify NVT */
	}
	break;
    case OPFLUSH_OUT:
	RESET_BUFFER(Pty.inbuff);
	break;
    case OPFLUSH_IO:
	RESET_BUFFER(Pty.inbuff);
	if (Pty.outbuff->b_hold) {
	    RESET_BUFFER(Pty.outbuff);
	    pn_wrok();		/* Notify NVT */
	}
	break;
    }
    PTY_SETSTATE("do_ptyflush", PTY_WAITNVTCM);
    do_nvtflush(mode);
}

void
do_ptyhangup(void)
{
    print_action("do_ptyhangup");
    RESET_BUFFER(Pty.inbuff);
    if (Pty.outbuff->b_hold) {
	RESET_BUFFER(Pty.outbuff);
	pn_wrok();		/* Notify NVT */
    }
    dev_hangup();
}

void
do_ptyinterrupt(void)
{
    print_action("do_ptyinterrupt");
    dev_interrupt();
}

/*
 * NVT External events handlers (rn_*)
 */


void
rn_nop(struct event *evp)
{
    const char *const event = Nvt_events[evp->ev_code];
    sysmessage(MSG_DEBUG, "NVT state (EVENT %s): %s\n", event,
	       tsr_states(event));
}

void
rn_cmdok(struct event *unused)
{
/* VALID STATES => NVT_WAITRCPW || NVT_WAITRASC */
    int state = Nvt.state;
    unused = unused;
    switch (state) {
    case NVT_WAITRASCM:
	NVT_SETSTATE("rn_cmdok", NVT_OPER);
	break;
    case NVT_WAITRCPW:
	NVT_SETSTATE("rn_cmdok", NVT_WAITPTYWR);
	break;
    }

    np_cmdok();			/* Passes control to PTY object */
}

void
rn_wrok(struct event *unused)
{
/* VALID STATES => NVT_WAITRASWR || NVT_WAITRWPW */
    int state = Nvt.state;
    unused = unused;
    switch (state) {
    case NVT_WAITRASWR:
	NVT_SETSTATE("rn_wrok", NVT_OPER);
	break;
    case NVT_WAITRWPW:
	NVT_SETSTATE("rn_wrok", NVT_WAITPTYWR);
	break;
    }

    if (do_nvtdata() == E_NORMAL) {
	np_wrok();		/* Passes control to PTY object */
    }
}

void
rn_ntfy(struct event *evp)
{
    int notify;

    notify = *(int *) evp->ev_param;

    switch (notify) {
    case NT_DCDON:
	np_dcdon();
	break;
    case NT_DCDOFF:
	np_dcdoff();
	break;
    case NT_BREAK:
	np_break();
	break;
    case NT_PARITY:
	np_parity();
	break;
    }
}

void
rn_data(struct event *unused)
{
    int ret;

    unused = unused;
    if ((ret = do_ptydata()) != E_NORMAL) {
	if (ret == E_BLOCKED) {
	    switch (Nvt.state) {
	    case NVT_OPER:
		NVT_SETSTATE("rn_data", NVT_WAITPTYWR);
		break;
	    case NVT_WAITRASWR:
		NVT_SETSTATE("rn_data", NVT_WAITRWPW);
		break;
	    case NVT_WAITRASCM:
		NVT_SETSTATE("rn_data", NVT_WAITRCPW);
		break;
	    }
	}			/* else ERROR */
    }
}

/*
 * NVT Internal events handlers (pn_*)
 */

void
pn_nop(const char *const evhand)
{
    sysmessage(MSG_DEBUG, "NVT state (INT EVENT %s): %s\n", evhand,
	       tsr_states(evhand));
}

void
pn_wrok(void)
{
    (*Nvt_pnevents[Nvt.state][EV_PNWROK]) ();
}

void
pn_wok01(void)
{
    NVT_SETSTATE("pn_wrok", NVT_OPER);
}

void
pn_wok02(void)
{
    NVT_SETSTATE("pn_wrok", NVT_WAITRASWR);
}

void
pn_woker(void)
{
    pn_nop("ev_pnwrok");
}

/*
 * NVT Operations (do_nvt*)
 */

void
do_nvterror(const char *const action)
{
    sysmessage(MSG_ERR, "Undesirable NVT state for ACTION %s: %s\n",
	       action, tsr_states(action));
}

int
do_nvtdata(void)
{
    int ret;
    struct buffer *bp = Nvt.outbuff;

    print_action("do_nvtdata");
    if (!bp->b_hold) {
	return (E_NORMAL);
    }
    switch (Nvt.state) {
    case NVT_OPER:
    case NVT_WAITPTYWR:
	if ((ret = tel_putdata(bp)) == 0) {
	    if (bp->b_hold != 0) {
		if (Nvt.state == NVT_OPER) {
		    NVT_SETSTATE("do_nvtdata", NVT_WAITRASWR);
		}
		else {
		    NVT_SETSTATE("do_nvtdata", NVT_WAITRWPW);
		}
		ret = E_BLOCKED;
	    }
	    else {
		ret = E_NORMAL;
	    }
	}
	else {
	    Hang_up = TRUE;
	    if (Debug > 0) {
		sysmessage(MSG_DEBUG, "HANGUP DO_NVTDATA\n");
	    }
	    ret = E_FILEIO;
	}
	break;
    default:
	do_nvterror("do_nvtdata");
	ret = E_BLOCKED;	/* Transition to NVT_OPER must wakeup PTY */
	break;
    }
    return (ret);
}


void
do_nvtdtron(void)
{

    print_action("do_nvtdtron");
    switch (Nvt.state) {
    case NVT_OPER:
    case NVT_WAITPTYWR:
	tel_putcmd(USR_COM_SET_CONTROL, COM_DTR_ON);
	if (Nvt.state == NVT_OPER) {
	    NVT_SETSTATE("do_nvtdtron", NVT_WAITRASCM);
	}
	else {
	    NVT_SETSTATE("do_nvtdtron", NVT_WAITRCPW);
	}
	break;

    default:
	do_nvterror("do_nvtdtron");
	break;
    }
}

void
do_nvtdtroff(void)
{
    print_action("do_nvtdtroff");
    switch (Nvt.state) {
    case NVT_OPER:
    case NVT_WAITPTYWR:
	tel_putcmd(USR_COM_SET_CONTROL, COM_DTR_OFF);
	if (Nvt.state == NVT_OPER) {
	    NVT_SETSTATE("do_nvtdtroff", NVT_WAITRASCM);
	}
	else {
	    NVT_SETSTATE("do_nvtdtroff", NVT_WAITRCPW);
	}
	break;

    default:
	do_nvterror("do_nvtdtroff");
	break;
    }
}

void
do_nvtconfig(struct portconfig *pcp)
{
    struct portconfig *cur = &Nvt.comport->portconfig;
    int cmds = 0;

    print_action("do_nvtconfig");
    switch (Nvt.state) {
    case NVT_OPER:
    case NVT_WAITPTYWR:
	if (pcp->speed != cur->speed) {
	    tel_putcmd(USR_COM_SET_BAUDRATE, pcp->speed);
	    cmds++;
	}
	if (pcp->datasize != cur->datasize) {
	    tel_putcmd(USR_COM_SET_DATASIZE, pcp->datasize);
	    cmds++;
	}
	if (pcp->stopsize != cur->stopsize) {
	    tel_putcmd(USR_COM_SET_STOPSIZE, pcp->stopsize);
	    cmds++;
	}
	if (pcp->parity != cur->parity) {
	    tel_putcmd(USR_COM_SET_PARITY, pcp->stopsize);
	    cmds++;
	}
	if (pcp->flowc != cur->flowc) {
	    tel_putcmd(USR_COM_SET_CONTROL, pcp->flowc);
	    cmds++;
	}
	if (cmds) {
	    if (Nvt.state == NVT_OPER) {
		NVT_SETSTATE("do_nvtconfig", NVT_WAITRASCM);
	    }
	    else {
		NVT_SETSTATE("do_nvtconfig", NVT_WAITRCPW);
	    }
	}
	else {
	    np_cmdok();		/* Wakeup PTY */
	}
	break;
    default:
	do_nvterror("do_nvtconfig");
	break;
    }
}

void
do_nvtsendbreak(int interval)
{
    print_action("do_nvtsendbreak");
    switch (Nvt.state) {
    case NVT_OPER:
    case NVT_WAITPTYWR:
	tel_putcmd(USR_COM_SET_CONTROL, COM_BREAK_ON);
# ifdef ACCEPT_BREAK_INTERVAL
	if (interval) {
	    interval *= 250;
	}
	else {
	    interval = 250;
	}
# else
	interval = 250;
# endif
	sysdelay(interval);
	tel_putcmd(USR_COM_SET_CONTROL, COM_BREAK_OFF);
	if (Nvt.state == NVT_OPER) {
	    NVT_SETSTATE("do_nvtsendbreak", NVT_WAITRASCM);
	}
	else {
	    NVT_SETSTATE("do_nvtsendbreak", NVT_WAITRCPW);
	}
	break;
    default:
	do_nvterror("do_nvtsendbreak");
	break;
    }
}

void
do_nvtflush(int mode)
{
    int purgemode;

    print_action("do_nvtflush");
    switch (Nvt.state) {
    case NVT_OPER:
    case NVT_WAITPTYWR:
	switch (mode) {
	case OPFLUSH_IN:
	    purgemode = COM_PURGE_RECV;
	    break;
	case OPFLUSH_OUT:
	    purgemode = COM_PURGE_XMIT;
	    break;
	case OPFLUSH_IO:
	default:
	    purgemode = COM_PURGE_BOTH;
	    break;
	}

	tel_putcmd(USR_COM_PURGE_DATA, purgemode);
	if (Nvt.state == NVT_OPER) {
	    NVT_SETSTATE("do_nvtflush", NVT_WAITRASCM);
	}
	else {
	    NVT_SETSTATE("do_nvtflush", NVT_WAITRCPW);
	}
	break;
    default:
	do_nvterror("do_nvtflush");
	break;
    }
}


/*
 * Debug routines
 */

char debugbuf[128];

char *
tsr_states(const char *const unused)
{
    const char *pstate, *psubstate;
    const char *nstate, *nsubstate;

    pstate = Pty_states[Pty.state].stname;

    if (Pty_states[Pty.state].subnames) {
	psubstate = Pty_states[Pty.state].subnames[Pty.substate];
    }
    else {
	psubstate = "NONE";
    }


    nstate = Nvt_states[Nvt.state].stname;

    if (Nvt_states[Nvt.state].subnames) {
	nsubstate = Nvt_states[Nvt.state].subnames[Nvt.substate];
    }
    else {
	nsubstate = "NONE";
    }

    sprintf(debugbuf, "%s %s -- %s %s\n", pstate, psubstate,
	    nstate, nsubstate);
    return (debugbuf);

}

void
print_ptystate(const char *const hand)
{
    const char *state, *substate;

    if (Debug > 0) {
	state = Pty_states[Pty.state].stname;

	if (Pty_states[Pty.state].subnames) {
	    substate = Pty_states[Pty.state].subnames[Pty.substate];
	}
	else {
	    substate = "NONE";
	}

	sysmessage(MSG_DEBUG, "PTYSTATE (%s): %s %s\n", hand, state,
		   substate);
    }
}

void
print_nvtstate(const char *const hand)
{
    const char *state, *substate;

    if (Debug > 0) {
	state = Nvt_states[Nvt.state].stname;

	if (Nvt_states[Nvt.state].subnames) {
	    substate = Nvt_states[Nvt.state].subnames[Nvt.substate];
	}
	else {
	    substate = "NONE";
	}

	sysmessage(MSG_DEBUG, "NVTSTATE (%s): %s %s\n", hand, state,
		   substate);
    }
}

void
print_action(const char *const hand)
{
    if (Debug > 1)
	sysmessage(MSG_DEBUG, "ACTION %s\n", hand);
}


void
print_event(struct event *evp)
{
    unsigned char *cp;
    const char *type;
    const char *name;

    if (Debug > 1) {
	switch (evp->ev_type) {
	case EV_UP:
	    type = "EV_UP";
	    name = Pty_events[evp->ev_code];
	    break;
	case EV_RN:
	    type = "EV_RN";
	    name = Nvt_events[evp->ev_code];
	    break;
	default:
	    type = "EV_UNK";
	    name = "UNKNOWN";
	    break;
	}
	if (evp->ev_param) {
	    cp = (unsigned char *) evp->ev_param;
	    sprintf(debugbuf, "%02X %02X %02X %02X", *cp, *(cp + 1)
		    , *(cp + 2), *(cp + 3));
	    sysmessage(MSG_DEBUG, "EVENT %s %s, size %d: %s\n", type, name,
		       evp->ev_size, debugbuf);
	}
	else {
	    sysmessage(MSG_DEBUG, "EVENT %s %s\n", type, name);
	}

    }
}
