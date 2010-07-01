/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * measure.h
 * Activity measure definitions
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 */

# ifdef _TSR_MEASURE_

# define EXTERN
# else
# define EXTERN extern
# endif

EXTERN void			start_measure(void);
EXTERN void			cpu_measure(int all);

EXTERN int			devreads;
EXTERN int			devnreads;
EXTERN int			devwrites;
EXTERN int			devnwrites;
EXTERN int			netreads;
EXTERN int			netnreads;
EXTERN int			netwrites;
EXTERN int			netnwrites;
EXTERN int			devrbytes;
EXTERN int			devwbytes;
EXTERN int			netrbytes;
EXTERN int			netwbytes;
EXTERN int			ioscheds;

# undef EXTERN
