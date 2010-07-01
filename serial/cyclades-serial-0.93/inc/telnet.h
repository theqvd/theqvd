/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * telnet.h
 * Telnet Network Virtual Terminal definitions
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 */

/* Some Telnet Special chars */

# define IAC					255
# define WILL					251
# define WONT					252
# define DO					253
# define DONT					254
# define SE					240
# define SB					250

/* Telnet receiver substates */

# define S_DATA	0
# define S_IAC	1
# define S_WILL	2
# define S_WONT	3
# define S_DO	4
# define S_DONT	5
# define S_SB	6
# define S_SE	7	


/* Telnet Options stuff */

# define NVT_BINARY		0
# define NVT_ECHO		1
# define NVT_SUPP_GO_AHEAD	3
# define NVT_COM_PORT_OPTION	44

# define NVT_NUMOPTS		256

int NvtOptions[NVT_NUMOPTS];

# define I_WILL			0x01	/* I desire to support it */
# define I_DO			0x02	/* I do support it */
# define I_SENT			0x04	/* I desire and already sent it */
# define HE_WILL		0x10	/* I want he supports it */
# define HE_DOES		0x20	/* He supports it */
# define HE_RECV		0x40	/* He recv my response */

# define I_WANT_TO_SUPPORT(opt) 	(NvtOptions[(opt)] & I_WILL)
# define I_DO_SUPPORT(opt)		(NvtOptions[(opt)] & I_DO)
# define I_SENT_IT(opt)			(NvtOptions[(opt)] & I_SENT)

# define HE_MAY_SUPPORT(opt)		(NvtOptions[(opt)] & HE_WILL)
# define HE_DOES_SUPPORT(opt)		(NvtOptions[(opt)] & HE_DOES)
# define HE_RECV_IT(opt)		(NvtOptions[(opt)] & HE_RECV)

# define SET_I_WANT_TO_SUPPORT(opt)	(NvtOptions[(opt)] |= I_WILL)
# define SET_I_DO_SUPPORT(opt)		(NvtOptions[(opt)] |= I_DO)
# define SET_I_SENT_IT(opt)		(NvtOptions[(opt)] |= I_SENT)

# define SET_HE_MAY_SUPPORT(opt)	(NvtOptions[(opt)] |= HE_WILL)
# define SET_HE_DOES_SUPPORT(opt)	(NvtOptions[(opt)] |= HE_DOES)
# define SET_HE_RECV_IT(opt)		(NvtOptions[(opt)] |= HE_RECV)

# define CLR_I_WANT_TO_SUPPORT(opt)	(NvtOptions[(opt)] &= ~I_WILL)
# define CLR_I_DO_SUPPORT(opt)		(NvtOptions[(opt)] &= ~I_DO)
# define CLR_I_SENT_IT(opt)		(NvtOptions[(opt)] &= ~I_SENT)

# define CLR_HE_MAY_SUPPORT(opt)	(NvtOptions[(opt)] &= ~HE_WILL)
# define CLR_HE_DOES_SUPPORT(opt)	(NvtOptions[(opt)] &= ~HE_DOES)
# define CLR_HE_RECV_IT(opt)		(NvtOptions[(opt)] &= ~HE_RECV)


# define SEND_DO(opt)			(send_option(DO, (opt)))
# define SEND_DONT(opt)			(send_option(DONT, (opt)))
# define SEND_WILL(opt)			(send_option(WILL, (opt)))
# define SEND_WONT(opt)			(send_option(WONT, (opt)))

/* RFC2217 Stuff */

# define GET_VALUE_4(p) ( ((int) (*((p)  )) << 24) + ((int) (*((p)+1)) << 16) \
			+ ((int) (*((p)+2)) <<  8) + ((int) (*((p)+3))) )

# define GET_VALUE_1(p) (*(p))

# define SET_VALUE_4(p, val) { \
			*((p))   = (val >> 24) & 0xff; \
			*((p)+1) = (val >> 16) & 0xff; \
			*((p)+2) = (val >> 8) & 0xff; \
			*((p)+3) = val & 0xff; \
			}

# define SET_VALUE_1(p, val) { \
			*((p))   = val & 0xff; \
			}

/* Com port commands and notifications */

/* Client codes  */

# define USR_COM_SIGNATURE			0	/* none, RFC2217 says */
# define USR_COM_SET_BAUDRATE			1
# define USR_COM_SET_DATASIZE			2
# define USR_COM_SET_PARITY			3
# define USR_COM_SET_STOPSIZE			4
# define USR_COM_SET_CONTROL			5
# define USR_COM_NOTIFY_LINESTATE		6
# define USR_COM_NOTIFY_MODEMSTATE		7
# define USR_COM_FLOWCONTROL_SUSPEND		8
# define USR_COM_FLOWCONTROL_RESUME		9
# define USR_COM_SET_LINESTATE_MASK		10
# define USR_COM_SET_MODEMSTATE_MASK		11
# define USR_COM_PURGE_DATA			12

# define NUM_COMCMDS				USR_COM_PURGE_DATA + 1

/*
 * State control of NVT Com Port Commands
 */

int CmdState[NUM_COMCMDS];

# define CMD_INACTIVE				0
# define CMD_ACTIVE				1

# define SET_CMD_ACTIVE(cmd)			(CmdState[(cmd)] = CMD_ACTIVE)
# define CLR_CMD_ACTIVE(cmd)			(CmdState[(cmd)] = CMD_INACTIVE)

# define IS_CMD_ACTIVE(cmd)			(CmdState[(cmd)] == CMD_ACTIVE)

/* Access Server codes */
# define RAS_COM_SIGNATURE			100	/* none, RFC2217 says */
# define RAS_COM_SET_BAUDRATE			101
# define RAS_COM_SET_DATASIZE			102
# define RAS_COM_SET_PARITY			103
# define RAS_COM_SET_STOPSIZE			104
# define RAS_COM_SET_CONTROL			105
# define RAS_COM_NOTIFY_LINESTATE		106
# define RAS_COM_NOTIFY_MODEMSTATE		107
# define RAS_COM_FLOWCONTROL_SUSPEND		108
# define RAS_COM_FLOWCONTROL_RESUME		109
# define RAS_COM_SET_LINESTATE_MASK		110
# define RAS_COM_SET_MODEMSTATE_MASK		111
# define RAS_COM_PURGE_DATA			112

# define RAS_COM_START				RAS_COM_SIGNATURE
# define RAS_COM_END				RAS_COM_PURGE_DATA

/* SET-BAUDRATE Stuff */
# define COM_BAUD_REQ				0
# define COM_BAUD(x)				x

/* SET-DATASIZE Stuff */
# define COM_DSIZE_REQ				0
# define COM_DSIZE(x)				x

/* SET-PARITY Stuff */
# define COM_PARITY_REQ				0
# define COM_PARITY_NONE			1
# define COM_PARITY_ODD				2
# define COM_PARITY_EVEN			3
# define COM_PARITY_MARK			4
# define COM_PARITY_SPACE			5

/* COM-STOPSIZE Stuff */
# define COM_SSIZE_REQ				0
# define COM_SSIZE_ONE				1
# define COM_SSIZE_TWO				2
# define COM_SSIZE_1DOT5			3

/* SET-CONTROL Stuff */
# define COM_OFLOW_REQ				0
# define COM_OFLOW_NONE				1
# define COM_OFLOW_SOFT				2
# define COM_OFLOW_HARD				3

# define COM_BREAK_REQ				4
# define COM_BREAK_ON				5
# define COM_BREAK_OFF				6

# define COM_DTR_REQ				7
# define COM_DTR_ON				8
# define COM_DTR_OFF				9

# define COM_RTS_REQ				10
# define COM_RTS_ON				11
# define COM_RTS_OFF				12

# define COM_IFLOW_REQ				13
# define COM_IFLOW_NONE				14
# define COM_IFLOW_SOFT				15
# define COM_IFLOW_HARD				16

# define COM_DCD_FLOW				17
# define COM_DTR_FLOW				18
# define COM_DSR_FLOW				19

# define COM_FLOW_REQ				COM_OFLOW_REQ
# define COM_FLOW_NONE				COM_OFLOW_NONE
# define COM_FLOW_SOFT				COM_OFLOW_SOFT
# define COM_FLOW_HARD				COM_OFLOW_HARD

/* LINESTATE MASK (COM-LINESTATE-MASK command / NOTIFY-LINESTATE notification*/
# define LINE_TIMEOUT_ERROR			128
# define LINE_SHIFTREG_EMPTY			64
# define LINE_HOLDREG_EMPTY			32
# define LINE_BREAK_ERROR			16
# define LINE_FRAME_ERROR			8
# define LINE_PARITY_ERROR			4
# define LINE_OVERRUN_ERROR			2
# define LINE_DATA_READY			1

/* MODEMSTATE MASK (SET-MODEMSTATE-MASK / NOTIFY-MODEMSTATE */

# define MODEM_DCD				128
# define MODEM_RI				64
# define MODEM_DSR				32
# define MODEM_CTS				16
# define MODEM_DELTA_DCD			8
# define MODEM_TRAIL_RI				4
# define MODEM_DELTA_DSR			2
# define MODEM_DELTA_CTS			1

/* PURGE-DATA Stuff */
# define COM_PURGE_RECV				1
# define COM_PURGE_XMIT				2
# define COM_PURGE_BOTH				3

/*
 * External accessible routines
 */

# ifdef _TSR_TELNET_

# define EXTERN
# else
# define EXTERN extern
# endif

#ifdef INIT_BUFFER
EXTERN int 	tel_init(int netsize, struct buffer *ibp, struct buffer *obp);
EXTERN int	tel_putdata (struct buffer *bp);
#endif
EXTERN int	tel_getdata (void);
EXTERN int 	tel_putcmd (int command, int arg);
EXTERN void	tel_free (void);
EXTERN int	sync_comport_command (int command, int arg);


EXTERN struct nvt	Nvt;

# undef EXTERN

