#ifndef _TIME_H_
#define _TIME_H_

#include <signal.h>
#include <sys/types.h>
#include <sys/time.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif


#define CLK_TCK	((clock_t)__sysconf(2))
#define CLOCK_REALTIME	0
#define TIMER_ABSTIME	1
#define CLOCKS_PER_SEC	1000000l


    struct tm {
	int tm_sec;
	int tm_min;
	int tm_hour;
	int tm_mday;
	int tm_mon;
	int tm_year;
	int tm_wday;
	int tm_yday;
	int tm_isdst;
	long int tm_gmtoff;
	char *tm_zone;
    };

    struct itimerspec {
	struct timespec it_interval;
	struct timespec it_value;
    };





/* Returned by clock()*/



/* Returned by `time'*/



/* POSIX.1b structure for a time value.*/



/* Used by other time functions.*/



    extern int __daylight;
    extern long int __timezone;
    extern char *__tzname[2];
    extern char *asctime(const struct tm *);
    extern clock_t clock(void);
    extern char *ctime(const time_t *);
    extern char *ctime_r(const time_t *, char *);
    extern double difftime(time_t, time_t);
    extern struct tm *getdate(const char *);
    extern int getdate_err;
    extern struct tm *gmtime(const time_t *);
    extern struct tm *localtime(const time_t *);
    extern time_t mktime(struct tm *);
    extern int stime(const time_t *);
    extern size_t strftime(char *, size_t, const char *,
			   const struct tm *);
    extern char *strptime(const char *, const char *, struct tm *);
    extern time_t time(time_t *);
    extern int nanosleep(const struct timespec *, struct timespec *);
    extern int daylight;
    extern long int timezone;
    extern char *tzname[2];
    extern void tzset(void);
    extern char *asctime_r(const struct tm *, char *);
    extern struct tm *gmtime_r(const time_t *, struct tm *);
    extern struct tm *localtime_r(const time_t *, struct tm *);
    extern int clock_getcpuclockid(pid_t, clockid_t *);
    extern int clock_getres(clockid_t, struct timespec *);
    extern int clock_gettime(clockid_t, struct timespec *);
    extern int clock_nanosleep(clockid_t, int, const struct timespec *,
			       struct timespec *);
    extern int clock_settime(clockid_t, const struct timespec *);
    extern int timer_create(clockid_t, struct sigevent *, timer_t *);
    extern int timer_delete(timer_t);
    extern int timer_getoverrun(timer_t);
    extern int timer_gettime(timer_t, struct itimerspec *);
    extern int timer_settime(timer_t, int, const struct itimerspec *,
			     struct itimerspec *);
#ifdef __cplusplus
}
#endif
#endif
