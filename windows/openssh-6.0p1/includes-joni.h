
#ifndef INCLUDES_JONI_H
#define INCLUDES_JONI_H

#ifndef __WIN32__
# ifdef _WIN32
#  define __WIN32__
# endif
#endif

#ifndef HAVE_FSBLKCNT_T
typedef unsigned long fsblkcnt_t;
#endif
#ifndef HAVE_FSFILCNT_T
typedef unsigned long fsfilcnt_t;
#endif

#ifndef ST_RDONLY
#define ST_RDONLY	1
#endif
#ifndef ST_NOSUID
#define ST_NOSUID	2
#endif

	/* as defined in IEEE Std 1003.1, 2004 Edition */
struct statvfs {
	unsigned long f_bsize;	/* File system block size. */
	unsigned long f_frsize;	/* Fundamental file system block size. */
	fsblkcnt_t f_blocks;	/* Total number of blocks on file system in */
				/* units of f_frsize. */
	fsblkcnt_t    f_bfree;	/* Total number of free blocks. */
	fsblkcnt_t    f_bavail;	/* Number of free blocks available to  */
				/* non-privileged process.  */
	fsfilcnt_t    f_files;	/* Total number of file serial numbers. */
	fsfilcnt_t    f_ffree;	/* Total number of free file serial numbers. */
	fsfilcnt_t    f_favail;	/* Number of file serial numbers available to */
				/* non-privileged process. */
	unsigned long f_fsid;	/* File system ID. */
	unsigned long f_flag;	/* BBit mask of f_flag values. */
	unsigned long f_namemax;/*  Maximum filename length. */
};

#include <sys/time.h>

#include <stdio.h>
#include <stdint.h>

#define HAVE_INTXX_T
#define HAVE_UINTXX_T
#define HAVE_SIZE_T
#define HAVE_SSIZE_T
#define HAVE_SA_FAMILY_T
#define HAVE_MODE_T
#define HAVE_ATTRIBUTE__NONNULL__
#define HAVE_GETOPT_OPTRESET

#ifdef __WIN32__
#define WIN32_LEAN_AND_MEAN
#define MISSING_NFDBITS
#define MISSING_HOWMANY
#define GETPGRP_VOID
#endif

#ifndef __WIN32__
#define HAVE_VASPRINTF
#endif

#include "defines.h"

#ifdef __WIN32__
typedef unsigned short u_short;
typedef unsigned long u_long;
typedef unsigned long long int u_int64_t;
typedef unsigned long uid_t;
typedef unsigned long gid_t;
#endif

#include "openbsd-compat/vis.h"

#define	FMT_SCALED_STRSIZE	7

/* The passwd structure.  */
struct passwd
{
  char *pw_name;		/* Username.  */
  char *pw_passwd;		/* Password.  */
  uid_t pw_uid;		/* User ID.  */
  gid_t pw_gid;		/* Group ID.  */
  char *pw_gecos;		/* Real name.  */
  char *pw_dir;			/* Home directory.  */
  char *pw_shell;		/* Shell program.  */
};

typedef long fd_mask;

#define	S_ISUID	04000	/* Set user ID on execution.  */
#define	S_ISGID	02000	/* Set group ID on execution.  */
#define	S_ISVTX	01000	/* Save swapped text after use (sticky).  */

#include <sys/stat.h>

#ifdef __WIN32__
#define lstat(A,B) stat((A),(B)) /* no symlinks on Windows */
#define link(A,B) (-1)           /* no hardlinks on Windows */
#define readlink(A,B,C) (EINVAL) /* no symlinks on Windows */
#define realpath(R,N) (_fullpath((R),(N),_MAX_PATH)) /* no symlinks on Windows */
#define symlink(R,N) (EPERM) /* no symlinks on Windows */
#endif

/*
 * priorities/facilities are encoded into a single 32-bit quantity, where the
 * bottom 3 bits are the priority (0-7) and the top 28 bits are the facility
 * (0-big number).  Both the priorities and the facilities map roughly
 * one-to-one to strings in the syslogd(8) source code.  This mapping is
 * included in this file.
 *
 * priorities (these are ordered)
 */
#define	LOG_EMERG	0	/* system is unusable */
#define	LOG_ALERT	1	/* action must be taken immediately */
#define	LOG_CRIT	2	/* critical conditions */
#define	LOG_ERR		3	/* error conditions */
#define	LOG_WARNING	4	/* warning conditions */
#define	LOG_NOTICE	5	/* normal but significant condition */
#define	LOG_INFO	6	/* informational */
#define	LOG_DEBUG	7	/* debug-level messages */

#define	LOG_PRIMASK	0x07	/* mask to extract priority part (internal) */
				/* extract priority */
#define	LOG_PRI(p)	((p) & LOG_PRIMASK)
#define	LOG_MAKEPRI(fac, pri)	(((fac) << 3) | (pri))
/*
 * Option flags for openlog.
 *
 * LOG_ODELAY no longer does anything.
 * LOG_NDELAY is the inverse of what it used to be.
 */
#define	LOG_PID		0x01	/* log the pid with each message */
#define	LOG_CONS	0x02	/* log on the console if errors in sending */
#define	LOG_ODELAY	0x04	/* delay open until first syslog() (default) */
#define	LOG_NDELAY	0x08	/* don't delay open */
#define	LOG_NOWAIT	0x10	/* don't wait for console forks: DEPRECATED */
#define	LOG_PERROR	0x20	/* log to stderr as well */

/* facility codes */
#define	LOG_KERN	(0<<3)	/* kernel messages */
#define	LOG_USER	(1<<3)	/* random user-level messages */
#define	LOG_MAIL	(2<<3)	/* mail system */
#define	LOG_DAEMON	(3<<3)	/* system daemons */
#define	LOG_AUTH	(4<<3)	/* security/authorization messages */
#define	LOG_SYSLOG	(5<<3)	/* messages generated internally by syslogd */
#define	LOG_LPR		(6<<3)	/* line printer subsystem */
#define	LOG_NEWS	(7<<3)	/* network news subsystem */
#define	LOG_UUCP	(8<<3)	/* UUCP subsystem */
#define	LOG_CRON	(9<<3)	/* clock daemon */
#define	LOG_AUTHPRIV	(10<<3)	/* security/authorization messages (private) */
#define	LOG_FTP		(11<<3)	/* ftp daemon */

	/* other codes through 15 reserved for system use */
#define	LOG_LOCAL0	(16<<3)	/* reserved for local use */
#define	LOG_LOCAL1	(17<<3)	/* reserved for local use */
#define	LOG_LOCAL2	(18<<3)	/* reserved for local use */
#define	LOG_LOCAL3	(19<<3)	/* reserved for local use */
#define	LOG_LOCAL4	(20<<3)	/* reserved for local use */
#define	LOG_LOCAL5	(21<<3)	/* reserved for local use */
#define	LOG_LOCAL6	(22<<3)	/* reserved for local use */
#define	LOG_LOCAL7	(23<<3)	/* reserved for local use */
#endif /* INCLUDES_JONI_H */
