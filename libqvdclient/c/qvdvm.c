#include <stdlib.h>
#include <string.h>
#include "qvdclient.h"
vm *QvdVmNew(int id, const char *name, const char *state, int blocked) {
  vm *ptr;
  if (!(ptr = malloc(sizeof(vm)))) {
    return NULL;
  }

  ptr->id = id;
  ptr->name = strdup(name);
  ptr->state = strdup(state);
  ptr->blocked = blocked;
  return ptr;
}

void QvdVmFree(vm *ptr) {
  free(ptr->state);
  free(ptr->name);
  free(ptr);
}

void QvdVmListInit(vmlist *ptr) {
  ptr->data = NULL;
  ptr->next = NULL;
}

void QvdVmListAppendVm(qvdclient *qvd, vmlist *vmlistptr, vm *vmptr) {
  vmlist *ptr;
  if (vmptr == NULL) {
    return;
  }
  if (vmlistptr->data == NULL) {
    vmlistptr->data = vmptr;
    vmlistptr->next = NULL;
    return;
  }
  ptr = vmlistptr;
  while(ptr->next != NULL) {
    ptr = ptr->next;
  }
  if (!(ptr->next=malloc(sizeof(vmlist)))) {
    qvd_error(qvd, "Error allocating memory for list of Virtual Machines");
    return;
  }
  ptr->next->data = vmptr;
  ptr->next->next = NULL;
}

void QvdVmListFree(vmlist *vmlistptr) {
  vmlist *ptr, *ptrtofree;
  if (vmlistptr->data == NULL) {
    free(vmlistptr);
    return;
  }
  ptr = vmlistptr;
  while(ptr->next != NULL) {
    QvdVmFree(ptr->data);
    ptrtofree = ptr;
    ptr = ptr->next;
    free(ptrtofree);
  }
  
}
