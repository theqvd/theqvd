/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * dev.h
 * Unix Pty Device definitions
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 */

/*
 * Message types (returned by dev_probe())
 */

# define PROBE_DATA	1
# define PROBE_EOF	2
# define PROBE_FLUSH	3
# define PROBE_CLOCAL	4
# define PROBE_GENERIC	5

# ifdef _TSR_DEV_

# define EXTERN
# else
# define EXTERN extern
# endif

EXTERN int	dev_getaddr(char *dname);
EXTERN void	dev_free(void);
EXTERN void	dev_unlink(void);
EXTERN int	dev_init(int iosize, int devmodem, int closemode,
		struct buffer *ibp, struct buffer *obp, struct comport *cp);
EXTERN int	dev_config (void);
EXTERN int	dev_closeslave(void);
EXTERN int	dev_probe(void);
EXTERN int	dev_getdata(void);
EXTERN int	dev_putdata(struct buffer *bp);
EXTERN void	dev_interrupt(void);
EXTERN void	dev_hangup(void);

EXTERN struct pty 		Pty;
/* handle for pty master */
EXTERN int			P_mfd;
/* handle for pty slave */
EXTERN int			P_sfd;
/* handle for control socket listener */
EXTERN int			P_contr_listen;
/* handle for control socket */
#define MAX_CONTROL_SOCKS 32
EXTERN int			P_contr[MAX_CONTROL_SOCKS];
/* struct for port information */
EXTERN struct comport		Comport;
/* device name */
EXTERN char			P_devname[NAMESIZE];
/* control socket name */
EXTERN char			P_contrname[108];

# undef EXTERN
