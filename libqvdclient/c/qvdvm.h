#ifndef _QVDVM_H
#define _QVDVM_H
#include "qvdclient.h"

vm *QvdVmNew(int64_t id, const char *name, const char *state, int64_t blocked);
void QvdVmFree(vm *ptr);
void QvdVmListInit(vmlist *ptr);
void QvdVmListAppendVm(qvdclient *qvd, vmlist *vmlistptr, vm *vmptr);
void QvdVmListFree(vmlist *vmlistptr);

#endif
