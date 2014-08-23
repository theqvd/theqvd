/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */

#ifndef QVDBUFFER_H
#define QVDBUFFER_H

typedef struct {
    char data[BUFFER_SIZE];
    int offset;
    int size;
} QvdBuffer;


#endif
