
/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#include <stdio.h>
#include <errno.h>
#include <time.h>
#include <sys/types.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include "tcpconnect.h"

static int _tcpconnect_debug = 0;

void tcpconnect_set_debug() {
  _tcpconnect_debug = 1;
}
void tcpconnect_unset_debug() {
  _tcpconnect_debug = 1;
}

#ifdef __MACH__
#define CLOCK_REALTIME 0
int clock_gettime(int notused, struct timespec *t ) {
    struct timeval now;
    int rv = gettimeofday(&now, NULL);
    if (rv) return rv;
    t->tv_sec=now.tv_sec;
    t->tv_nsec=now.tv_usec * 1000;
    return 0;
}

#endif

#define _tcpconnect_perror(str) if (_tcpconnect_debug) perror(str);

int tcpconnect(  struct sockaddr_in *addr, long timeoutsec, long timeoutnano) { 
  struct timeval tv;
  int s, res, valopt, myerrno;
  long fcntlarg;
  fd_set myset;
  socklen_t lon;

  /* Create socket */
  if ((s = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
    _tcpconnect_perror("socket");
    return errno;
  } 


  /* Set non blocking */
  if ((fcntlarg = fcntl(s, F_GETFL, NULL)) < 0) {
    _tcpconnect_perror("fcntl GETFL");
    close(s);
    return errno;    
  }
  fcntlarg |= O_NONBLOCK;
  if (fcntl(s, F_SETFL, fcntlarg) < 0) {
    _tcpconnect_perror("fcntl SETFL");
    close(s);
    return errno;
  }

  /* connect */
  res = connect(s, (struct sockaddr *) addr, sizeof(*addr));
  if (res == -1 && errno != EINPROGRESS) {
	myerrno = errno;
	_tcpconnect_perror("connect");
	close(s);
	return myerrno;
  }
  if (res == -1 && errno == EINPROGRESS) {
    while (1) {
      tv.tv_sec = timeoutsec;
      tv.tv_usec = (int) (timeoutnano / 1000);
      FD_ZERO(&myset);
      FD_SET(s, &myset);
      res = select(s+1, NULL, &myset, NULL, &tv);
      /* EINTR */
      if (res < 0 && errno == EINTR) {
	continue;
      }
      /* Error */
      if (res < 0 && errno != EINTR) {
	myerrno = errno;
	_tcpconnect_perror("select");
	close(s);
	return myerrno;
      }
      /* timeout */
      if (res == 0) {
	errno = ETIMEDOUT;
	_tcpconnect_perror("timeout");
	close(s);
	return ETIMEDOUT;
      }
      /* res > 0 */
      if (res > 0) {
	lon = sizeof(int);
	if (getsockopt(s, SOL_SOCKET, SO_ERROR, (void *)(&valopt), &lon) < 0) {
	  myerrno = errno;
	  _tcpconnect_perror("getsockopt SO_ERROR");
	  close(s);
	  return myerrno;
	}
	if (valopt) {
	  errno = valopt;
	  _tcpconnect_perror("getsockopt SO_ERROR valopt");
	  close(s);
	  return valopt;
	}
	break;
      }
      /* Should never reach here */
      fprintf(stderr, "Error should never get here\n");
    }
  }

  /* Close socket */
  if (close(s)) {
    _tcpconnect_perror("close");
    return errno;
  }
  errno = 0;
  return 0;
}

/* 
 * Returns 1 if the specified timeout has passed and 0 otherwise
 */
int _tcpconnect_timeout(struct timespec *begin_time, long timeoutsec, long timeoutnano) {
  int timeout;
  struct timespec cur_time;
  clock_gettime(CLOCK_REALTIME, &cur_time);
  long limitsec = begin_time->tv_sec + timeoutsec;
  long limitnano = begin_time->tv_nsec + timeoutnano;
  timeout = (cur_time.tv_sec > limitsec) ||
    ((cur_time.tv_sec == limitsec) && (cur_time.tv_nsec == limitnano))
    ;
  return timeout;
}

int wait_for_tcpconnect(const char *host, int port, long timeoutsec, long timeoutnano) {
  int connect_ret, timeout;
  struct timespec begin_time;
  struct sockaddr_in addr;

  addr.sin_family = AF_INET;
  addr.sin_port = htons(port);
  addr.sin_addr.s_addr = inet_addr(host);

  if (addr.sin_addr.s_addr == INADDR_NONE) {
    fprintf(stderr, "Error converting host to inet address: %s\n", host);
    return -1;
  }

  clock_gettime(CLOCK_REALTIME, &begin_time);
  do {
    connect_ret = tcpconnect(&addr, TCPCONNECT_TO_SEC, TCPCONNECT_TO_USEC);
    timeout = _tcpconnect_timeout(&begin_time, timeoutsec, timeoutnano);
  } while (connect_ret != 0 && !timeout);

  return connect_ret;
}
