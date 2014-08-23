/*
 * Copyright 2009-2014 by Qindel Formacion y Servicios S.L.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU GPL version 3 as published by the Free
 * Software Foundation
 *
 */
#ifndef _QVDVM_H
#define _QVDVM_H
#include "qvdclient.h"

vm *QvdVmNew(int id, const char *name, const char *state, int blocked);
void QvdVmFree(vm *ptr);
void QvdVmListInit(vmlist *ptr);
void QvdVmListAppendVm(qvdclient *qvd, vmlist *vmlistptr, vm *vmptr);
void QvdVmListFree(vmlist *vmlistptr);

#endif
