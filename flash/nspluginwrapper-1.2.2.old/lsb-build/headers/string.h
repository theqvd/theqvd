#ifndef _STRING_H_
#define _STRING_H_

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif





    extern void *__mempcpy(void *, const void *, size_t);
    extern char *__stpcpy(char *, const char *);
    extern char *__strtok_r(char *, const char *, char **);
    extern void bcopy(const void *, void *, size_t);
    extern void *memchr(const void *, int, size_t);
    extern int memcmp(const void *, const void *, size_t);
    extern void *memcpy(void *, const void *, size_t);
    extern void *memmem(const void *, size_t, const void *, size_t);
    extern void *memmove(void *, const void *, size_t);
    extern void *memset(void *, int, size_t);
    extern char *strcat(char *, const char *);
    extern char *strchr(const char *, int);
    extern int strcmp(const char *, const char *);
    extern int strcoll(const char *, const char *);
    extern char *strcpy(char *, const char *);
    extern size_t strcspn(const char *, const char *);
    extern char *strerror(int);
    extern size_t strlen(const char *);
    extern char *strncat(char *, const char *, size_t);
    extern int strncmp(const char *, const char *, size_t);
    extern char *strncpy(char *, const char *, size_t);
    extern char *strpbrk(const char *, const char *);
    extern char *strrchr(const char *, int);
    extern char *strsignal(int);
    extern size_t strspn(const char *, const char *);
    extern char *strstr(const char *, const char *);
    extern char *strtok(char *, const char *);
    extern size_t strxfrm(char *, const char *, size_t);
    extern int bcmp(const void *, const void *, size_t);
    extern void bzero(void *, size_t);
    extern int ffs(int);
    extern char *index(const char *, int);
    extern void *memccpy(void *, const void *, int, size_t);
    extern char *rindex(const char *, int);
    extern int strcasecmp(const char *, const char *);
    extern char *strdup(const char *);
    extern int strncasecmp(const char *, const char *, size_t);
    extern char *strndup(const char *, size_t);
    extern size_t strnlen(const char *, size_t);
    extern char *strsep(char **, const char *);
    extern char *strerror_r(int, char *, size_t);
    extern char *strtok_r(char *, const char *, char **);
    extern char *strcasestr(const char *, const char *);
    extern char *stpcpy(char *, const char *);
    extern char *stpncpy(char *, const char *, size_t);
    extern void *memrchr(const void *, int, size_t);
#ifdef __cplusplus
}
#endif
#endif
