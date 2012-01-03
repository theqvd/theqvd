/*
 *  test-rpc-types.c - Test marshaling of common data types
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
#include "utils.h"
#include <stdarg.h>

#define DEBUG 1
#include "debug.h"

#define RPC_TEST_MAX_ARGS 32

enum
  {
    RPC_TEST_METHOD_VOID__VOID = 1,
    RPC_TEST_METHOD_VOID__CHAR,
    RPC_TEST_METHOD_VOID__CHARx10,
    RPC_TEST_METHOD_VOID__BOOL, 
    RPC_TEST_METHOD_VOID__BOOLx10,
    RPC_TEST_METHOD_VOID__INT32x10,
    RPC_TEST_METHOD_VOID__UINT32x10,
    RPC_TEST_METHOD_VOID__UINT64x10,
    RPC_TEST_METHOD_VOID__DOUBLEx5,
    RPC_TEST_METHOD_VOID__STRINGx3,
    RPC_TEST_METHOD_VOID__CHAR_ARRAY,
    RPC_TEST_METHOD_VOID__INT32_ARRAY,
    RPC_TEST_METHOD_VOID__UINT64_ARRAY,
    RPC_TEST_METHOD_VOID__DOUBLE_ARRAY,
    RPC_TEST_METHOD_VOID__STRING_ARRAY,
    RPC_TEST_METHOD_VOID__NULL_ARRAY,
    RPC_TEST_METHOD_VOID__0LEN_ARRAY,
    RPC_TEST_METHOD_VOID__MIXED_ARRAY
 };

const gchar *
rpc_test_get_connection_path (void)
{
  return NPW_CONNECTION_PATH "/Test.RPC.Types";
}

static void
rpc_test_signature (gboolean is_invoke, ...)
{
  va_list  args;
  gint     type, n_args;
  gboolean was_array;
  GString *str;

  if ((str = g_string_new (NULL)) == NULL)
    return;
  n_args = 0;
  was_array = FALSE;
  va_start (args, is_invoke);
  while ((type = va_arg (args, gint)) != RPC_TYPE_INVALID)
    {
      if (++n_args > 1 && !was_array)
	g_string_append (str, ", ");
      if (was_array)
	{
	  va_arg (args, guint32);
	  if (is_invoke)
	    va_arg (args, gpointer);
	}
      switch (type)
	{
	case RPC_TYPE_CHAR:
	  g_string_append (str, "char");
	  if (is_invoke && !was_array)
	    va_arg (args, int);
	  was_array = FALSE;
	  break;
	case RPC_TYPE_BOOLEAN:
	  g_string_append (str, "bool");
	  if (is_invoke && !was_array)
	    va_arg (args, int);
	  was_array = FALSE;
	  break;
	case RPC_TYPE_INT32:
	  g_string_append (str, "int32");
	  if (is_invoke && !was_array)
	    va_arg (args, gint32);
	  was_array = FALSE;
	  break;
	case RPC_TYPE_UINT32:
	  g_string_append (str, "uint32");
	  if (is_invoke && !was_array)
	    va_arg (args, guint32);
	  was_array = FALSE;
	  break;
	case RPC_TYPE_UINT64:
	  g_string_append (str, "uint64");
	  if (is_invoke && !was_array)
	    va_arg (args, guint64);
	  was_array = FALSE;
	  break;
	case RPC_TYPE_DOUBLE:
	  g_string_append (str, "double");
	  if (is_invoke && !was_array)
	    va_arg (args, gdouble);
	  was_array = FALSE;
	  break;
	case RPC_TYPE_STRING:
	  g_string_append (str, "string");
	  if (is_invoke && !was_array)
	    va_arg (args, gchar *);
	  was_array = FALSE;
	  break;
	case RPC_TYPE_ARRAY:
	  /* XXX: don't allow array of arrays */
	  if (!was_array)
	    {
	      g_string_append (str, "array of ");
	      was_array = TRUE;
	      break;
	    }
	  /* fall-through */
	default:
	  npw_printf ("ERROR: unknown type %d\n", type);
	  abort ();
	}
      if (!is_invoke && type != RPC_TYPE_ARRAY)
	va_arg (args, gpointer);
    }
  va_end (args);
  if (n_args == 0)
    g_string_append (str, "void");
  g_print ("void f (%s)\n", str->str);
  g_string_free (str, TRUE);
}

#define rpc_test_invoke(method, ...) do {				\
  int error;								\
  rpc_connection_t *connection;						\
  connection = rpc_test_get_connection ();				\
  rpc_test_signature (TRUE, __VA_ARGS__);				\
  error = rpc_method_invoke (connection, method, __VA_ARGS__);		\
  RPC_TEST_ENSURE_NO_ERROR (error);					\
  error = rpc_method_wait_for_reply (connection, RPC_TYPE_INVALID);	\
  RPC_TEST_ENSURE_NO_ERROR (error);					\
} while (0)

#define rpc_test_get_args(connection, ...) do {				\
  int error;								\
  rpc_test_signature (FALSE, __VA_ARGS__);				\
  error = rpc_method_get_args (connection, __VA_ARGS__);		\
  RPC_TEST_ENSURE_NO_ERROR (error);					\
} while (0)

static gchar g_char_array[] =
  { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h' };
static gint32 g_int32_array[] =
  { G_MININT32, G_MININT32+1, -2, -1, 0, 1, 2, G_MAXINT32-1, G_MAXINT32 };
static guint64 g_uint64_array[] =
  { 0, 1, G_MAXUINT32-1, G_MAXUINT32, G_MAXUINT32+1, G_MAXUINT64-1, G_MAXUINT64 };
static gdouble g_double_array[] =
  { -2.0, -1.0, 0.0, 1.0, 2.0 };
static const gchar *g_string_array[] =
  { "string", "", NULL, "another one" };

#ifdef BUILD_SERVER
typedef union _RPCTestArg RPCTestArg;

union _RPCTestArg
{
  gchar   c;
  guint   b;
  gint32  i;
  guint32 u;
  guint64 j;
  gdouble d;
  gchar  *s;
  struct {
    gint  l;
    void *p;
  }       a;
};

#define RPC_TEST_ARG_CHAR	c
#define RPC_TEST_ARG_BOOLEAN	b
#define RPC_TEST_ARG_INT32	i
#define RPC_TEST_ARG_UINT32	u
#define RPC_TEST_ARG_UINT64	j
#define RPC_TEST_ARG_DOUBLE	d
#define RPC_TEST_ARG_STRING	s

static RPCTestArg g_args[RPC_TEST_MAX_ARGS];

#define RPC_GET_ARG(N, TYPE) \
	RPC_TYPE_##TYPE, &g_args[N].RPC_TEST_ARG_##TYPE

#define RPC_GET_ARRAY_ARG(N, TYPE) \
	RPC_TYPE_ARRAY, RPC_TYPE_##TYPE, &g_args[N].a.l, &g_args[N].a.p

static int
handle_VOID__VOID (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_INVALID);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__CHAR (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_CHAR, &g_args[0].c,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].c == 'a');

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__CHARx10 (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_CHAR, &g_args[0].c,
		     RPC_TYPE_CHAR, &g_args[1].c,
		     RPC_TYPE_CHAR, &g_args[2].c,
		     RPC_TYPE_CHAR, &g_args[3].c,
		     RPC_TYPE_CHAR, &g_args[4].c,
		     RPC_TYPE_CHAR, &g_args[5].c,
		     RPC_TYPE_CHAR, &g_args[6].c,
		     RPC_TYPE_CHAR, &g_args[7].c,
		     RPC_TYPE_CHAR, &g_args[8].c,
		     RPC_TYPE_CHAR, &g_args[9].c,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].c == 'a');
  RPC_TEST_ENSURE (g_args[1].c == 'b');
  RPC_TEST_ENSURE (g_args[2].c == 'c');
  RPC_TEST_ENSURE (g_args[3].c == 'd');
  RPC_TEST_ENSURE (g_args[4].c == 'e');
  RPC_TEST_ENSURE (g_args[5].c == '1');
  RPC_TEST_ENSURE (g_args[6].c == '2');
  RPC_TEST_ENSURE (g_args[7].c == '3');
  RPC_TEST_ENSURE (g_args[8].c == '4');
  RPC_TEST_ENSURE (g_args[9].c == '5');

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__BOOL (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_BOOLEAN, &g_args[0].b,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].b == TRUE);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__BOOLx10 (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_BOOLEAN, &g_args[0].b,
		     RPC_TYPE_BOOLEAN, &g_args[1].b,
		     RPC_TYPE_BOOLEAN, &g_args[2].b,
		     RPC_TYPE_BOOLEAN, &g_args[3].b,
		     RPC_TYPE_BOOLEAN, &g_args[4].b,
		     RPC_TYPE_BOOLEAN, &g_args[5].b,
		     RPC_TYPE_BOOLEAN, &g_args[6].b,
		     RPC_TYPE_BOOLEAN, &g_args[7].b,
		     RPC_TYPE_BOOLEAN, &g_args[8].b,
		     RPC_TYPE_BOOLEAN, &g_args[9].b,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].b == TRUE);
  RPC_TEST_ENSURE (g_args[1].b == FALSE);
  RPC_TEST_ENSURE (g_args[2].b == TRUE);
  RPC_TEST_ENSURE (g_args[3].b == FALSE);
  RPC_TEST_ENSURE (g_args[4].b == TRUE);
  RPC_TEST_ENSURE (g_args[5].b == FALSE);
  RPC_TEST_ENSURE (g_args[6].b == TRUE);
  RPC_TEST_ENSURE (g_args[7].b == FALSE);
  RPC_TEST_ENSURE (g_args[8].b == TRUE);
  RPC_TEST_ENSURE (g_args[9].b == FALSE);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__INT32x10 (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_INT32, &g_args[0].i,
		     RPC_TYPE_INT32, &g_args[1].i,
		     RPC_TYPE_INT32, &g_args[2].i,
		     RPC_TYPE_INT32, &g_args[3].i,
		     RPC_TYPE_INT32, &g_args[4].i,
		     RPC_TYPE_INT32, &g_args[5].i,
		     RPC_TYPE_INT32, &g_args[6].i,
		     RPC_TYPE_INT32, &g_args[7].i,
		     RPC_TYPE_INT32, &g_args[8].i,
		     RPC_TYPE_INT32, &g_args[9].i,
		     RPC_TYPE_INVALID);
  
  RPC_TEST_ENSURE (g_args[0].i == 0);
  RPC_TEST_ENSURE (g_args[1].i == 1);
  RPC_TEST_ENSURE (g_args[2].i == -1);
  RPC_TEST_ENSURE (g_args[3].i == 2);
  RPC_TEST_ENSURE (g_args[4].i == -2);
  RPC_TEST_ENSURE (g_args[5].i == G_MAXINT32);
  RPC_TEST_ENSURE (g_args[6].i == G_MININT32);
  RPC_TEST_ENSURE (g_args[7].i == G_MAXINT32 - 1);
  RPC_TEST_ENSURE (g_args[8].i == G_MININT32 + 1);
  RPC_TEST_ENSURE (g_args[9].i == 0);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__UINT32x10 (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_UINT32, &g_args[0].u,
		     RPC_TYPE_UINT32, &g_args[1].u,
		     RPC_TYPE_UINT32, &g_args[2].u,
		     RPC_TYPE_UINT32, &g_args[3].u,
		     RPC_TYPE_UINT32, &g_args[4].u,
		     RPC_TYPE_UINT32, &g_args[5].u,
		     RPC_TYPE_UINT32, &g_args[6].u,
		     RPC_TYPE_UINT32, &g_args[7].u,
		     RPC_TYPE_UINT32, &g_args[8].u,
		     RPC_TYPE_UINT32, &g_args[9].u,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].u == 0);
  RPC_TEST_ENSURE (g_args[1].u == 1);
  RPC_TEST_ENSURE (g_args[2].u == 0xffffffff);
  RPC_TEST_ENSURE (g_args[3].u == 2);
  RPC_TEST_ENSURE (g_args[4].u == 0xfffffffe);
  RPC_TEST_ENSURE (g_args[5].u == G_MAXUINT32);
  RPC_TEST_ENSURE (g_args[6].u == G_MAXUINT32 - 1);
  RPC_TEST_ENSURE (g_args[7].u == 0x80000000);
  RPC_TEST_ENSURE (g_args[8].u == 0x80000001);
  RPC_TEST_ENSURE (g_args[9].u == 0);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__UINT64x10 (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_UINT64, &g_args[0].j,
		     RPC_TYPE_UINT64, &g_args[1].j,
		     RPC_TYPE_UINT64, &g_args[2].j,
		     RPC_TYPE_UINT64, &g_args[3].j,
		     RPC_TYPE_UINT64, &g_args[4].j,
		     RPC_TYPE_UINT64, &g_args[5].j,
		     RPC_TYPE_UINT64, &g_args[6].j,
		     RPC_TYPE_UINT64, &g_args[7].j,
		     RPC_TYPE_UINT64, &g_args[8].j,
		     RPC_TYPE_UINT64, &g_args[9].j,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].j == 0);
  RPC_TEST_ENSURE (g_args[1].j == G_GINT64_CONSTANT (0x00000000000000ffU));
  RPC_TEST_ENSURE (g_args[2].j == G_GINT64_CONSTANT (0x000000000000ff00U));
  RPC_TEST_ENSURE (g_args[3].j == G_GINT64_CONSTANT (0x0000000000ff0000U));
  RPC_TEST_ENSURE (g_args[4].j == G_GINT64_CONSTANT (0x00000000ff000000U));
  RPC_TEST_ENSURE (g_args[5].j == G_GINT64_CONSTANT (0x000000ff00000000U));
  RPC_TEST_ENSURE (g_args[6].j == G_GINT64_CONSTANT (0x0000ff0000000000U));
  RPC_TEST_ENSURE (g_args[7].j == G_GINT64_CONSTANT (0x00ff000000000000U));
  RPC_TEST_ENSURE (g_args[8].j == G_GINT64_CONSTANT (0xff00000000000000U));
  RPC_TEST_ENSURE (g_args[9].j == G_GINT64_CONSTANT (0x0123456789abcdefU));

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__DOUBLEx5 (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_DOUBLE, &g_args[0].d,
		     RPC_TYPE_DOUBLE, &g_args[1].d,
		     RPC_TYPE_DOUBLE, &g_args[2].d,
		     RPC_TYPE_DOUBLE, &g_args[3].d,
		     RPC_TYPE_DOUBLE, &g_args[4].d,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].d == 0.0);
  RPC_TEST_ENSURE (g_args[1].d == 1.0);
  RPC_TEST_ENSURE (g_args[2].d == -1.0);
  RPC_TEST_ENSURE (g_args[3].d == 2.0);
  RPC_TEST_ENSURE (g_args[4].d == -2.0);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__STRINGx3 (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_TYPE_STRING, &g_args[0].s,
		     RPC_TYPE_STRING, &g_args[1].s,
		     RPC_TYPE_STRING, &g_args[2].s,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].s && strcmp (g_args[0].s, "") == 0);
  free (g_args[0].s);
  RPC_TEST_ENSURE (g_args[1].s && strcmp (g_args[1].s, "one") == 0);
  free (g_args[1].s);
  RPC_TEST_ENSURE (g_args[2].s == NULL);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__CHAR_ARRAY (rpc_connection_t *connection)
{
  guint32 len;
  gchar  *array;

  rpc_test_get_args (connection,
		     RPC_TYPE_ARRAY, RPC_TYPE_CHAR, &len, &array,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (len == G_N_ELEMENTS (g_char_array));
  RPC_TEST_ENSURE (array != NULL);
  for (int i = 0; i < len; i++)
    RPC_TEST_ENSURE (array[i] == g_char_array[i]);

  free (array);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__INT32_ARRAY (rpc_connection_t *connection)
{
  guint32 len;
  gint32 *array;

  rpc_test_get_args (connection,
		     RPC_TYPE_ARRAY, RPC_TYPE_INT32, &len, &array,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (len == G_N_ELEMENTS (g_int32_array));
  RPC_TEST_ENSURE (array != NULL);
  for (int i = 0; i < len; i++)
    RPC_TEST_ENSURE (array[i] == g_int32_array[i]);

  free (array);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__UINT64_ARRAY (rpc_connection_t *connection)
{
  guint32  len;
  guint64 *array;

  rpc_test_get_args (connection,
		     RPC_TYPE_ARRAY, RPC_TYPE_UINT64, &len, &array,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (len == G_N_ELEMENTS (g_uint64_array));
  RPC_TEST_ENSURE (array != NULL);
  for (int i = 0; i < len; i++)
    RPC_TEST_ENSURE (array[i] == g_uint64_array[i]);

  free (array);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__DOUBLE_ARRAY (rpc_connection_t *connection)
{
  guint32  len;
  gdouble *array;

  rpc_test_get_args (connection,
		     RPC_TYPE_ARRAY, RPC_TYPE_DOUBLE, &len, &array,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (len == G_N_ELEMENTS (g_double_array));
  RPC_TEST_ENSURE (array != NULL);
  for (int i = 0; i < len; i++)
    RPC_TEST_ENSURE (array[i] == g_double_array[i]);

  free (array);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__STRING_ARRAY (rpc_connection_t *connection)
{
  guint32 len;
  gchar **array;

  rpc_test_get_args (connection,
		     RPC_TYPE_ARRAY, RPC_TYPE_STRING, &len, &array,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (len == G_N_ELEMENTS (g_string_array));
  RPC_TEST_ENSURE (array != NULL);
  for (int i = 0; i < len; i++)
    {
      if (g_string_array[i])
	{
	  RPC_TEST_ENSURE (array[i] != NULL);
	  RPC_TEST_ENSURE (strcmp (array[i], g_string_array[i]) == 0);

	  free (array[i]);
	}
      else
	RPC_TEST_ENSURE (array[i] == NULL);
    }

  free (array);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__NULL_ARRAY_with_length (rpc_connection_t *connection,
				     gint32            expected_length)
{
  gint32 len;
  gchar *array = GUINT_TO_POINTER (0xdeadbeef);

  rpc_test_get_args (connection,
		     RPC_TYPE_ARRAY, RPC_TYPE_CHAR, &len, &array,
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (len == expected_length);
  RPC_TEST_ENSURE (array == NULL);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

static int
handle_VOID__NULL_ARRAY (rpc_connection_t *connection)
{
  return handle_VOID__NULL_ARRAY_with_length (connection, 1);
}

static int
handle_VOID__0LEN_ARRAY (rpc_connection_t *connection)
{
  return handle_VOID__NULL_ARRAY_with_length (connection, 0);
}

static int
handle_VOID__MIXED_ARRAY (rpc_connection_t *connection)
{
  rpc_test_get_args (connection,
		     RPC_GET_ARRAY_ARG (0, CHAR),
		     RPC_GET_ARRAY_ARG (1, CHAR),
		     RPC_GET_ARRAY_ARG (2, CHAR),
		     RPC_GET_ARRAY_ARG (3, CHAR),
		     RPC_GET_ARRAY_ARG (4, CHAR),
		     RPC_TYPE_INVALID);

  RPC_TEST_ENSURE (g_args[0].a.l == G_N_ELEMENTS (g_char_array));
  RPC_TEST_ENSURE (g_args[0].a.p != NULL);
  RPC_TEST_ENSURE (memcmp (g_args[0].a.p, g_char_array, g_args[0].a.l) == 0);
  RPC_TEST_ENSURE (g_args[1].a.l == G_N_ELEMENTS (g_char_array));
  RPC_TEST_ENSURE (g_args[1].a.p != NULL);
  RPC_TEST_ENSURE (memcmp (g_args[1].a.p, g_char_array, g_args[1].a.l) == 0);
  RPC_TEST_ENSURE (g_args[2].a.l == 0);
  RPC_TEST_ENSURE (g_args[2].a.p == NULL);
  RPC_TEST_ENSURE (g_args[3].a.l == 0);
  RPC_TEST_ENSURE (g_args[3].a.p == NULL);
  RPC_TEST_ENSURE (g_args[4].a.l == 1);
  RPC_TEST_ENSURE (g_args[4].a.p == NULL);

  free (g_args[0].a.p);
  free (g_args[1].a.p);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}
#endif

int
rpc_test_init (int argc, char *argv[])
{
#ifdef BUILD_SERVER
  rpc_connection_t *connection;

  static const rpc_method_descriptor_t vtable[] =
	{
	  { RPC_TEST_METHOD_VOID__VOID,		handle_VOID__VOID	},
	  { RPC_TEST_METHOD_VOID__CHAR,		handle_VOID__CHAR	},
	  { RPC_TEST_METHOD_VOID__CHARx10,	handle_VOID__CHARx10	},
	  { RPC_TEST_METHOD_VOID__BOOL,		handle_VOID__BOOL	},
	  { RPC_TEST_METHOD_VOID__BOOLx10,	handle_VOID__BOOLx10	},
	  { RPC_TEST_METHOD_VOID__INT32x10,	handle_VOID__INT32x10	},
	  { RPC_TEST_METHOD_VOID__UINT32x10,	handle_VOID__UINT32x10	},
	  { RPC_TEST_METHOD_VOID__UINT64x10,	handle_VOID__UINT64x10	},
	  { RPC_TEST_METHOD_VOID__DOUBLEx5,	handle_VOID__DOUBLEx5	},
	  { RPC_TEST_METHOD_VOID__STRINGx3,	handle_VOID__STRINGx3	},
	  { RPC_TEST_METHOD_VOID__CHAR_ARRAY,	handle_VOID__CHAR_ARRAY	},
	  { RPC_TEST_METHOD_VOID__INT32_ARRAY,	handle_VOID__INT32_ARRAY  },
	  { RPC_TEST_METHOD_VOID__UINT64_ARRAY,	handle_VOID__UINT64_ARRAY },
	  { RPC_TEST_METHOD_VOID__DOUBLE_ARRAY,	handle_VOID__DOUBLE_ARRAY },
	  { RPC_TEST_METHOD_VOID__STRING_ARRAY,	handle_VOID__STRING_ARRAY },
	  { RPC_TEST_METHOD_VOID__NULL_ARRAY,	handle_VOID__NULL_ARRAY	},
	  { RPC_TEST_METHOD_VOID__0LEN_ARRAY,	handle_VOID__0LEN_ARRAY	},
	  { RPC_TEST_METHOD_VOID__MIXED_ARRAY,	handle_VOID__MIXED_ARRAY }
	};

  connection = rpc_test_get_connection ();
  RPC_TEST_ENSURE (connection != NULL);

  if (rpc_connection_add_method_descriptors(connection,
					    vtable,
					    G_N_ELEMENTS (vtable)) < 0)
    g_error ("could not add method descriptors");
#endif

  return 0;
}

int
rpc_test_execute (gpointer user_data)
{
#ifdef BUILD_CLIENT
  /* Basic types */
  rpc_test_invoke (RPC_TEST_METHOD_VOID__VOID,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__CHAR,
		   RPC_TYPE_CHAR, 'a',
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__CHARx10,
		   RPC_TYPE_CHAR, 'a',
		   RPC_TYPE_CHAR, 'b',
		   RPC_TYPE_CHAR, 'c',
		   RPC_TYPE_CHAR, 'd',
		   RPC_TYPE_CHAR, 'e',
		   RPC_TYPE_CHAR, '1',
		   RPC_TYPE_CHAR, '2',
		   RPC_TYPE_CHAR, '3',
		   RPC_TYPE_CHAR, '4',
		   RPC_TYPE_CHAR, '5',
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__BOOL,
		   RPC_TYPE_BOOLEAN, TRUE,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__BOOLx10,
		   RPC_TYPE_BOOLEAN, TRUE,
		   RPC_TYPE_BOOLEAN, FALSE,
		   RPC_TYPE_BOOLEAN, TRUE,
		   RPC_TYPE_BOOLEAN, FALSE,
		   RPC_TYPE_BOOLEAN, TRUE,
		   RPC_TYPE_BOOLEAN, FALSE,
		   RPC_TYPE_BOOLEAN, TRUE,
		   RPC_TYPE_BOOLEAN, FALSE,
		   RPC_TYPE_BOOLEAN, TRUE,
		   RPC_TYPE_BOOLEAN, FALSE,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__INT32x10,
		   RPC_TYPE_INT32, 0,
		   RPC_TYPE_INT32, 1,
		   RPC_TYPE_INT32, -1,
		   RPC_TYPE_INT32, 2,
		   RPC_TYPE_INT32, -2,
		   RPC_TYPE_INT32, G_MAXINT32,
		   RPC_TYPE_INT32, G_MININT32,
		   RPC_TYPE_INT32, G_MAXINT32 - 1,
		   RPC_TYPE_INT32, G_MININT32 + 1,
		   RPC_TYPE_INT32, 0,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__UINT32x10,
		   RPC_TYPE_UINT32, 0,
		   RPC_TYPE_UINT32, 1,
		   RPC_TYPE_UINT32, 0xffffffff,
		   RPC_TYPE_UINT32, 2,
		   RPC_TYPE_UINT32, 0xfffffffe,
		   RPC_TYPE_UINT32, G_MAXUINT32,
		   RPC_TYPE_UINT32, G_MAXUINT32 - 1,
		   RPC_TYPE_UINT32, 0x80000000,
		   RPC_TYPE_UINT32, 0x80000001,
		   RPC_TYPE_UINT32, 0,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__UINT64x10,
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0x00000000000000ffU),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0x000000000000ff00U),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0x0000000000ff0000U),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0x00000000ff000000U),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0x000000ff00000000U),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0x0000ff0000000000U),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0x00ff000000000000U),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0xff00000000000000U),
		   RPC_TYPE_UINT64, G_GINT64_CONSTANT (0x0123456789abcdefU),
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__DOUBLEx5,
		   RPC_TYPE_DOUBLE, 0.0,
		   RPC_TYPE_DOUBLE, 1.0,
		   RPC_TYPE_DOUBLE, -1.0,
		   RPC_TYPE_DOUBLE, 2.0,
		   RPC_TYPE_DOUBLE, -2.0,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__STRINGx3,
		   RPC_TYPE_STRING, "",
		   RPC_TYPE_STRING, "one",
		   RPC_TYPE_STRING, NULL,
		   RPC_TYPE_INVALID);

  /* Arrays */
  rpc_test_invoke (RPC_TEST_METHOD_VOID__CHAR_ARRAY,
		   RPC_TYPE_ARRAY, RPC_TYPE_CHAR,
		   (gint32)G_N_ELEMENTS (g_char_array), g_char_array,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__INT32_ARRAY,
		   RPC_TYPE_ARRAY, RPC_TYPE_INT32,
		   (gint32)G_N_ELEMENTS (g_int32_array), g_int32_array,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__UINT64_ARRAY,
		   RPC_TYPE_ARRAY, RPC_TYPE_UINT64,
		   (gint32)G_N_ELEMENTS (g_uint64_array), g_uint64_array,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__DOUBLE_ARRAY,
		   RPC_TYPE_ARRAY, RPC_TYPE_DOUBLE,
		   (gint32)G_N_ELEMENTS (g_double_array), g_double_array,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__STRING_ARRAY,
		   RPC_TYPE_ARRAY, RPC_TYPE_STRING,
		   (gint32)G_N_ELEMENTS (g_string_array), g_string_array,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__NULL_ARRAY,
		   RPC_TYPE_ARRAY, RPC_TYPE_CHAR, 1, NULL,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__0LEN_ARRAY,
		   RPC_TYPE_ARRAY, RPC_TYPE_CHAR, 0, g_char_array,
		   RPC_TYPE_INVALID);

  rpc_test_invoke (RPC_TEST_METHOD_VOID__MIXED_ARRAY,
		   RPC_TYPE_ARRAY, RPC_TYPE_CHAR,
		   (gint32)G_N_ELEMENTS (g_char_array), g_char_array,
		   RPC_TYPE_ARRAY, RPC_TYPE_CHAR,
		   (gint32)G_N_ELEMENTS (g_char_array), g_char_array,
		   RPC_TYPE_ARRAY, RPC_TYPE_CHAR, 0, NULL,
		   RPC_TYPE_ARRAY, RPC_TYPE_CHAR, 0, g_char_array,
		   RPC_TYPE_ARRAY, RPC_TYPE_CHAR, 1, NULL,
		   RPC_TYPE_INVALID);
#endif
  return RPC_TEST_EXECUTE_SUCCESS;
}
