#ifndef _ERRNO_H_
#define _ERRNO_H_


#ifdef __cplusplus
extern "C" {
#endif


#define errno	(*__errno_location())



/* errno values*/
#define EPERM	1
#define ECHILD	10
#define ENETDOWN	100
#define ENETUNREACH	101
#define ENETRESET	102
#define ECONNABORTED	103
#define ECONNRESET	104
#define ENOBUFS	105
#define EISCONN	106
#define ENOTCONN	107
#define ESHUTDOWN	108
#define ETOOMANYREFS	109
#define EAGAIN	11
#define ETIMEDOUT	110
#define ECONNREFUSED	111
#define EHOSTDOWN	112
#define EHOSTUNREACH	113
#define EALREADY	114
#define EINPROGRESS	115
#define ESTALE	116
#define EUCLEAN	117
#define ENOTNAM	118
#define ENAVAIL	119
#define ENOMEM	12
#define EISNAM	120
#define EREMOTEIO	121
#define EDQUOT	122
#define ENOMEDIUM	123
#define EMEDIUMTYPE	124
#define ECANCELED	125
#define EACCES	13
#define EFAULT	14
#define ENOTBLK	15
#define EBUSY	16
#define EEXIST	17
#define EXDEV	18
#define ENODEV	19
#define ENOENT	2
#define ENOTDIR	20
#define EISDIR	21
#define EINVAL	22
#define ENFILE	23
#define EMFILE	24
#define ENOTTY	25
#define ETXTBSY	26
#define EFBIG	27
#define ENOSPC	28
#define ESPIPE	29
#define ESRCH	3
#define EROFS	30
#define EMLINK	31
#define EPIPE	32
#define EDOM	33
#define ERANGE	34
#define EDEADLK	35
#if __s390x__
#define EDEADLOCK	35
#endif
#define ENAMETOOLONG	36
#define ENOLCK	37
#define ENOSYS	38
#define ENOTEMPTY	39
#define EINTR	4
#define ELOOP	40
#define ENOMSG	42
#define EIDRM	43
#define ECHRNG	44
#define EL2NSYNC	45
#define EL3HLT	46
#define EL3RST	47
#define ELNRNG	48
#define EUNATCH	49
#define EIO	5
#define ENOANO	55
#define EBADRQC	56
#define EBADSLT	57
#if __powerpc__ && !__powerpc64__
#define EDEADLOCK	58
#endif
#if __powerpc64__
#define EDEADLOCK	58
#endif
#define EBFONT	59
#define ENXIO	6
#define ENOSTR	60
#define ENODATA	61
#define ETIME	62
#define ENOSR	63
#define ENONET	64
#define ENOPKG	65
#define EREMOTE	66
#define ENOLINK	67
#define EADV	68
#define ESRMNT	69
#define E2BIG	7
#define ECOMM	70
#define EPROTO	71
#define EMULTIHOP	72
#define EDOTDOT	73
#define EBADMSG	74
#define EOVERFLOW	75
#define ENOTUNIQ	76
#define EBADFD	77
#define EREMCHG	78
#define ELIBACC	79
#define ENOEXEC	8
#define ELIBBAD	80
#define ELIBSCN	81
#define ELIBMAX	82
#define ELIBEXEC	83
#define EILSEQ	84
#define ERESTART	85
#define ESTRPIPE	86
#define EUSERS	87
#define ENOTSOCK	88
#define EDESTADDRREQ	89
#define EBADF	9
#define EMSGSIZE	90
#define EPROTOTYPE	91
#define ENOPROTOOPT	92
#define EPROTONOSUPPORT	93
#define ESOCKTNOSUPPORT	94
#define EOPNOTSUPP	95
#define EPFNOSUPPORT	96
#define EAFNOSUPPORT	97
#define EADDRINUSE	98
#define EADDRNOTAVAIL	99
#define EWOULDBLOCK	EAGAIN
#if __i386__
#define EDEADLOCK	EDEADLK
#endif
#if __ia64__
#define EDEADLOCK	EDEADLK
#endif
#if __s390__ && !__s390x__
#define EDEADLOCK	EDEADLK
#endif
#if __x86_64__
#define EDEADLOCK	EDEADLK
#endif
#define ENOTSUP	EOPNOTSUPP



    extern int *__errno_location(void);
#ifdef __cplusplus
}
#endif
#endif
