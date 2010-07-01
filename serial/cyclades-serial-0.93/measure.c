/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * measure.c
 * Activity measure
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 */


# include <sys/types.h>
# include <sys/param.h>
# include <sys/times.h>

# define _TSR_MEASURE_

#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrmeasure.h"

# ifdef TSR_MEASURE

/*
 * Internal Variables
 */

static int progst;
static int progend;

void
start_measure(void)
{
    struct tms ts;

    progst = times(&ts);
}

void
cpu_measure(int all)
{
    struct tms ts;
    int usr, sys, tot, pru, prs, prt, msecu, msecs, msect, secs;

    progend = times(&ts);

    usr = (int) ts.tms_utime;
    sys = (int) ts.tms_stime;
    tot = progend - progst;

    pru = usr * 100 / tot;
    prs = sys * 100 / tot;
    prt = pru + prs;

    msecu = 1000 * usr / HZ;
    msecs = 1000 * sys / HZ;
    msect = msecu + msecs;

    printf("%s: \n\
	%5d ms (%2d%%) user, %5d ms (%2d%%) sys, %5d ms (%3d%%) total\n", Idmsg, msecu, pru, msecs, prs, msect, prt);

    if (all) {
	secs = tot / HZ;
	if (secs == 0)
	    secs = 1;
	if (devreads == 0)
	    devreads = 1;
	if (devwrites == 0)
	    devwrites = 1;
	if (netreads == 0)
	    netreads = 1;
	if (netwrites == 0)
	    netwrites = 1;

	printf("%s:\n\
	devrds : %6d (%6d null) , %3d  reads/sec, %.2f bytes/read)\n\
	devwrs : %6d (%6d null) , %3d writes/sec, %.2f bytes/write)\n", Idmsg, devreads, devnreads, devreads / secs, (double) devrbytes / devreads, devwrites, devnwrites, devwrites / secs, (double) devwbytes / devwrites);

	printf("%s:\n\
	netrds : %6d (%6d null) , %3d  reads/sec, %.2f bytes/read)\n\
	netwrs : %6d (%6d null) , %3d writes/sec, %.2f bytes/write)\n", Idmsg, netreads, netnreads, netreads / secs, (double) netrbytes / netreads, netwrites, netnwrites, netwrites / secs, (double) netwbytes / netwrites);

	printf("%s:\n\
	scheds : %6d (%3d scheds/sec)\n", Idmsg, ioscheds, ioscheds / secs);

    }
}

# endif
