/*
 *  test-rpc-nested-2.c - Test nested RPC invoke
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
    RPC_TEST_METHOD_F1 = 1,
    RPC_TEST_METHOD_F2,
    RPC_TEST_METHOD_F3,
    RPC_TEST_METHOD_F4,
    RPC_TEST_METHOD_F5
  };

static const char *
f_name (int method)
{
  switch (method)
    {
    case RPC_TEST_METHOD_F1: return "f1";
    case RPC_TEST_METHOD_F2: return "f2";
    case RPC_TEST_METHOD_F3: return "f3";
    case RPC_TEST_METHOD_F4: return "f4";
    case RPC_TEST_METHOD_F5: return "f5";
    }
  return "<unknown>";
}

#define print_func(pfx, method)	npw_printf ("%s: %s()\n", pfx, f_name (method))
#define print_func_SEND(method)	print_func ("SEND", method)
#define print_func_RECV(method) print_func ("RECV", method)

static void
f (int method)
{
  rpc_connection_t *connection;
  int               error;

  print_func_SEND (method);

  connection = rpc_test_get_connection ();
  RPC_TEST_ENSURE (connection != NULL);

  RPC_TEST_ENSURE (rpc_method_invoke_possible (connection));
  error = rpc_method_invoke (connection, method, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  error = rpc_method_wait_for_reply (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);
}

static int
handle_f1 (rpc_connection_t *connection)
{
  int error;

  print_func_RECV (RPC_TEST_METHOD_F1);

  error = rpc_method_get_args (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  f (RPC_TEST_METHOD_F2);

  error = rpc_method_send_reply (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  return error;
}

static int
handle_fN (rpc_connection_t *connection, int method)
{
  int error;

  print_func_RECV (method);

  error = rpc_method_get_args (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  error = rpc_method_send_reply (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  return error;
}

static int
handle_f2 (rpc_connection_t *connection)
{
  int error;

  print_func_RECV (RPC_TEST_METHOD_F2);

  error = rpc_method_get_args (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  f (RPC_TEST_METHOD_F3);

  error = rpc_method_send_reply (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  return error;
}

static int
handle_f3 (rpc_connection_t *connection)
{
  int error;

  print_func_RECV (RPC_TEST_METHOD_F3);

  error = rpc_method_get_args (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  f (RPC_TEST_METHOD_F4);

  error = rpc_method_send_reply (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  f (RPC_TEST_METHOD_F5);

  return error;
}

static int
handle_f4 (rpc_connection_t *connection)
{
  return handle_fN (connection, RPC_TEST_METHOD_F4);
}

static int
handle_f5 (rpc_connection_t *connection)
{
  return handle_fN (connection, RPC_TEST_METHOD_F5);
}

int
rpc_test_init (int argc, char *argv[])
{
  rpc_connection_t *connection;

  connection = rpc_test_get_connection ();
  RPC_TEST_ENSURE (connection != NULL);

  static const rpc_method_descriptor_t vtable[] = {
    { RPC_TEST_METHOD_F1, handle_f1 },
    { RPC_TEST_METHOD_F2, handle_f2 },
    { RPC_TEST_METHOD_F3, handle_f3 },
    { RPC_TEST_METHOD_F4, handle_f4 },
    { RPC_TEST_METHOD_F5, handle_f5 }
  };

  if (rpc_connection_add_method_descriptors (connection, &vtable[0],
					     G_N_ELEMENTS (vtable)) < 0)
    g_error ("could not add method descriptors");

  return 0;
}

int
rpc_test_execute (gpointer user_data)
{
#ifdef BUILD_CLIENT
  f (RPC_TEST_METHOD_F1);
#endif
  npw_printf ("done\n");
  return RPC_TEST_EXECUTE_SUCCESS;
}
