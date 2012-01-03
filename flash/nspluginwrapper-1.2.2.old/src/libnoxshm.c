#include <stdio.h>
#include <string.h>

/*
 * This is a simple hacky library that disables the SHM-MIT and XVideo extenstions on any X application requesting
 * it. To compile this run
 *
 * gcc -shared -ldl -o noshm.so noshm.c
 *
 * Author:  Alexander Graf
 *          SuSE Linux Products GmbH
 *
 * License: Public Domain
 *
 */

int (*real_XQueryExtension)(register void *dpy,const char *name,int *major_opcode,int *first_event,int *first_error) = NULL;
void *RTLD_NEXT = (void*)-1l;
void *dlsym(void *handle, const char *symbol);

int
XQueryExtension(
    register void *dpy,
    const char *name,
    int *major_opcode,
    int *first_event,
    int *first_error)
{       
	if(!strcmp(name, "MIT-SHM")) return 0;
	if(!strcmp(name, "XVideo")) return 0;
	if(!real_XQueryExtension) {
	    real_XQueryExtension = dlsym(RTLD_NEXT, "XQueryExtension");
	}
	return real_XQueryExtension(dpy, name, major_opcode, first_event, first_error);
}
