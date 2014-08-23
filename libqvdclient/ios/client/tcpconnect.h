/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */
#ifndef _TCPCONNECT_H
#define _TCPCONNECT_H

#include <arpa/inet.h>

/* 
 * Timeouts for each connect call
 */
#define TCPCONNECT_TO_SEC 0
#define TCPCONNECT_TO_USEC 200000

/* 
 * Does a TCP connect to the specified host and port
 * Returns:
 * 0 on success
 * != 0 otherwise. It will return error as in errno
 * from the last socket operation
 */
int tcpconnect(struct sockaddr_in *addr, long timeoutsec, long timeoutnano);

/* 
 * wait for the specified timeout until the port is up and responds to a TCP
 * connection
 * Returns:
 * 0: if the tcp port is up in the specified timeout
 * != 0: On timeout. It will return the errno of the last socket operation that failed.
 * Returns -1, if an error in host or port is detected.
 */
int wait_for_tcpconnect(const char *host, int port, long timeoutsec, long timeoutnano);

void tcpconnect_set_debug();
void tcpconnect_unset_debug();

#endif
