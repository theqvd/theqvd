/*
 *  test-rpc-concurrent.c - Test concurrent RPC invoke
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
#include <string.h>

#define DEBUG 1
#include "debug.h"

#define RPC_TEST_USE_IDLE   TRUE

enum
  {
    RPC_TEST_METHOD_STEP = 1,
    RPC_TEST_METHOD_DONE
  };

static gboolean g_is_silent = TRUE;
static gint     g_n_steps   = 5000;
static gboolean g_got_done  = FALSE;

static void
invoke_step (int n)
{
  rpc_connection_t *connection;
  int               error;
  int32_t           ret;

  connection = rpc_test_get_connection ();
  RPC_TEST_ENSURE (connection != NULL);

  error = rpc_method_invoke (connection,
			     RPC_TEST_METHOD_STEP,
			     RPC_TYPE_INT32, n,
			     RPC_TYPE_INVALID);
  /* Error out early for invalid messages types.

     The problem we are looking at is rpc_method_invoke() waiting for
     the other side MSG_ACK prior to sending the arguments. Sometimes,
     the other side sends a new message first (MSG_START). So, we get
     a mismatch. */
  RPC_TEST_ENSURE (error != RPC_ERROR_MESSAGE_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  error = rpc_method_wait_for_reply (connection,
				     RPC_TYPE_INT32, &ret,
				     RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);
  RPC_TEST_ENSURE (ret == n);
}

static int
handle_step (rpc_connection_t *connection)
{
  int32_t n;
  int     error;

  error = rpc_method_get_args (connection,
			       RPC_TYPE_INT32, &n,
			       RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  if (!g_is_silent)
    npw_printf ("Got message %d from the other end\n", n);

  error = rpc_method_send_reply (connection,
				 RPC_TYPE_INT32, n,
				 RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  return error;
}

static void
invoke_done (void)
{
  rpc_connection_t *connection;
  int               error;

  connection = rpc_test_get_connection ();
  RPC_TEST_ENSURE (connection != NULL);

  error = rpc_method_invoke (connection,
			     RPC_TEST_METHOD_DONE,
			     RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  error = rpc_method_wait_for_reply (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);
}

static int
handle_done (rpc_connection_t *connection)
{
  int error;

  error = rpc_method_get_args (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  g_got_done = TRUE;

#ifdef BUILD_CLIENT
  if (g_n_steps == 0)
    rpc_test_exit_full (0);
#endif

  error = rpc_method_send_reply (connection, RPC_TYPE_INVALID);
  RPC_TEST_ENSURE_NO_ERROR (error);

  return error;
}

static inline void
do_step (int n)
{
  invoke_step (n);
}

static inline void
do_done (void)
{
  invoke_done ();
}

static gboolean
invoke_step_cb (gpointer user_data)
{
  do_step (g_n_steps);

  if (--g_n_steps == 0)
    {
#ifdef BUILD_CLIENT
      if (g_got_done)
	rpc_test_exit_full (0);
#endif
#ifdef BUILD_SERVER
      do_done ();
#endif
    }

  return g_n_steps > 0;
}

int
rpc_test_init (int argc, char *argv[])
{
  rpc_connection_t *connection;

  for (int i = 1; i < argc; i++)
    {
      const gchar *arg = argv[i];
      if (strcmp (arg, "--silent") == 0 || strcmp (arg, "-q") == 0)
	g_is_silent = TRUE;
      else if (strcmp (arg, "--verbose") == 0 || strcmp (arg, "-v") == 0)
	g_is_silent = FALSE;
      else if (strcmp (arg, "--count") == 0)
	{
	  if (++i < argc)
	    {
	      unsigned long v = strtoul (argv[i], NULL, 10);
	      if (v > 0)
		g_n_steps = v;
	    }
	}
      else if (strcmp (arg, "--help") == 0)
	{
	  g_print ("Usage: %s [--silent|--verbose] [--count COUNT]\n", argv[0]);
	  rpc_test_exit (0);
	}
    }

  connection = rpc_test_get_connection ();
  RPC_TEST_ENSURE (connection != NULL);

  static const rpc_method_descriptor_t vtable[] = {
    { RPC_TEST_METHOD_STEP, handle_step },
    { RPC_TEST_METHOD_DONE, handle_done }
  };

  if (rpc_connection_add_method_descriptors (connection, &vtable[0],
					     G_N_ELEMENTS (vtable)) < 0)
    g_error ("could not add method descriptors");

  if (RPC_TEST_USE_IDLE)
    {
      /* XXX: we hope to trigger concurrent rpc_method_invoke() */
      /* XXX: add a barrier to synchronize both processes? */
      //g_idle_add (invoke_step_cb, NULL);
      g_timeout_add (0, invoke_step_cb, NULL);
    }
  else
    {
      while (--g_n_steps >= 0)
	do_step (g_n_steps);
    }
  return 0;
}

int
rpc_test_execute (gpointer user_data)
{
#ifdef BUILD_CLIENT
  if (RPC_TEST_USE_IDLE)
    return RPC_TEST_EXECUTE_SUCCESS|RPC_TEST_EXECUTE_DONT_QUIT;
#endif
  return RPC_TEST_EXECUTE_SUCCESS;
}
