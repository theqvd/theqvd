/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * tsrsock.c
 * cyclades-ser-cli main code
 *
 * History
 * 08/17/1999 V.1.0.0 Initial revision
 *
 * 17/12/1999 V.1.0.1 Version was changed to 1.0.1
 *
 * Oct-27-2001 V.1.0.2
 *	Program version has changed to 1.2.0
 *	Retry message now is of Warning type 
 */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

# define _TSR_TSRSOCK_

#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrio.h"
#include "inc/sock.h"
#include "inc/dev.h"
#include "inc/misc.h"
#include "inc/telnet.h"
#include <sys/socket.h>
#include <sys/un.h>
#include <signal.h>

int P_contr[MAX_CONTROL_SOCKS], P_contr_listen;

/*
 * Internal Variables
 */

static const char *const Version =
    "cyclades-ser-cli " TSRDEV_VERSION " " TSRDEV_DATE;

/*
 * Internal Functions
 */

#ifndef HAVE_DAEMON
#include "inc/daemon.h"
#endif

static void helpmsg(void);
static void mkidmsg(char *pgname, char *device);

int
main(int argc, char **argv)
{
    int i;
    char *device;
    char *rasname;
    int physport;
    int ptyiosize;
    int netiosize;
    int retrydelay;
    int retry, nretries;
    int opt;
    int retst;
    int devmodem;
    int closemode;
    int baseport;
    struct sockaddr_un control_addr;
    struct sigaction act;
    struct stat stat_buf;

    act.sa_handler = SIG_IGN;
    if (sigaction(SIGPIPE, &act, NULL))
	sysmessage(MSG_ERR, "Can't block SIGPIPE.\n");

    ptyiosize = DEV_DEFIOSZ;
    netiosize = SOCK_DEFIOSZ;
    retrydelay = RETRY_DELAY;
    nretries = NUM_RETRIES;
    Nvt.servertype = SRV_RTELNET;
    devmodem = DEV_MODEM;
    closemode = CLOSE_HANG;
    baseport = 0;

    Console = FALSE;
    Foreground = FALSE;
    LogFile = NULL;

    Pgname = argv[0];
    Debug = 0;

    while ((opt = getopt(argc, argv, "u:n:r:fi:st:m:c:p:d:xvhHl:")) != EOF) {
	switch (opt) {
	case 'u':
	    ptyiosize = atoi(optarg);
	    if (ptyiosize > DEV_MAXIOSZ) {
		ptyiosize = DEV_MAXIOSZ;
	    }
	    break;
	case 'n':
	    netiosize = atoi(optarg);
	    if (netiosize > SOCK_MAXIOSZ) {
		netiosize = SOCK_MAXIOSZ;
	    }
	    break;
	case 'r':
	    nretries = atoi(optarg);
	    break;
	case 'f':
	    Foreground = TRUE;
	    break;
	case 'i':
	    retrydelay = atoi(optarg) * 1000;
	    break;
	case 's':
	    Nvt.servertype = SRV_SOCKET;
	    if (!baseport)
		baseport = SOCKET_BASE;
	    break;
	case 'm':
	    devmodem = atoi(optarg);
	    break;
	case 'c':
	    closemode = atoi(optarg);
	    break;
	case 'p':
	    baseport = atoi(optarg);
	    break;
	case 'd':
	    Debug = atoi(optarg);
	    break;
	case 'x':
	    Console = TRUE;
	    Foreground = TRUE;
	    break;
	case 'v':
	    printf("%s\n", Version);
	    exit(E_NORMAL);
	case 'l':
	    LogFile = strdup(optarg);
	    break;
	case 'h':
	case 'H':
	default:
	    helpmsg();
	    exit(E_PARMINVAL);
	}
    }
    if (!baseport)
	baseport = RTELNET_BASE;

    argc -= optind;
    argv += optind;

    if (argc != 3) {
	helpmsg();
	exit(E_PARMINVAL);
    }

    device = argv[0];

    mkidmsg(Pgname, device);

    rasname = argv[1];

    physport = atoi(argv[2]);

    if (physport == 0) {
	if (Nvt.servertype == SRV_RTELNET) {
	    baseport = RTELNET_STD;
	}
	else {
	    fprintf(stderr,
		    "%s: Physical port must be > 0 for socket service\n",
		    Idmsg);
	    exit(E_PARMINVAL);
	}
    }

    init_system();

/* Get socket and device addresses */

    if ((retst = dev_getaddr(device)) != E_NORMAL) {
	exit(retst);
    }

    if (Nvt.servertype == SRV_RTELNET) {
	P_contr_listen = socket(PF_UNIX, SOCK_STREAM, 0);
	if (P_contr_listen == -1) {
	    sysmessage(MSG_ERR, "Can't create Unix socket.\n");
	    exit(1);
	}
	control_addr.sun_family = AF_UNIX;
	snprintf(P_contrname, sizeof(P_contrname), "%s.control", device);
	P_contrname[sizeof(P_contrname) - 1] = '\0';
	if (!stat(P_contrname, &stat_buf)) {
	    sysmessage(MSG_WARNING, "Removing old control socket \"%s\".\n",
		       P_contrname);
	    unlink(P_contrname);
	}
	strcpy(control_addr.sun_path, P_contrname);
	if (bind
	    (P_contr_listen, (struct sockaddr *) &control_addr,
	     sizeof(control_addr)) || listen(P_contr_listen, 8)) {
	    sysmessage(MSG_ERR, "Can't bind Unix socket.\n");
	    exit(1);
	}
	for (i = 0; i < MAX_CONTROL_SOCKS; i++)
	    P_contr[i] = -1;
    }

    if ((retst = sock_getaddr(rasname, baseport, physport)) != E_NORMAL)
	exit(retst);


    retry = 0;

    if (!Foreground)
	daemon(0, 0);

    while (retry < nretries) {

	if (retry) {
	    if (retrydelay) {
		sysdelay(retrydelay);
	    }
	    sysmessage(MSG_WARNING, "Trying again ... \n");
	}


	if ((retst = sock_link(netiosize)) != E_NORMAL) {
	    if (retst != E_CONNECT) {
		doexit(retst);
	    }
	    retry++;
	    continue;
	}

	retry = 0;

	tsr_init(netiosize, ptyiosize, devmodem, closemode);

/* Main scheduler */

	tsr_io();

	retry++;
    }

    sysmessage(MSG_ERR, "Exiting ...\n");

    doexit(E_RETRYEND);

    /* Not Reached */
    return 0;			/* gcc gives a warning otherwise */
}

static void
helpmsg(void)
{
    fprintf(stderr,
	    "Usage: cyclades-ser-cli [options] devname rasname physport\n");
    fprintf(stderr, "\toptions:\n");
    fprintf(stderr, "\t\t[-h] [-v] [-x]\n");
    fprintf(stderr, "\t\t[-u ptyiosize]  [-n netiosize] [-i retrydelay]\n");
    fprintf(stderr, "\t\t[-r numretries] [-t devtype]   [-s servertype]\n");
    fprintf(stderr, "\t\t[-m devmodem]   [-c closemode] [-p startport]\n");
    fprintf(stderr, "\t\t[-d deblevel]\n");
    fprintf(stderr, "\t\t[-l logfile]\n");
}


static void
mkidmsg(char *pgname, char *device)
{
    char *cp;
    if ((cp = strrchr(pgname, '/')) != (char *) NULL) {
	cp++;
    }
    else {
	cp = pgname;
    }
    Pgname = cp;
    sprintf(Idmsg, "%7s %s", cp, device);
}
