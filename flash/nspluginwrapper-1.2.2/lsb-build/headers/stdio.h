#ifndef _STDIO_H_
#define _STDIO_H_

#include <sys/types.h>
#include <unistd.h>
#include <wctype.h>
#include <stddef.h>
#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif


#define EOF	(-1)
#define P_tmpdir	"/tmp"
#if __i386__
#define __IO_FILE_SIZE	148
#endif
#if __powerpc__ && !__powerpc64__
#define __IO_FILE_SIZE	152
#endif
#if __s390__ && !__s390x__
#define __IO_FILE_SIZE	152
#endif
#define FOPEN_MAX	16
#define L_tmpnam	20
#if __ia64__
#define __IO_FILE_SIZE	216
#endif
#if __powerpc64__
#define __IO_FILE_SIZE	216
#endif
#if __x86_64__
#define __IO_FILE_SIZE	216
#endif
#if __s390x__
#define __IO_FILE_SIZE	216
#endif
#define FILENAME_MAX	4096
#define BUFSIZ	8192
#define L_ctermid	9
#define L_cuserid	9


    typedef struct {
	off_t __pos;
	mbstate_t __state;
    } fpos_t;

    typedef struct {
	off64_t __pos;
	mbstate_t __state;
    } fpos64_t;

    struct _IO_FILE {
	char dummy[__IO_FILE_SIZE];
    };


/* The opaque type of streams.*/


    typedef struct _IO_FILE FILE;





/* The possibilities for the third argument to `setvbuf'.*/
#define _IOFBF	0
#define _IOLBF	1
#define _IONBF	2



/* The possibilities for the third argument to `fseek'.*/



/* End of file character.*/



    extern char *const _sys_errlist[128];
    extern void clearerr(FILE *);
    extern int fclose(FILE *);
    extern FILE *fdopen(int, const char *);
    extern int fflush_unlocked(FILE *);
    extern int fileno(FILE *);
    extern FILE *fopen(const char *, const char *);
    extern int fprintf(FILE *, const char *, ...);
    extern int fputc(int, FILE *);
    extern FILE *freopen(const char *, const char *, FILE *);
    extern FILE *freopen64(const char *, const char *, FILE *);
    extern int fscanf(FILE *, const char *, ...);
    extern int fseek(FILE *, long int, int);
    extern int fseeko(FILE *, off_t, int);
    extern int fseeko64(FILE *, loff_t, int);
    extern off_t ftello(FILE *);
    extern loff_t ftello64(FILE *);
    extern int getchar(void);
    extern int getchar_unlocked(void);
    extern int getw(FILE *);
    extern int pclose(FILE *);
    extern void perror(const char *);
    extern FILE *popen(const char *, const char *);
    extern int printf(const char *, ...);
    extern int putc_unlocked(int, FILE *);
    extern int putchar(int);
    extern int putchar_unlocked(int);
    extern int putw(int, FILE *);
    extern int remove(const char *);
    extern void rewind(FILE *);
    extern int scanf(const char *, ...);
    extern void setbuf(FILE *, char *);
    extern int sprintf(char *, const char *, ...);
    extern int sscanf(const char *, const char *, ...);
    extern FILE *stderr;
    extern FILE *stdin;
    extern FILE *stdout;
    extern char *tempnam(const char *, const char *);
    extern FILE *tmpfile64(void);
    extern FILE *tmpfile(void);
    extern char *tmpnam(char *);
    extern int vfprintf(FILE *, const char *, va_list);
    extern int vprintf(const char *, va_list);
    extern int feof(FILE *);
    extern int ferror(FILE *);
    extern int fflush(FILE *);
    extern int fgetc(FILE *);
    extern int fgetpos(FILE *, fpos_t *);
    extern char *fgets(char *, int, FILE *);
    extern int fputs(const char *, FILE *);
    extern size_t fread(void *, size_t, size_t, FILE *);
    extern int fsetpos(FILE *, const fpos_t *);
    extern long int ftell(FILE *);
    extern size_t fwrite(const void *, size_t, size_t, FILE *);
    extern int getc(FILE *);
    extern char *gets(char *);
    extern int putc(int, FILE *);
    extern int puts(const char *);
    extern int setvbuf(FILE *, char *, int, size_t);
    extern int snprintf(char *, size_t, const char *, ...);
    extern int ungetc(int, FILE *);
    extern int vsnprintf(char *, size_t, const char *, va_list);
    extern int vsprintf(char *, const char *, va_list);
    extern void flockfile(FILE *);
    extern int asprintf(char **, const char *, ...);
    extern int fgetpos64(FILE *, fpos64_t *);
    extern FILE *fopen64(const char *, const char *);
    extern int fsetpos64(FILE *, const fpos64_t *);
    extern int ftrylockfile(FILE *);
    extern void funlockfile(FILE *);
    extern int getc_unlocked(FILE *);
    extern void setbuffer(FILE *, char *, size_t);
    extern int vasprintf(char **, const char *, va_list);
    extern int vdprintf(int, const char *, va_list);
    extern int vfscanf(FILE *, const char *, va_list);
    extern int vscanf(const char *, va_list);
    extern int vsscanf(const char *, const char *, va_list);
    extern size_t __fpending(FILE *);
#ifdef __cplusplus
}
#endif
#endif
