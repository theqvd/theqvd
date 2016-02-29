/* $OpenBSD: misc.c,v 1.86 2011/09/05 05:59:08 djm Exp $ */
/*
 * Copyright (c) 2000 Markus Friedl.  All rights reserved.
 * Copyright (c) 2005,2006 Damien Miller.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "includes-joni.h"

#include <sys/types.h>
/*#include <sys/ioctl.h>*/
/*#include <sys/socket.h>*/
#include <sys/param.h>

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
/*
#include <netinet/in.h>
#include <netinet/in_systm.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
*/
#include <errno.h>
#include <fcntl.h>
/*#include <netdb.h>*/
#ifdef HAVE_PATHS_H
# include <paths.h>
#endif
/*#include <pwd.h>*/
/*#include <grp.h>*/
#ifdef SSH_TUN_OPENBSD
#include <net/if.h>
#endif

#include "xmalloc.h"
#include "misc.h"
#include "log.h"
#include "ssh.h"

/* remove newline at end of string */
char *
chop(char *s)
{
	char *t = s;
	while (*t) {
		if (*t == '\n' || *t == '\r') {
			*t = '\0';
			return s;
		}
		t++;
	}
	return s;

}

uid_t
getuid() {
    return 0;
}

struct passwd *
getpwuid(uid_t uid) {
    static struct passwd pwd = {
        "qvd",      /* username */
        "secret",   /* password */
        0,          /* uid */
        0,          /* gid */
        "QVD",      /* full name */
        NULL,       /* home dir */
        "",         /* shell */
    };
    pwd.pw_dir = getenv("USERPROFILE");
    return &pwd;
}

struct passwd *
getpwnam(const char *name)
{
    return getpwuid(0);
}

char *
user_from_uid(uid_t uid, int nouser)
{
    struct passwd *pwd = getpwuid(uid);
    return pwd->pw_name;
}

char *
group_from_gid(gid_t gid, int nogroup) {
    return "qvd";
}

/*
 * Expands tildes in the file name.  Returns data allocated by xmalloc.
 * Warning: this calls getpw*.
 */
char *
tilde_expand_filename(const char *filename, uid_t uid)
{
	const char *path;
	char user[128], ret[MAXPATHLEN];
	struct passwd *pw;
	u_int len, slash;

	if (*filename != '~')
		return (xstrdup(filename));
	filename++;

	path = strchr(filename, '/');
	if (path != NULL && path > filename) {		/* ~user/path */
		slash = path - filename;
		if (slash > sizeof(user) - 1)
			fatal("tilde_expand_filename: ~username too long");
		memcpy(user, filename, slash);
		user[slash] = '\0';
		if ((pw = getpwnam(user)) == NULL)
			fatal("tilde_expand_filename: No such user %s", user);
	} else if ((pw = getpwuid(uid)) == NULL)	/* ~/path */
		fatal("tilde_expand_filename: No such uid %ld", (long)uid);

	if (strlcpy(ret, pw->pw_dir, sizeof(ret)) >= sizeof(ret))
		fatal("tilde_expand_filename: Path too long");

	/* Make sure directory has a trailing '/' */
	len = strlen(pw->pw_dir);
	if ((len == 0 || pw->pw_dir[len - 1] != '/') &&
	    strlcat(ret, "/", sizeof(ret)) >= sizeof(ret))
		fatal("tilde_expand_filename: Path too long");

	/* Skip leading '/' from specified path */
	if (path != NULL)
		filename = path + 1;
	if (strlcat(ret, filename, sizeof(ret)) >= sizeof(ret))
		fatal("tilde_expand_filename: Path too long");

	return (xstrdup(ret));
}

/*
 * Expand a string with a set of %[char] escapes. A number of escapes may be
 * specified as (char *escape_chars, char *replacement) pairs. The list must
 * be terminated by a NULL escape_char. Returns replaced string in memory
 * allocated by xmalloc.
 */
char *
percent_expand(const char *string, ...)
{
#define EXPAND_MAX_KEYS	16
	u_int num_keys, i, j;
	struct {
		const char *key;
		const char *repl;
	} keys[EXPAND_MAX_KEYS];
	char buf[4096];
	va_list ap;

	/* Gather keys */
	va_start(ap, string);
	for (num_keys = 0; num_keys < EXPAND_MAX_KEYS; num_keys++) {
		keys[num_keys].key = va_arg(ap, char *);
		if (keys[num_keys].key == NULL)
			break;
		keys[num_keys].repl = va_arg(ap, char *);
		if (keys[num_keys].repl == NULL)
			fatal("%s: NULL replacement", __func__);
	}
	if (num_keys == EXPAND_MAX_KEYS && va_arg(ap, char *) != NULL)
		fatal("%s: too many keys", __func__);
	va_end(ap);

	/* Expand string */
	*buf = '\0';
	for (i = 0; *string != '\0'; string++) {
		if (*string != '%') {
 append:
			buf[i++] = *string;
			if (i >= sizeof(buf))
				fatal("%s: string too long", __func__);
			buf[i] = '\0';
			continue;
		}
		string++;
		/* %% case */
		if (*string == '%')
			goto append;
		for (j = 0; j < num_keys; j++) {
			if (strchr(keys[j].key, *string) != NULL) {
				i = strlcat(buf, keys[j].repl, sizeof(buf));
				if (i >= sizeof(buf))
					fatal("%s: string too long", __func__);
				break;
			}
		}
		if (j >= num_keys)
			fatal("%s: unknown key %%%c", __func__, *string);
	}
	return (xstrdup(buf));
#undef EXPAND_MAX_KEYS
}

/*
 * Read an entire line from a public key file into a static buffer, discarding
 * lines that exceed the buffer size.  Returns 0 on success, -1 on failure.
 */
int
read_keyfile_line(FILE *f, const char *filename, char *buf, size_t bufsz,
   u_long *lineno)
{
	while (fgets(buf, bufsz, f) != NULL) {
		if (buf[0] == '\0')
			continue;
		(*lineno)++;
		if (buf[strlen(buf) - 1] == '\n' || feof(f)) {
			return 0;
		} else {
			debug("%s: %s line %lu exceeds size limit", __func__,
			    filename, *lineno);
			/* discard remainder of line */
			while (fgetc(f) != '\n' && !feof(f))
				;	/* nothing */
		}
	}
	return -1;
}

struct passwd *
pwcopy(struct passwd *pw)
{
	struct passwd *copy = xcalloc(1, sizeof(*copy));

	copy->pw_name = xstrdup(pw->pw_name);
	copy->pw_passwd = xstrdup(pw->pw_passwd);
	copy->pw_gecos = xstrdup(pw->pw_gecos);
	copy->pw_uid = pw->pw_uid;
	copy->pw_gid = pw->pw_gid;
#ifdef HAVE_PW_EXPIRE_IN_PASSWD
	copy->pw_expire = pw->pw_expire;
#endif
#ifdef HAVE_PW_CHANGE_IN_PASSWD
	copy->pw_change = pw->pw_change;
#endif
#ifdef HAVE_PW_CLASS_IN_PASSWD
	copy->pw_class = xstrdup(pw->pw_class);
#endif
	copy->pw_dir = xstrdup(pw->pw_dir);
	copy->pw_shell = xstrdup(pw->pw_shell);
	return copy;
}

char *
tohex(const void *vp, size_t l)
{
	const u_char *p = (const u_char *)vp;
	char b[3], *r;
	size_t i, hl;

	if (l > 65536)
		return xstrdup("tohex: length > 65536");

	hl = l * 2 + 1;
	r = xcalloc(1, hl);
	for (i = 0; i < l; i++) {
		snprintf(b, sizeof(b), "%02x", p[i]);
		strlcat(r, b, hl);
	}
	return (r);
}

u_int64_t
get_u64(const void *vp)
{
	const u_char *p = (const u_char *)vp;
	u_int64_t v;

	v  = (u_int64_t)p[0] << 56;
	v |= (u_int64_t)p[1] << 48;
	v |= (u_int64_t)p[2] << 40;
	v |= (u_int64_t)p[3] << 32;
	v |= (u_int64_t)p[4] << 24;
	v |= (u_int64_t)p[5] << 16;
	v |= (u_int64_t)p[6] << 8;
	v |= (u_int64_t)p[7];

	return (v);
}

u_int32_t
get_u32(const void *vp)
{
	const u_char *p = (const u_char *)vp;
	u_int32_t v;

	v  = (u_int32_t)p[0] << 24;
	v |= (u_int32_t)p[1] << 16;
	v |= (u_int32_t)p[2] << 8;
	v |= (u_int32_t)p[3];

	return (v);
}

u_int16_t
get_u16(const void *vp)
{
	const u_char *p = (const u_char *)vp;
	u_int16_t v;

	v  = (u_int16_t)p[0] << 8;
	v |= (u_int16_t)p[1];

	return (v);
}

void
put_u64(void *vp, u_int64_t v)
{
	u_char *p = (u_char *)vp;

	p[0] = (u_char)(v >> 56) & 0xff;
	p[1] = (u_char)(v >> 48) & 0xff;
	p[2] = (u_char)(v >> 40) & 0xff;
	p[3] = (u_char)(v >> 32) & 0xff;
	p[4] = (u_char)(v >> 24) & 0xff;
	p[5] = (u_char)(v >> 16) & 0xff;
	p[6] = (u_char)(v >> 8) & 0xff;
	p[7] = (u_char)v & 0xff;
}

void
put_u32(void *vp, u_int32_t v)
{
	u_char *p = (u_char *)vp;

	p[0] = (u_char)(v >> 24) & 0xff;
	p[1] = (u_char)(v >> 16) & 0xff;
	p[2] = (u_char)(v >> 8) & 0xff;
	p[3] = (u_char)v & 0xff;
}


void
put_u16(void *vp, u_int16_t v)
{
	u_char *p = (u_char *)vp;

	p[0] = (u_char)(v >> 8) & 0xff;
	p[1] = (u_char)v & 0xff;
}

