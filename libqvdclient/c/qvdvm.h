#ifndef _QVDVM_H
#define _QVDVM_H
#include "qvdclient.h"

vm *QvdVmNew(int id, const char *name, const char *state, int blocked);
void QvdVmFree(vm *ptr);
void QvdVmListInit(vmlist *ptr);
void QvdVmListAppendVm(qvdclient *qvd, vmlist *vmlistptr, vm *vmptr);
void QvdVmListFree(vmlist *vmlistptr);

#endif
