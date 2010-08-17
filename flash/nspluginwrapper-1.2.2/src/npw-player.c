/*
 *  npw-player.c - Standalone plugin player
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
#include <unistd.h>
#include <glib.h>
#include <glib/gstdio.h>
#include <glib/gthread.h>
#include <gtk/gtk.h>
#include <gdk/gdkx.h>
#include <gdk/gdkkeysyms.h>
#include "rpc.h"
#include "utils.h"
#include "glibcurl.h"
#include "gtk2xtbin.h"
#include "npw-rpc.h"

#define XP_UNIX 1
#define MOZ_X11 1
#include <npapi.h>
#include <npupp.h>

#define DEBUG 1
#include "debug.h"

// Define to use XEMBED
#define USE_XEMBED 1

#define DEFAULT_WIDTH  640
#define DEFAULT_HEIGHT 480

enum
  {
    BACKEND_GTK = 1,
  };

static gboolean g_verbose     = FALSE;
static guint g_backend        = BACKEND_GTK;
static guint g_n_plugins      = 0;

typedef struct _Plugin		Plugin;
typedef struct _PluginDataType	PluginDataType;
typedef struct _StreamInstance  StreamInstance;
typedef struct _StreamBuffer    StreamBuffer;
typedef struct _PlayerApp	PlayerApp;
typedef struct _GtkDisplay	GtkDisplay;

typedef NPError (*NP_InitializeUPP) (NPNetscapeFuncs *, NPPluginFuncs *);
typedef NPError (*NP_ShutdownUPP) (void);
typedef NPError (*NP_GetValueUPP) (void *, NPPVariable, void *);
typedef char *  (*NP_GetMIMEDescriptionUPP) (void);

#define GTK_DISPLAY(display)		((GtkDisplay *)(display))
#define APP_GTK_DISPLAY(app)		GTK_DISPLAY ((app)->display)
#define DISPLAY_WIDTH(display)		GTK_DISPLAY (display)->width
#define DISPLAY_HEIGHT(display)		GTK_DISPLAY (display)->height

struct _GtkDisplay
{
  GtkWidget *window;
  GtkWidget *canvas;
  gint width;
  gint height;
};

struct _PlayerApp
{
  GtkWidget  *window;
  gpointer    display;
  guint       width;
  guint       height;
  guint16     mode;
  GHashTable *attrs;
  Plugin     *plugin;
  GList      *plugins;
};

struct _Plugin
{
  gchar                   *path;
  gchar                   *src;
  gchar                   *mime_type;
  GModule                 *module;
  GList                   *data_types;
  GtkWidget               *window;
  gboolean                 use_xembed;

  rpc_connection_t *     (*get_master_connection)(void);
  NPP                      instance;
  NPWindow                 np_window;
  NP_InitializeUPP         NP_Initialize;
  NP_ShutdownUPP           NP_Shutdown;
  NP_GetValueUPP           NP_GetValue;
  NP_GetMIMEDescriptionUPP NP_GetMIMEDescription;
  NPPluginFuncs            plugin_funcs;
  NPNetscapeFuncs          mozilla_funcs;
};

enum
  {
    PLUGIN_DATA_TYPE_MIME        = 0,
    PLUGIN_DATA_TYPE_EXTENSION   = 1,
    PLUGIN_DATA_TYPE_DESCRIPTION = 2,
    PLUGIN_DATA_TYPE_VALUE_COUNT
  };

struct _PluginDataType
{
  gchar *values[PLUGIN_DATA_TYPE_VALUE_COUNT];
};

enum
  {
    STREAM_STATUS_IDLE    = 0,
    STREAM_STATUS_ACTIVE  = 1 << 1,
    STREAM_STATUS_ERROR   = 1 << 2,
    STREAM_STATUS_FINISH  = 1 << 3,
    STREAM_STATUS_DESTROY = 1 << 4
  };

enum
  {
    URI_TYPE_UNKNOWN = 0,
    URI_TYPE_FILE,
    URI_TYPE_HTTP,
    URI_TYPE_FTP
  };

struct _StreamInstance
{
  NPStream  *np_stream;
  Plugin    *plugin;
  gchar     *mime_type;
  gpointer   notify_data;
  guint16    stype;
  guint      uri_type;
  gboolean   seekable;
  guint      status;

  /* XXX: machinery to download stream then propagate it to the plugin */
  CURL      *curl_handle;
  FILE      *temp_file;
  gchar     *temp_filename;
  gint       commit_source;
  GList     *buffers;
  guint      offset;
};

struct _StreamBuffer
{
  guchar    *bytes;
  guint      size;
  guint      offset;
};

static GList *
plugin_get_data_types (Plugin *plugin);

static gboolean
on_stream_open_cb (gpointer user_data);

static void
on_stream_close_cb (gpointer user_data);

static gboolean
on_stream_commit_cb (gpointer user_data);

static StreamInstance *
stream_new (Plugin *plugin,
	    const gchar *src, const gchar *type, void *notify_data,
	    NPError *error);

static void
stream_destroy (StreamInstance *pstream);

static StreamBuffer *
stream_buffer_new (guchar *bytes, gsize nbytes);

static void
stream_buffer_destroy (StreamBuffer *buffer);


/* ====================================================================== */
/* === Utility functions                                              === */
/* ====================================================================== */

static int
uri_type_from_url (const gchar *url)
{
  int uri_type = URI_TYPE_UNKNOWN;
  if (g_ascii_strncasecmp (url, "file://", 7) == 0)
    uri_type   = URI_TYPE_FILE;
  else if (g_ascii_strncasecmp (url, "http://", 7) == 0)
    uri_type   = URI_TYPE_HTTP;
  else if (g_ascii_strncasecmp (url, "ftp://", 6) == 0)
    uri_type   = URI_TYPE_FTP;
  return uri_type;
}

/* Sanitize URL, e.g. translate local file names to file:// syntax */
gchar *
sanitize_url (const gchar *uri)
{
  /* Local contents has preference if no URI scheme is specified.
   *
   * This means that if you set src to 'www.example.com/thing.swf' and
   * you have a www.example.com directory in the current working
   * directory, then the file:// protocol will be prepended. Should
   * you need http://, then this has to be specified explicitly.
   * However, if there is no www.example.com directory, then libcurl
   * will try to resolve this to http:// or whatever.
   */
  if (uri_type_from_url (uri) != URI_TYPE_UNKNOWN)
    return g_strdup (uri);

  if (!g_file_test (uri, G_FILE_TEST_EXISTS))
    return g_strdup (uri);

  GString *new_uri = g_string_new ("file://");
  if (uri[0] != G_DIR_SEPARATOR)
    {
      gchar *cwd = g_get_current_dir ();
      g_string_append (new_uri, cwd);
      g_string_append (new_uri, G_DIR_SEPARATOR_S);
      g_free (cwd);
    }
  g_string_append (new_uri, uri);
  return g_string_free (new_uri, FALSE);
}

static gchar *
get_mime_type_from_content (guchar *bytes, guint size)
{
  gchar *mime_type = NULL;

  /* XXX: poor man's MIME type characterisation */
  static const guchar gif_sig[] = {0x47, 0x49, 0x46, 0x38};
  static const guchar png_sig[] = {0x89, 0x50, 0x4e, 0x47};
  static const guchar jpg_sig[] = {0xff, 0xd8, 0xff};
  static const guchar bmp_sig[] = {0x42, 0x4d};
  static const guchar flv_sig[] = {0x46, 0x4c, 0x56};
  static const guchar xml_sig[] = {0x3c, 0x3f, 0x78, 0x6d, 0x6c};

#define MATCH(TYPE)						\
  (size >= sizeof (TYPE##_sig) &&				\
   memcmp (bytes, TYPE##_sig, sizeof (TYPE##_sig)) == 0)

  if (MATCH(png))
    mime_type = "image/png";
  else if (MATCH(jpg))
    mime_type = "image/jpeg";
  else if (MATCH(gif))
    mime_type = "image/gif";
  else if (MATCH(bmp))
    mime_type = "image/bmp";
  else if (MATCH(flv))
    mime_type = "video/x-flv";
  else if (MATCH(xml))
    mime_type = "text/xml";
  else if (size >= 6 && g_ascii_strncasecmp ((gchar *)bytes, "<html>", 6) == 0)
    mime_type = "text/html";

#undef MATCH

  if (mime_type)
    return g_strdup (mime_type);

  D(bug("Could not determine MIME type for {%02x,%02x,%02x,%02x,%02x,%02x}\n",
	bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5]));
  return NULL;
}

static void
player_app_main_quit (void)
{
  if (g_backend == BACKEND_GTK)
    gtk_main_quit ();
}

#define UNIMPLEMENTED() NP_Unimplemented (__func__, __FILE__, __LINE__)

static void
NP_Unimplemented (const gchar *funcname, const gchar *filename, gint lineno)
{
  npw_printf ("WARNING: unimplemented function %s() at %s:%d\n",
	      funcname, filename, lineno);
}


/* ====================================================================== */
/* === NPRuntime API                                                  === */
/* ====================================================================== */

static NPObject *
g_NPN_CreateObject (NPP instance, NPClass *klass)
{
  if (instance == NULL)
    return NULL;

  if (klass == NULL)
    return NULL;

  NPObject *npobj;
  if (klass->allocate)
    npobj = klass->allocate (instance, klass);
  else
    npobj = g_new (NPObject, 1);

  if (npobj)
    {
      npobj->_class = klass;
      npobj->referenceCount = 1;
    }

  return npobj;
}

static NPObject *
g_NPN_RetainObject (NPObject *npobj)
{
  if (npobj)
    g_atomic_int_add ((volatile gint *)&npobj->referenceCount, 1);

  return npobj;
}

static void
g_NPN_ReleaseObject (NPObject *npobj)
{
  if (npobj == NULL)
    return;

  g_atomic_int_add ((volatile gint *)&npobj->referenceCount, -1);
  if (g_atomic_int_get ((volatile gint *)&npobj->referenceCount) == 0)
    {
      if (npobj->_class && npobj->_class->deallocate)
	npobj->_class->deallocate (npobj);
      else
	g_free (npobj);
    }
}

static bool
g_NPN_Invoke (NPP instance, NPObject *npobj, NPIdentifier methodName,
	      const NPVariant *args, uint32_t argCount, NPVariant *result)
{
  if (!instance || !npobj || !npobj->_class || !npobj->_class->invoke)
    return false;

  return npobj->_class->invoke (npobj, methodName, args, argCount, result);
}

static bool
g_NPN_InvokeDefault (NPP instance, NPObject *npobj,
		     const NPVariant *args, uint32_t argCount, NPVariant *result)
{
  if (!instance || !npobj || !npobj->_class || !npobj->_class->invokeDefault)
    return false;

  return npobj->_class->invokeDefault (npobj, args, argCount, result);
}

static bool
g_NPN_Evaluate (NPP instance, NPObject *npobj, NPString *script, NPVariant *result)
{
  if (!instance || !npobj)
    return false;

  if (result)
    VOID_TO_NPVARIANT (*result);

  if (!script || !script->utf8length || !script->utf8characters)
    return true; // nothing to evaluate

  UNIMPLEMENTED();
  return false;
}

static bool
g_NPN_GetProperty (NPP instance, NPObject *npobj, NPIdentifier propertyName,
		   NPVariant *result)
{
  if (!instance || !npobj || !npobj->_class || !npobj->_class->getProperty)
    return false;

  return npobj->_class->getProperty (npobj, propertyName, result);
}

static bool
g_NPN_SetProperty (NPP instance, NPObject *npobj, NPIdentifier propertyName,
		   const NPVariant *value)
{
  if (!instance || !npobj || !npobj->_class || !npobj->_class->setProperty)
    return false;

  return npobj->_class->setProperty (npobj, propertyName, value);
}

static bool
g_NPN_RemoveProperty (NPP instance, NPObject *npobj, NPIdentifier propertyName)
{
  if (!instance || !npobj || !npobj->_class || !npobj->_class->removeProperty)
    return false;

  return npobj->_class->removeProperty (npobj, propertyName);
}

static bool
g_NPN_HasProperty (NPP instance, NPObject *npobj, NPIdentifier propertyName)
{
  if (!instance || !npobj || !npobj->_class || !npobj->_class->hasProperty)
    return false;

  return npobj->_class->hasProperty (npobj, propertyName);
}

static bool
g_NPN_HasMethod (NPP instance, NPObject *npobj, NPIdentifier methodName)
{
  if (!instance || !npobj || !npobj->_class || !npobj->_class->hasMethod)
    return false;

  return npobj->_class->hasProperty (npobj, methodName);
}

static void
g_NPN_SetException (NPObject *npobj, const NPUTF8 *message)
{
  UNIMPLEMENTED();
}

static void
g_NPN_ReleaseVariantValue (NPVariant *variant)
{
  /* XXX: suppress double free condition in npw-wrapper.c */
  switch (variant->type)
    {
    case NPVariantType_String:
      {
	NPString *s = &NPVARIANT_TO_STRING (*variant);
	if (s->utf8characters)
	  {
	    g_free ((gpointer)s->utf8characters);
	    s->utf8characters = NULL;
	  }
	break;
      }
    case NPVariantType_Object:
      {
	NPObject *npobj = NPVARIANT_TO_OBJECT (*variant);
	if (npobj)
	  g_NPN_ReleaseObject (npobj);
	break;
      }
    default:
      break;
    }

  VOID_TO_NPVARIANT (*variant);
}

/* NOTE: g_intern_string() returns linear ids */
#define NP_IDENTIFIER_OBJECT	0x0
#define NP_IDENTIFIER_INT	0x1
#define NP_IDENTIFIER_STRING	0x2

static inline gboolean
is_string_identifier (NPIdentifier id)
{
  return (GPOINTER_TO_UINT (id) & 3) == NP_IDENTIFIER_STRING;
}

static inline NPIdentifier
pack_string_identifier (const gchar *str)
{
  guint32 id = g_quark_from_string (str);
  return GUINT_TO_POINTER ((id << 2) | NP_IDENTIFIER_STRING);
}

static inline const gchar *
unpack_string_identifier (NPIdentifier id)
{
  g_return_val_if_fail (is_string_identifier (id), NULL);
  return g_quark_to_string (GPOINTER_TO_UINT (id) >> 2);
}

static inline gboolean
is_int_identifier (NPIdentifier id)
{
  /* NOTE: the integer value must be 31-bit */
  return (GPOINTER_TO_UINT (id) & 1) == NP_IDENTIFIER_INT;
}

static inline NPIdentifier
pack_int_identifier (int32_t value)
{
  
  return GUINT_TO_POINTER ((((uint32_t)value) << 1) | NP_IDENTIFIER_INT);
}

static inline int32_t
unpack_int_identifier (NPIdentifier id)
{
  g_return_val_if_fail (is_int_identifier (id), 0);
  return ((int32_t)(GPOINTER_TO_INT (id))) >> 1;
}

static NPIdentifier
g_NPN_GetStringIdentifier (const NPUTF8 *name)
{
  if (name == NULL)
    return NULL;

  return pack_string_identifier ((gchar *)name);
}

static void
g_NPN_GetStringIdentifiers (const NPUTF8 **names, uint32_t nameCount, NPIdentifier *identifiers)
{
  if (names == NULL)
    return;

  if (identifiers == NULL)
    return;

  for (int i = 0; i < nameCount; i++)
    identifiers[i] = pack_string_identifier ((gchar *)names[i]);
}

static NPIdentifier
g_NPN_GetIntIdentifier (int32_t intid)
{
  return pack_int_identifier (intid);
}

static bool
g_NPN_IdentifierIsString (NPIdentifier identifier)
{
  return is_string_identifier (identifier);
}

static NPUTF8 *
g_NPN_UTF8FromIdentifier(NPIdentifier identifier)
{
  return (NPUTF8 *)unpack_string_identifier (identifier);
}

static int32_t
g_NPN_IntFromIdentifier (NPIdentifier identifier)
{
  return unpack_int_identifier (identifier);
}

/* ====================================================================== */
/* === Browser side plug-in API                                       === */
/* ====================================================================== */

static const char *
g_NPN_UserAgent(NPP instance)
{
  D(bug("NPN_UserAgent instance %p\n", instance));

  return "Mozilla/5.0 (X11; U; Linux i386; en-US; rv:1.8.1) Gecko/20061010 Firefox/2.0";
}

static void
g_NPN_Status (NPP instance, const char *message)
{
  D(bug("NPN_Status instance %p\n", instance));

  UNIMPLEMENTED();
}

static NPError
g_NPN_GetValue (NPP instance, NPNVariable variable, void *value)
{
  D(bug("NPN_GetValue instance %p, variable %d [%08x]\n",
	instance, variable & 0xffff, variable));

  switch (variable) {
#if 0
  case NPNVxDisplay:
    break;
  case NPNVxtAppContext:
    break;
#endif
  case NPNVToolkit:
    *(NPNToolkitType *)value = NPNVGtk2;
    break;
  case NPNVSupportsXEmbedBool:
    *(PRBool *)value = USE_XEMBED;
    break;
  default:
    npw_printf ("WARNING: unhandled variable %d in NPN_GetValue()\n", variable);
    return NPERR_INVALID_PARAM;
  }

  return NPERR_NO_ERROR;
}

static NPError
g_NPN_SetValue (NPP instance, NPPVariable variable, void *value)
{
  D(bug("NPN_SetValue instance %p\n", instance));

  UNIMPLEMENTED();

  return NPERR_GENERIC_ERROR;
}

static NPError
g_NPN_GetURL (NPP instance, const char *url, const char *target)
{
  if (instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  D(bug("NPN_GetURL instance %p\n", instance));

  UNIMPLEMENTED();

  return NPERR_GENERIC_ERROR;
}

static NPError
g_NPN_GetURLNotify (NPP instance, const char *url, const char *target, void *notifyData)
{
  if (instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  D(bug("NPN_GetURLNotify instance %p\n", instance));

  if (target == NULL)
    {
      NPError ret = NPERR_GENERIC_ERROR;
      stream_new (instance->ndata, url, NULL, notifyData, &ret);
      return ret;
    }

  UNIMPLEMENTED();

  return NPERR_GENERIC_ERROR;
}

static NPError
g_NPN_PostURL (NPP instance, const char *url, const char *target, uint32 len, const char *buf, NPBool file)
{
  if (instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  D(bug("NPN_PostURL instance %p\n", instance));

  UNIMPLEMENTED ();

  return NPERR_GENERIC_ERROR;
}

static NPError
g_NPN_PostURLNotify (NPP instance, const char *url, const char *target, uint32 len, const char *buf, NPBool file, void *notifyData)
{
  if (instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  D(bug("NPN_PostURLNotify instance %p\n", instance));

  UNIMPLEMENTED();

  return NPERR_GENERIC_ERROR;
}

static NPError
g_NPN_NewStream (NPP instance, NPMIMEType type, const char *target, NPStream **stream)
{
  if (instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  if (stream == NULL)
    return NPERR_INVALID_PARAM;
  *stream = NULL;

  D(bug("NPN_NewStream instance %p\n", instance));

  UNIMPLEMENTED();

  return NPERR_GENERIC_ERROR;
}

static NPError
g_NPN_DestroyStream (NPP instance, NPStream *stream, NPError reason)
{
  if (instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  if (stream == NULL)
    return NPERR_INVALID_PARAM;

  D(bug("NPN_DestroyStream instance %p, stream %p, reason %s\n",
	instance, stream, string_of_NPReason(reason)));

  UNIMPLEMENTED();

  return NPERR_GENERIC_ERROR;
}

static NPError
g_NPN_RequestRead (NPStream *stream, NPByteRange *rangeList)
{
  if (stream == NULL || stream->ndata == NULL || rangeList == NULL)
	return NPERR_INVALID_PARAM;

  D(bug("NPN_RequestRead stream=%p\n", stream));

  UNIMPLEMENTED();

  return NPERR_GENERIC_ERROR;
}

static int32
g_NPN_Write (NPP instance, NPStream *stream, int32 len, void *buf)
{
  if (instance == NULL)
    return -1;

  if (stream == NULL)
    return -1;

  D(bug("NPN_Write instance %p, stream %p, len %d, buf %p\n", instance, stream, len, buf));

  UNIMPLEMENTED();

  return -1;
}

static void *
g_NPN_MemAlloc (uint32 size)
{
  D(bug("NPN_MemAlloc size %u\n", size));

  return g_malloc (size);
}

static uint32
g_NPN_MemFlush (uint32 size)
{
  D(bug("NPN_MemFlush size %u\n", size));

  return 0;
}

static void
g_NPN_MemFree (void *ptr)
{
  D(bug("NPN_MemFree ptr %p\n", ptr));

  g_free (ptr);
}

static void
g_NPN_InvalidateRect (NPP instance, NPRect *invalidRect)
{
  D(bug("NPN_InvalidateRect instance %p\n", instance));

  UNIMPLEMENTED();
}

static void
g_NPN_InvalidateRegion (NPP instance, NPRegion invalidRegion)
{
  D(bug("NPN_InvalidateRegion instance %p\n", instance));

  UNIMPLEMENTED();
}

static void
g_NPN_ReloadPlugins(NPBool reloadPages)
{
  D(bug("NPN_ReloadPlugins reloadPages %d\n", reloadPages));

  UNIMPLEMENTED();
}

static void
g_NPN_ForceRedraw(NPP instance)
{
  D(bug("NPN_ForceRedraw instance %p\n", instance));

  UNIMPLEMENTED();
}

static JRIEnv *
g_NPN_GetJavaEnv(void)
{
  D(bug("NPN_GetJavaEnv\n"));

  return NULL;
}

static jref
g_NPN_GetJavaPeer (NPP instance)
{
  D(bug("NPN_GetJavaPeer instance %p\n", instance));

  return NULL;
}

static void
g_NPN_PushPopupsEnabledState (NPP instance, NPBool enabled)
{
  if (instance == NULL)
    return;

  D(bug("NPN_PushPopupsEnabledState instance %p, enabled %d\n", instance, enabled));

  UNIMPLEMENTED();
}

static void
g_NPN_PopPopupsEnabledState (NPP instance)
{
  if (instance == NULL)
    return;

  D(bug("NPN_PopPopupsEnabledState instance %p\n", instance));

  UNIMPLEMENTED();
}

static NPError
g_NP_Initialize (Plugin *plugin)
{
  g_return_val_if_fail (plugin != NULL, NPERR_INVALID_FUNCTABLE_ERROR);

  memset (&plugin->plugin_funcs, 0, sizeof (plugin->plugin_funcs));
  plugin->plugin_funcs.size = sizeof (plugin->plugin_funcs);

  memset (&plugin->mozilla_funcs, 0, sizeof (plugin->mozilla_funcs));
  plugin->mozilla_funcs.size = sizeof (plugin->mozilla_funcs);
  plugin->mozilla_funcs.version = NP_VERSION_MINOR; /* XXX: make it the "compatible" way */
  plugin->mozilla_funcs.geturl = NewNPN_GetURLProc (g_NPN_GetURL);
  plugin->mozilla_funcs.posturl = NewNPN_PostURLProc (g_NPN_PostURL);
  plugin->mozilla_funcs.requestread = NewNPN_RequestReadProc (g_NPN_RequestRead);
  plugin->mozilla_funcs.newstream = NewNPN_NewStreamProc (g_NPN_NewStream);
  plugin->mozilla_funcs.write = NewNPN_WriteProc (g_NPN_Write);
  plugin->mozilla_funcs.destroystream = NewNPN_DestroyStreamProc (g_NPN_DestroyStream);
  plugin->mozilla_funcs.status = NewNPN_StatusProc (g_NPN_Status);
  plugin->mozilla_funcs.uagent = NewNPN_UserAgentProc (g_NPN_UserAgent);
  plugin->mozilla_funcs.memalloc = NewNPN_MemAllocProc (g_NPN_MemAlloc);
  plugin->mozilla_funcs.memfree = NewNPN_MemFreeProc (g_NPN_MemFree);
  plugin->mozilla_funcs.memflush = NewNPN_MemFlushProc (g_NPN_MemFlush);
  plugin->mozilla_funcs.reloadplugins = NewNPN_ReloadPluginsProc (g_NPN_ReloadPlugins);
  plugin->mozilla_funcs.getJavaEnv = NewNPN_GetJavaEnvProc (g_NPN_GetJavaEnv);
  plugin->mozilla_funcs.getJavaPeer = NewNPN_GetJavaPeerProc (g_NPN_GetJavaPeer);
  plugin->mozilla_funcs.geturlnotify = NewNPN_GetURLNotifyProc (g_NPN_GetURLNotify);
  plugin->mozilla_funcs.posturlnotify = NewNPN_PostURLNotifyProc (g_NPN_PostURLNotify);
  plugin->mozilla_funcs.getvalue = NewNPN_GetValueProc (g_NPN_GetValue);
  plugin->mozilla_funcs.setvalue = NewNPN_SetValueProc (g_NPN_SetValue);
  plugin->mozilla_funcs.invalidaterect = NewNPN_InvalidateRectProc (g_NPN_InvalidateRect);
  plugin->mozilla_funcs.invalidateregion = NewNPN_InvalidateRegionProc (g_NPN_InvalidateRegion);
  plugin->mozilla_funcs.forceredraw = NewNPN_ForceRedrawProc (g_NPN_ForceRedraw);
  plugin->mozilla_funcs.pushpopupsenabledstate = NewNPN_PushPopupsEnabledStateProc (g_NPN_PushPopupsEnabledState);
  plugin->mozilla_funcs.poppopupsenabledstate = NewNPN_PopPopupsEnabledStateProc (g_NPN_PopPopupsEnabledState);

  if ((plugin->mozilla_funcs.version & 0xff) >= NPVERS_HAS_NPRUNTIME_SCRIPTING)
    {
      D(bug(" browser supports scripting through npruntime\n"));
      plugin->mozilla_funcs.getstringidentifier = NewNPN_GetStringIdentifierProc (g_NPN_GetStringIdentifier);
      plugin->mozilla_funcs.getstringidentifiers = NewNPN_GetStringIdentifiersProc (g_NPN_GetStringIdentifiers);
      plugin->mozilla_funcs.getintidentifier = NewNPN_GetIntIdentifierProc (g_NPN_GetIntIdentifier);
      plugin->mozilla_funcs.identifierisstring = NewNPN_IdentifierIsStringProc (g_NPN_IdentifierIsString);
      plugin->mozilla_funcs.utf8fromidentifier = NewNPN_UTF8FromIdentifierProc (g_NPN_UTF8FromIdentifier);
      plugin->mozilla_funcs.intfromidentifier = NewNPN_IntFromIdentifierProc (g_NPN_IntFromIdentifier);
      plugin->mozilla_funcs.createobject = NewNPN_CreateObjectProc (g_NPN_CreateObject);
      plugin->mozilla_funcs.retainobject = NewNPN_RetainObjectProc (g_NPN_RetainObject);
      plugin->mozilla_funcs.releaseobject = NewNPN_ReleaseObjectProc (g_NPN_ReleaseObject);
      plugin->mozilla_funcs.invoke = NewNPN_InvokeProc (g_NPN_Invoke);
      plugin->mozilla_funcs.invokeDefault = NewNPN_InvokeDefaultProc (g_NPN_InvokeDefault);
      plugin->mozilla_funcs.evaluate = NewNPN_EvaluateProc (g_NPN_Evaluate);
      plugin->mozilla_funcs.getproperty = NewNPN_GetPropertyProc (g_NPN_GetProperty);
      plugin->mozilla_funcs.setproperty = NewNPN_SetPropertyProc (g_NPN_SetProperty);
      plugin->mozilla_funcs.removeproperty = NewNPN_RemovePropertyProc (g_NPN_RemoveProperty);
      plugin->mozilla_funcs.hasproperty = NewNPN_HasPropertyProc (g_NPN_HasProperty);
      plugin->mozilla_funcs.hasmethod = NewNPN_HasMethodProc (g_NPN_HasMethod);
      plugin->mozilla_funcs.releasevariantvalue = NewNPN_ReleaseVariantValueProc (g_NPN_ReleaseVariantValue);
      plugin->mozilla_funcs.setexception = NewNPN_SetExceptionProc (g_NPN_SetException);
    }

  return plugin->NP_Initialize (&plugin->mozilla_funcs, &plugin->plugin_funcs);
}

static void
g_NP_Shutdown (Plugin *plugin)
{
  if (plugin && plugin->NP_Shutdown)
    plugin->NP_Shutdown ();
}

/* ====================================================================== */
/* === Plug-in side API                                               === */
/* ====================================================================== */

typedef struct _GetAttribsArg GetAttribsArg;

struct _GetAttribsArg
{
  GPtrArray *names;
  GPtrArray *values;
};

static void
get_attribs_cb (gpointer key, gpointer value, gpointer user_data)
{
  GetAttribsArg *arg = (GetAttribsArg *)user_data;
  g_ptr_array_add (arg->names,  g_strdup (key));
  g_ptr_array_add (arg->values, g_strdup (value));
}

static NPError
g_NPP_New (Plugin *plugin, guint16 mode, GHashTable *attrs, guint w, guint h)
{
  if (plugin == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  if (attrs == NULL)
    return NPERR_INVALID_PARAM;

  if ((plugin->instance = g_new0 (NPP_t, 1)) == NULL)
    return NPERR_OUT_OF_MEMORY_ERROR;
  plugin->instance->ndata = plugin;

  GetAttribsArg arg;
  gint n_args = g_hash_table_size (attrs);
  arg.names  = g_ptr_array_sized_new (n_args);
  arg.values = g_ptr_array_sized_new (n_args);
  g_hash_table_foreach (attrs, get_attribs_cb, &arg);

  GString *str = g_string_new (NULL);
  g_string_printf (str, "%d", w);
  g_ptr_array_add (arg.names,  g_strdup ("width"));
  g_ptr_array_add (arg.values, g_strdup (str->str));
  ++n_args;
  g_string_printf (str, "%d", h);
  g_ptr_array_add (arg.names,  g_strdup ("height"));
  g_ptr_array_add (arg.values, g_strdup (str->str));
  ++n_args;
  g_string_free (str, TRUE);

  g_return_val_if_fail (arg.names->len  == n_args, NPERR_GENERIC_ERROR);
  g_return_val_if_fail (arg.values->len == n_args, NPERR_GENERIC_ERROR);

  NPError ret = CallNPP_NewProc (plugin->plugin_funcs.newp,
				 plugin->mime_type,
				 plugin->instance,
				 mode,
				 n_args,
				 (gchar **)arg.names->pdata,
				 (gchar **)arg.values->pdata,
				 NULL);

  g_ptr_array_foreach (arg.names, (GFunc)g_free, NULL);
  g_ptr_array_free (arg.names, TRUE);
  g_ptr_array_foreach (arg.values, (GFunc)g_free, NULL);
  g_ptr_array_free (arg.values, TRUE);

  // check if XEMBED is to be used
  PRBool supports_XEmbed = PR_FALSE;
  if (plugin->mozilla_funcs.getvalue)
    {
      NPError error = plugin->mozilla_funcs.getvalue (NULL, NPNVSupportsXEmbedBool, (void *)&supports_XEmbed);
      if (error == NPERR_NO_ERROR && plugin->plugin_funcs.getvalue)
	{
	  PRBool needs_XEmbed = PR_FALSE;
	  error = plugin->plugin_funcs.getvalue (plugin->instance, NPPVpluginNeedsXEmbed, (void *)&needs_XEmbed);
	  if (error == NPERR_NO_ERROR)
	    plugin->use_xembed = supports_XEmbed && needs_XEmbed;
	}
    }
  return ret;
}

static NPError
g_NPP_Destroy (Plugin *plugin)
{
  if (plugin == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  if (plugin->plugin_funcs.destroy == NULL)
    return NPERR_INVALID_FUNCTABLE_ERROR;

  NPSavedData save_data;
  NPSavedData *psave_data = &save_data;
  NPError ret = CallNPP_DestroyProc (plugin->plugin_funcs.destroy,
				     plugin->instance,
				     &psave_data);

  if (plugin->instance)
    {
      g_free (plugin->instance);
      plugin->instance = NULL;
    }
  return ret;
}

static NPError
g_NPP_SetWindow (Plugin *plugin, GtkWidget *parent, gpointer display)
{
  if (plugin == NULL || plugin->instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  guint width  = DISPLAY_WIDTH  (display);
  guint height = DISPLAY_HEIGHT (display);

  if (plugin->window == NULL)
    {
      /* Create the window for the first time */
      Window xid = 0;
      NPSetWindowCallbackStruct *ws_info = NULL;

      if (TRUE)
	{
	  if (plugin->use_xembed)
	    {
	      if ((plugin->window = gtk_socket_new ()) != NULL)
		gtk_container_add (GTK_CONTAINER (parent), plugin->window);
	    }
	  else
	    plugin->window = gtk_xtbin_new (parent->window, NULL);

	  if (plugin->window == NULL)
	    return NPERR_GENERIC_ERROR;
	  gtk_widget_set_size_request (plugin->window, width, height);
	  gtk_widget_show (plugin->window);

	  if ((ws_info = g_new0 (NPSetWindowCallbackStruct, 1)) == NULL)
	    return NPERR_OUT_OF_MEMORY_ERROR;
	  ws_info->type = 0; // should be NP_SETWINDOW but Mozilla sets it to 0

	  if (plugin->use_xembed)
	    {
	      GdkWindow * const win = plugin->window->window;
	      ws_info->display  = GDK_WINDOW_XDISPLAY (win);
	      ws_info->visual   = GDK_VISUAL_XVISUAL (gdk_drawable_get_visual(win));
	      ws_info->colormap = GDK_COLORMAP_XCOLORMAP (gdk_drawable_get_colormap (win));
	      ws_info->depth    = gdk_drawable_get_visual (win)->depth;
	      xid               = GDK_WINDOW_XWINDOW (win);
	    }
	  else
	    {
	      ws_info->display  = GTK_XTBIN (plugin->window)->xtdisplay;
	      ws_info->visual   = GTK_XTBIN (plugin->window)->xtclient.xtvisual;
	      ws_info->colormap = GTK_XTBIN (plugin->window)->xtclient.xtcolormap;
	      ws_info->depth    = GTK_XTBIN (plugin->window)->xtclient.xtdepth;
	      xid               = GTK_XTBIN (plugin->window)->xtwindow;
	    }
	}

      memset (&plugin->np_window, 0, sizeof (plugin->np_window));
      plugin->np_window.type    = NPWindowTypeWindow;
      plugin->np_window.window  = GUINT_TO_POINTER (xid);
      plugin->np_window.x       = 0;
      plugin->np_window.y       = 0;
      plugin->np_window.width   = width;
      plugin->np_window.height  = height;
      plugin->np_window.ws_info = ws_info;
    }
  else
    {
      /* Update window size */
      plugin->np_window.width   = width;
      plugin->np_window.height  = height;
      gtk_widget_set_size_request (plugin->window, width, height);
      // XXX: flash9 has some problems when resized too rapidly

      if (GTK_IS_XTBIN (plugin->window))
	{
	  // XXX: yes, two of these... for acrobat5!
	  // or an extra gtk_widget_size_allocate()
	  gtk_xtbin_resize (plugin->window, width, height);
	  gtk_xtbin_resize (plugin->window, width, height);
	}
    }

  return CallNPP_SetWindowProc (plugin->plugin_funcs.setwindow,
				plugin->instance,
				&plugin->np_window);
}

static NPError
g_NPP_NewStream (StreamInstance *pstream)
{
  if (pstream == NULL)
    return NPERR_INVALID_PARAM;

  Plugin *plugin = pstream->plugin;
  if (plugin == NULL || plugin->instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  return CallNPP_NewStreamProc (plugin->plugin_funcs.newstream,
				plugin->instance,
				pstream->mime_type,
				pstream->np_stream,
				pstream->seekable,
				&pstream->stype);
}

static NPError
g_NPP_DestroyStream (StreamInstance *pstream)
{
  if (pstream == NULL)
    return NPERR_INVALID_PARAM;

  Plugin *plugin = pstream->plugin;
  if (plugin == NULL || plugin->instance == NULL)
    return NPERR_INVALID_INSTANCE_ERROR;

  NPReason reason = NPRES_DONE;
  if (pstream->status & STREAM_STATUS_ERROR)
    reason = NPRES_NETWORK_ERR;

  return CallNPP_DestroyStreamProc (plugin->plugin_funcs.destroystream,
				    plugin->instance,
				    pstream->np_stream,
				    reason);
}

static int32
g_NPP_WriteReady (StreamInstance *pstream)
{
  if (pstream == NULL)
    return -1;

  Plugin *plugin = pstream->plugin;
  if (plugin == NULL || plugin->instance == NULL)
    return -1;

  return CallNPP_WriteReadyProc (plugin->plugin_funcs.writeready,
				 plugin->instance,
				 pstream->np_stream);
}

static int32
g_NPP_Write (StreamInstance *pstream, StreamBuffer *buffer, guint32 len)
{
  if (pstream == NULL)
    return -1;

  if (buffer == NULL)
    return -1;

  Plugin *plugin = pstream->plugin;
  if (plugin == NULL || plugin->instance == NULL)
    return -1;

  return CallNPP_WriteProc (plugin->plugin_funcs.write,
			    plugin->instance,
			    pstream->np_stream,
			    pstream->offset,
			    len,
			    buffer->bytes + buffer->offset);
}

static void
g_NPP_StreamAsFile (StreamInstance *pstream, const gchar *filename)
{
  if (pstream == NULL)
    return;

  Plugin *plugin = pstream->plugin;
  if (plugin == NULL || plugin->instance == NULL)
    return;

  if (g_ascii_strncasecmp (filename, "file://", 7) == 0)
    filename += 7;

  CallNPP_StreamAsFileProc (plugin->plugin_funcs.asfile,
			    plugin->instance,
			    pstream->np_stream,
			    filename);
}

static void
g_NPP_URLNotify (StreamInstance *pstream)
{
  if (pstream == NULL)
    return;

  Plugin *plugin = pstream->plugin;
  if (plugin == NULL || plugin->instance == NULL)
    return;

  NPReason reason = NPRES_DONE;
  if (pstream->status & STREAM_STATUS_ERROR)
    reason = NPRES_NETWORK_ERR;

  CallNPP_URLNotifyProc (plugin->plugin_funcs.urlnotify,
			 plugin->instance,
			 pstream->np_stream->url,
			 reason,
			 pstream->np_stream->notifyData);
}

/* ====================================================================== */
/* === Stream support functions                                       === */
/* ====================================================================== */

static size_t
on_stream_read_nothing_cb (void *ptr, size_t size, size_t nmemb, void *user_data)
{
  // don't download anything
  return 0;
}

static NPStream *
np_stream_new (const gchar *url, void *notify_data)
{
  /* retrieve (remote) file information */
  /* XXX: should be incrementally updated in wrapper+viewer through NPP_*() */
  CURL *handle = curl_easy_init ();
  if (handle == NULL)
    return NULL;

  curl_easy_setopt (handle, CURLOPT_URL, url);
  curl_easy_setopt (handle, CURLOPT_WRITEFUNCTION, on_stream_read_nothing_cb);
  curl_easy_setopt (handle, CURLOPT_FILETIME, 1);
  curl_easy_setopt (handle, CURLOPT_TIMECONDITION, CURL_TIMECOND_LASTMOD);
  if (uri_type_from_url (url) == URI_TYPE_HTTP)
    curl_easy_setopt (handle, CURLOPT_FOLLOWLOCATION, 1);

  curl_easy_perform (handle);

  double size;
  if (curl_easy_getinfo (handle, CURLINFO_CONTENT_LENGTH_DOWNLOAD, &size) != CURLE_OK)
    size = 0;

  long lastmod;
  if (curl_easy_getinfo (handle, CURLINFO_FILETIME, &lastmod) != CURLE_OK ||
      lastmod == -1)
    lastmod = 0;

  curl_easy_cleanup (handle);

  NPStream *np_stream = g_new0 (NPStream, 1);
  if (np_stream == NULL)
    return NULL;
  np_stream->url          = g_strdup (url);
  np_stream->end          = size;
  np_stream->lastmodified = lastmod;
  np_stream->notifyData   = notify_data;
  return np_stream;
}

static void
np_stream_destroy (NPStream *np_stream)
{
  if (np_stream == NULL)
    return;

  if (np_stream->url)
    {
      g_free ((gpointer)np_stream->url);
      np_stream->url = NULL;
    }

  g_free (np_stream);
}

static StreamInstance *
stream_new (Plugin *plugin,
	    const gchar *src, const gchar *type, void *notify_data,
	    NPError *error)
{
  StreamInstance *pstream   = NULL;
  NPStream       *np_stream = NULL;
  NPError         ret       = NPERR_NO_ERROR;

  if ((pstream = g_new0 (StreamInstance, 1)) == NULL)
    {
      ret = NPERR_OUT_OF_MEMORY_ERROR;
      goto l_error;
    }

  if ((np_stream = np_stream_new (src, notify_data)) == NULL)
    {
      ret = NPERR_OUT_OF_MEMORY_ERROR;
      goto l_error;
    }

  np_stream->ndata      = pstream;
  pstream->plugin       = plugin;
  pstream->np_stream    = np_stream;
  pstream->mime_type    = g_strdup (type);
  pstream->stype        = NP_NORMAL;
  pstream->status       = STREAM_STATUS_IDLE;
  pstream->notify_data  = notify_data;
  pstream->uri_type     = uri_type_from_url (src);
  pstream->seekable     = 0 && (pstream->uri_type == URI_TYPE_FILE);

  if (notify_data == NULL)
    {
      if ((ret = g_NPP_NewStream (pstream)) != NPERR_NO_ERROR)
	goto l_error;
      pstream->status |= STREAM_STATUS_ACTIVE;
    }
  g_idle_add (on_stream_open_cb, pstream);
  goto l_return;

 l_error:
  if (np_stream)
    np_stream_destroy (np_stream);
  if (pstream)
    g_free (pstream);
  pstream = NULL;

 l_return:
  if (error)
    *error = ret;
  return pstream;
}

static void
stream_destroy (StreamInstance *pstream)
{
  if (pstream == NULL)
    return;

  if (pstream->curl_handle)
    {
      glibcurl_remove (pstream->curl_handle);
      curl_easy_cleanup (pstream->curl_handle);
      pstream->curl_handle = NULL;
    }

  if (pstream->buffers)
    {
      g_list_foreach (pstream->buffers, (GFunc)stream_buffer_destroy, NULL);
      g_list_free (pstream->buffers);
      pstream->buffers = NULL;
    }

  if (pstream->temp_file)
    {
      /* Close the file prior to calling NPP_StreamAsFile() [Acrobat5] */
      fclose (pstream->temp_file);
      pstream->temp_file = NULL;
    }

  if (pstream->status & STREAM_STATUS_DESTROY)
    {
      if (pstream->stype == NP_ASFILE || pstream->stype == NP_ASFILEONLY)
	{
	  /* temporary files are used only for remote files */
	  const gchar *fname = pstream->temp_filename;
	  if (fname == NULL)
	    fname = pstream->np_stream->url;
	  g_NPP_StreamAsFile (pstream, fname);
	}

      g_NPP_DestroyStream (pstream);

      if (pstream->notify_data)
	g_NPP_URLNotify (pstream);
    }

  if (pstream->temp_filename)
    {
      unlink (pstream->temp_filename);
      g_free (pstream->temp_filename);
      pstream->temp_filename = NULL;
    }

  if (pstream->mime_type)
    {
      g_free (pstream->mime_type);
      pstream->mime_type = NULL;
    }

  if (pstream->np_stream)
    {
      np_stream_destroy (pstream->np_stream);
      pstream->np_stream = NULL;
    }

  g_free (pstream);
}

static void
stream_commit (StreamInstance *pstream)
{
  if (pstream == NULL)
    return;

  if (pstream->commit_source == 0)
    pstream->commit_source = g_idle_add (on_stream_commit_cb, pstream);
}

static void
stream_schedule_destroy (StreamInstance *pstream, gboolean now)
{
  if (pstream == NULL)
    return;

  if (now)
    pstream->status |= STREAM_STATUS_DESTROY;
  else
    pstream->status |= STREAM_STATUS_FINISH;
  stream_commit (pstream);
}

static inline gboolean
stream_use_npp_write (StreamInstance *pstream)
{
  /* If the stream comes from a local file in NP_ASFILEONLY mode,
   * the NPP_Write() and NPP_WriteReady() functions are not called.
   */
  if (pstream->stype == NP_ASFILEONLY && pstream->uri_type == URI_TYPE_FILE)
    return FALSE;
  return TRUE;
}

static int32
stream_write_ready (StreamInstance *pstream)
{
  int32 write_ready = 0x0fffff;
  if (stream_use_npp_write (pstream))
    write_ready = g_NPP_WriteReady (pstream);
  return write_ready;
}

static int32
stream_write (StreamInstance *pstream, StreamBuffer *buffer, guint32 len)
{
  switch (pstream->stype)
    {
    case NP_ASFILE:
    case NP_ASFILEONLY:
      if (pstream->temp_file)
	{
	  if (fwrite (buffer->bytes + buffer->offset, len, 1, pstream->temp_file) != 1)
	    return -1;
	}
      break;
    }
  if (!stream_use_npp_write (pstream))
    return len;
  return g_NPP_Write (pstream, buffer, len);
}

static StreamBuffer *
stream_buffer_new (guchar *bytes, gsize nbytes)
{
  StreamBuffer *buffer = g_new0 (StreamBuffer, 1);

  if (buffer)
    {
      buffer->bytes  = g_memdup (bytes, nbytes);
      buffer->size   = nbytes;
      buffer->offset = 0;
    }

  return buffer;
}

static void
stream_buffer_destroy (StreamBuffer *buffer)
{
  if (buffer == NULL)
    return;

  if (buffer->bytes)
    {
      g_free (buffer->bytes);
      buffer->bytes = NULL;
    }

  g_free (buffer);
}

static gboolean
on_stream_commit_cb (gpointer user_data)
{
  StreamInstance *pstream = (StreamInstance *)user_data;

  if (pstream->buffers)
    {
      StreamBuffer *buffer = pstream->buffers->data;

      if (!(pstream->status & STREAM_STATUS_ACTIVE))
	{
	  /* XXX: determine MIME type (should be done in NPN_GetURL*()...) */
	  if (pstream->mime_type == NULL)
	    pstream->mime_type = get_mime_type_from_content (buffer->bytes,
							     buffer->size);
	  if (pstream->mime_type == NULL)
	    pstream->mime_type = g_strdup (pstream->plugin->mime_type);

	  if (g_NPP_NewStream (pstream) != NPERR_NO_ERROR)
	    goto force_destroy;
	  pstream->status |= STREAM_STATUS_ACTIVE;
	}

      int32 write_ready = stream_write_ready (pstream);

      if (write_ready < 0)
	{
	  /* The plug-in doesn't want the stream, kill all pending buffers */
	  pstream->status |= STREAM_STATUS_DESTROY;
	}
      else if (write_ready > 0)
	{
	  int32 len = MIN (buffer->size - buffer->offset, write_ready);

	  len = stream_write (pstream, buffer, len);

	  if (len < 0)
	    pstream->status |= STREAM_STATUS_ERROR | STREAM_STATUS_DESTROY;
	  else if (len > 0)
	    {
	      if ((buffer->offset += len) >= buffer->size)
		{
		  stream_buffer_destroy (buffer);
		  pstream->offset += len;
		  pstream->buffers = g_list_delete_link (pstream->buffers,
							 pstream->buffers);
		}
	    }
	}
    }

  if (pstream->buffers == NULL && (pstream->status & STREAM_STATUS_FINISH))
    pstream->status |= STREAM_STATUS_DESTROY;

  if (pstream->buffers == NULL || (pstream->status & STREAM_STATUS_DESTROY))
    {
    force_destroy:
      g_source_remove (pstream->commit_source);
      pstream->commit_source = 0;
      if (pstream->status & STREAM_STATUS_DESTROY)
	stream_destroy (pstream);
      return FALSE;
    }

  return TRUE;
}

static size_t
on_stream_read_cb (void *ptr, size_t size, size_t nmemb, void *user_data)
{
  StreamInstance *pstream = (StreamInstance *)user_data;
  size_t real_size = size * nmemb;

  StreamBuffer *buffer = stream_buffer_new (ptr, real_size);
  if (buffer == NULL)
    return 0;
  pstream->buffers = g_list_append (pstream->buffers, buffer);
  stream_commit (pstream);
  return real_size;
}

static gboolean
on_stream_open_cb (gpointer user_data)
{
  StreamInstance *pstream = (StreamInstance *)user_data;

  switch (pstream->stype)
    {
    case NP_NORMAL:
      break;
    case NP_ASFILE:
    case NP_ASFILEONLY:
      /* Technically speaking, the Firefox specs say that the file is
       * downloaded to the cache even for local files. However, it
       * turns out the file name passed to NPP_StreamAsFile() is not
       * the path to the cached file but actually that of the original
       * file, if it is a local file.
       *
       * So, we only use temporary files for remote files. The
       * standalone player doesn't handle a persistent cache.
       *
       * This also means that if you remove the original file while
       * viewing it, then you can get unexpected behaviour since the
       * plugin won't be using the cached file.
       *
       * And, in order to be even clearer, the Acrobat Reader plugin expects
       * stream->url == fname passed to NPP_StreamAsFile().
       */
      if (pstream->uri_type != URI_TYPE_FILE)
	{
	  /* XXX: handle errors! */
	  /* XXX: better use tmpfile() but how to get the filename in a portable way? */
	  pstream->temp_filename = g_malloc (L_tmpnam + 1);
	  tmpnam (pstream->temp_filename);
	  pstream->temp_file = fopen (pstream->temp_filename, "w");
	}
      break;
    default:
      UNIMPLEMENTED();
      return FALSE;
    }

  if ((pstream->curl_handle = curl_easy_init ()) == NULL)
    npw_printf ("WARNING: could not create CURL stream\n");

  CURL * const handle = pstream->curl_handle;
  curl_easy_setopt (handle, CURLOPT_URL, pstream->np_stream->url);
  curl_easy_setopt (handle, CURLOPT_WRITEFUNCTION, on_stream_read_cb);
  curl_easy_setopt (handle, CURLOPT_WRITEDATA, pstream);
  curl_easy_setopt (handle, CURLOPT_PRIVATE, pstream);
  if (pstream->uri_type == URI_TYPE_HTTP)
    curl_easy_setopt (handle, CURLOPT_FOLLOWLOCATION, 1);
  glibcurl_add (handle);
  return FALSE;
}

static void
on_stream_close_cb (gpointer user_data)
{
  CURLMsg *msg;
  int in_queue;

  while ((msg = curl_multi_info_read (glibcurl_handle (), &in_queue)) != NULL)
    {
      if (msg->msg != CURLMSG_DONE)
	continue;

      StreamInstance *pstream;
      
      CURL *handle = msg->easy_handle;
      if (curl_easy_getinfo (handle, CURLINFO_PRIVATE, &pstream) == CURLE_OK)
	{
	  if (!(pstream->status & STREAM_STATUS_ACTIVE))
	    {
	      /* Special case for JavaScript that CURL could not handle */
	      const gchar * const url = pstream->np_stream->url;
	      if (g_ascii_strncasecmp (url, "javascript:", 11) == 0)
		{
		  if (pstream->mime_type)
		    g_free (pstream->mime_type);
		  pstream->mime_type = g_strdup ("text/html");

		  /* XXX: this is just a hack to get top.location */
		  GString *text = NULL;
		  const gchar *jscode = url + 11;
		  if (g_ascii_strncasecmp (jscode, "top.location", 12) == 0)
		    text = g_string_new (pstream->plugin->src);
		  if (text)
		    {
		      bool ok = TRUE;

		      /* XXX: only allow string concatenation */
		      jscode += 12;
		      while (*jscode != '\0')
			{
			  while (g_ascii_isspace (*jscode))
			    ++jscode;
			  if (*jscode == '\0')
			    break;
			  if (*jscode != '+')
			    { ok = FALSE; break; }
			  if (*++jscode == '\0')
			    { ok = FALSE; break; }
			  while (g_ascii_isspace (*jscode))
			    ++jscode;
			  if (*jscode != '"')
			    { ok = FALSE; break; }
			  if (*++jscode == '\0')
			    { ok = FALSE; break; }
			  const gchar *str = jscode;
			  while (*jscode != '"')
			    {
			      if (*jscode == '\0')
				{ ok = FALSE; break; }
			      ++jscode;
			    }
			  g_string_append_len (text, str, jscode - str);
			  ++jscode;
			}
		      if (ok)
			on_stream_read_cb (text->str, text->len, 1, pstream);
		      g_string_free (text, TRUE);
		    }
		}

	      /* XXX: consider the stream in error if it was never started */
	      if (pstream->buffers == NULL)
		pstream->status |= STREAM_STATUS_ERROR;
	    }

	  stream_schedule_destroy (pstream, FALSE);
	}
    }
}

/* ====================================================================== */
/* === Plugin database                                                === */
/* ====================================================================== */

static PluginDataType *
plugin_data_type_new (const gchar *mime, const gchar *ext, const gchar *desc)
{
  PluginDataType *data_type = g_new0 (PluginDataType, 1);
  if (data_type == NULL)
    return NULL;
  data_type->values[PLUGIN_DATA_TYPE_MIME]        = g_strdup (mime);
  data_type->values[PLUGIN_DATA_TYPE_EXTENSION]   = g_strdup (ext);
  data_type->values[PLUGIN_DATA_TYPE_DESCRIPTION] = g_strdup (desc);
  if (g_verbose)
    npw_printf ("%-8s  %-50s  %s\n", ext, mime, desc);
  return data_type;
}

static void
plugin_data_type_destroy (PluginDataType *data_type)
{
  if (data_type == NULL)
    return;

  for (gint i = 0; i < PLUGIN_DATA_TYPE_VALUE_COUNT; i++)
    {
      if (data_type->values[i])
	{
	  g_free (data_type->values[i]);
	  data_type->values[i] = NULL;
	}
    }

  g_free (data_type);
}

static GList *
plugin_get_data_types (Plugin *plugin)
{
  g_return_val_if_fail (plugin != NULL, NULL);

  if (plugin->data_types)
    return plugin->data_types;

  gchar *mime_desc = plugin->NP_GetMIMEDescription ();
  if (mime_desc == NULL)
    return NULL;

  GList *data_types = NULL;
  gchar **mime_descs = g_strsplit (mime_desc, ";", -1);
  for (gint i = 0; mime_descs[i] != NULL; i++)
    {
      gchar **mime_parts = g_strsplit (mime_descs[i], ":", -1);
      if (mime_parts && mime_parts[0] && mime_parts[1] && mime_parts[2])
	{
	  gchar **extensions = g_strsplit (mime_parts[1], ",", -1);
	  for (gint j = 0; extensions[j] != NULL; j++)
	    {
	      PluginDataType *data_type = plugin_data_type_new (mime_parts[0],
								extensions[j],
								mime_parts[2]);
	      if (data_type)
		data_types = g_list_prepend (data_types, data_type);
	    }
	  g_strfreev (extensions);
	}
      g_strfreev (mime_parts);
    }
  g_strfreev (mime_descs);
  if (data_types == NULL)
    return NULL;
  plugin->data_types = g_list_reverse (data_types);
  return plugin->data_types;
}

static Plugin *
plugin_new (const gchar *path)
{
  Plugin *plugin = g_new0 (Plugin, 1);
  if (plugin == NULL)
    return NULL;
  plugin->path = g_strdup (path);

  if ((plugin->module = g_module_open (path, G_MODULE_BIND_LOCAL)) == NULL)
    goto error;

  gpointer symbol;
  if (!g_module_symbol (plugin->module, "NP_Initialize", &symbol))
    goto error;
  plugin->NP_Initialize = (NP_InitializeUPP)symbol;
  if (!g_module_symbol (plugin->module, "NP_Shutdown", &symbol))
    goto error;
  plugin->NP_Shutdown = (NP_ShutdownUPP)symbol;
  if (!g_module_symbol (plugin->module, "NP_GetMIMEDescription", &symbol))
    goto error;
  plugin->NP_GetMIMEDescription = (NP_GetMIMEDescriptionUPP)symbol;
  if (g_module_symbol (plugin->module, "NP_GetValue", &symbol))
    plugin->NP_GetValue = (NP_GetValueUPP)symbol;
  if (g_module_symbol (plugin->module, "npw_master_connection", &symbol))
    plugin->get_master_connection = (rpc_connection_t *(*)(void))symbol;
  goto do_return;

 error:
  if (plugin)
    {
      g_free (plugin);
      plugin = NULL;
    }

do_return:
  return plugin;
}

static void
plugin_destroy (Plugin *plugin)
{
  if (plugin == NULL)
    return;

  if (plugin->module)
    {
      g_module_close (plugin->module);
      plugin->module = NULL;
    }

  if (plugin->path)
    {
      g_free (plugin->path);
      plugin->path = NULL;
    }

  if (plugin->src)
    {
      g_free (plugin->src);
      plugin->src = NULL;
    }

  if (plugin->mime_type)
    {
      g_free (plugin->mime_type);
      plugin->mime_type = NULL;
    }

  if (plugin->data_types)
    {
      g_list_foreach (plugin->data_types, (GFunc)plugin_data_type_destroy, NULL);
      g_list_free (plugin->data_types);
      plugin->data_types = NULL;
    }

  if (plugin->np_window.ws_info)
    {
      g_free (plugin->np_window.ws_info);
      plugin->np_window.ws_info = NULL;
    }

  g_free (plugin);
}

static void
plugin_destroy_if_not (Plugin *plugin, Plugin *plugin_to_keep)
{
  if (plugin != plugin_to_keep)
    plugin_destroy (plugin);
}

static void
plugin_start (Plugin *plugin, PlayerApp *app)
{
  NPError ret;

  D(bug("Execute plugin '%s'\n", plugin->path));

  ret = g_NP_Initialize (plugin);
  if (ret != NPERR_NO_ERROR)
    {
      npw_printf ("ERROR: could not execute: %s\n", string_of_NPError (ret));
      player_app_main_quit ();
      return;
    }

  plugin->src = g_hash_table_lookup (app->attrs, "src");

  /* XXX: determine plugin MIME type supported, move elsewhere? */
  if (plugin->mime_type == NULL)
    {
      const gchar *mime_type;
      if ((mime_type = g_hash_table_lookup (app->attrs, "type")) != NULL)
	plugin->mime_type = g_strdup (mime_type);
    }
  if (plugin->mime_type == NULL)
    {
      npw_printf ("ERROR: no MIME type specified for this plugin\n");
      player_app_main_quit ();
      return;
    }

  guint width  = DISPLAY_WIDTH  (app->display);
  guint height = DISPLAY_HEIGHT (app->display);

  ret = g_NPP_New (plugin, app->mode, app->attrs, width, height);
  if (ret != NPERR_NO_ERROR)
    {
      npw_printf ("ERROR: could not create NPP instance\n");
      player_app_main_quit ();
      return;
    }

  ret = g_NPP_SetWindow (plugin, app->window, app->display);
  if (ret != NPERR_NO_ERROR)
    {
      npw_printf ("ERROR: could not create NPP window\n");
      player_app_main_quit ();
      return;
    }

  if (plugin->src)
    {
      NPError error;
      StreamInstance *pstream;
      pstream = stream_new (plugin, plugin->src, plugin->mime_type, NULL, &error);
      if (pstream == NULL || error != NPERR_NO_ERROR)
	{
	  if (pstream)
	    stream_destroy (pstream);
	  npw_printf ("ERROR: could not create NPP stream from '%s'\n", plugin->src);
	  player_app_main_quit ();
	  return;
	}
    }
}

static void
plugin_stop (Plugin *plugin)
{
  if (plugin == NULL)
    return;

  if (plugin->plugin_funcs.setwindow)
    {
      if (plugin->np_window.ws_info)
	{
	  g_free (plugin->np_window.ws_info);
	  plugin->np_window.ws_info = NULL;
	}

      /* A NULL handle means the plugin must not do any graphics operation further */
      plugin->np_window.window = NULL;

      CallNPP_SetWindowProc (plugin->plugin_funcs.setwindow,
			     plugin->instance,
			     &plugin->np_window);
    }

  g_NPP_Destroy (plugin);
  g_NP_Shutdown (plugin);
}

static GList *
g_list_prepend_if_path_exists (GList *dirs, const gchar *path)
{
  if (g_file_test (path, G_FILE_TEST_IS_DIR))
    dirs = g_list_prepend (dirs, g_strdup (path));
  return dirs;
}

static GList *
get_plugin_dirs (void)
{
  GList *dirs = NULL;
  gchar *path;

  path = g_build_filename (g_get_home_dir (), ".mozilla", "plugins", NULL);
  dirs = g_list_prepend_if_path_exists (dirs, path);
  g_free (path);

  const gchar *moz_plugin_path = g_getenv ("MOZ_PLUGIN_PATH");
  if (moz_plugin_path)
    {
      gchar **moz_plugin_paths = g_strsplit (moz_plugin_path, ":", -1);
      for (gint i = 0; moz_plugin_paths[i] != NULL; i++)
	dirs = g_list_prepend_if_path_exists (dirs, moz_plugin_paths[i]);
      g_strfreev (moz_plugin_paths);
    }

  path = g_build_filename
    (G_DIR_SEPARATOR_S "usr", "lib", "mozilla", "plugins", NULL);
  dirs = g_list_prepend_if_path_exists (dirs, path);
  g_free (path);

  path = g_build_filename
    (G_DIR_SEPARATOR_S "usr", "lib", "browser", "plugins", NULL);
  dirs = g_list_prepend_if_path_exists (dirs, path);
  g_free (path);

  return dirs;
}

static gboolean
is_npapi_plugin (const gchar *path)
{
  GModule *module = g_module_open (path, G_MODULE_BIND_LOCAL);
  if (module == NULL)
    {
      if (g_verbose)
	npw_printf ("WARNING: %s\n", g_module_error ());
      return FALSE;
    }

  gpointer symbol;
  gboolean is_valid = TRUE;
  if (!g_module_symbol (module, "NP_Initialize", &symbol))
    is_valid = FALSE;
  if (!g_module_symbol (module, "NP_Shutdown", &symbol))
    is_valid = FALSE;
  if (!g_module_symbol (module, "NP_GetMIMEDescription", &symbol))
    is_valid = FALSE;

  g_module_close (module);
  return is_valid;
}

static void
player_app_load_plugin (PlayerApp *app, const gchar *path)
{
  Plugin *plugin;

  if ((plugin = plugin_new (path)) == NULL)
    g_error ("could not initialize plugin '%s'", path);

  app->plugins = g_list_prepend (app->plugins, plugin);
}

static void
player_app_load_plugins (PlayerApp *app, const gchar *dirname)
{
  GDir        *dir;
  gchar       *old_dir = g_get_current_dir ();
  const gchar *name;
  gchar       *path;

  if ((dir = g_dir_open (dirname, 0, NULL)) == NULL)
    return;

  g_chdir (dirname);

  while ((name = g_dir_read_name (dir)) != NULL)
    {
      path = g_build_filename (dirname, name, NULL);
      if (is_npapi_plugin (path))
	player_app_load_plugin (app, path);
      g_free (path);
    }

  g_dir_close (dir);

  g_chdir (old_dir);
  g_free (old_dir);
}

typedef struct _FindPluginCustomArg FindPluginCustomArg;

struct _FindPluginCustomArg
{
  gint id;
  const gchar *value;
  gchar **pmime;
};

static gint
find_plugin_custom_cb (PluginDataType *data_type, FindPluginCustomArg *arg)
{
  int ret = strcmp (data_type->values[arg->id], arg->value);
  if (ret == 0 && arg->pmime)
    *arg->pmime = g_strdup (data_type->values[PLUGIN_DATA_TYPE_MIME]);
  return ret;
}

static Plugin *
find_plugin_custom (PlayerApp *app, gint id, const gchar *value, gchar **pmime)
{
  GList *l;
  for (l = app->plugins; l != NULL; l = l->next)
    {
      Plugin *plugin = (Plugin *)l->data;

      FindPluginCustomArg arg;
      arg.id    = id;
      arg.value = value;
      arg.pmime = pmime;
      if (g_list_find_custom (plugin_get_data_types (plugin),
			      &arg, (GCompareFunc)find_plugin_custom_cb))
	return plugin;
    }
  return NULL;
}

static inline Plugin *
find_plugin_by_mime (PlayerApp *app, const gchar *mime_type)
{
  return find_plugin_custom (app, PLUGIN_DATA_TYPE_MIME, mime_type, NULL);
}

static Plugin *
find_plugin_by_uri (PlayerApp *app, const gchar *uri, gchar **pmime)
{
  Plugin *plugin = NULL;

  gchar *extension = strrchr (uri, '.');
  if (extension)
    ++extension;

  plugin = find_plugin_custom (app, PLUGIN_DATA_TYPE_EXTENSION, extension, pmime);
  if (plugin)
    return plugin;

  /* XXX: load and lookup object MIME type */
  return NULL;
}

static void
player_app_destroy (PlayerApp *app)
{
  if (app == NULL)
    return;

  if (app->plugin)
    {
      plugin_destroy (app->plugin);
      app->plugin = NULL;
    }

  if (app->display)
    {
      g_free (app->display);
      app->display = NULL;
    }

  g_free (app);
}

static gboolean
player_app_run (PlayerApp *app)
{
  GList *plugin_dirs = get_plugin_dirs ();
  for (GList *l = plugin_dirs; l != NULL; l = l->next)
    {
      gchar *plugin_dir = (gchar *)l->data;
      player_app_load_plugins (app, plugin_dir);
      g_free (plugin_dir);
    }
  g_list_free (plugin_dirs);
  plugin_dirs = NULL;

  /* Lookup plugin by MIME type first, then try by object type (from URI) */
  gchar *value;
  if ((value = g_hash_table_lookup (app->attrs, "type")) != NULL)
    app->plugin = find_plugin_by_mime (app, value);
  else if ((value = g_hash_table_lookup (app->attrs, "src")) != NULL)
    {
      gchar *mime_type = NULL;
      if ((app->plugin = find_plugin_by_uri (app, value, &mime_type)) != NULL)
	{
	  if (!g_hash_table_lookup_extended (app->attrs, "type", NULL, NULL))
	    g_hash_table_insert (app->attrs, "type", mime_type);
	}
    }
  else
    app->plugin = NULL;

  if (app->plugin == NULL)
    g_error ("could not find any plugin to use");

  /* Free all other plugins */
  if (app->plugins)
    {
      g_list_foreach (app->plugins, (GFunc)plugin_destroy_if_not, app->plugin);
      g_list_free (app->plugins);
      app->plugins = NULL;
    }

  plugin_start (app->plugin, app);
  return FALSE;
}

static void
player_app_quit (PlayerApp *app)
{
  if (app == NULL)
    return;

  plugin_stop (app->plugin);
}


/* ====================================================================== */
/* === GUI glue                                                       === */
/* ====================================================================== */

static void
print_help (const gchar *program_name)
{
  g_print ("Usage: %s [option]* [--plugin] [name[=value]]*\n", program_name);
  g_print ("\n");

  g_print ("Options:\n");
  g_print ("  -v|--verbose            enable verbose mode\n");
  g_print ("  -f|--fullscreen         start in fullscreen mode\n");
  g_print ("\n");

  g_print ("Common attributes include:\n");
  g_print ("  embed                   use NP_EMBED mode\n");
  g_print ("  full                    use NP_FULL mode (default)\n");
  g_print ("  src=URI                 location (URL) of the object to load\n");
  g_print ("  type=MIME-TYPE          MIME type of the object\n");
  g_print ("  width=WIDTH             width (in pixels)\n");
  g_print ("  height=HEIGHT           height (in pixels)\n");
  g_print ("\n");

  g_print ("Other attributes will be passed down to the plugin (e.g. flashvars)\n");
  g_print ("\n");
}

static gboolean
on_configure_event_cb (GtkWidget         *widget,
		       GdkEventConfigure *event,
		       PlayerApp         *app)
{
  if (g_backend != BACKEND_GTK)
    return FALSE;

  if (event->width == app->width && event->height == app->height)
    return FALSE;

  // synchronize toplevel window size that actually changed
  app->width  = event->width;
  app->height = event->height;

  // notify plugin of the new dimensions
  GtkDisplay *display = GTK_DISPLAY (app->display);
  display->width  = event->width;
  display->height = event->height;
  g_NPP_SetWindow (app->plugin, app->window, display);
  return FALSE;
}

static gboolean
on_window_state_event_cb (GtkWidget           *widget,
			  GdkEventWindowState *event,
			  PlayerApp           *app)
{
  if (g_backend != BACKEND_GTK)
    return FALSE;

  if (event->changed_mask & GDK_WINDOW_STATE_FULLSCREEN)
    {
      /* Fullscreen mode requested */
      GtkDisplay *display = GTK_DISPLAY (app->display);
      gtk_window_get_size (GTK_WINDOW (widget), &display->width, &display->height);
    }
  return FALSE;
}

static gboolean
on_window_destroy_cb (GtkWidget *widget, gpointer user_data)
{
  if (--g_n_plugins == 0)
    gtk_main_quit ();
  return FALSE;
}

static GdkFilterReturn
on_client_message_cb (GdkXEvent *gdk_xevent, GdkEvent *event, gpointer user_data)
{
  XEvent    *xevent = (XEvent *)gdk_xevent;
  PlayerApp *app    = (PlayerApp *)user_data;

  if (app->plugin == NULL || app->plugin->use_xembed)
    return GDK_FILTER_CONTINUE;

  if (xevent->type != ClientMessage)
    return GDK_FILTER_CONTINUE;

  if (xevent->xclient.message_type != gdk_x11_get_xatom_by_name ("WM_PROTOCOLS"))
    return GDK_FILTER_CONTINUE;

#if 0
  /* XXX: avoid gtk2 from resetting the focus to its focus proxy? */
  if ((Atom)xevent->xclient.data.l[0] == gdk_x11_get_xatom_by_name ("WM_TAKE_FOCUS"))
    return GDK_FILTER_REMOVE;
#endif

  return GDK_FILTER_CONTINUE;
}

static void
set_focus_window (PlayerApp *app)
{
  if (app->plugin == NULL || app->plugin->use_xembed)
    return;

  Window focus_window;
  int focus_state;
  XGetInputFocus (GDK_WINDOW_XDISPLAY (app->window->window), &focus_window, &focus_state);

  /* Don't change anything if the focus moved to another window per plugin's request */
  /* XXX: in that case, is GDK supposed to know about it for sure (non-NULL GDK window)? */
  GdkWindow *gdk_focus_window = gdk_window_lookup (focus_window);
  if (gdk_focus_window && gdk_focus_window != app->window->window)
    return;

  /* XXX: XSetInputFocus() is calling for trouble but I don't know of
   * a better way and Firefox is actually doing this...
   */
  gdk_error_trap_push ();
  XSetInputFocus (GDK_WINDOW_XDISPLAY (app->window->window),
		  GDK_WINDOW_XWINDOW (app->window->window),
		  RevertToNone, CurrentTime);
  gdk_flush ();
  gdk_error_trap_pop ();

  /* Give us a chance to filter out WM_TAKE_FOCUS */
  gdk_window_add_filter (NULL, on_client_message_cb, app);
}

static void
unset_focus_window (PlayerApp *app)
{
  if (app->plugin == NULL || app->plugin->use_xembed)
    return;

  gdk_window_remove_filter (NULL, on_client_message_cb, app);
}

static GdkFilterReturn
on_window_filter_cb (GdkXEvent *gdk_xevent, GdkEvent *event, gpointer user_data)
{
  XEvent    *xevent = (XEvent *)gdk_xevent;
  PlayerApp *app    = (PlayerApp *)user_data;
  GtkWidget *widget;
  GdkWindow *plugin_window;

  GdkFilterReturn ret = GDK_FILTER_CONTINUE;

  switch (xevent->type)
    {
    case CreateNotify:
    case ReparentNotify:
      /* Make sure we have not messed up the plugin->use_xembed logic */
      if (xevent->type == CreateNotify)
	plugin_window = gdk_window_lookup (xevent->xcreatewindow.window);
      else
	{
	  if (xevent->xreparent.event != xevent->xreparent.parent)
	    break;
	  plugin_window = gdk_window_lookup (xevent->xreparent.window);
	}
      if (plugin_window)
	{
	  user_data = NULL;
	  gdk_window_get_user_data (plugin_window, &user_data);
	  widget = GTK_WIDGET (user_data);

	  if (GTK_IS_XTBIN (widget))
	    {
	      g_assert (app->plugin ? !app->plugin->use_xembed : TRUE);
	      /* Ensure focus is set to the newly created (toplevel)
	       * window if the pointer turns out to hang over it already
	       */
	      set_focus_window (app);
	      break;
	    }
	  else if (GTK_IS_SOCKET (widget))
	    {
	      g_assert (app->plugin ? app->plugin->use_xembed : TRUE);
	      break;
	    }
	}
      ret = GDK_FILTER_REMOVE;
      break;
    case EnterNotify:
      set_focus_window (app);
      break;
    case DestroyNotify:
      gdk_window_remove_filter (app->window->window, on_window_filter_cb, app);
      unset_focus_window (app);
      break;
    default:
      break;
    }
  return ret;
}

static gboolean
on_key_press_event_cb (GtkWidget *widget, GdkEventKey *event, gpointer user_data)
{
  if (event->type != GDK_KEY_PRESS)
    return FALSE;

  switch (event->keyval)
    {
    case GDK_Escape:
    case GDK_Q:
    case GDK_q:
      if ((event->state & GDK_CONTROL_MASK) != 0)
	return on_window_destroy_cb (widget, user_data);
      break;
    }
  return FALSE;
}

typedef struct _PluginDescriptor PluginDescriptor;

struct _PluginDescriptor
{
  guint width;
  guint height;
  guint16 mode;
  GHashTable *attrs;
  PlayerApp  *app;
};

static PluginDescriptor *
plugin_descriptor_new (void)
{
  PluginDescriptor *plugin_desc = g_new0 (PluginDescriptor, 1);
  if (plugin_desc == NULL)
    return NULL;
  plugin_desc->width  = DEFAULT_WIDTH;
  plugin_desc->height = DEFAULT_HEIGHT;
  plugin_desc->mode   = NP_FULL;
  plugin_desc->attrs  = g_hash_table_new (g_str_hash, g_str_equal);
  return plugin_desc;
}

int
main (int argc, char *argv[])
{
  GPtrArray        *plugin_descs = g_ptr_array_new ();
  PluginDescriptor *plugin_desc  = NULL;

  const gchar *title     = "nspluginplayer";
  gboolean is_fullscreen = FALSE;
  guint display_width    = DEFAULT_WIDTH;
  guint display_height   = DEFAULT_HEIGHT;
  gint i;

  g_thread_init (NULL);
  gdk_threads_init ();
  glibcurl_init ();
  glibcurl_set_callback (on_stream_close_cb, NULL);
  gtk_init (&argc, &argv);

  for (i = 1; i < argc; i++)
    {
      const gchar *arg = argv[i];
      if (strcmp (arg, "--help") == 0)
	{
	  print_help (argv[0]);
	  return 0;
	}
      else if (strcmp (arg, "--verbose") == 0)
	g_verbose = TRUE;
      else if (strcmp (arg, "--title") == 0)
	{
	  if (++i < argc)
	    title = argv[i];
	}
      else if (strcmp (arg, "--gtk") == 0)
	g_backend = BACKEND_GTK;
      else if (strcmp (arg, "--backend") == 0)
	{
	  if (++i < argc)
	    {
	      const gchar *backend_str = argv[i];
	      if (strcmp (backend_str, "gtk") == 0)
		g_backend = BACKEND_GTK;
	      else
		g_error ("unknown backend '%s'", backend_str);
	    }
	}
      else if (strcmp (arg, "--window") == 0)
	is_fullscreen = FALSE;
      else if (strcmp (arg, "--fullscreen") == 0)
	is_fullscreen = TRUE;
      else if (strcmp (arg, "--plugin") == 0)
	{
	  if (plugin_desc)
	    g_ptr_array_add (plugin_descs, plugin_desc);
	  plugin_desc = plugin_descriptor_new ();
	}
      else
	{
	  if (plugin_desc == NULL)
	    plugin_desc = plugin_descriptor_new ();

	  gchar **attrs = g_strsplit (arg, "=", 2);
	  if (attrs)
	    {
	      gchar *name  = attrs[0];
	      gchar *value = attrs[1];
	      if (value == NULL)
		{
		  /* Only accept "embed" and "full" attributes */
		  if (g_ascii_strcasecmp (name, "embed") == 0)
		    plugin_desc->mode = NP_EMBED;
		  else if (g_ascii_strcasecmp (name, "full") == 0)
		    plugin_desc->mode = NP_FULL;
		  else
		    npw_printf ("WARNING: skip attribute '%s'\n", name);
		}
	      else if (g_ascii_strcasecmp (name, "width") == 0)
		plugin_desc->width = atoi (value);
	      else if (g_ascii_strcasecmp (name, "height") == 0)
		plugin_desc->height = atoi (value);
	      else
		{
		  /* Build up the attrs hash with names in lowercase */
		  if (g_ascii_strcasecmp (name, "src") == 0)
		    value = sanitize_url (value);
		  else
		    value = g_strdup (value);

		  g_hash_table_insert (plugin_desc->attrs,
				       g_ascii_strdown (name, -1), value);
		}
	    }
	  g_strfreev (attrs);
	}
    }

  if (plugin_desc)
    g_ptr_array_add (plugin_descs, plugin_desc);

  if (plugin_descs->len == 0)
    {
      print_help (argv[0]);
      return 1;
    }

  const gchar *backend_str;
  switch (g_backend)
    {
    case BACKEND_GTK:
      backend_str = "gtk";
      break;
    default:
      g_error ("unknown backend type (%d)", g_backend);
      break;
    }

  g_n_plugins = plugin_descs->len;
  for (i = 0; i < plugin_descs->len; i++)
    {
      PluginDescriptor *plugin_desc = g_ptr_array_index (plugin_descs, i);
      guint width  = plugin_desc->width;
      guint height = plugin_desc->height;

      /* XXX: in Gtk windowed mode, fit window to plugin drawing area size */
      if (g_backend == BACKEND_GTK)
	{
	  display_width  = plugin_desc->width;
	  display_height = plugin_desc->height;
	}

      PlayerApp *app;
      if ((app = g_new0 (PlayerApp, 1)) == NULL)
	g_error ("could not allocate application data");
      app->width  = display_width;
      app->height = display_height;
      app->mode   = plugin_desc->mode;
      app->attrs  = plugin_desc->attrs;
      plugin_desc->app = app;

      g_timeout_add (100, (GSourceFunc)player_app_run, app);

      if (TRUE)
	{
	  GtkWidget *window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
	  if ((app->window = window) == NULL)
	    g_error ("could not create toplevel window");

	  gtk_widget_set_size_request (window, display_width, display_height);
	  gtk_window_set_title (GTK_WINDOW (window), title);
	  if (is_fullscreen)
	    gtk_window_fullscreen (GTK_WINDOW (window));
	  gtk_widget_show (window);

	  /* Ensure focus window is this window not gtk's proxy for non XEMBED case */
	  XWindowAttributes xattrs;
	  XGetWindowAttributes (GDK_DISPLAY (), GDK_WINDOW_XWINDOW (window->window), &xattrs);
	  XSelectInput (GDK_DISPLAY (),
			GDK_WINDOW_XWINDOW (window->window),
			xattrs.your_event_mask | SubstructureNotifyMask);
	  gdk_window_add_filter (window->window, on_window_filter_cb, app);
	  XSync (GDK_DISPLAY (), False);

	  g_signal_connect (window, "destroy",
			    G_CALLBACK (on_window_destroy_cb), NULL);
	  g_signal_connect (window, "key-press-event",
			    G_CALLBACK (on_key_press_event_cb), app);
	  g_signal_connect (window, "configure-event",
			    G_CALLBACK (on_configure_event_cb), app);
	  g_signal_connect (window, "window-state-event",
			    G_CALLBACK (on_window_state_event_cb), app);
	}

      if (g_backend == BACKEND_GTK)
	{
	  GtkWidget *rwindow = NULL;
	  GtkWidget *canvas  = NULL;

	  GtkDisplay *display = g_new0 (GtkDisplay, 1);
	  display->window  = rwindow;
	  display->canvas  = canvas;
	  display->width   = width;
	  display->height  = height;
	  app->display     = display;
	}
    }

  if (g_backend == BACKEND_GTK)
    gtk_main ();

  for (i = 0; i < plugin_descs->len; i++)
    {
      PluginDescriptor *plugin_desc = g_ptr_array_index (plugin_descs, i);
      if (plugin_desc->app)
	{
	  player_app_quit (plugin_desc->app);
	  player_app_destroy (plugin_desc->app);
	}
      g_free (plugin_desc);
    }
  g_ptr_array_free (plugin_descs, TRUE);
  return 0;
}
