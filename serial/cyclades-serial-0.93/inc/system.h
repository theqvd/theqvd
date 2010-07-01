/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * system.h
 * Unix system-dependent definitions
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 */

# ifdef _TSR_SYSTEM_

# define EXTERN
# else
# define EXTERN extern
# endif

EXTERN void			mindelay(void);
EXTERN void			sysdelay(int msecs);
EXTERN void			sysmessage(int type, const char * const format, ...);
EXTERN void			doexit(int val);
EXTERN void			init_system(void);
EXTERN unsigned char *		mem_get(int size);
EXTERN void			mem_free(void * ptr);

EXTERN char			Idmsg[128];

# undef EXTERN
