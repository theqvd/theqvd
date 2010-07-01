/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * sock.h
 * Unix socket definitions 
 *
 * History
 * 08/16/1999 V.1.0.0 Initial revision
 *
 */

# ifdef _TSR_SOCK_

# define EXTERN
# else
# define EXTERN extern
# endif

EXTERN int	sock_getaddr (char *host, int base, int physport);
EXTERN int	sock_link(int iosize);
EXTERN int	sock_unlink(void);
EXTERN int	sock_write (unsigned char *buf, int n);
EXTERN int	sock_read(unsigned char *buf, int n);

EXTERN int	S_fd;

# undef EXTERN
