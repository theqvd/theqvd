/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * tsrsock.h
 * Tsrsock main definitions
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 * 05/09/2002 V.1.0.1
 * Increase buffer sizes
 */

#include "conf.h"

/*
 * PTY and Network I/O sizes
 */

# define	DEV_MAXIOSZ		32768
# define	DEV_DEFIOSZ		1024
# define	SOCK_MAXIOSZ		16384
# define	SOCK_DEFIOSZ		128


/* Delays (in miliseconds) */

# define	RETRY_DELAY	15000
# define	SCHED_DELAY	1000
# define	SERVER_DELAY	1000
# define	NOTIFY_DELAY	1000
# define	OPTION_DELAY	200
# define	ROOM_DELAY	200
# define	COMPORT_DELAY	200

/* Error recovery retries */

# define	BIGNUM		0x7fffffff
# define	NUM_RETRIES	BIGNUM
 
/* modem control for the device */
# define	DEV_MODEM	0	/* Check modem control lines */
# define	DEV_LOCAL	1	/* Don't check them */

/* last tty close behavior */
# define	CLOSE_HANG	0	/* Do hangup on last close */
# define	CLOSE_NOHANG	1	/* Don't do it */

/* Socket / Rtelnet ports */
# define	SOCKET_BASE	31000
# define	RTELNET_BASE	30000
# define	RTELNET_STD	23

/* server type */
# define	SRV_RTELNET	0	/* Reverse telnet */
# define	SRV_SOCKET	1	/* Raw socket */

/* Exit/return error codes */

# define	E_NORMAL	0	/* Normal exit/return */
# define	E_FILEIO	1	/* File access error */
# define	E_PARMINVAL	2	/* Invalid parameter */
# define	E_SIGNAL	3	/* Signal received */
# define	E_CONNECT	4	/* Connection side error */
# define	E_RETRYEND	5	/* Retries exausted */
# define	E_BLOCKED	6	/* A write was blocked */
# define	E_SYSTEM	7	/* A write was blocked */

/* Log Messages */
# define MSG_DEBUG	0
# define MSG_INFO	1
# define MSG_NOTICE	2
# define MSG_WARNING	3
# define MSG_ERR	4
# define MAX_LOG_FILE_SIZE (10*1024)


/* Miscelaneous */

# define	NAMESIZE	64

# ifndef TRUE
# define 	TRUE		1
# define 	FALSE		0
# endif

# ifndef NULL
# define NULL			0
# endif

# ifndef min
# define min(a,b) ((a) < (b) ? (a) : (b))
# endif
# ifndef max
# define max(a,b) ((a) > (b) ? (a) : (b))
# endif


typedef int			(*PFI)();
typedef void			(*PFV)();

# ifdef _TSR_TSRSOCK_

# define EXTERN
# else
# define EXTERN extern
# endif

EXTERN char *			Pgname;
EXTERN int 			Debug;
EXTERN int 			Console;
EXTERN int 			Foreground;
EXTERN char * 			LogFile;

# undef EXTERN
