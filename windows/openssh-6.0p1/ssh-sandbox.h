/* $OpenBSD: ssh-sandbox.h,v 1.1 2011/06/23 09:34:13 djm Exp $ */
/*
 * Copyright (c) 2011 Damien Miller <djm@mindrot.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

typedef struct Sandbox Sandbox;

struct Sandbox {
	const char	*name;
	int		(*probe)(void);
	void		*(*init)(void);
	void	    	(*child)(void *);
	void		(*parent_finish)(void *);
	void	    	(*parent_preauth)(void *, pid_t);
};

void *ssh_sandbox_init(void);
void ssh_sandbox_child(void *);
void ssh_sandbox_parent_finish(void *);
void ssh_sandbox_parent_preauth(void *, pid_t);

extern Sandbox ssh_sandbox_systrace;
extern Sandbox ssh_sandbox_darwin;
extern Sandbox ssh_sandbox_seccomp_filter;
extern Sandbox ssh_sandbox_rlimit;
extern Sandbox ssh_sandbox_null;
