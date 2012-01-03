#ifndef _WCTYPE_H_
#define _WCTYPE_H_

#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif




    typedef unsigned long int wctype_t;

    typedef unsigned int wint_t;

    typedef const int32_t *wctrans_t;

    typedef struct {
	int count;
	wint_t value;
    } __mbstate_t;


/* This really belongs in wchar.h, but it's presense creates a circular dependency with stdio.h, so put it here to break the circle.*/


    typedef __mbstate_t mbstate_t;


    extern int iswblank(wint_t);
    extern wint_t towlower(wint_t);
    extern wint_t towupper(wint_t);
    extern wctrans_t wctrans(const char *);
    extern int iswalnum(wint_t);
    extern int iswalpha(wint_t);
    extern int iswcntrl(wint_t);
    extern int iswctype(wint_t, wctype_t);
    extern int iswdigit(wint_t);
    extern int iswgraph(wint_t);
    extern int iswlower(wint_t);
    extern int iswprint(wint_t);
    extern int iswpunct(wint_t);
    extern int iswspace(wint_t);
    extern int iswupper(wint_t);
    extern int iswxdigit(wint_t);
    extern wctype_t wctype(const char *);
    extern wint_t towctrans(wint_t, wctrans_t);
#ifdef __cplusplus
}
#endif
#endif
