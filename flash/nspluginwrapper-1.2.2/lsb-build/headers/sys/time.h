#ifndef _SYS_TIME_H_
#define _SYS_TIME_H_

#include <sys/types.h>

#ifdef __cplusplus
extern "C" {
#endif


#define ITIMER_REAL	0
#define ITIMER_VIRTUAL	1
#define ITIMER_PROF	2


    struct timezone {
	int tz_minuteswest;
	int tz_dsttime;
    };





/* Values for the first argument to `getitimer' and `setitimer'.*/


    typedef int __itimer_which_t;




    struct timespec {
	time_t tv_sec;
	long int tv_nsec;
    };







    struct timeval {
	time_t tv_sec;
	suseconds_t tv_usec;
    };


/* Type of the second argument to `getitimer' and
the second and third arguments `setitimer'.*/


    struct itimerval {
	struct timeval it_interval;
	struct timeval it_value;
    };


    extern int getitimer(__itimer_which_t, struct itimerval *);
    extern int setitimer(__itimer_which_t, const struct itimerval *,
			 struct itimerval *);
    extern int adjtime(const struct timeval *, struct timeval *);
    extern int gettimeofday(struct timeval *, struct timezone *);
    extern int utimes(const char *, const struct timeval *);
#ifdef __cplusplus
}
#endif
#endif
