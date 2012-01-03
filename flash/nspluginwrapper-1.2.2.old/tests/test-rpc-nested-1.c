/*
 *  test-rpc-nested.c - Test nested RPC invoke
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

#include "sysdeps.h"
#include "test-rpc-common.h"
#include <unistd.h>

#define DEBUG 1
#include "debug.h"

enum
  {
    RPC_TEST_METHOD_GET_PID = 1
  };

static gint
get_remote_pid (void)
{
  rpc_connection_t *connection;
  int               error;
  gint32            pid;

  connection = rpc_test_get_connection ();
  RPC_TEST_ENSURE (connection != NULL);

  error = rpc_method_invoke (connection,
			     RPC_TEST_METHOD_GET_PID,
			     RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  error = rpc_method_wait_for_reply (connection,
				     RPC_TYPE_INT32, &pid,
				     RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  return pid;
}

static inline gint
get_local_pid (void)
{
  return getpid ();
}

static inline gint
get_client_pid (void)
{
#ifdef BUILD_CLIENT
  return get_local_pid ();
#endif
#ifdef BUILD_SERVER
  return get_remote_pid ();
#endif
  return -1;
}

static int
handle_get_pid (rpc_connection_t *connection)
{
  gint pid;
  int  error;

  error = rpc_method_get_args (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  pid = get_client_pid ();

  error = rpc_method_send_reply (connection,
				 RPC_TYPE_INT32, pid,
				 RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  return error;
}

int
rpc_test_init (int argc, char *argv[])
{
  rpc_connection_t *connection;

  connection = rpc_test_get_connection ();
  RPC_TEST_ENSURE (connection != NULL);

  static const rpc_method_descriptor_t vtable[] = {
    { RPC_TEST_METHOD_GET_PID, handle_get_pid },
  };

  if (rpc_connection_add_method_descriptor (connection, &vtable[0]) < 0)
    g_error ("could not add method descriptors");

  return 0;
}

int
rpc_test_execute (gpointer user_data)
{
#ifdef BUILD_CLIENT
  gint pid = get_remote_pid ();
  RPC_TEST_ENSURE (pid == get_local_pid ());
#endif
  return RPC_TEST_EXECUTE_SUCCESS;
}
