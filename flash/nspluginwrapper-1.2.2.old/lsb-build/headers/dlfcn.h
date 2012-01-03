#ifndef _DLFCN_H_
#define _DLFCN_H_


#ifdef __cplusplus
extern "C" {
#endif


#define RTLD_NEXT	((void *) -1l)
#define RTLD_LOCAL	0
#define RTLD_LAZY	0x00001
#define RTLD_NOW	0x00002
#define RTLD_GLOBAL	0x00100


    typedef struct {
	char *dli_fname;
	void *dli_fbase;
	char *dli_sname;
	void *dli_saddr;
    } Dl_info;


    extern int dladdr(const void *, Dl_info *);
    extern int dlclose(void *);
    extern char *dlerror(void);
    extern void *dlopen(const char *, int);
    extern void *dlsym(void *, const char *);
#ifdef __cplusplus
}
#endif
#endif
