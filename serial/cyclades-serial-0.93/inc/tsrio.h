/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * tsrio.h
 * Tsrsock I/O Scheduler definitions
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 * 01/21/2001 V.1.0.1 Debug messages are sent only if debug is on 
 */

/*
 * Simple buffer managment (for delayed writes and/or on NONBLOCK devices)
 */

struct buffer {
	unsigned char *	  	b_base;			/* Area               */
	unsigned char *	  	b_ins;			/* Insert data ptr */
	unsigned char *	  	b_rem;			/* Remove data ptr */
	int		  	b_hold;			/* Valid data bytes   */
	int		  	b_size;			/* Buffer size    */
};

# define INIT_BUFFER(buf, size) \
	if ((buf.b_base = mem_get (size)) == NULL) { \
		sysmessage (MSG_ERR,"%s: out of memory\n", Idmsg); \
		return (E_SYSTEM); \
	} \
	buf.b_ins = buf.b_rem = buf.b_base; \
	buf.b_size = size; \
	buf.b_hold = 0;

# define FREE_BUFFER(buf)	mem_free(buf.b_base);

# define COPY_TO_BUFFER(b, p, nn) \
	{ \
		int XXi = (b)->b_size - (b)->b_hold; \
		if (nn > XXi) { \
			sysmessage (MSG_ERR, "%s: Buffer overflow\n", Idmsg); \
			nn = XXi; \
		} \
		memcpy ((b)->b_ins, p, nn); \
		(b)->b_ins += nn; \
		(b)->b_hold += nn; \
	}

# define PUT_BUFFER(b, c) \
	{ \
		if ((b)->b_hold < (b)->b_size) { \
			*(b)->b_ins++ = (c); (b)->b_hold++; \
		} else { \
			sysmessage (MSG_ERR, "%s: Buffer overflow\n", Idmsg); \
		} \
	}
		

# define GET_BUFFER(b)		(b)->b_hold ? *(b)->b_rem++ : 0; \
				if ((b)->b_hold) (b)->b_hold--;

# define COPY_FROM_BUFFER(b, p, nn) \
		memcpy (p, (b)->b_rem, nn); \
		(b)->b_rem += nn; \
		(b)->b_hold -= nn;

# define REWIND_BUFFER(b, n)	(b)->b_rem -= n; (b)->b_hold += n;

# define FORWARD_BUFFER(b, n)	(b)->b_rem += n; (b)->b_hold -= n;

# define RESET_BUFFER(b)	(b)->b_rem = (b)->b_ins = (b)->b_base; \
				(b)->b_hold = 0;

struct portconfig {
	int			speed;
	int			datasize;
	int			stopsize;
	int			parity;
	int			flowc;
};		

struct portstate {
	int			modemstate;
	int			linestate;
};

struct comport {
	int			support;
	struct portconfig 	portconfig;
	struct portstate	portstate;
};


struct nvt {
	int			state;
	int			substate;
	int			servertype;
	int			iosize;
	struct comport *	comport;
	struct buffer *		inbuff;
	struct buffer *		outbuff;
};

struct iocontrol {
	int 	io_oper;
	union {
		struct portconfig	portconfig;
		int			arg;	
	}	io_param;
};

# define io_portconfig	io_param.portconfig
# define io_arg		io_param.arg

struct pty {
	int			state;
	int			substate;
	int			iosize;
	int			portmodes;
	struct iocontrol	iocontrol;
	struct comport *	comport;
	struct buffer *		inbuff;
	struct buffer *		outbuff;
};

/* Bits for portmodes */

# define PORT_HUPCL		0x00000001
# define PORT_CLOCAL		0x00000002
# define PORT_IGNBRK		0x00000004
# define PORT_BRKINT		0x00000008
# define PORT_IGNPAR		0x00000010
# define PORT_PARMRK		0x00000020

/* State values */
/* PTY States */

# define PTY_INITIAL		0
# define PTY_CLOSING		1
# define PTY_CLOSED		2
# define PTY_OPENING		3
# define PTY_WAITDCD		4
# define PTY_OPER		5
# define PTY_CONFIG		6
# define PTY_WAITNVTWR		7
# define PTY_WAITUSRWR		8
# define PTY_WAITNWUW		9 /* Wait both */
# define PTY_WAITNVTCM		10
# define PTY_WAITCLOCAL		11	/* Pseudo-states */
# define PTY_WAITCLOSE		12
# define PTY_OPERRONLY		13
# define PTY_WAITUSRWR0		14
# define PTY_WAITUSRWR2		15

# define PTY_STATES		PTY_WAITUSRWR2 + 1

/* NVT States */

# define NVT_INITIAL		0
# define NVT_OPER		1
# define NVT_WAITPTYWR		2
# define NVT_WAITRASWR		3
# define NVT_WAITRWPW		4
# define NVT_WAITRASCM		5
# define NVT_WAITRCPW		6

# define NVT_STATES		NVT_WAITRCPW + 1

/*
 * State macros
 */

# define PTY_SETSTATE(routine, newstate) \
	Pty.state = newstate; \
	print_ptystate(routine);

# define NVT_SETSTATE(routine, newstate) \
	Nvt.state = newstate; \
	print_nvtstate(routine);


/* External polling */
# define DEV_READ	0x01
# define DEV_WRITE	0x02
# define DEV_EXCEPT	0x04
# define DEV_PROBE	0x08
# define SOCK_READ	0x10
# define SOCK_WRITE	0x20
# define SOCK_EXCEPT	0x40
# define SOCK_PROBE	0x40


struct event {
	int	ev_type;
	int	ev_code;
	void *	ev_param;
	int	ev_size;
	struct event *	ev_next;
	struct event *	ev_last;
};

/* External event types */

# define EV_NONE	0	/* Free event entry */
# define EV_UP		1	/* USR => PTY events */
# define EV_RN		2	/* RAS => NVT events */
# define EV_NP		3	/* NVT => PTY events */
# define EV_PN		4	/* PTY => NVT events */

/* event codes */

/* User => PTY events */

# define EV_UPOPEN	0	/* First open  */
# define EV_UPCLOSE	1	/* Last close */
# define EV_UPDATA	2	/* Valid data on pty read */
# define EV_UPCONTROL	3	/* Pty ioctl */
# define EV_UPFLUSH	4	/* Flush buffers */
# define EV_UPWROK	5	/* Data was written on pty */

# define EV_UPEVENTS	EV_UPWROK + 1

/* EV_UPCONTROL Parameters */

# define OP_NONE	0
# define OP_SETNOW	1
# define OP_SETWAIT	2
# define OP_SETFLUSH	3
# define OP_SENDBREAK	4
# define OP_SETLINES	5
# define OP_FLUSH	6

/* OP_FLUSH modes */
# define OPFLUSH_IN	0
# define OPFLUSH_OUT	1
# define OPFLUSH_IO	2

/* RAS => NVT events */

# define EV_RNNTFY	0
# define EV_RNDATA	1
# define EV_RNHANG	2
# define EV_RNCMDOK	3
# define EV_RNWROK	4

# define EV_RNEVENTS	EV_RNWROK + 1

/* EV_RNNTFY Notifications */
# define NT_DCDON	0
# define NT_DCDOFF	1
# define NT_BREAK	2
# define NT_PARITY	3


/* NVT => PTY internal events */

# define EV_NPWROK	0
# define EV_NPCMDOK	1
# define EV_NPDCDON	2
# define EV_NPDCDOFF	3
# define EV_NPPARITY	4
# define EV_NPBREAK	5

# define EV_NPEVENTS	EV_NPBREAK + 1

/* PTY => NVT Internal events */

# define EV_PNWROK	0

# define EV_PNEVENTS	EV_PNWROK + 1

# define MAX_EVENTS	20
# define EVENT_PARAMSZ	128

struct event	Eventpoll[MAX_EVENTS];

struct event	Evhead;

# define INIT_EVENTS()	Evhead.ev_last = Evhead.ev_next = &Evhead;

# define FREE_EVENTS() \
	{ \
		struct event *evp; \
		int i; \
		for (i = 0, evp = &Eventpoll[0]; i < MAX_EVENTS; i++, evp++) { \
			evp->ev_type = EV_NONE; \
		} \
		Evhead.ev_last = Evhead.ev_next = &Evhead; \
	}
	

# define SET_EVENT(evtype, evcode, evparam, evsize) \
	{ \
		struct event *evp; \
		void *	memptr; \
		int XXi; \
		for(XXi = 0, evp = &Eventpoll[0]; XXi < MAX_EVENTS; XXi++, evp++) { \
			if(evp->ev_type == EV_NONE) { \
				break; \
			} \
		} \
		if(XXi == MAX_EVENTS) { \
			sysmessage (MSG_ERR, "%s: Too many events", Idmsg); \
		} else { \
			evp->ev_type = evtype; \
			evp->ev_code = evcode; \
			if (evparam) { \
				if ((memptr = mem_get (EVENT_PARAMSZ)) \
					== (void *)0) { \
					sysmessage (MSG_ERR, \
						"%s: No memory", Idmsg); \
				} \
				memcpy (memptr, evparam, evsize); \
				evp->ev_param = (void *) memptr; \
				evp->ev_size = evsize; \
			} else { \
				evp->ev_param = (void *) evparam; \
				evp->ev_size = 0; \
			} \
			evp->ev_next = &Evhead; \
			evp->ev_last = Evhead.ev_last; \
			Evhead.ev_last->ev_next = evp; \
			Evhead.ev_last = evp; \
		} \
	}

# define SET_HIPRI_EVENT(evtype, evcode, evparam, evsize) \
	{ \
		struct event *evp; \
		int i; \
		for (i = 0, evp = &Eventpoll[i]; i < MAX_EVENTS; i++, evp++) { \
			if (evp->ev_type == EV_NONE) { \
				break; \
			} \
		} \
		if (i == MAX_EVENTS) { \
			sysmessage (MSG_ERR, "%s: Too many events", Idmsg; \
		} else { \
			evp->ev_type = evtype; \
			evp->ev_code = evcode; \
			if (evparam) { \
				if ((memptr = mem_get (EVENT_PARAMSZ)) \
					== (void *)0) { \
					sysmessage (MSG_ERR, \
						"%s: No memory", Idmsg); \
				} \
				memcpy (memptr, evparam, evsize); \
				evp->ev_param = (void *) memptr; \
				evp->ev_size = evsize; \
			} else { \
				evp->ev_param = (void *) 0; \
				evp->ev_size = 0; \
			} \
			evp->ev_last = &Evhead; \
			evp->ev_next = Evhead.ev_next; \
			Evhead.ev_next->ev_last = evp; \
			Evhead.ev_next = evp; \
		} \
	}

# define GET_EVENT() \
		Evhead.ev_next == &Evhead ? 0 : Evhead.ev_next;

# define CLR_EVENT(evp) \
	{ \
		evp->ev_last->ev_next = evp->ev_next; \
		evp->ev_next->ev_last = evp->ev_last; \
		evp->ev_type = EV_NONE; \
		if (evp->ev_param) { \
			(void) mem_free (evp->ev_param); \
		} \
	}

/*
 * External accessible routines
 */

# ifdef _TSR_TSRIO_

# define EXTERN
# else
# define EXTERN extern
# endif

EXTERN int	tsr_init(int netsize, int devsize, int devmodem, int closemode);
EXTERN void	tsr_io(void);
EXTERN void	imminent_event(int msgtype);

EXTERN int	Hang_up;

# undef EXTERN
