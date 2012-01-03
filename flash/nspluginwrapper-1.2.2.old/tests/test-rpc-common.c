/*
 *  test-rpc-common.c - Common RPC test code
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
#include <signal.h>

#define DEBUG 1
#include "debug.h"

#ifdef  BUILD_WRAPPER
#define BUILD_CLIENT 1
#endif

#ifdef  BUILD_VIEWER
#define BUILD_SERVER 1
#endif

typedef struct _RPCTest RPCTest;
struct _RPCTest
{
  RPCTestFuncs funcs;
  gpointer     user_data;
};

static RPCTest           g_test;
static rpc_connection_t *g_connection;
static const gchar      *g_connection_path;
static GMainLoop        *g_main_loop;
static GPid              g_child_pid;
static guint             g_child_watch_id;
static gint              g_exit_status;

void
rpc_test_set_funcs (const RPCTestFuncs *funcs, gpointer user_data)
{
  g_test.user_data = user_data;
  if (funcs && funcs->pre_dispatch_hook)
    g_test.funcs.pre_dispatch_hook = funcs->pre_dispatch_hook;
  if (funcs && funcs->post_dispatch_hook)
    g_test.funcs.post_dispatch_hook = funcs->post_dispatch_hook;
}

rpc_connection_t *
rpc_test_get_connection (void)
{
  return g_connection;
}

#ifdef BUILD_CLIENT
static void
child_exited_cb (GPid pid, gint status, gpointer user_data)
{
  g_print ("child_exited_cb(), pid %d, status %d\n", pid, status);
  if (status)
    g_exit_status = status;
  g_main_loop_quit (g_main_loop);
  if (g_child_watch_id)
    g_source_remove (g_child_watch_id);
  g_spawn_close_pid (pid);
}

static void
kill_child_now (void)
{
  if (g_child_watch_id)
    g_source_remove (g_child_watch_id);
  if (g_child_pid)
    {
      g_spawn_close_pid (g_child_pid);
      kill (g_child_pid, SIGTERM);
    }
}

static void
urgent_exit_sig (int sig)
{
  kill_child_now ();
}
#endif

static gboolean
rpc_event_prepare (GSource *source, gint *timeout)
{
  *timeout = -1;
  return FALSE;
}

static gboolean
rpc_event_check (GSource *source)
{
  return rpc_wait_dispatch (g_connection, 0) > 0;
}

static gboolean
rpc_event_dispatch (GSource *source, GSourceFunc callback, gpointer user_data)
{
  gint rc;

  if (g_test.funcs.pre_dispatch_hook)
    {
      if (!g_test.funcs.pre_dispatch_hook (g_test.user_data))
	return TRUE;
    }

  rc = rpc_dispatch (g_connection);

  if (g_test.funcs.post_dispatch_hook)
    g_test.funcs.post_dispatch_hook (g_test.user_data);

  return rc != RPC_ERROR_CONNECTION_CLOSED;
}

typedef gboolean (*GSourcePrepare)      (GSource *, gint *);
typedef gboolean (*GSourceCheckFunc)    (GSource *);
typedef gboolean (*GSourceDispatchFunc) (GSource *, GSourceFunc, gpointer);
typedef void     (*GSourceFinalizeFunc) (GSource *);

static GSourceFuncs rpc_event_funcs =
  {
    rpc_event_prepare,
    rpc_event_check,
    rpc_event_dispatch,
    (GSourceFinalizeFunc)g_free,
    (GSourceFunc)NULL,
    (GSourceDummyMarshal)NULL
  };

static gboolean
rpc_test_execute_cb (gpointer user_data)
{
  int rc = RPC_TEST_EXECUTE_SUCCESS;

  if (rpc_test_execute)
    rc = rpc_test_execute (g_test.user_data);
  RPC_TEST_ENSURE ((rc & ~RPC_TEST_EXECUTE_DONT_QUIT) == RPC_TEST_EXECUTE_SUCCESS);

#ifdef BUILD_CLIENT
  if ((rc & RPC_TEST_EXECUTE_DONT_QUIT) == 0)
    rpc_test_exit_full (0);
#endif
  return FALSE;
}

static gchar **
clone_args (gchar **args)
{
  gchar **new_args;
  gint    i, n, rc = 0;

  if ((new_args = g_strdupv (args)) == NULL)
    g_error ("could not duplicate the program arguments");
  n = g_strv_length (new_args);

#ifdef BUILD_CLIENT
  /* first arg was path to server program, skip it */
  RPC_TEST_ENSURE (n >= 2);
  g_free (new_args[1]);
  for (i = 1; i < n - 1; i++)
    new_args[i] = new_args[i + 1];
  new_args[i] = NULL;
#endif

  return new_args;
}

static void
rpc_test_init_invoke (gchar **program_args)
{
  gchar **args  = NULL;
  gint    n, rc = 0;

  if ((args = clone_args (program_args)) == NULL)
    g_error ("could not clone program arguments");
  n = g_strv_length (args);

  if (rpc_test_init)
    rc = rpc_test_init (n, args);
  g_strfreev (args);
  RPC_TEST_ENSURE (rc == 0);

  g_timeout_add (0, rpc_test_execute_cb, NULL);
}

void
rpc_test_exit (int status)
{
  if (status)
    g_exit_status = status;
  g_main_loop_quit (g_main_loop);
}

void
rpc_test_exit_full (int status)
{
#ifdef BUILD_CLIENT
  /* Tell server to quit, don't expect any reply from him */
  rpc_method_invoke (g_connection,
		     RPC_TEST_METHOD_EXIT,
		     RPC_TYPE_INT32, status,
		     RPC_TYPE_INVALID);
#endif

  rpc_test_exit (status);
}

static int
handle_rpc_test_exit (rpc_connection_t *connection)
{
  int    error;
  gint32 status;

  error = rpc_method_get_args (connection,
			       RPC_TYPE_INT32, &status,
			       RPC_TYPE_INVALID);

  if (error == RPC_ERROR_NO_ERROR)
    rpc_test_exit (status);

  return error;
}

int
main (int argc, char *argv[])
{
  if (rpc_test_get_connection_path)
    g_connection_path = rpc_test_get_connection_path ();
  else
    g_connection_path = NPW_CONNECTION_PATH "/Test.RPC";

#ifdef BUILD_CLIENT
  gchar **child_args;

  if (argc < 2)
    g_error ("no server program provided on command line");

  signal (SIGSEGV, urgent_exit_sig);
  signal (SIGBUS,  urgent_exit_sig);
  signal (SIGINT,  urgent_exit_sig);
  signal (SIGABRT, urgent_exit_sig);

  if ((child_args = clone_args (argv)) == NULL)
    g_error ("could not create server program arguments\n");
  g_free (child_args[0]);
  child_args[0] = g_strdup (argv[1]);

  if (!g_spawn_async (NULL,
		      child_args,
		      NULL,
		      G_SPAWN_DO_NOT_REAP_CHILD,
		      NULL,
		      NULL,
		      &g_child_pid,
		      NULL))
    g_error ("could not start server program '%s'", child_args[0]);

  g_strfreev (child_args);

  if ((g_connection = rpc_init_client (g_connection_path)) == NULL)
    g_error ("failed to initialize RPC client connection");
#endif

#ifdef BUILD_SERVER
  if ((g_connection = rpc_init_server (g_connection_path)) == NULL)
    g_error ("failed to initialize RPC server connection");
#endif

  int        fd            = -1;
  GSource   *rpc_source    = NULL;
  guint      rpc_source_id = 0;
  GPollFD    rpc_event_poll_fd;

#ifdef BUILD_CLIENT
  fd = rpc_socket (g_connection);
#endif
#ifdef BUILD_SERVER
  fd = rpc_listen_socket (g_connection);
#endif
  RPC_TEST_ENSURE (fd >= 0);

  if ((rpc_source = g_source_new (&rpc_event_funcs, sizeof (GSource))) == NULL)
    g_error ("failed to initialize RPC source");

  rpc_source_id = g_source_attach (rpc_source, NULL);
  memset (&rpc_event_poll_fd, 0, sizeof (rpc_event_poll_fd));
  rpc_event_poll_fd.fd      = fd;
  rpc_event_poll_fd.events  = G_IO_IN;
  rpc_event_poll_fd.revents = 0;
  g_source_add_poll (rpc_source, &rpc_event_poll_fd);

  static const rpc_method_descriptor_t vtable[] = {
    { RPC_TEST_METHOD_EXIT, handle_rpc_test_exit }
  };
  if (rpc_connection_add_method_descriptor (g_connection, &vtable[0]) < 0)
    g_error ("could not add method descriptor for TEST_RPC_METHOD_EXIT");

  g_main_loop = g_main_loop_new (NULL, TRUE);
#ifdef BUILD_CLIENT
  g_child_watch_id = g_child_watch_add (g_child_pid, child_exited_cb, NULL);
#endif
  rpc_test_init_invoke (argv);
  g_main_loop_run (g_main_loop);
  if (rpc_source_id)
    g_source_remove (rpc_source_id);
  if (g_connection)
    rpc_exit (g_connection);
  return g_exit_status;
}
