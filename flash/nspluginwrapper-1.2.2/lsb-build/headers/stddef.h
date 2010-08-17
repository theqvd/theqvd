#ifndef _STDDEF_H_
#define _STDDEF_H_


#ifdef __cplusplus
extern "C" {
#endif


#define offsetof(TYPE,MEMBER)	((size_t)&((TYPE*)0)->MEMBER)

#if !defined(__cplusplus)

#define NULL	(void*)(0)

    typedef int wchar_t;

#endif
#if __ia64__
/* IA64 */
    typedef long int ptrdiff_t;

#endif
#if __i386__
/* IA32 */
    typedef unsigned int size_t;

#endif
#if __ia64__
/* IA64 */
    typedef unsigned long int size_t;

#endif
#if __powerpc__ && !__powerpc64__
/* PPC32 */
    typedef unsigned int size_t;

#endif
#if __powerpc64__
/* PPC64 */
    typedef unsigned long int size_t;

#endif
#if __s390__ && !__s390x__
/* S390 */
    typedef unsigned long int size_t;

#endif
#if __i386__
/* IA32 */
    typedef int ptrdiff_t;

#endif
#if __powerpc__ && !__powerpc64__
/* PPC32 */
    typedef int ptrdiff_t;

#endif
#if __s390__ && !__s390x__
/* S390 */
    typedef int ptrdiff_t;

#endif
#if __powerpc64__
/* PPC64 */
    typedef long int ptrdiff_t;

#endif
#if __s390x__
/* S390X */
    typedef unsigned long int size_t;

#endif
#if __x86_64__
/* x86-64 */
    typedef long int ptrdiff_t;

#endif
#if __x86_64__
/* x86-64 */
    typedef unsigned long int size_t;

#endif
#if __s390x__
/* S390X */
    typedef long int ptrdiff_t;

#endif

#ifdef __cplusplus
}
#endif
#endif
