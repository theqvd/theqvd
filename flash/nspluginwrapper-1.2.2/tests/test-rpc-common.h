/*
 *  test-rpc-common.h - Common RPC test code
 *
 *  nspluginwrapper (C) 2005-2009 Gwenole Beauchesne
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef TEST_RPC_COMMON_H
#define TEST_RPC_COMMON_H

#include "rpc.h"
#include <glib.h>

enum
  {
    /* void rpc_test_exit (int status); */
    RPC_TEST_METHOD_EXIT = 0,
  };

enum
  {
    RPC_TEST_EXECUTE_SUCCESS   = 0,
    RPC_TEST_EXECUTE_FAILURE   = 1,
    RPC_TEST_EXECUTE_DONT_QUIT = 0x8000,
  };

#define RPC_TEST_ENSURE(expr) do {				\
  if (!(expr)) {						\
    npw_printf ("ERROR:(%s:%d):%s: assertion failed: (%s)\n",	\
		__FILE__, __LINE__, __func__, #expr);		\
    abort ();							\
  }								\
} while (0)

#define RPC_TEST_ENSURE_ERROR(error, error_code) do {	\
  if ((error) != (error_code)) {			\
    npw_printf ("ERROR:(%s:%d):%s: %s\n",		\
		__FILE__, __LINE__, __func__,		\
		rpc_strerror (error));			\
    abort ();						\
  }							\
} while (0)

#define RPC_TEST_ENSURE_NO_ERROR(error)			\
  RPC_TEST_ENSURE_ERROR(error, RPC_ERROR_NO_ERROR)

typedef struct _RPCTestFuncs RPCTestFuncs;
struct _RPCTestFuncs
{
  gboolean (*pre_dispatch_hook)  (gpointer user_data);
  void     (*post_dispatch_hook) (gpointer user_data);
};

void
rpc_test_set_funcs (const RPCTestFuncs *funcs, gpointer user_data);

rpc_connection_t *
rpc_test_get_connection (void);

/* IMPLEMENT: default is NPW_CONNECTION_PATH "/Test.RPC"; */
const gchar *
rpc_test_get_connection_path (void)
  __attribute__((__weak__));

/* IMPLEMENT: default is return 0; */
int
rpc_test_init (int argc, char *argv[])
  __attribute__((__weak__));

/* IMPLEMENT: default is return 0; */
int
rpc_test_execute (gpointer user_data)
  __attribute__((__weak__));

void
rpc_test_exit (int status);

void
rpc_test_exit_full (int status);

#endif /* TEST_RPC_COMMON_H */
