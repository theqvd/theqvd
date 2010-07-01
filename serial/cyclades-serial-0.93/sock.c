/*
 *
 * Copyright (C) Cyclades Corporation, 1999-1999. All rights reserved.
 *
 *
 * sock.c
 * Unix socket routines 
 *
 * History
 * 08/16/1999 V.1.0.0 Initial revision
 *
 */

# include <sys/types.h>
# include <sys/socket.h>
# include <sys/ioctl.h>
# include <fcntl.h>
# include <netinet/in.h>
# include <arpa/inet.h>
# include <netdb.h>
# include <errno.h>
# include <string.h>
# include <unistd.h>
# include <stdio.h>

# define _TSR_SOCK_

#include "inc/cyclades-ser-cli.h"
#include "inc/system.h"
#include "inc/tsrio.h"
#include "inc/sock.h"

#ifdef TSR_MEASURE
#include "inc/tsrmeasure.h"
#endif

#ifndef INADDR_NONE
#define INADDR_NONE 0xffffffff
#endif

/*
 * Internal Variables
 */

struct sockaddr_in S_inaddr;

int
sock_getaddr(char *host, int base, int physport)
{

    struct sockaddr_in *sp = &S_inaddr;
    struct hostent *hp;
    int tcpport;

    if ((hp = gethostbyname(host)) != (struct hostent *) NULL) {
	memcpy((char *) &sp->sin_addr, hp->h_addr, hp->h_length);
	sp->sin_family = hp->h_addrtype;
    }
    else if ((sp->sin_addr.s_addr = inet_addr(host)) != INADDR_NONE) {
	sp->sin_family = AF_INET;
    }
    else {
	sysmessage(MSG_ERR, "%s: No such host\n", host);
	return (E_PARMINVAL);
    }

    tcpport = base + physport;

    sp->sin_port = htons(tcpport);

    sysmessage(MSG_NOTICE, "Using %s:%d socket\n",
	       inet_ntoa(sp->sin_addr), tcpport);
    return (E_NORMAL);

}

int
sock_link(int iosize)
{

    int fd;
    struct sockaddr_in *sp = &S_inaddr;
    int flag;
    char dummy[4];
    int bufsize;

    if ((fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) == -1) {
	sysmessage(MSG_ERR,
		   "Can't create a socket for communication : %s\n",
		   strerror(errno));
	return (E_FILEIO);
    }

    bufsize = 2 * iosize;

    if (setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &bufsize, sizeof(int))
	== -1) {
	sysmessage(MSG_ERR, "Can't set socket buffer size : %s\n",
		   strerror(errno));
	return (E_FILEIO);
    }
    if (connect(fd, (struct sockaddr *) sp, sizeof(struct sockaddr_in))
	== -1) {
	sysmessage(MSG_WARNING,
		   "Can't initiate connection on a socket : %s\n",
		   strerror(errno));
	close(fd);
	return (E_CONNECT);
    }

# ifdef USE_FIONBIO
    flag = 1;
    if (ioctl(fd, FIONBIO, &flag) == -1) {
	sysmessage(MSG_ERR,
		   "Can't set non-block on a socket : %s\n", strerror(errno));
	close(fd);
	return (E_FILEIO);
    }
# else
    if ((flag = fcntl(fd, F_GETFL, 0)) == -1) {
	sysmessage(MSG_ERR,
		   "Can't get file flags of a socket : %s\n",
		   strerror(errno));
	close(fd);
	return (E_FILEIO);
    }
# ifdef USE_STD_NDELAY
    flag |= O_NDELAY;
# elif defined USE_POSIX_NONBLOCK
    flag |= O_NONBLOCK;
# else
    close(fd);
    return (E_PARMINVAL);	/* Socket must be in non_blockin mode */
# endif
    if (fcntl(fd, F_SETFL, flag) == -1) {
	sysmessage(MSG_ERR,
		   "Can't set file flags of a socket : %s\n",
		   strerror(errno));
	close(fd);
	return (E_FILEIO);
    }
# endif
    sysdelay(SERVER_DELAY);	/* Wait server startup */

    if (recv(fd, dummy, 0, 0) == -1) {
	if (errno != EAGAIN && errno != EWOULDBLOCK) {
	    sysmessage(MSG_WARNING,
		       "Can't initiate connection on a socket : (recv) %s\n",
		       strerror(errno));
	    close(fd);
	    return (E_CONNECT);
	}
    }
    S_fd = fd;
    return (E_NORMAL);
}

int
sock_unlink(void)
{
    (void) close(S_fd);

    return (E_NORMAL);
}

/*
 * Network routines using BSD socket interface
 */


int
sock_write(unsigned char *buf, int n)
{

    int ret;

    if ((ret = send(S_fd, buf, n, 0)) < 0) {
	if (errno == EAGAIN || errno == EWOULDBLOCK) {
	    ret = 0;
	}
	else {
	    sysmessage(MSG_ERR, "send : %s\n", strerror(errno));
	}
    }
# ifdef TSR_MEASURE
    if (ret > 0) {
	netwrites++;
	netwbytes += ret;
    }
    else {
	netnwrites++;
    }
# endif

    return (ret);
}

int
sock_read(unsigned char *buf, int n)
{
    register int ret;
    int tot;
    int rcnt;

    tot = rcnt = 0;

    do {
	if ((ret = recv(S_fd, buf, n, 0)) > 0) {
	    tot += ret;
	    buf += ret;
	    n -= ret;

# ifdef TSR_MEASURE
	    netreads++;
	    netrbytes += ret;
# endif
# ifdef BRAKES_ON
	    /* Delays to avoid system overload on small reads */
	    mindelay();
	    if (rcnt++) {
		if (n > 0) {
		    rcnt = 0;
		    delay(100);
		}
	    }
# endif
	}
	else if (ret < 0) {
	    if (errno == EAGAIN || errno == EWOULDBLOCK) {
		ret = 0;
	    }
	    else {
		sysmessage(MSG_ERR, "recv : %s\n", strerror(errno));
	    }
	}
# ifdef TSR_MEASURE
	if (ret == 0) {
	    netnreads++;
	}
# endif
    } while (n > 0 && ret > 0);
    if (ret >= 0) {
	ret = tot;
    }

    return (ret);
}
