/* $Id$ */
/*
 * Copyright (c) 2012 Colin Watson <cjwatson@debian.org>
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

#include <sys/types.h>

#include <stdlib.h>
#include <stdarg.h>

#include "log.h"
#include "ssh-sandbox.h"

static Sandbox *sandboxes[] = {
	&ssh_sandbox_systrace,
	&ssh_sandbox_darwin,
	&ssh_sandbox_seccomp_filter,
	&ssh_sandbox_rlimit,
	&ssh_sandbox_null,
	NULL
};

static Sandbox *selected;

static void
sandbox_select(void)
{
	Sandbox **sandbox;

	if (selected)
		return;

	for (sandbox = sandboxes; sandbox; sandbox++) {
		if ((*sandbox)->probe && (*sandbox)->probe()) {
			selected = *sandbox;
			return;
		}
	}

	/* should never happen, as ssh_sandbox_null always succeeds */
	fatal("no sandbox implementation found");
}

void *
ssh_sandbox_init(void)
{
	sandbox_select();
	return selected->init();
}

void
ssh_sandbox_child(void *box)
{
	sandbox_select();
	return selected->child(box);
}

void
ssh_sandbox_parent_finish(void *box)
{
	sandbox_select();
	return selected->parent_finish(box);
}

void
ssh_sandbox_parent_preauth(void *box, pid_t child_pid)
{
	sandbox_select();
	return selected->parent_preauth(box, child_pid);
}
