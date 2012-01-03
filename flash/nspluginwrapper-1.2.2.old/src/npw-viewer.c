/*
 *  npw-viewer.c - Target plugin loader and viewer
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

#define _GNU_SOURCE 1 /* RTLD_NEXT */
#include "sysdeps.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <dlfcn.h>
#include <unistd.h>
#include <errno.h>

#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Intrinsic.h>
#include <X11/Shell.h>
#include <X11/StringDefs.h>
#include <X11/extensions/XShm.h>

#include <gtk/gtk.h>
#include <gdk/gdkx.h>

#include "utils.h"
#include "xembed.h"
#include "npw-common.h"
#include "npw-malloc.h"
#include "npw-use-tcp-sockets.h"
#define DEBUG 1
#include "debug.h"


// [UNIMPLEMENTED] Define to use XPCOM emulation
#define USE_XPCOM 0

// Define to use XEMBED hack (don't let browser kill our window)
#define USE_XEMBED_HACK 1

// Define to allow windowless plugins
#define ALLOW_WINDOWLESS_PLUGINS 1

// RPC global connections
rpc_connection_t *g_rpc_connection attribute_hidden = NULL;

// Viewer orignal pid - check against incorrect plugins
static pid_t g_viewer_pid = 0;

// Instance state information about the plugin
typedef struct _PluginInstance {
  NPW_DECL_PLUGIN_INSTANCE;
  bool use_xembed;
  bool is_windowless;
  NPWindow window;
  uint32_t width, height;
  void *toolkit_data;
  GdkWindow *browser_toplevel;
} PluginInstance;

#define PLUGIN_INSTANCE(instance) \
  ((PluginInstance *)NPW_PLUGIN_INSTANCE(instance))

#define PLUGIN_INSTANCE_NPP(plugin) \
  NPW_PLUGIN_INSTANCE_NPP((NPW_PluginInstance *)(plugin))

// Browser side data for an NPStream instance
typedef struct _StreamInstance {
  NPW_DECL_STREAM_INSTANCE;
} StreamInstance;

// Xt wrapper data
typedef struct _XtData {
  Window browser_window;
  Widget top_widget;
  Widget form;
} XtData;

// Gtk wrapper data
typedef struct _GtkData {
  GtkWidget *container;
  GtkWidget *socket;
} GtkData;

// Prototypes
static void destroy_window(PluginInstance *plugin);


/* ====================================================================== */
/* === Helpers                                                        === */
/* ====================================================================== */

// PluginInstance vfuncs
static void *plugin_instance_allocate(void);
static void plugin_instance_deallocate(PluginInstance *plugin);
static void plugin_instance_finalize(PluginInstance *plugin);
static void plugin_instance_invalidate(PluginInstance *plugin);

static NPW_PluginInstanceClass PluginInstanceClass = {
  (NPW_PluginInstanceAllocateFunctionPtr)plugin_instance_allocate,
  (NPW_PluginInstanceDeallocateFunctionPtr)plugin_instance_deallocate,
  (NPW_PluginInstanceFinalizeFunctionPtr)plugin_instance_finalize,
  (NPW_PluginInstanceInvalidateFunctionPtr)plugin_instance_invalidate
};

static void *plugin_instance_allocate(void)
{
  return NPW_MemNew0(PluginInstance, 1);
}

static void plugin_instance_deallocate(PluginInstance *plugin)
{
  NPW_MemFree(plugin);
}

static void plugin_instance_finalize(PluginInstance *plugin)
{
  if (plugin->browser_toplevel) {
	g_object_unref(plugin->browser_toplevel);
	plugin->browser_toplevel = NULL;
  }
  if (plugin->instance) {
	free(plugin->instance);
	plugin->instance = NULL;
  }
}

static void plugin_instance_invalidate(PluginInstance *plugin)
{
  destroy_window(plugin);

  /* NPP instance is no longer valid beyond this point. Drop the link
	 to the PluginInstance now so that future RPC with this
	 PluginInstance will actually emit a NULL instance, which the
	 other side will deal as a no-op for all functions but
	 NPN_GetValue().

	 However, don't free() the NPP instance yet as it could be used
	 later, e.g. in some NPObject::Invalidate()... Note: this also
	 means we forbid that function to call into the browser in an NPP
	 instance. */
  if (plugin->instance_id) {
	id_remove(plugin->instance_id);
	plugin->instance_id = 0;
  }
}

// Pid support routines
static void pid_init(void)
{
  g_viewer_pid = getpid();
}

bool pid_check(void)
{
#if USE_PID_CHECK
  return (g_viewer_pid == getpid());
#endif
  return true;
}

// Delayed calls machinery
// XXX: use a pipe, this should be faster (avoids GSource creation and
// explicit memory allocation)
enum {
  RPC_DELAYED_NPN_RELEASE_OBJECT = 1,
  RPC_DELAYED_NPN_INVALIDATE_RECT,
};

typedef struct _DelayedCall {
  gint type;
  gpointer data;
} DelayedCall;

static GList *g_delayed_calls = NULL;
static guint g_delayed_calls_id = 0;

static void g_NPN_ReleaseObject_Now(NPObject *npobj);
static gboolean delayed_calls_process_cb(gpointer user_data);

static void delayed_calls_add(int type, gpointer data)
{
  DelayedCall *dcall = NPW_MemNew(DelayedCall, 1);
  if (dcall == NULL)
	return;
  dcall->type = type;
  dcall->data = data;
  g_delayed_calls = g_list_append(g_delayed_calls, dcall);

  if (g_delayed_calls_id == 0)
	g_delayed_calls_id = g_idle_add_full(G_PRIORITY_LOW,
										 delayed_calls_process_cb, NULL, NULL);
}

// Returns whether there are pending calls left in the queue
static gboolean delayed_calls_process(PluginInstance *plugin, gboolean is_in_NPP_Destroy)
{
  GList *l = g_delayed_calls;
  while (l != NULL) {
	GList *cl = l;
	l = l->next;

	if (!is_in_NPP_Destroy) {
	  /* Continue later if there is incoming RPC */
	  if (rpc_wait_dispatch(g_rpc_connection, 0) > 0)
		return TRUE;
	}

	DelayedCall *dcall = (DelayedCall *)cl->data;
	switch (dcall->type) {
	case RPC_DELAYED_NPN_RELEASE_OBJECT:
	  {
		NPObject *npobj = (NPObject *)dcall->data;
		g_NPN_ReleaseObject_Now(npobj);
		break;
	  }
	}
	NPW_MemFree(dcall);
	g_delayed_calls = g_list_delete_link(g_delayed_calls, cl);
  }

  if (g_delayed_calls)
	return TRUE;

  if (g_delayed_calls_id) {
	g_source_remove(g_delayed_calls_id);
	g_delayed_calls_id = 0;
  }
  return FALSE;
}

static gboolean delayed_calls_process_cb(gpointer user_data)
{
  return delayed_calls_process(NULL, FALSE);
}


/* ====================================================================== */
/* === X Toolkit glue                                                 === */
/* ====================================================================== */

static Display *x_display;
static XtAppContext x_app_context;

typedef struct _XtTMRec {
    XtTranslations  translations;       /* private to Translation Manager    */
    XtBoundActions  proc_table;         /* procedure bindings for actions    */
    struct _XtStateRec *current_state;  /* Translation Manager state ptr     */
    unsigned long   lastEventTime;
} XtTMRec, *XtTM;   

typedef struct _CorePart {
    Widget          self;               /* pointer to widget itself          */
    WidgetClass     widget_class;       /* pointer to Widget's ClassRec      */
    Widget          parent;             /* parent widget                     */
    XrmName         xrm_name;           /* widget resource name quarkified   */
    Boolean         being_destroyed;    /* marked for destroy                */
    XtCallbackList  destroy_callbacks;  /* who to call when widget destroyed */
    XtPointer       constraints;        /* constraint record                 */
    Position        x, y;               /* window position                   */
    Dimension       width, height;      /* window dimensions                 */
    Dimension       border_width;       /* window border width               */
    Boolean         managed;            /* is widget geometry managed?       */
    Boolean         sensitive;          /* is widget sensitive to user events*/
    Boolean         ancestor_sensitive; /* are all ancestors sensitive?      */
    XtEventTable    event_table;        /* private to event dispatcher       */
    XtTMRec         tm;                 /* translation management            */
    XtTranslations  accelerators;       /* accelerator translations          */
    Pixel           border_pixel;       /* window border pixel               */
    Pixmap          border_pixmap;      /* window border pixmap or NULL      */
    WidgetList      popup_list;         /* list of popups                    */
    Cardinal        num_popups;         /* how many popups                   */
    String          name;               /* widget resource name              */
    Screen          *screen;            /* window's screen                   */
    Colormap        colormap;           /* colormap                          */
    Window          window;             /* window ID                         */
    Cardinal        depth;              /* number of planes in window        */
    Pixel           background_pixel;   /* window background pixel           */
    Pixmap          background_pixmap;  /* window background pixmap or NULL  */
    Boolean         visible;            /* is window mapped and not occluded?*/
    Boolean         mapped_when_managed;/* map window if it's managed?       */
} CorePart;

typedef struct _WidgetRec {
    CorePart    core;
} WidgetRec, CoreRec;

extern void XtResizeWidget(
    Widget              /* widget */,
    _XtDimension        /* width */,
    _XtDimension        /* height */,
    _XtDimension        /* border_width */
);

// Dummy X error handler
static int trapped_error_code;
static int (*old_error_handler)(Display *, XErrorEvent *);

static int error_handler(Display *display, XErrorEvent *error)
{
  trapped_error_code = error->error_code;
  return 0;
}
 
static void trap_errors(void)
{
  trapped_error_code = 0;
  old_error_handler = XSetErrorHandler(error_handler);
}

static int untrap_errors(void)
{
  XSetErrorHandler(old_error_handler);
  return trapped_error_code;
}

// Install the _XEMBED_INFO property
static void xt_client_set_info(Widget w, unsigned long flags)
{
  Atom atom_XEMBED_INFO = XInternAtom(x_display, "_XEMBED_INFO", False);

  unsigned long buffer[2];
  buffer[1] = 0;		/* Protocol version */
  buffer[1] = flags;
  XChangeProperty(XtDisplay(w), XtWindow(w),
				  atom_XEMBED_INFO,
				  atom_XEMBED_INFO,
				  32, PropModeReplace, (unsigned char *)buffer, 2);
}

// Send an XEMBED message to the specified window
static void send_xembed_message(Display *display,
								Window   window,
								long     message,
								long     detail,
								long     data1,
								long     data2)
{
  XEvent xevent;
  memset(&xevent, 0, sizeof(xevent));
  xevent.xclient.window = window;
  xevent.xclient.type = ClientMessage;
  xevent.xclient.message_type = XInternAtom(display, "_XEMBED", False);
  xevent.xclient.format = 32;
  xevent.xclient.data.l[0] = CurrentTime; // XXX: evil?
  xevent.xclient.data.l[1] = message;
  xevent.xclient.data.l[2] = detail;
  xevent.xclient.data.l[3] = data1;
  xevent.xclient.data.l[4] = data2;

  trap_errors();
  XSendEvent(display, xevent.xclient.window, False, NoEventMask, &xevent);
  XSync(display, False);
  untrap_errors();
}

/*
 *  NSPluginWrapper strategy to handle input focus.
 *
 *  - XEMBED must be enabled with NPPVpluginNeedsXEmbed set to
 *    PR_TRUE. This causes Firefox to pass a plain GtkSocket ID into
 *    NPWindow::window. i.e. the GtkXtBin window ID is NOT used.
 *
 *  - A click into the plugin window sends an XEMBED_REQUEST_FOCUS
 *    event to the parent (socket) window.
 *
 *  - An XFocusEvent is simulated when XEMBED_FOCUS_IN and
 *    XEMBED_FOCUS_OUT messages arrive to the plugin window.
 *
 *  - Key events are forwarded from the top widget (which window was
 *    reparented to the socket window) to the actual canvas (form).
 *
 *  Reference checkpoints, i.e. check the following test cases still
 *  work if you want to change the policy.
 *
 *  [1] Debian bug #435912
 *      <http://www.addictinggames.com/bloxors.html>
 *
 *  Goto to stage 1, use arrow keys to move the block. Now, click
 *  outside of the game window, use arrow keys to try to move the
 *  block: it should NOT move.
 *
 *  [2] User reported bug
 *      <http://www.forom.com/>
 *
 *  Choose a language and then a mirror. Do NOT move the cursor out of
 *  the plugin window. Now, click into the "Login" input field and try
 *  to type in something, you should have the input focus.
 *
 *  [3] Additional test that came in during debugging
 *
 *  Go to either [1] or [2], double-click the browser URL entry to
 *  select it completely. Now, click into the Flash plugin area. The
 *  URL selection MUST now be unselected AND using the Tab key selects
 *  various fields in the Flash window (e.g. menu items for [1]).
 */

// Simulate client focus
static void xt_client_simulate_focus(Widget w, int type)
{
  XEvent xevent;
  memset(&xevent, 0, sizeof(xevent));
  xevent.xfocus.type = type;
  xevent.xfocus.window = XtWindow(w);
  xevent.xfocus.display = XtDisplay(w);
  xevent.xfocus.mode = NotifyNormal;
  xevent.xfocus.detail = NotifyAncestor;

  trap_errors();
  XSendEvent(XtDisplay(w), xevent.xfocus.window, False, NoEventMask, &xevent);
  XSync(XtDisplay(w), False);
  untrap_errors();
}

// Various hacks for decent events filtery
static void xt_client_event_handler(Widget w, XtPointer client_data, XEvent *event, Boolean *cont)
{
  XtData *toolkit = (XtData *)client_data;

  switch (event->type) {
  case ClientMessage:
	// Handle XEMBED messages, in particular focus changes
	if (event->xclient.message_type == XInternAtom(x_display, "_XEMBED", False)) {
	  switch (event->xclient.data.l[1]) {
	  case XEMBED_FOCUS_IN:
		xt_client_simulate_focus(toolkit->form, FocusIn);
		break;
	  case XEMBED_FOCUS_OUT:
		xt_client_simulate_focus(toolkit->form, FocusOut);
		break;
	  }
	}
	break;
  case KeyPress:
  case KeyRelease:
	// Propagate key events down to the actual window
	if (event->xkey.window == XtWindow(toolkit->top_widget)) {
	  event->xkey.window = XtWindow(toolkit->form);
	  trap_errors();
	  XSendEvent(XtDisplay(toolkit->form), event->xfocus.window, False, NoEventMask, event);
	  XSync(XtDisplay(toolkit->form), False);
	  untrap_errors();
	  *cont = False;
	}
	break;
  case ButtonRelease:
	// Notify the embedder that we want the input focus
	send_xembed_message(XtDisplay(w), toolkit->browser_window, XEMBED_REQUEST_FOCUS, 0, 0, 0);
	break;
  }
}


/* ====================================================================== */
/* === XPCOM glue                                                     === */
/* ====================================================================== */

#if defined(__GNUC__) && (__GNUC__ > 2)
#define NS_LIKELY(x)    (__builtin_expect((x), 1))
#define NS_UNLIKELY(x)  (__builtin_expect((x), 0))
#else
#define NS_LIKELY(x)    (x)
#define NS_UNLIKELY(x)  (x)
#endif

#define NS_FAILED(_nsresult) (NS_UNLIKELY((_nsresult) & 0x80000000))
#define NS_SUCCEEDED(_nsresult) (NS_LIKELY(!((_nsresult) & 0x80000000)))

typedef uint32 nsresult;
typedef struct nsIServiceManager nsIServiceManager;
extern nsresult NS_GetServiceManager(nsIServiceManager **result);


/* ====================================================================== */
/* === Window utilities                                               === */
/* ====================================================================== */

// Reconstruct window attributes
static int create_window_attributes(NPSetWindowCallbackStruct *ws_info)
{
  if (ws_info == NULL)
	return -1;
  GdkVisual *gdk_visual;
  if (ws_info->visual)
	gdk_visual = gdkx_visual_get((uintptr_t)ws_info->visual);
  else
	gdk_visual = gdk_visual_get_system();
  if (gdk_visual == NULL) {
	npw_printf("ERROR: could not reconstruct XVisual from visualID\n");
	return -2;
  }
  ws_info->display = x_display;
  ws_info->visual = gdk_x11_visual_get_xvisual(gdk_visual);
  return 0;
}

// Destroy window attributes struct
static void destroy_window_attributes(NPSetWindowCallbackStruct *ws_info)
{
  if (ws_info == NULL)
	return;
  NPW_MemFree(ws_info);
}

// Fix size hints in NPWindow (Flash Player doesn't like null width)
static void fixup_size_hints(PluginInstance *plugin)
{
  NPWindow *window = &plugin->window;

  // check global hints (got through EMBED plugin args)
  if (window->width == 0 || window->height == 0) {
	if (plugin->width && plugin->height) {
	  window->width = plugin->width;
	  window->height = plugin->height;
	  return;
	}
  }

  // check actual window size and commit back to plugin data
  if (window->window && (window->width == 0 || window->height == 0)) {
	XWindowAttributes win_attr;
	if (XGetWindowAttributes(x_display, (Window)window->window, &win_attr)) {
	  plugin->width = window->width = win_attr.width;
	  plugin->height = window->height = win_attr.height;
	  return;
	}
  }

  if (window->width == 0 || window->height == 0)
	npw_printf("WARNING: grmpf, despite much effort, I could not determine the actual plugin area size...\n");
}

// Create a new window from NPWindow
static int create_window(PluginInstance *plugin, NPWindow *window)
{
  // XXX destroy previous window here?
  if (plugin->is_windowless) {
	destroy_window_attributes(plugin->window.ws_info);
	plugin->window.ws_info = NULL;
  }
  assert(plugin->window.ws_info == NULL);

  // cache new window information and reconstruct window attributes
  NPSetWindowCallbackStruct *ws_info;
  if ((ws_info = NPW_MemClone(NPSetWindowCallbackStruct, window->ws_info)) == NULL)
	return -1;
  if (create_window_attributes(ws_info) < 0)
	return -1;
  memcpy(&plugin->window, window, sizeof(*window));
  window = &plugin->window;
  window->ws_info = ws_info;
  fixup_size_hints(plugin);

  // that's all for windowless plugins
  if (plugin->is_windowless)
	return 0;

  // create the new window
  if (plugin->use_xembed) {
    if (use_remote_invocation())
      {
	/*	void *container, *socket;
	printf("The window id of the parent is: %p\n", window->window);
	printf("Enter separated by space the windowid of the container and the windowid of the socket:");
	scanf("%p %p", &container, &socket);
	printf("The ids passed were %p and %p\n", container, socket);
	window->window = socket;
	*/
	/*
	GtkData *toolkit = calloc(1, sizeof(*toolkit));
	if (toolkit == NULL)
	  return -1;
	toolkit->container = gtk_window_new (GTK_WINDOW_POPUP);
	toolkit->socket = gtk_socket_new();
	gtk_container_add (GTK_CONTAINER (toolkit->container), toolkit->socket);
	gtk_widget_set_size_request (toolkit->socket, window->width, window->height);
	gtk_widget_show (toolkit->socket);
	gtk_widget_realize (toolkit->container);
	GdkWindow* window_container = gdk_window_foreign_new((Window)window->window);
	if (GTK_WIDGET_MAPPED(toolkit->container))
	  gtk_widget_unmap(toolkit->container);
	    
	gdk_window_reparent(toolkit->container->window, window_container, 0, 0);
	gtk_widget_show (toolkit->container);
	
	window->window = (void *)gtk_socket_get_id(GTK_SOCKET(toolkit->socket));
	plugin->toolkit_data = toolkit;
#if USE_XEMBED_HACK
	// don't let the browser kill our window out of NPP_Destroy() scope
	g_signal_connect(toolkit->container, "delete-event",
			 G_CALLBACK(gtk_true), NULL);
#endif
	// make sure we don't try to destroy the widget again in destroy_window()
	g_signal_connect(toolkit->container, "destroy",
			 G_CALLBACK(gtk_widget_destroyed), &toolkit->container);
	// keep the socket as the plugin tries to destroy the widget itself
	g_signal_connect(toolkit->socket, "plug_removed",
			 G_CALLBACK(gtk_true), NULL);

	window->window = (void *)gtk_socket_get_id(GTK_SOCKET(toolkit->socket));
	plugin->toolkit_data = toolkit;
	
	return(0);
	*/
	GtkData *toolkit = calloc(1, sizeof(*toolkit));
	if (toolkit == NULL)
	  return -1;
	D(bug("create_window Before creationg toolkit->container\n"));
	//toolkit->container = gtk_window_new (GTK_WINDOW_TOPLEVEL);
	toolkit->container = gtk_window_new (GTK_WINDOW_POPUP);
	// gdk_window_set_override_redirect(toolkit->container->window, TRUE);
	if (toolkit->container == NULL)
	  return -1;
	D(bug("create_window Before realizing toolkit->container\n"));
	//D(bug("can focus container: %d\n", gtk_widget_get_can_focus(toolkit->container)));
	//gtk_widget_set_can_focus(toolkit->container, TRUE);
	//D(bug("can focus container: %d\n", gtk_widget_get_can_focus(toolkit->container)));
	//D(bug("event mask container: 0x%x\n", gtk_widget_get_events(toolkit->container)));
	//gtk_widget_add_events(toolkit->container, GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK);
	//D(bug("event mask container after adding : 0x%x\n", gtk_widget_get_events(toolkit->container)));
	//gtk_widget_set_events(toolkit->container, GDK_POINTER_MOTION_MASK | GDK_POINTER_MOTION_HINT_MASK | GDK_BUTTON_MOTION_MASK |  GDK_BUTTON1_MOTION_MASK | GDK_BUTTON2_MOTION_MASK | GDK_BUTTON3_MOTION_MASK | GDK_BUTTON_PRESS_MASK | GDK_BUTTON_RELEASE_MASK);
	//	D(bug("event mask container: %d\n", gtk_widget_get_events(toolkit->container)));
	gtk_widget_realize(toolkit->container);
	D(bug("create_window Before set size_request toolkit->container\n"));
 	gtk_widget_set_size_request(toolkit->container, window->width, window->height);
	D(bug("create_window Before gdk_window_foreign_new window %p\n", window->window));
	GdkWindow *parent = gdk_window_foreign_new((Window)window->window);
	//	D(bug("create_window Before set showing parent window \n"));
	//gtk_widget_show(parent);
	//D(bug("event mask parent: %d\n", gtk_widget_get_events(parent)));
	//gtk_widget_set_events(parent, 0x0fffff);
	//D(bug("event mask parent: %d\n", gtk_widget_get_events(parent)));
	D(bug("create_window Before reparent toolkit->container %p->%p\n", GDK_WINDOW_XID(toolkit->container->window), window->window));
	gdk_window_reparent(toolkit->container->window, parent, 0, 0);
	D(bug("create_window Before show toolkit->container\n"));
	gtk_widget_show(toolkit->container);
	D(bug("create_window container is: %p\n",  GDK_WINDOW_XID(toolkit->container->window)));

	// Test
	//	D(bug("create_window Create button\n"));
	//GtkWidget *button;
	//button = gtk_button_new_with_label ("Hello World");
	//gtk_container_add (GTK_CONTAINER(toolkit->container), button);
	//gtk_widget_show(button);
	//gtk_widget_set_sensitive(toolkit->container, TRUE);
	toolkit->socket = gtk_socket_new();
	if (toolkit->socket == NULL)
	  return -1;
	//D(bug("event mask socket: %d\n", gtk_widget_get_events(toolkit->socket)));
	// Careful not to pass all events -> the expose event kills the plugin
	//	gtk_widget_set_events(toolkit->socket, 0x0fffff);
	//D(bug("event mask socket: %d\n", gtk_widget_get_events(toolkit->socket)));
	gtk_widget_set_size_request (toolkit->socket, window->width, window->height);
	gtk_container_add(GTK_CONTAINER(toolkit->container), toolkit->socket);
	gtk_widget_show (toolkit->socket);
	D(bug("create_window socket is: %p\n", gtk_socket_get_id((GtkSocket *)toolkit->socket)));
	D(bug("can focus before parent: %d, container: %d, socket: %d\n", GTK_WIDGET_CAN_FOCUS(parent),
	      GTK_WIDGET_CAN_FOCUS(toolkit->container), GTK_WIDGET_CAN_FOCUS(toolkit->socket)));
	//	gtk_widget_set_can_focus(parent, TRUE);
	//	gtk_widget_set_can_focus(toolkit->container, TRUE);
	//	gtk_widget_set_can_focus(toolkit->socket, TRUE);
	D(bug("can focus after parent: %d, container: %d, socket: %d\n", GTK_WIDGET_CAN_FOCUS(parent),
	      GTK_WIDGET_CAN_FOCUS(toolkit->container), GTK_WIDGET_CAN_FOCUS(toolkit->socket)));
	D(bug("widget state parent: %d, container: %d, socket: %d\n", GTK_WIDGET_STATE(parent),
	      GTK_WIDGET_STATE(toolkit->container), GTK_WIDGET_STATE(toolkit->socket)));
	D(bug("widget sensitive parent: %d, container: %d, socket: %d\n", GTK_WIDGET_IS_SENSITIVE(parent),
	      GTK_WIDGET_IS_SENSITIVE(toolkit->container), GTK_WIDGET_IS_SENSITIVE(toolkit->socket)));

	//	gtk_widget_grab_focus(toolkit->container);
	//gtk_widget_show_all(toolkit->container);
	//gtk_widget_grab_focus(toolkit->container);
	//gtk_widget_grab_focus(toolkit->container);

	D(bug("create_window parent window=0x%lx, container=0x%lx, socket=0x%lx\n", window->window, GDK_WINDOW_XID(toolkit->container->window), gtk_socket_get_id((GtkSocket *)toolkit->socket)));
	//	D(bug("create_window parent window=0x%lx, container=0x%lx, socket=0x%lx\n", GDK_WINDOW_XID(window->window), GDK_WINDOW_XID(toolkit->container->window), GDK_WINDOW_XID(toolkit->socket->window)));
	//	D(bug("create_window parent window=0x%lx, container=0x%lx, socket=0x%lx\n", window->window, toolkit->container->window, GDK_WINDOW_XID(toolkit->socket->window)));

	window->window = (void *)gtk_socket_get_id(GTK_SOCKET(toolkit->socket));
	plugin->toolkit_data = toolkit;
#if USE_XEMBED_HACK
	// don't let the browser kill our window out of NPP_Destroy() scope
	g_signal_connect(toolkit->container, "delete-event",
					 G_CALLBACK(gtk_true), NULL);
#endif
	// make sure we don't try to destroy the widget again in destroy_window()
	g_signal_connect(toolkit->container, "destroy",
					 G_CALLBACK(gtk_widget_destroyed), &toolkit->container);
	// keep the socket as the plugin tries to destroy the widget itself
	g_signal_connect(toolkit->socket, "plug_removed",
					 G_CALLBACK(gtk_true), NULL);
	return 0;
	/*	XtData *toolkit = calloc(1, sizeof(*toolkit));
	if (toolkit == NULL)
	  return -1;

	String app_name, app_class;
	
	D(bug("Before XtGetApplicationNameAndClass\n"));
	XtGetApplicationNameAndClass(x_display, &app_name, &app_class);
	D(bug("Before top_widget\n"));
	Widget top_widget = XtVaAppCreateShell("drawingArea", app_class, topLevelShellWidgetClass, x_display,
					       XtNoverrideRedirect, True,
					       XtNborderWidth, 0,
					       XtNbackgroundPixmap, None,
					       XtNwidth, window->width,
					       XtNheight, window->height,
					       NULL);
	
	D(bug("Before realize top_widget\n"));
	XtRealizeWidget(top_widget);
	D(bug("Before form. top widget is 0x%x\n", XtWindow(top_widget)));
	Widget form = XtVaCreateManagedWidget("form", compositeWidgetClass, top_widget,
					      XtNdepth, ws_info->depth,
					      XtNvisual, ws_info->visual,
					      XtNcolormap, ws_info->colormap,
					      XtNborderWidth, 0,
					      XtNbackgroundPixmap, None,
					      XtNwidth, window->width,
					      XtNheight, window->height,
					      NULL);

	D(bug("Before realize top_widget and form is 0x%x\n", XtWindow(form)));
	XtRealizeWidget(top_widget);
	D(bug("Before reparent window->window is 0x%x\n", window->window));
	XReparentWindow(x_display, XtWindow(top_widget), (Window)window->window, 0, 0);
	D(bug("Before realize form\n"));
	XtRealizeWidget(form);
	
	D(bug("Before XSelectInput\n"));
	XSelectInput(x_display, XtWindow(top_widget), 0x0fffff);
	D(bug("Before XAddEventHandler\n"));
	XtAddEventHandler(top_widget, (SubstructureNotifyMask|KeyPress|KeyRelease), True, xt_client_event_handler, toolkit);
	XtAddEventHandler(form, (ButtonReleaseMask), True, xt_client_event_handler, toolkit);
	xt_client_set_info(form, 0);

	plugin->toolkit_data = toolkit;
	toolkit->top_widget = top_widget;
	toolkit->form = form;
	toolkit->browser_window = (Window)window->window;
	window->window = (void *)XtWindow(form);
	return 0;
	*/
      }
    else
      {
	GtkData *toolkit = calloc(1, sizeof(*toolkit));
	if (toolkit == NULL)
	  return -1;
	toolkit->container = gtk_plug_new((GdkNativeWindow)window->window);
	if (toolkit->container == NULL)
	  return -1;
	gtk_widget_set_size_request(toolkit->container, window->width, window->height); 
	gtk_widget_show(toolkit->container);
	toolkit->socket = gtk_socket_new();
	if (toolkit->socket == NULL)
	  return -1;
	gtk_widget_show(toolkit->socket);
	gtk_container_add(GTK_CONTAINER(toolkit->container), toolkit->socket);
	gtk_widget_show_all(toolkit->container);
	window->window = (void *)gtk_socket_get_id(GTK_SOCKET(toolkit->socket));
	plugin->toolkit_data = toolkit;
#if USE_XEMBED_HACK
	// don't let the browser kill our window out of NPP_Destroy() scope
	g_signal_connect(toolkit->container, "delete-event",
					 G_CALLBACK(gtk_true), NULL);
#endif
	// make sure we don't try to destroy the widget again in destroy_window()
	g_signal_connect(toolkit->container, "destroy",
					 G_CALLBACK(gtk_widget_destroyed), &toolkit->container);
	// keep the socket as the plugin tries to destroy the widget itself
	g_signal_connect(toolkit->socket, "plug_removed",
					 G_CALLBACK(gtk_true), NULL);
	return 0;

      }
  }

  XtData *toolkit = calloc(1, sizeof(*toolkit));
  if (toolkit == NULL)
	return -1;

  String app_name, app_class;
  XtGetApplicationNameAndClass(x_display, &app_name, &app_class);
  Widget top_widget = XtVaAppCreateShell("drawingArea", app_class, topLevelShellWidgetClass, x_display,
										 XtNoverrideRedirect, True,
										 XtNborderWidth, 0,
										 XtNbackgroundPixmap, None,
										 XtNwidth, window->width,
										 XtNheight, window->height,
										 NULL);

  Widget form = XtVaCreateManagedWidget("form", compositeWidgetClass, top_widget,
										XtNdepth, ws_info->depth,
										XtNvisual, ws_info->visual,
										XtNcolormap, ws_info->colormap,
										XtNborderWidth, 0,
										XtNbackgroundPixmap, None,
										XtNwidth, window->width,
										XtNheight, window->height,
										NULL);

  XtRealizeWidget(top_widget);
  XReparentWindow(x_display, XtWindow(top_widget), (Window)window->window, 0, 0);
  XtRealizeWidget(form);

  XSelectInput(x_display, XtWindow(top_widget), 0x0fffff);
  XtAddEventHandler(top_widget, (SubstructureNotifyMask|KeyPress|KeyRelease), True, xt_client_event_handler, toolkit);
  XtAddEventHandler(form, (ButtonReleaseMask), True, xt_client_event_handler, toolkit);
  xt_client_set_info(form, 0);

  plugin->toolkit_data = toolkit;
  toolkit->top_widget = top_widget;
  toolkit->form = form;
  toolkit->browser_window = (Window)window->window;
  window->window = (void *)XtWindow(form);
  return 0;
}

// Update window information from NPWindow
static int update_window(PluginInstance *plugin, NPWindow *window)
{
  if (plugin->is_windowless) {
	npw_printf("ERROR: update_window() called for windowless plugin\n");
	return -1;
  }

  if (window->ws_info == NULL) {
	npw_printf("ERROR: no window attributes for window %p\n", window->window);
	return -1;
  }

  // always synchronize window attributes
  NPSetWindowCallbackStruct *ws_info = plugin->window.ws_info;
  memcpy(ws_info, window->ws_info, sizeof(*ws_info));
  create_window_attributes(ws_info);

  // synchronize cliprect
  memcpy(&plugin->window.clipRect, &window->clipRect, sizeof(window->clipRect));;

  // synchronize window position, if it changed
  if (plugin->window.x != window->x || plugin->window.y != window->y) {
	plugin->window.x = window->x;
	plugin->window.y = window->y;
  }

  // synchronize window size, if it changed
  if (plugin->window.width != window->width || plugin->window.height != window->height) {
	plugin->window.width = window->width;
	plugin->window.height = window->height;
	if (plugin->toolkit_data) {
	  if (plugin->use_xembed) {
		// window size changes are already caught per the XEMBED protocol
	        if (use_remote_invocation())
		  {
		    GtkData *toolkit = plugin->toolkit_data;
		    gtk_widget_set_size_request (toolkit->container, window->width, window->height);
		    gtk_widget_set_size_request (toolkit->socket, window->width, window->height);
		  }
	  }
	  else {
		XtData *toolkit = (XtData *)plugin->toolkit_data;
		if (toolkit->form)
		  XtResizeWidget(toolkit->form, plugin->window.width, plugin->window.height, 0);
		if (toolkit->top_widget)
		  XtResizeWidget(toolkit->top_widget, plugin->window.width, plugin->window.height, 0);
	  }
	}
  }
  return 0;
}

// Destroy window
static void destroy_window(PluginInstance *plugin)
{
  if (plugin->toolkit_data) {
	if (plugin->use_xembed) {
	  GtkData *toolkit = (GtkData *)plugin->toolkit_data;
	  if (toolkit->container) {
		gdk_flush();
		gtk_widget_destroy(toolkit->container);
		gdk_flush();
		toolkit->container = NULL;
	  }
	}
	else {
	  XtData *toolkit = (XtData *)plugin->toolkit_data;
	  if (toolkit->top_widget) {
		XSync(x_display, False);
		XtUnrealizeWidget(toolkit->top_widget);
		XtDestroyWidget(toolkit->top_widget);
		XSync(x_display, False);
		toolkit->top_widget = None;
	  }
	}
	free(plugin->toolkit_data);
	plugin->toolkit_data = NULL;
  }

  if (plugin->window.ws_info) {
	destroy_window_attributes(plugin->window.ws_info);
	plugin->window.ws_info = NULL;
  }
}


/* ====================================================================== */
/* === Browser side plug-in API                                       === */
/* ====================================================================== */

static char *g_user_agent = NULL;

// Does browser have specified feature?
#define NPN_HAS_FEATURE(FEATURE) ((mozilla_funcs.version & 0xff) >= NPVERS_HAS_##FEATURE)

// Netscape exported functions
static NPNetscapeFuncs mozilla_funcs;

// Forces a repaint message for a windowless plug-in
static void
g_NPN_ForceRedraw(NPP instance)
{
  D(bug("NPN_ForceRedraw instance=%p\n", instance));

  NPW_UNIMPLEMENTED();
}

// Asks the browser to create a stream for the specified URL
static NPError
invoke_NPN_GetURL(PluginInstance *plugin, const char *url, const char *target)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_GET_URL,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_STRING, url,
								RPC_TYPE_STRING, target,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetURL() invoke", error);
	return NPERR_GENERIC_ERROR;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetURL() wait for reply", error);
	return NPERR_GENERIC_ERROR;
  }

  return ret;
}

static NPError
g_NPN_GetURL(NPP instance, const char *url, const char *target)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_GetURL called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }

  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  D(bugiI("NPN_GetURL instance=%p\n", instance));
  npw_plugin_instance_ref(plugin);
  NPError ret = invoke_NPN_GetURL(plugin, url, target);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_GetURL return: %d [%s]\n", ret, string_of_NPError(ret)));
  return ret;
}

// Requests creation of a new stream with the contents of the specified URL
static NPError
invoke_NPN_GetURLNotify(PluginInstance *plugin, const char *url, const char *target, void *notifyData)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_GET_URL_NOTIFY,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_STRING, url,
								RPC_TYPE_STRING, target,
								RPC_TYPE_NP_NOTIFY_DATA, notifyData,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetURLNotify() invoke", error);
	return NPERR_GENERIC_ERROR;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetURLNotify() wait for reply", error);
	return NPERR_GENERIC_ERROR;
  }

  return ret;
}

static NPError
g_NPN_GetURLNotify(NPP instance, const char *url, const char *target, void *notifyData)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_GetURLNotify called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }
	
  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  D(bugiI("NPN_GetURLNotify instance=%p\n", instance));
  npw_plugin_instance_ref(plugin);
  NPError ret = invoke_NPN_GetURLNotify(plugin, url, target, notifyData);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_GetURLNotify return: %d [%s]\n", ret, string_of_NPError(ret)));
  return ret;
}

// Allows the plug-in to query the browser for information
static NPError
invoke_NPN_GetValue(PluginInstance *plugin, NPNVariable variable, void *value)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_GET_VALUE,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_UINT32, variable,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetValue() invoke", error);
	return NPERR_GENERIC_ERROR;
  }

  int32_t ret;
  switch (rpc_type_of_NPNVariable(variable)) {
  case RPC_TYPE_UINT32:
	{
	  uint32_t n = 0;
	  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_UINT32, &n, RPC_TYPE_INVALID);
	  if (error != RPC_ERROR_NO_ERROR) {
		npw_perror("NPN_GetValue() wait for reply", error);
		ret = NPERR_GENERIC_ERROR;
	  }
	  D(bug("-> value: %u\n", n));
	  *((unsigned int *)value) = n;
	  break;
	}
  case RPC_TYPE_BOOLEAN:
	{
	  uint32_t b = 0;
	  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_BOOLEAN, &b, RPC_TYPE_INVALID);
	  if (error != RPC_ERROR_NO_ERROR) {
		npw_perror("NPN_GetValue() wait for reply", error);
		ret = NPERR_GENERIC_ERROR;
	  }
	  D(bug("-> value: %s\n", b ? "true" : "false"));
	  *((PRBool *)value) = b ? PR_TRUE : PR_FALSE;
	  break;
	}
  case RPC_TYPE_NP_OBJECT:
	{
	  NPObject *npobj = NULL;
	  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_NP_OBJECT, &npobj, RPC_TYPE_INVALID);
	  if (error != RPC_ERROR_NO_ERROR) {
		npw_perror("NPN_GetValue() wait for reply", error);
		ret = NPERR_GENERIC_ERROR;
	  }
	  D(bug("-> value: <object %p>\n", npobj));
	  *((NPObject **)value) = npobj;
	  break;
	}
  }

  return ret;
}

static NPError
g_NPN_GetValue_real(NPP instance, NPNVariable variable, void *value)
{
  PluginInstance *plugin = NULL;
  if (instance)
	plugin = PLUGIN_INSTANCE(instance);

  npw_plugin_instance_ref(plugin);
  NPError ret = invoke_NPN_GetValue(plugin, variable, value);
  npw_plugin_instance_unref(plugin);
  return ret;
}

static NPError
g_NPN_GetValue(NPP instance, NPNVariable variable, void *value)
{
  D(bug("NPN_GetValue instance=%p, variable=%d [%s]\n", instance, variable, string_of_NPNVariable(variable)));

  if (!pid_check()) {
	npw_printf("WARNING: NPN_GetValue called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }

  PluginInstance *plugin = NULL;
  if (instance)
	plugin = PLUGIN_INSTANCE(instance);

  switch (variable) {
  case NPNVxDisplay:
	*(void **)value = x_display;
	break;
  case NPNVxtAppContext:
	*(void **)value = XtDisplayToApplicationContext(x_display);
	break;
  case NPNVToolkit:
	*(NPNToolkitType *)value = NPW_TOOLKIT;
	break;
#if USE_XPCOM
  case NPNVserviceManager: {
	nsIServiceManager *sm;
	int ret = NS_GetServiceManager(&sm);
	if (NS_FAILED(ret)) {
	  npw_printf("WARNING: NS_GetServiceManager failed\n");
	  return NPERR_GENERIC_ERROR;
	}
	*(nsIServiceManager **)value = sm;
	break;
  }
  case NPNVDOMWindow:
  case NPNVDOMElement:
	npw_printf("WARNING: %s is not supported by NPN_GetValue()\n", string_of_NPNVariable(variable));
	return NPERR_INVALID_PARAM;
#endif
  case NPNVnetscapeWindow:
	if (plugin == NULL) {
	  npw_printf("ERROR: NPNVnetscapeWindow requires a non NULL instance\n");
	  return NPERR_INVALID_INSTANCE_ERROR;
	}
	if (plugin->browser_toplevel == NULL) {
	  GdkNativeWindow netscape_xid = None;
	  NPError error = g_NPN_GetValue_real(instance, variable, &netscape_xid);
	  if (error != NPERR_NO_ERROR)
		return error;
	  if (netscape_xid == None)
		return NPERR_GENERIC_ERROR;
	  plugin->browser_toplevel = gdk_window_foreign_new(netscape_xid);
	  if (plugin->browser_toplevel == NULL)
		return NPERR_GENERIC_ERROR;
	}
	*((GdkNativeWindow *)value) = GDK_WINDOW_XWINDOW(plugin->browser_toplevel);
	break;
#if ALLOW_WINDOWLESS_PLUGINS
  case NPNVSupportsWindowless:
#endif
  case NPNVSupportsXEmbedBool:
  case NPNVWindowNPObject:
  case NPNVPluginElementNPObject:
	return g_NPN_GetValue_real(instance, variable, value);
  default:
	switch (variable & 0xff) {
	case 13: /* NPNVToolkit */
	  if (NPW_TOOLKIT == NPNVGtk2) {
		// Gtk2 does not need to depend on a specific C++ ABI
		*(NPNToolkitType *)value = NPW_TOOLKIT;
		return NPERR_NO_ERROR;
	  }
	  break;
	}
	npw_printf("WARNING: unhandled variable %d (%s) in NPN_GetValue()\n", variable, string_of_NPNVariable(variable));
	return NPERR_INVALID_PARAM;
  }

  return NPERR_NO_ERROR;
}

// Invalidates specified drawing area prior to repainting or refreshing a windowless plug-in
static void
invoke_NPN_InvalidateRect(PluginInstance *plugin, NPRect *invalidRect)
{
  npw_return_if_fail(rpc_method_invoke_possible(g_rpc_connection));

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_INVALIDATE_RECT,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_RECT, invalidRect,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_InvalidateRect() invoke", error);
	return;
  }

  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_InvalidateRect() wait for reply", error);
	return;
  }
}

static void
g_NPN_InvalidateRect(NPP instance, NPRect *invalidRect)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_InvalidateRect called from the wrong process\n");
	return;
  }

  if (instance == NULL)
	return;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return;

  if (invalidRect == NULL)
	return;

  D(bugiI("NPN_InvalidateRect instance=%p\n", PLUGIN_INSTANCE_NPP(plugin)));
  npw_plugin_instance_ref(plugin);
  invoke_NPN_InvalidateRect(plugin, invalidRect);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_InvalidateRect done\n"));
}

// Invalidates specified region prior to repainting or refreshing a windowless plug-in
static void
g_NPN_InvalidateRegion(NPP instance, NPRegion invalidRegion)
{
  D(bug("NPN_InvalidateRegion instance=%p\n", instance));

  NPW_UNIMPLEMENTED();
}

// Allocates memory from the browser's memory space
static void *
g_NPN_MemAlloc(uint32 size)
{
  D(bugiI("NPN_MemAlloc size=%d\n", size));

  void *ptr = NPW_MemAlloc(size);
  D(bugiD("NPN_MemAlloc return: %p\n", ptr));
  return ptr;
}

// Requests that the browser free a specified amount of memory
static uint32
g_NPN_MemFlush(uint32 size)
{
  D(bug("NPN_MemFlush size=%d\n", size));
  return 0;
}

// Deallocates a block of allocated memory
static void
g_NPN_MemFree(void *ptr)
{
  D(bugiI("NPN_MemFree ptr=%p\n", ptr));
  NPW_MemFree(ptr);
  D(bugiD("NPN_MemFree done\n"));
}

// Posts data to a URL
static NPError
invoke_NPN_PostURL(PluginInstance *plugin, const char *url, const char *target, uint32 len, const char *buf, NPBool file)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_POST_URL,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_STRING, url,
								RPC_TYPE_STRING, target,
								RPC_TYPE_ARRAY, RPC_TYPE_CHAR, len, buf,
								RPC_TYPE_BOOLEAN, file,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_PostURL() invoke", error);
	return NPERR_GENERIC_ERROR;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_PostURL() wait for reply", error);
	return NPERR_GENERIC_ERROR;
  }

  return ret;
}

static NPError
g_NPN_PostURL(NPP instance, const char *url, const char *target, uint32 len, const char *buf, NPBool file)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_PostURL called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }

  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  D(bugiI("NPN_PostURL instance=%p\n", instance));
  npw_plugin_instance_ref(plugin);
  NPError ret = invoke_NPN_PostURL(plugin, url, target, len, buf, file);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_PostURL return: %d [%s]\n", ret, string_of_NPError(ret)));
  return ret;
}

// Posts data to a URL, and receives notification of the result
static NPError
invoke_NPN_PostURLNotify(PluginInstance *plugin, const char *url, const char *target, uint32 len, const char *buf, NPBool file, void *notifyData)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_POST_URL_NOTIFY,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_STRING, url,
								RPC_TYPE_STRING, target,
								RPC_TYPE_ARRAY, RPC_TYPE_CHAR, len, buf,
								RPC_TYPE_BOOLEAN, file,
								RPC_TYPE_NP_NOTIFY_DATA, notifyData,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_PostURLNotify() invoke", error);
	return NPERR_GENERIC_ERROR;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_PostURLNotify() wait for reply", error);
	return NPERR_GENERIC_ERROR;
  }

  return ret;
}

static NPError
g_NPN_PostURLNotify(NPP instance, const char *url, const char *target, uint32 len, const char *buf, NPBool file, void *notifyData)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_PostURLNotify called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }
	
  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  D(bugiI("NPN_PostURLNotify instance=%p\n", instance));
  npw_plugin_instance_ref(plugin);
  NPError ret = invoke_NPN_PostURLNotify(plugin, url, target, len, buf, file, notifyData);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_PostURLNotify return: %d [%s]\n", ret, string_of_NPError(ret)));
  return ret;
}

// Posts data to a URL, and receives notification of the result
static void
g_NPN_ReloadPlugins(NPBool reloadPages)
{
  D(bug("NPN_ReloadPlugins reloadPages=%d\n", reloadPages));

  NPW_UNIMPLEMENTED();
}

// Returns the Java execution environment
static JRIEnv *
g_NPN_GetJavaEnv(void)
{
  D(bug("NPN_GetJavaEnv\n"));

  return NULL;
}

// Returns the Java object associated with the plug-in instance
static jref
g_NPN_GetJavaPeer(NPP instance)
{
  D(bug("NPN_GetJavaPeer instance=%p\n", instance));

  return NULL;
}

// Requests a range of bytes for a seekable stream
static NPError
invoke_NPN_RequestRead(NPStream *stream, NPByteRange *rangeList)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_REQUEST_READ,
								RPC_TYPE_NP_STREAM, stream,
								RPC_TYPE_NP_BYTE_RANGE, rangeList,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_RequestRead() invoke", error);
	return NPERR_GENERIC_ERROR;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_RequestRead() wait for reply", error);
	return NPERR_GENERIC_ERROR;
  }

  return ret;
}

static NPError
g_NPN_RequestRead(NPStream *stream, NPByteRange *rangeList)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_RequestRead called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }

  if (stream == NULL || stream->ndata == NULL || rangeList == NULL)
	return NPERR_INVALID_PARAM;

  D(bugiI("NPN_RequestRead stream=%p\n", stream));
  NPError ret = invoke_NPN_RequestRead(stream, rangeList);
  D(bugiD("NPN_RequestRead return: %d [%s]\n", ret, string_of_NPError(ret)));
  return ret;
}

// Sets various modes of plug-in operation
static NPError
invoke_NPN_SetValue(PluginInstance *plugin, NPPVariable variable, void *value)
{
  switch (rpc_type_of_NPPVariable(variable)) {
  case RPC_TYPE_BOOLEAN:
	break;
  default:
	npw_printf("WARNING: unhandled variable %d in NPN_SetValue()\n", variable);
	return NPERR_INVALID_PARAM;
  }

  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_SET_VALUE,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_UINT32, variable,
								RPC_TYPE_BOOLEAN, (uint32_t)(uintptr_t)value,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_SetValue() invoke", error);
	return NPERR_GENERIC_ERROR;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INT32, &ret, RPC_TYPE_INVALID);
  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_SetValue() wait for reply", error);
	return NPERR_GENERIC_ERROR;
  }
  return ret;
}

static NPError
g_NPN_SetValue(NPP instance, NPPVariable variable, void *value)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_SetValue called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }

  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  D(bugiI("NPN_SetValue instance=%p, variable=%d [%s]\n", instance, variable, string_of_NPPVariable(variable)));
  npw_plugin_instance_ref(plugin);
  NPError ret = invoke_NPN_SetValue(plugin, variable, value);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_SetValue return: %d [%s]\n", ret, string_of_NPError(ret)));
  return ret;
}

// Displays a message on the status line of the browser window
static void
invoke_NPN_Status(PluginInstance *plugin, const char *message)
{
  npw_return_if_fail(rpc_method_invoke_possible(g_rpc_connection));

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_STATUS,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_STRING, message,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_Status() invoke", error);
	return;
  }

  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_Status() wait for reply", error);
	return;
  }
}

static void
g_NPN_Status(NPP instance, const char *message)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_Status called from the wrong process\n");
	return;
  }

  PluginInstance *plugin = NULL;
  if (instance)
	plugin = PLUGIN_INSTANCE(instance);

  D(bugiI("NPN_Status instance=%p, message='%s'\n", instance, message));
  npw_plugin_instance_ref(plugin);
  invoke_NPN_Status(plugin, message);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_Status done\n"));
}

// Returns the browser's user agent field
static char *
invoke_NPN_UserAgent(void)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), NULL);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_USER_AGENT,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_UserAgent() invoke", error);
	return NULL;
  }

  char *user_agent;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_STRING, &user_agent,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_UserAgent() wait for reply", error);
	return NULL;
  }

  return user_agent;
}

static const char *
g_NPN_UserAgent(NPP instance)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_UserAgent called from the wrong process\n");
	return NULL;
  }

  D(bugiI("NPN_UserAgent instance=%p\n", instance));
  if (g_user_agent == NULL)
	g_user_agent = invoke_NPN_UserAgent();
  D(bugiD("NPN_UserAgent return: '%s'\n", g_user_agent));
  return g_user_agent;
}

// Requests the creation of a new data stream produced by the plug-in and consumed by the browser
static NPError
invoke_NPN_NewStream(PluginInstance *plugin, NPMIMEType type, const char *target, NPStream **pstream)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_NEW_STREAM,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_STRING, type,
								RPC_TYPE_STRING, target,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_NewStream() invoke", error);
	return NPERR_OUT_OF_MEMORY_ERROR;
  }

  int32_t ret;
  uint32_t stream_id;
  char *url;
  uint32_t end;
  uint32_t lastmodified;
  void *notifyData;
  char *headers;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_INT32, &ret,
									RPC_TYPE_UINT32, &stream_id,
									RPC_TYPE_STRING, &url,
									RPC_TYPE_UINT32, &end,
									RPC_TYPE_UINT32, &lastmodified,
									RPC_TYPE_NP_NOTIFY_DATA, &notifyData,
									RPC_TYPE_STRING, &headers,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_NewStream() wait for reply", error);
	return NPERR_GENERIC_ERROR;
  }

  NPStream *stream = NULL;
  if (ret == NPERR_NO_ERROR) {
	if ((stream = malloc(sizeof(*stream))) == NULL)
	  return NPERR_OUT_OF_MEMORY_ERROR;
	memset(stream, 0, sizeof(*stream));

	StreamInstance *stream_ndata;
	if ((stream_ndata = malloc(sizeof(*stream_ndata))) == NULL) {
	  free(stream);
	  return NPERR_OUT_OF_MEMORY_ERROR;
	}
	stream->ndata = stream_ndata;
	stream->url = url;
	stream->end = end;
	stream->lastmodified = lastmodified;
	stream->notifyData = notifyData;
	stream->headers = headers;
	memset(stream_ndata, 0, sizeof(*stream_ndata));
	stream_ndata->stream_id = stream_id;
	id_link(stream_id, stream_ndata);
	stream_ndata->stream = stream;
	stream_ndata->is_plugin_stream = 1;
  }
  else {
	if (url)
	  free(url);
	if (headers)
	  free(headers);
  }
  *pstream = stream;

  return ret;
}

static NPError
g_NPN_NewStream(NPP instance, NPMIMEType type, const char *target, NPStream **stream)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_NewStream called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }

  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  if (stream == NULL)
	return NPERR_INVALID_PARAM;
  *stream = NULL;

  D(bugiI("NPN_NewStream instance=%p\n", instance));
  npw_plugin_instance_ref(plugin);
  NPError ret = invoke_NPN_NewStream(plugin, type, target, stream);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_NewStream return: %d [%s]\n", ret, string_of_NPError(ret)));
  return ret;
}

// Closes and deletes a stream
static NPError
invoke_NPN_DestroyStream(PluginInstance *plugin, NPStream *stream, NPError reason)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 NPERR_GENERIC_ERROR);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_DESTROY_STREAM,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_STREAM, stream,
								RPC_TYPE_INT32, (int32_t)reason,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_DestroyStream() invoke", error);
	return NPERR_GENERIC_ERROR;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_INT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_DestroyStream() wait for reply", error);
	return NPERR_GENERIC_ERROR;
  }

  return ret;
}

static NPError
g_NPN_DestroyStream(NPP instance, NPStream *stream, NPError reason)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_DestroyStream called from the wrong process\n");
	return NPERR_INVALID_INSTANCE_ERROR;
  }
  
  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  if (stream == NULL)
	return NPERR_INVALID_PARAM;

  D(bugiI("NPN_DestroyStream instance=%p, stream=%p, reason=%s\n",
		instance, stream, string_of_NPReason(reason)));
  npw_plugin_instance_ref(plugin);
  NPError ret = invoke_NPN_DestroyStream(plugin, stream, reason);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_DestroyStream return: %d [%s]\n", ret, string_of_NPError(ret)));

  // Mozilla calls NPP_DestroyStream() for its streams, keep stream
  // info in that case
  StreamInstance *stream_ndata = stream->ndata;
  if (stream_ndata && stream_ndata->is_plugin_stream) {
	id_remove(stream_ndata->stream_id);
	free(stream_ndata);
	free((char *)stream->url);
	free((char *)stream->headers);
	free(stream);
  }

  return ret;
}

// Pushes data into a stream produced by the plug-in and consumed by the browser
static int
invoke_NPN_Write(PluginInstance *plugin, NPStream *stream, int32 len, void *buf)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), -1);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_WRITE,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_STREAM, stream,
								RPC_TYPE_ARRAY, RPC_TYPE_CHAR, len, buf,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_Write() invoke", error);
	return -1;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_INT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_Write() wait for reply", error);
	return -1;
  }

  return ret;
}

static int32
g_NPN_Write(NPP instance, NPStream *stream, int32 len, void *buf)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_Write called from the wrong process\n");
	return -1;
  }
  
  if (instance == NULL)
	return -1;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return -1;

  if (stream == NULL)
	return -1;

  D(bugiI("NPN_Write instance=%p, stream=%p, len=%d, buf=%p\n", instance, stream, len, buf));
  npw_plugin_instance_ref(plugin);
  int32 ret = invoke_NPN_Write(plugin, stream, len, buf);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_Write return: %d\n", ret));
  return ret;
}

// Enable popups while executing code where popups should be enabled
static void
invoke_NPN_PushPopupsEnabledState(PluginInstance *plugin, NPBool enabled)
{
  npw_return_if_fail(rpc_method_invoke_possible(g_rpc_connection));

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_PUSH_POPUPS_ENABLED_STATE,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_UINT32, (uint32_t)enabled,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_PushPopupsEnabledState() invoke", error);
	return;
  }

  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INVALID);
  
  if (error != RPC_ERROR_NO_ERROR)
	npw_perror("NPN_PushPopupsEnabledState() wait for reply", error);
}

static void
g_NPN_PushPopupsEnabledState(NPP instance, NPBool enabled)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_PushPopupsEnabledState called from the wrong process\n");
	return;
  }

  if (instance == NULL)
	return;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return;

  D(bugiI("NPN_PushPopupsEnabledState instance=%p, enabled=%d\n", instance, enabled));
  npw_plugin_instance_ref(plugin);
  invoke_NPN_PushPopupsEnabledState(plugin, enabled);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_PushPopupsEnabledState done\n"));
}

// Restore popups state
static void
invoke_NPN_PopPopupsEnabledState(PluginInstance *plugin)
{
  npw_return_if_fail(rpc_method_invoke_possible(g_rpc_connection));

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_POP_POPUPS_ENABLED_STATE,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_PopPopupsEnabledState() invoke", error);
	return;
  }

  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INVALID);
  
  if (error != RPC_ERROR_NO_ERROR)
	npw_perror("NPN_PopPopupsEnabledState() wait for reply", error);
}

static void
g_NPN_PopPopupsEnabledState(NPP instance)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_PophPopupsEnabledState called from the wrong process\n");
	return;
  }

  if (instance == NULL)
	return;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return;

  D(bugiI("NPN_PopPopupsEnabledState instance=%p\n", instance));
  npw_plugin_instance_ref(plugin);
  invoke_NPN_PopPopupsEnabledState(plugin);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_PopPopupsEnabledState done\n"));
}


/* ====================================================================== */
/* === NPRuntime glue                                                 === */
/* ====================================================================== */

// Allocates a new NPObject
static uint32_t
invoke_NPN_CreateObject(PluginInstance *plugin)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), 0);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_CREATE_OBJECT,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_CreateObject() invoke", error);
	return 0;
  }

  uint32_t npobj_id = 0;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &npobj_id,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_CreateObject() wait for reply", error);
	return 0;
  }

  return npobj_id;
}

static NPObject *
g_NPN_CreateObject(NPP instance, NPClass *class)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_CreateObject called from the wrong process\n");
	return NULL;
  }
  
  if (instance == NULL)
	return NULL;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NULL;

  if (class == NULL)
	return NULL;

  D(bugiI("NPN_CreateObject\n"));
  npw_plugin_instance_ref(plugin);
  uint32_t npobj_id = invoke_NPN_CreateObject(plugin);
  npw_plugin_instance_unref(plugin);
  assert(npobj_id != 0);
  NPObject *npobj = npobject_new(npobj_id, instance, class);
  D(bugiD("NPN_CreateObject return: %p (refcount: %d)\n", npobj, npobj->referenceCount));
  return npobj;
}

// Increments the reference count of the given NPObject
static uint32_t
invoke_NPN_RetainObject(NPObject *npobj)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 npobj->referenceCount);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_RETAIN_OBJECT,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_RetainObject() invoke", error);
	return npobj->referenceCount;
  }

  uint32_t refcount;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_UINT32, &refcount, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_RetainObject() wait for reply", error);
	return npobj->referenceCount;
  }

  return refcount;
}

static NPObject *
g_NPN_RetainObject(NPObject *npobj)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_RetainObject called from the wrong process\n");
	return NULL;
  }
	
  if (npobj == NULL)
	return NULL;

  D(bugiI("NPN_RetainObject npobj=%p\n", npobj));
  uint32_t refcount = invoke_NPN_RetainObject(npobj);
  D(bugiD("NPN_RetainObject return: %p (refcount: %d)\n", npobj, refcount));
  npobj->referenceCount = refcount;
  return npobj;
}

// Decrements the reference count of the give NPObject
static uint32_t
invoke_NPN_ReleaseObject(NPObject *npobj)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection),
						 npobj->referenceCount);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_RELEASE_OBJECT,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_ReleaseObject() invoke", error);
	return npobj->referenceCount;
  }

  uint32_t refcount;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_UINT32, &refcount, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_ReleaseObject() wait for reply", error);
	return npobj->referenceCount;
  }

  return refcount;
}

static void
g_NPN_ReleaseObject_Now(NPObject *npobj)
{
  D(bugiI("NPN_ReleaseObject npobj=%p\n", npobj));
  uint32_t refcount = invoke_NPN_ReleaseObject(npobj);
  D(bugiD("NPN_ReleaseObject done (refcount: %d)\n", refcount));

  if ((npobj->referenceCount = refcount) == 0)
	npobject_destroy(npobj);
}

static void
g_NPN_ReleaseObject_Delayed(NPObject *npobj)
{
  delayed_calls_add(RPC_DELAYED_NPN_RELEASE_OBJECT, npobj);
}

static void
g_NPN_ReleaseObject(NPObject *npobj)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_ReleaseObject called from the wrong process\n");
	return;
  }
	
  if (npobj == NULL)
	return;

  if (rpc_method_invoke_possible(g_rpc_connection)) {
	D(bug("NPN_ReleaseObject <now>\n"));
	g_NPN_ReleaseObject_Now(npobj);
  }
  else {
	D(bug("NPN_ReleaseObject <delayed>\n"));
	g_NPN_ReleaseObject_Delayed(npobj);
  }
}

// Invokes a method on the given NPObject
static bool
invoke_NPN_Invoke(PluginInstance *plugin, NPObject *npobj, NPIdentifier methodName,
				  const NPVariant *args, uint32_t argCount, NPVariant *result)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_INVOKE,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, methodName,
								RPC_TYPE_ARRAY, RPC_TYPE_NP_VARIANT, argCount, args,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_Invoke() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_NP_VARIANT, result,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_Invoke() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_Invoke(NPP instance, NPObject *npobj, NPIdentifier methodName,
			 const NPVariant *args, uint32_t argCount, NPVariant *result)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_Invoke called from the wrong process\n");
	return false;
  }

  if (instance == NULL)
	return false;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return false;
	
  if (!npobj || !npobj->_class || !npobj->_class->invoke)
	return false;

  D(bugiI("NPN_Invoke instance=%p, npobj=%p, methodName=%p\n", instance, npobj, methodName));
  print_npvariant_args(args, argCount);
  npw_plugin_instance_ref(plugin);
  bool ret = invoke_NPN_Invoke(plugin, npobj, methodName, args, argCount, result);
  npw_plugin_instance_unref(plugin);
  gchar *result_str = string_of_NPVariant(result);
  D(bugiD("NPN_Invoke return: %d (%s)\n", ret, result_str));
  g_free(result_str);
  return ret;
}

// Invokes the default method on the given NPObject
static bool
invoke_NPN_InvokeDefault(PluginInstance *plugin, NPObject *npobj,
						 const NPVariant *args, uint32_t argCount, NPVariant *result)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_INVOKE_DEFAULT,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_ARRAY, RPC_TYPE_NP_VARIANT, argCount, args,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_InvokeDefault() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_NP_VARIANT, result,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_InvokeDefault() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_InvokeDefault(NPP instance, NPObject *npobj,
					const NPVariant *args, uint32_t argCount, NPVariant *result)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_InvokeDefault called from the wrong process\n");
	return false;
  }

  if (instance == NULL)
	return false;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return false;

  if (!npobj || !npobj->_class || !npobj->_class->invokeDefault)
	return false;

  D(bugiI("NPN_InvokeDefault instance=%p, npobj=%p\n", instance, npobj));
  print_npvariant_args(args, argCount);
  npw_plugin_instance_ref(plugin);
  bool ret = invoke_NPN_InvokeDefault(plugin, npobj, args, argCount, result);
  npw_plugin_instance_unref(plugin);
  gchar *result_str = string_of_NPVariant(result);
  D(bugiD("NPN_InvokeDefault return: %d (%s)\n", ret, result_str));
  g_free(result_str);
  return ret;
}

// Evaluates a script on the scope of a given NPObject
static bool
invoke_NPN_Evaluate(PluginInstance *plugin, NPObject *npobj, NPString *script, NPVariant *result)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_EVALUATE,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_STRING, script,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_Evaluate() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_NP_VARIANT, result,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_Evaluate() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_Evaluate(NPP instance, NPObject *npobj, NPString *script, NPVariant *result)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_Evaluate called from the wrong process\n");
	return false;
  }

  if (instance == NULL)
	return false;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return false;

  if (!npobj)
	return false;

  if (!script || !script->utf8length || !script->utf8characters)
	return true; // nothing to evaluate

  D(bugiI("NPN_Evaluate instance=%p, npobj=%p\n", instance, npobj));
  npw_plugin_instance_ref(plugin);
  bool ret = invoke_NPN_Evaluate(plugin, npobj, script, result);
  npw_plugin_instance_unref(plugin);
  gchar *result_str = string_of_NPVariant(result);
  D(bugiD("NPN_Evaluate return: %d (%s)\n", ret, result_str));
  g_free(result_str);
  return ret;
}

// Gets the value of a property on the given NPObject
static bool
invoke_NPN_GetProperty(PluginInstance *plugin, NPObject *npobj, NPIdentifier propertyName,
					   NPVariant *result)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_GET_PROPERTY,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, propertyName,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetProperty() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_NP_VARIANT, result,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetProperty() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_GetProperty(NPP instance, NPObject *npobj, NPIdentifier propertyName,
				  NPVariant *result)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_GetProperty called from the wrong process\n");
	return false;
  }

  if (instance == NULL)
	return false;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return false;

  if (!npobj || !npobj->_class || !npobj->_class->getProperty)
	return false;

  D(bugiI("NPN_GetProperty instance=%p, npobj=%p, propertyName=%p\n", instance, npobj, propertyName));
  npw_plugin_instance_ref(plugin);
  bool ret = invoke_NPN_GetProperty(plugin, npobj, propertyName, result);
  npw_plugin_instance_unref(plugin);
  gchar *result_str = string_of_NPVariant(result);
  D(bugiD("NPN_GetProperty return: %d (%s)\n", ret, result_str));
  g_free(result_str);
  return ret;
}

// Sets the value of a property on the given NPObject
static bool
invoke_NPN_SetProperty(PluginInstance *plugin, NPObject *npobj, NPIdentifier propertyName,
					   const NPVariant *value)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_SET_PROPERTY,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, propertyName,
								RPC_TYPE_NP_VARIANT, value,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_SetProperty() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_SetProperty() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_SetProperty(NPP instance, NPObject *npobj, NPIdentifier propertyName,
				  const NPVariant *value)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_SetProperty called from the wrong process\n");
	return false;
  }

  if (instance == NULL)
	return false;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return false;

  if (!npobj || !npobj->_class || !npobj->_class->setProperty)
	return false;

  D(bugiI("NPN_SetProperty instance=%p, npobj=%p, propertyName=%p\n", instance, npobj, propertyName));
  npw_plugin_instance_ref(plugin);
  bool ret = invoke_NPN_SetProperty(plugin, npobj, propertyName, value);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_SetProperty return: %d\n", ret));
  return ret;
}

// Removes a property on the given NPObject
static bool
invoke_NPN_RemoveProperty(PluginInstance *plugin, NPObject *npobj, NPIdentifier propertyName)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_REMOVE_PROPERTY,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, propertyName,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_RemoveProperty() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_RemoveProperty() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_RemoveProperty(NPP instance, NPObject *npobj, NPIdentifier propertyName)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_RemoveProperty called from the wrong process\n");
	return false;
  }

  if (instance == NULL)
	return false;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return false;

  if (!npobj || !npobj->_class || !npobj->_class->removeProperty)
	return false;

  D(bugiI("NPN_RemoveProperty instance=%p, npobj=%p, propertyName=%p\n", instance, npobj, propertyName));
  npw_plugin_instance_ref(plugin);
  bool ret = invoke_NPN_RemoveProperty(plugin, npobj, propertyName);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_RemoveProperty return: %d\n", ret));
  return ret;
}

// Checks if a given property exists on the given NPObject
static bool
invoke_NPN_HasProperty(PluginInstance *plugin, NPObject *npobj, NPIdentifier propertyName)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_HAS_PROPERTY,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, propertyName,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_HasProperty() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_HasProperty() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_HasProperty(NPP instance, NPObject *npobj, NPIdentifier propertyName)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_HasProperty called from the wrong process\n");
	return false;
  }

  if (instance == NULL)
	return false;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return false;

  if (!npobj || !npobj->_class || !npobj->_class->hasProperty)
	return false;

  D(bugiI("NPN_HasProperty instance=%p, npobj=%p, propertyName=%p\n", instance, npobj, propertyName));
  npw_plugin_instance_ref(plugin);
  bool ret = invoke_NPN_HasProperty(plugin, npobj, propertyName);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_HasProperty return: %d\n", ret));
  return ret;
}

// Checks if a given method exists on the given NPObject
static bool
invoke_NPN_HasMethod(PluginInstance *plugin, NPObject *npobj, NPIdentifier methodName)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_HAS_METHOD,
								RPC_TYPE_NPW_PLUGIN_INSTANCE, plugin,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, methodName,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_HasMethod() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_HasMethod() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_HasMethod(NPP instance, NPObject *npobj, NPIdentifier methodName)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_HasMethod called from the wrong process\n");
	return false;
  }

  if (instance == NULL)
	return false;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return false;

  if (!npobj || !npobj->_class || !npobj->_class->hasMethod)
	return false;

  D(bugiI("NPN_HasMethod instance=%p, npobj=%p, methodName=%p\n", instance, npobj, methodName));
  npw_plugin_instance_ref(plugin);
  bool ret = invoke_NPN_HasMethod(plugin, npobj, methodName);
  npw_plugin_instance_unref(plugin);
  D(bugiD("NPN_HasMethod return: %d\n", ret));
  return ret;
}

// Indicates that a call to one of the plugins NPObjects generated an error
static void
invoke_NPN_SetException(NPObject *npobj, const NPUTF8 *message)
{
  npw_return_if_fail(rpc_method_invoke_possible(g_rpc_connection));

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_SET_EXCEPTION,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_STRING, message,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_SetException() invoke", error);
	return;
  }

  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_SetException() wait for reply", error);
	return;
  }
}

static void
g_NPN_SetException(NPObject *npobj, const NPUTF8 *message)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_SetException called from the wrong process\n");
	return;
  }

  D(bugiI("NPN_SetException npobj=%p, message='%s'\n", npobj, message));
  invoke_NPN_SetException(npobj, message);
  D(bugiD("NPN_SetException done\n"));
}

// Releases the value in the given variant
static void
g_NPN_ReleaseVariantValue(NPVariant *variant)
{
  D(bugiI("NPN_ReleaseVariantValue\n"));
  npvariant_clear(variant);
  D(bugiD("NPN_ReleaseVariantValue done\n"));
}

// Returns an opaque identifier for the string that is passed in
static NPIdentifier
invoke_NPN_GetStringIdentifier(const NPUTF8 *name)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), NULL);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_GET_STRING_IDENTIFIER,
								RPC_TYPE_STRING, name,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetStringIdentifier() invoke", error);
	return NULL;
  }

  NPIdentifier ident;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_NP_IDENTIFIER, &ident,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetStringIdentifier() wait for reply", error);
	return NULL;
  }

  return ident;
}

static NPIdentifier
g_NPN_GetStringIdentifier(const NPUTF8 *name)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_GetStringIdentifier called from the wrong process\n");
	return NULL;
  }

  if (name == NULL)
	return NULL;

  D(bugiI("NPN_GetStringIdentifier name='%s'\n", name));
  NPIdentifier ret = invoke_NPN_GetStringIdentifier(name);
  D(bugiD("NPN_GetStringIdentifier return: %p\n", ret));
  return ret;
}

// Returns an array of opaque identifiers for the names that are passed in
static void
invoke_NPN_GetStringIdentifiers(const NPUTF8 **names, uint32_t nameCount, NPIdentifier *identifiers)
{
  npw_return_if_fail(rpc_method_invoke_possible(g_rpc_connection));

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_GET_STRING_IDENTIFIERS,
								RPC_TYPE_ARRAY, RPC_TYPE_STRING, nameCount, names,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetStringIdentifiers() invoke", error);
	return;
  }

  uint32_t n_idents;
  NPIdentifier *idents;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_ARRAY, RPC_TYPE_NP_IDENTIFIER, &n_idents, &idents,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetStringIdentifiers() wait for reply", error);
	return;
  }

  if (identifiers) {
	if (n_idents != nameCount) {
	  npw_printf("ERROR: NPN_GetStringIdentifiers returned fewer NPIdentifiers than expected\n");
	  if (n_idents > nameCount)
		n_idents = nameCount;
	}
	for (int i = 0; i < n_idents; i++)
	  identifiers[i] = idents[i];
	free(idents);
  }
}

static void
g_NPN_GetStringIdentifiers(const NPUTF8 **names, uint32_t nameCount, NPIdentifier *identifiers)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_GetStringIdentifiers called from the wrong process\n");
	return;
  }

  if (names == NULL)
	return;

  if (identifiers == NULL)
	return;

  D(bugiI("NPN_GetStringIdentifiers names=%p\n", names));
  invoke_NPN_GetStringIdentifiers(names, nameCount, identifiers);
  D(bugiD("NPN_GetStringIdentifiers done\n"));
}

// Returns an opaque identifier for the integer that is passed in
static NPIdentifier
invoke_NPN_GetIntIdentifier(int32_t intid)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), NULL);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_GET_INT_IDENTIFIER,
								RPC_TYPE_INT32, intid,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetIntIdentifier() invoke", error);
	return NULL;
  }

  NPIdentifier ident;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_NP_IDENTIFIER, &ident,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_GetIntIdentifier() wait for reply", error);
	return NULL;
  }

  return ident;
}

static NPIdentifier
g_NPN_GetIntIdentifier(int32_t intid)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_GetIntIdentifier called from the wrong process\n");
	return NULL;
  }

  D(bugiI("NPN_GetIntIdentifier intid=%d\n", intid));
  NPIdentifier ret = invoke_NPN_GetIntIdentifier(intid);
  D(bugiD("NPN_GetIntIdentifier return: %p\n", ret));
  return ret;
}

// Returns true if the given identifier is a string identifier, or false if it is an integer identifier
static bool
invoke_NPN_IdentifierIsString(NPIdentifier identifier)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_IDENTIFIER_IS_STRING,
								RPC_TYPE_NP_IDENTIFIER, identifier,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_IdentifierIsString() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_IdentifierIsString() wait for reply", error);
	return false;
  }

  return ret;
}

static bool
g_NPN_IdentifierIsString(NPIdentifier identifier)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_IdentifierIsString called from the wrong process\n");
	return false;
  }
  
  D(bugiI("NPN_IdentifierIsString identifier=%p\n", identifier));
  bool ret = invoke_NPN_IdentifierIsString(identifier);
  D(bugiD("NPN_IdentifierIsString return: %d\n", ret));
  return ret;
}

// Returns a pointer to a UTF-8 string as a sequence of 8-bit units (NPUTF8)
static NPUTF8 *
invoke_NPN_UTF8FromIdentifier(NPIdentifier identifier)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), NULL);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_UTF8_FROM_IDENTIFIER,
								RPC_TYPE_NP_IDENTIFIER, identifier,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_UTF8FromIdentifier() invoke", error);
	return NULL;
  }

  NPUTF8 *str;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_NP_UTF8, &str,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_UTF8FromIdentifier() wait for reply", error);
	return NULL;
  }

  return str;
}

static NPUTF8 *
g_NPN_UTF8FromIdentifier(NPIdentifier identifier)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_UTF8FromIdentifier called from the wrong process\n");
	return NULL;
  }

  D(bugiI("NPN_UTF8FromIdentifier identifier=%p\n", identifier));
  NPUTF8 *ret = invoke_NPN_UTF8FromIdentifier(identifier);
  D(bugiD("NPN_UTF8FromIdentifier return: '%s'\n", ret));
  return ret;
}

// Returns the integer value for the given integer identifier
// NOTE: if the given identifier is not a integer identifier, the behavior is undefined (we return -1)
static int32_t
invoke_NPN_IntFromIdentifier(NPIdentifier identifier)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), -1);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_INT_FROM_IDENTIFIER,
								RPC_TYPE_NP_IDENTIFIER, identifier,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_IntFromIdentifier() invoke", error);
	return -1;
  }

  int32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_INT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_IntFromIdentifier() wait for reply", error);
	return -1;
  }

  return ret;
}

static int32_t
g_NPN_IntFromIdentifier(NPIdentifier identifier)
{
  if (!pid_check()) {
	npw_printf("WARNING: NPN_IntFromIdentifier called from the wrong process\n");
	return 0;
  }
  
  D(bugiI("NPN_IntFromIdentifier identifier=%p\n", identifier));
  int32_t ret = invoke_NPN_IntFromIdentifier(identifier);
  D(bugiD("NPN_IntFromIdentifier return: %d\n", ret));
  return ret;
}


/* ====================================================================== */
/* === Plug-in side data                                              === */
/* ====================================================================== */

// Functions supplied by the plug-in
static NPPluginFuncs plugin_funcs;

// Allows the browser to query the plug-in supported formats
typedef char * (*NP_GetMIMEDescriptionUPP)(void);
static NP_GetMIMEDescriptionUPP g_plugin_NP_GetMIMEDescription = NULL;

// Allows the browser to query the plug-in for information
typedef NPError (*NP_GetValueUPP)(void *instance, NPPVariable variable, void *value);
static NP_GetValueUPP g_plugin_NP_GetValue = NULL;

// Provides global initialization for a plug-in
typedef NPError (*NP_InitializeUPP)(NPNetscapeFuncs *moz_funcs, NPPluginFuncs *plugin_funcs);
static NP_InitializeUPP g_plugin_NP_Initialize = NULL;

// Provides global deinitialization for a plug-in
typedef NPError (*NP_ShutdownUPP)(void);
static NP_ShutdownUPP g_plugin_NP_Shutdown = NULL;


/* ====================================================================== */
/* === RPC communication                                              === */
/* ====================================================================== */

// NP_GetMIMEDescription
static char *
g_NP_GetMIMEDescription(void)
{
  if (g_plugin_NP_GetMIMEDescription == NULL)
	return NULL;

  D(bugiI("NP_GetMIMEDescription\n"));
  char *str = g_plugin_NP_GetMIMEDescription();
  D(bugiD("NP_GetMIMEDescription return: %s\n", str ? str : "<empty>"));
  return str;
}

static int handle_NP_GetMIMEDescription(rpc_connection_t *connection)
{
  D(bug("handle_NP_GetMIMEDescription\n"));

  int error = rpc_method_get_args(connection, RPC_TYPE_INVALID);
  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NP_GetMIMEDescription() get args", error);
	return error;
  }

  char *str = g_NP_GetMIMEDescription();
  return rpc_method_send_reply(connection, RPC_TYPE_STRING, str, RPC_TYPE_INVALID);
}

// NP_GetValue
static NPError
g_NP_GetValue(NPPVariable variable, void *value)
{
  if (g_plugin_NP_GetValue == NULL)
	return NPERR_INVALID_FUNCTABLE_ERROR;

  D(bugiI("NP_GetValue variable=%d [%s]\n", variable, string_of_NPPVariable(variable)));
  NPError ret = g_plugin_NP_GetValue(NULL, variable, value);
  D(bugiD("NP_GetValue return: %d\n", ret));
  return ret;
}

static int handle_NP_GetValue(rpc_connection_t *connection)
{
  D(bug("handle_NP_GetValue\n"));

  int32_t variable;
  int error = rpc_method_get_args(connection, RPC_TYPE_INT32, &variable, RPC_TYPE_INVALID);
  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NP_GetValue() get args", error);
	return error;
  }

  NPError ret = NPERR_GENERIC_ERROR;
  int variable_type = rpc_type_of_NPPVariable(variable);

  switch (variable_type) {
  case RPC_TYPE_STRING:
	{
	  char *str = NULL;
	  ret = g_NP_GetValue(variable, (void *)&str);
	  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_STRING, str, RPC_TYPE_INVALID);
	}
  case RPC_TYPE_INT32:
	{
	  uint32_t n = 0;
	  ret = g_NP_GetValue(variable, (void *)&n);
	  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INT32, n, RPC_TYPE_INVALID);
	}
  case RPC_TYPE_BOOLEAN:
	{
	  PRBool b = PR_FALSE;
	  ret = g_NP_GetValue(variable, (void *)&b);
	  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_BOOLEAN, b, RPC_TYPE_INVALID);
	}
  }

  npw_printf("ERROR: only basic types are supported in NP_GetValue()\n");
  abort();
}

// NP_Initialize
static NPError
g_NP_Initialize(uint32_t version)
{
  if (g_plugin_NP_Initialize == NULL)
	return NPERR_INVALID_FUNCTABLE_ERROR;

  memset(&plugin_funcs, 0, sizeof(plugin_funcs));
  plugin_funcs.size = sizeof(plugin_funcs);

  memset(&mozilla_funcs, 0, sizeof(mozilla_funcs));
  mozilla_funcs.size = sizeof(mozilla_funcs);
  mozilla_funcs.version = version;
  mozilla_funcs.geturl = NewNPN_GetURLProc(g_NPN_GetURL);
  mozilla_funcs.posturl = NewNPN_PostURLProc(g_NPN_PostURL);
  mozilla_funcs.requestread = NewNPN_RequestReadProc(g_NPN_RequestRead);
  mozilla_funcs.newstream = NewNPN_NewStreamProc(g_NPN_NewStream);
  mozilla_funcs.write = NewNPN_WriteProc(g_NPN_Write);
  mozilla_funcs.destroystream = NewNPN_DestroyStreamProc(g_NPN_DestroyStream);
  mozilla_funcs.status = NewNPN_StatusProc(g_NPN_Status);
  mozilla_funcs.uagent = NewNPN_UserAgentProc(g_NPN_UserAgent);
  mozilla_funcs.memalloc = NewNPN_MemAllocProc(g_NPN_MemAlloc);
  mozilla_funcs.memfree = NewNPN_MemFreeProc(g_NPN_MemFree);
  mozilla_funcs.memflush = NewNPN_MemFlushProc(g_NPN_MemFlush);
  mozilla_funcs.reloadplugins = NewNPN_ReloadPluginsProc(g_NPN_ReloadPlugins);
  mozilla_funcs.getJavaEnv = NewNPN_GetJavaEnvProc(g_NPN_GetJavaEnv);
  mozilla_funcs.getJavaPeer = NewNPN_GetJavaPeerProc(g_NPN_GetJavaPeer);
  mozilla_funcs.geturlnotify = NewNPN_GetURLNotifyProc(g_NPN_GetURLNotify);
  mozilla_funcs.posturlnotify = NewNPN_PostURLNotifyProc(g_NPN_PostURLNotify);
  mozilla_funcs.getvalue = NewNPN_GetValueProc(g_NPN_GetValue);
  mozilla_funcs.setvalue = NewNPN_SetValueProc(g_NPN_SetValue);
  mozilla_funcs.invalidaterect = NewNPN_InvalidateRectProc(g_NPN_InvalidateRect);
  mozilla_funcs.invalidateregion = NewNPN_InvalidateRegionProc(g_NPN_InvalidateRegion);
  mozilla_funcs.forceredraw = NewNPN_ForceRedrawProc(g_NPN_ForceRedraw);
  mozilla_funcs.pushpopupsenabledstate = NewNPN_PushPopupsEnabledStateProc(g_NPN_PushPopupsEnabledState);
  mozilla_funcs.poppopupsenabledstate = NewNPN_PopPopupsEnabledStateProc(g_NPN_PopPopupsEnabledState);

  if (NPN_HAS_FEATURE(NPRUNTIME_SCRIPTING)) {
	D(bug(" browser supports scripting through npruntime\n"));
	mozilla_funcs.getstringidentifier = NewNPN_GetStringIdentifierProc(g_NPN_GetStringIdentifier);
	mozilla_funcs.getstringidentifiers = NewNPN_GetStringIdentifiersProc(g_NPN_GetStringIdentifiers);
	mozilla_funcs.getintidentifier = NewNPN_GetIntIdentifierProc(g_NPN_GetIntIdentifier);
	mozilla_funcs.identifierisstring = NewNPN_IdentifierIsStringProc(g_NPN_IdentifierIsString);
	mozilla_funcs.utf8fromidentifier = NewNPN_UTF8FromIdentifierProc(g_NPN_UTF8FromIdentifier);
	mozilla_funcs.intfromidentifier = NewNPN_IntFromIdentifierProc(g_NPN_IntFromIdentifier);
	mozilla_funcs.createobject = NewNPN_CreateObjectProc(g_NPN_CreateObject);
	mozilla_funcs.retainobject = NewNPN_RetainObjectProc(g_NPN_RetainObject);
	mozilla_funcs.releaseobject = NewNPN_ReleaseObjectProc(g_NPN_ReleaseObject);
	mozilla_funcs.invoke = NewNPN_InvokeProc(g_NPN_Invoke);
	mozilla_funcs.invokeDefault = NewNPN_InvokeDefaultProc(g_NPN_InvokeDefault);
	mozilla_funcs.evaluate = NewNPN_EvaluateProc(g_NPN_Evaluate);
	mozilla_funcs.getproperty = NewNPN_GetPropertyProc(g_NPN_GetProperty);
	mozilla_funcs.setproperty = NewNPN_SetPropertyProc(g_NPN_SetProperty);
	mozilla_funcs.removeproperty = NewNPN_RemovePropertyProc(g_NPN_RemoveProperty);
	mozilla_funcs.hasproperty = NewNPN_HasPropertyProc(g_NPN_HasProperty);
	mozilla_funcs.hasmethod = NewNPN_HasMethodProc(g_NPN_HasMethod);
	mozilla_funcs.releasevariantvalue = NewNPN_ReleaseVariantValueProc(g_NPN_ReleaseVariantValue);
	mozilla_funcs.setexception = NewNPN_SetExceptionProc(g_NPN_SetException);

	if (!npobject_bridge_new())
	  return NPERR_OUT_OF_MEMORY_ERROR;
  }

  // Initialize function tables
  // XXX: remove the local copies from this file
  NPW_InitializeFuncs(&mozilla_funcs, &plugin_funcs);

  D(bugiI("NP_Initialize\n"));
  NPError ret = g_plugin_NP_Initialize(&mozilla_funcs, &plugin_funcs);
  D(bugiD("NP_Initialize return: %d\n", ret));
  return ret;
}

static int handle_NP_Initialize(rpc_connection_t *connection)
{
  D(bug("handle_NP_Initialize\n"));

  uint32_t version;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_UINT32, &version,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NP_Initialize() get args", error);
	return error;
  }

  NPError ret = g_NP_Initialize(version);
  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INVALID);
}

// NP_Shutdown
static NPError
g_NP_Shutdown(void)
{
  if (g_plugin_NP_Shutdown == NULL)
	return NPERR_INVALID_FUNCTABLE_ERROR;

  D(bugiI("NP_Shutdown\n"));
  NPError ret = g_plugin_NP_Shutdown();
  D(bugiD("NP_Shutdown done\n"));

  if (NPN_HAS_FEATURE(NPRUNTIME_SCRIPTING))
	npobject_bridge_destroy();

  gtk_main_quit();

  return ret;
}

static int handle_NP_Shutdown(rpc_connection_t *connection)
{
  D(bug("handle_NP_Shutdown\n"));

  int error = rpc_method_get_args(connection, RPC_TYPE_INVALID);
  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NP_Shutdown() get args", error);
	return error;
  }

  NPError ret = g_NP_Shutdown();
  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INVALID);
}

// NPP_New
static NPError g_NPP_New(NPMIMEType plugin_type, uint32_t instance_id,
						 uint16_t mode, int16_t argc, char *argn[], char *argv[],
						 NPSavedData *saved)
{
  PluginInstance *plugin = npw_plugin_instance_new(&PluginInstanceClass);
  if (plugin == NULL)
	return NPERR_OUT_OF_MEMORY_ERROR;
  plugin->instance_id = instance_id;
  id_link(instance_id, plugin);

  NPP instance = malloc(sizeof(*instance));
  if (instance == NULL)
	return NPERR_OUT_OF_MEMORY_ERROR;
  memset(instance, 0, sizeof(*instance));
  instance->ndata = plugin;
  plugin->instance = instance;

  // check for size hints
  for (int i = 0; i < argc; i++) {
	if (argn[i] == NULL)
	  continue;
	if (strcasecmp(argn[i], "width") == 0) {
	  if (i < argc && argv[i])
		plugin->width = atoi(argv[i]);
	}
	else if (strcasecmp(argn[i], "height") == 0) {
	  if (i < argc && argv[i])
		plugin->height = atoi(argv[i]);
	}
  }

  D(bugiI("NPP_New instance=%p\n", instance));
  NPError ret = plugin_funcs.newp(plugin_type, instance, mode, argc, argn, argv, saved);
  D(bugiD("NPP_New return: %d [%s]\n", ret, string_of_NPError(ret)));

  // check if XEMBED is to be used
  PRBool supports_XEmbed = PR_FALSE;
  if (mozilla_funcs.getvalue) {
	NPError error = mozilla_funcs.getvalue(NULL, NPNVSupportsXEmbedBool, (void *)&supports_XEmbed);
	if (error == NPERR_NO_ERROR && plugin_funcs.getvalue) {
	  PRBool needs_XEmbed = PR_FALSE;
	  error = plugin_funcs.getvalue(instance, NPPVpluginNeedsXEmbed, (void *)&needs_XEmbed);
	  if (error == NPERR_NO_ERROR)
		plugin->use_xembed = supports_XEmbed && needs_XEmbed;
	}
  }
  return ret;
}

static int handle_NPP_New(rpc_connection_t *connection)
{
  D(bug("handle_NPP_New\n"));

  rpc_connection_ref(connection);

  uint32_t instance_id;
  NPMIMEType plugin_type;
  int32_t mode;
  int argn_count, argv_count;
  char **argn, **argv;
  NPSavedData *saved;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_UINT32, &instance_id,
								  RPC_TYPE_STRING, &plugin_type,
								  RPC_TYPE_INT32, &mode,
								  RPC_TYPE_ARRAY, RPC_TYPE_STRING, &argn_count, &argn,
								  RPC_TYPE_ARRAY, RPC_TYPE_STRING, &argv_count, &argv,
								  RPC_TYPE_NP_SAVED_DATA, &saved,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_New() get args", error);
	return error;
  }

  assert(argn_count == argv_count);
  NPError ret = g_NPP_New(plugin_type, instance_id, mode, argn_count, argn, argv, saved);

  if (plugin_type)
	free(plugin_type);
  if (argn) {
	for (int i = 0; i < argn_count; i++)
	  free(argn[i]);
	free(argn);
  }
  if (argv) {
	for (int i = 0; i < argv_count; i++)
	  free(argv[i]);
	free(argv);
  }

  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INVALID);
}

// NPP_Destroy
static NPError g_NPP_Destroy(NPP instance, NPSavedData **sdata)
{
  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  if (sdata)
	*sdata = NULL;

  // Process all pending calls as the data could become junk afterwards
  // XXX: this also processes delayed calls from other instances
  delayed_calls_process(plugin, TRUE);

  D(bugiI("NPP_Destroy instance=%p\n", instance));
  NPError ret = plugin_funcs.destroy(instance, sdata);
  D(bugiD("NPP_Destroy return: %d [%s]\n", ret, string_of_NPError(ret)));

  npw_plugin_instance_invalidate(plugin);
  npw_plugin_instance_unref(plugin);
  return ret;
}

static int handle_NPP_Destroy(rpc_connection_t *connection)
{
  D(bug("handle_NPP_Destroy\n"));

  int error;
  PluginInstance *plugin;
  error = rpc_method_get_args(connection,
							  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
							  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_Destroy() get args", error);
	return error;
  }

  NPSavedData *save_area;
  NPError ret = g_NPP_Destroy(PLUGIN_INSTANCE_NPP(plugin), &save_area);

  error = rpc_method_send_reply(connection,
								RPC_TYPE_INT32, ret,
								RPC_TYPE_NP_SAVED_DATA, save_area,
								RPC_TYPE_INVALID);

  rpc_connection_unref(connection);
  return error;
}

// NPP_SetWindow
static NPError
g_NPP_SetWindow(NPP instance, NPWindow *np_window)
{
  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  PluginInstance *plugin = PLUGIN_INSTANCE(instance);
  if (plugin == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  if (plugin_funcs.setwindow == NULL)
	return NPERR_INVALID_FUNCTABLE_ERROR;

  plugin->is_windowless = np_window && np_window->type == NPWindowTypeDrawable;

  NPWindow *window = np_window;
  if (window && (window->window || plugin->is_windowless)) {
	if (plugin->toolkit_data) {
	  if (update_window(plugin, window) < 0)
		return NPERR_GENERIC_ERROR;
	}
	else {
	  if (create_window(plugin, window) < 0)
		return NPERR_GENERIC_ERROR;
	}
	window = &plugin->window;
  }

  D(bugiI("NPP_SetWindow instance=%p, window=%p\n", instance, window ? window->window : NULL));
  NPError ret = plugin_funcs.setwindow(instance, window);
  D(bugiD("NPP_SetWindow return: %d [%s]\n", ret, string_of_NPError(ret)));

  if (np_window == NULL || (np_window->window == NULL && !plugin->is_windowless))
	destroy_window(plugin);

  return ret;
}

static int handle_NPP_SetWindow(rpc_connection_t *connection)
{
  D(bug("handle_NPP_SetWindow\n"));

  int error;
  PluginInstance *plugin;
  NPWindow *window;

  error = rpc_method_get_args(connection,
							  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
							  RPC_TYPE_NP_WINDOW, &window,
							  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_SetWindow() get args", error);
	return error;
  }

  NPError ret = g_NPP_SetWindow(PLUGIN_INSTANCE_NPP(plugin), window);

  if (window) {
	if (window->ws_info) {
	  free(window->ws_info);
	  window->ws_info = NULL;
	}
	free(window);
  }

  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INVALID);
}

// NPP_GetValue
static NPError
g_NPP_GetValue(NPP instance, NPPVariable variable, void *value)
{
  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  if (plugin_funcs.getvalue == NULL)
	return NPERR_INVALID_FUNCTABLE_ERROR;

  D(bugiI("NPP_GetValue instance=%p, variable=%d [%s]\n", instance, variable, string_of_NPPVariable(variable)));
  NPError ret = plugin_funcs.getvalue(instance, variable, value);
  D(bugiD("NPP_GetValue return: %d [%s]\n", ret, string_of_NPError(ret)));
  return ret;
}

static int handle_NPP_GetValue(rpc_connection_t *connection)
{
  D(bug("handle_NPP_GetValue\n"));

  int error;
  PluginInstance *plugin;
  int32_t variable;

  error = rpc_method_get_args(connection,
							  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
							  RPC_TYPE_INT32, &variable,
							  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_printf("ERROR: could not get NPP_GetValue variable\n");
	return error;
  }

  NPError ret = NPERR_GENERIC_ERROR;
  int variable_type = rpc_type_of_NPPVariable(variable);

  switch (variable_type) {
  case RPC_TYPE_STRING:
	{
	  char *str = NULL;
	  ret = g_NPP_GetValue(PLUGIN_INSTANCE_NPP(plugin), variable, (void *)&str);
	  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_STRING, str, RPC_TYPE_INVALID);
	}
  case RPC_TYPE_INT32:
	{
	  uint32_t n = 0;
	  ret = g_NPP_GetValue(PLUGIN_INSTANCE_NPP(plugin), variable, (void *)&n);
	  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INT32, n, RPC_TYPE_INVALID);
	}
  case RPC_TYPE_BOOLEAN:
	{
	  PRBool b = PR_FALSE;
	  ret = g_NPP_GetValue(PLUGIN_INSTANCE_NPP(plugin), variable, (void *)&b);
	  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_BOOLEAN, b, RPC_TYPE_INVALID);
	}
  case RPC_TYPE_NP_OBJECT:
	{
	  NPObject *npobj = NULL;
	  ret = g_NPP_GetValue(PLUGIN_INSTANCE_NPP(plugin), variable, (void *)&npobj);
	  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_NP_OBJECT, npobj, RPC_TYPE_INVALID);
	}
  }

  abort();
}

// NPP_URLNotify
static void
g_NPP_URLNotify(NPP instance, const char *url, NPReason reason, void *notifyData)
{
  if (instance == NULL)
	return;

  if (plugin_funcs.urlnotify == NULL)
	return;

  D(bugiI("NPP_URLNotify instance=%p, url='%s', reason=%s, notifyData=%p\n",
		instance, url, string_of_NPReason(reason), notifyData));
  plugin_funcs.urlnotify(instance, url, reason, notifyData);
  D(bugiD("NPP_URLNotify done\n"));
}

static int handle_NPP_URLNotify(rpc_connection_t *connection)
{
  D(bug("handle_NPP_URLNotify\n"));

  int error;
  PluginInstance *plugin;
  char *url;
  int32_t reason;
  void *notifyData;

  error = rpc_method_get_args(connection,
							  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
							  RPC_TYPE_STRING, &url,
							  RPC_TYPE_INT32, &reason,
							  RPC_TYPE_NP_NOTIFY_DATA, &notifyData,
							  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_URLNotify() get args", error);
	return error;
  }

  g_NPP_URLNotify(PLUGIN_INSTANCE_NPP(plugin), url, reason, notifyData);

  if (url)
	free(url);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

// NPP_NewStream
static NPError
g_NPP_NewStream(NPP instance, NPMIMEType type, NPStream *stream, NPBool seekable, uint16 *stype)
{
  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  if (plugin_funcs.newstream == NULL)
	return NPERR_INVALID_FUNCTABLE_ERROR;

  D(bugiI("NPP_NewStream instance=%p, stream=%p, url='%s', type='%s', seekable=%d, stype=%s, notifyData=%p\n",
		instance, stream, stream->url, type, seekable, string_of_NPStreamType(*stype), stream->notifyData));
  NPError ret = plugin_funcs.newstream(instance, type, stream, seekable, stype);
  D(bugiD("NPP_NewStream return: %d [%s], stype=%s\n", ret, string_of_NPError(ret), string_of_NPStreamType(*stype)));
  return ret;
}

static int handle_NPP_NewStream(rpc_connection_t *connection)
{
  D(bug("handle_NPP_NewStream\n"));

  int error;
  PluginInstance *plugin;
  uint32_t stream_id;
  uint32_t seekable;
  NPMIMEType type;

  NPStream *stream;
  if ((stream = malloc(sizeof(*stream))) == NULL)
	return RPC_ERROR_NO_MEMORY;
  memset(stream, 0, sizeof(*stream));

  error = rpc_method_get_args(connection,
							  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
							  RPC_TYPE_STRING, &type,
							  RPC_TYPE_UINT32, &stream_id,
							  RPC_TYPE_STRING, &stream->url,
							  RPC_TYPE_UINT32, &stream->end,
							  RPC_TYPE_UINT32, &stream->lastmodified,
							  RPC_TYPE_NP_NOTIFY_DATA, &stream->notifyData,
							  RPC_TYPE_STRING, &stream->headers,
							  RPC_TYPE_BOOLEAN, &seekable,
							  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_NewStream() get args", error);
	return error;
  }

  StreamInstance *stream_ndata;
  if ((stream_ndata = malloc(sizeof(*stream_ndata))) == NULL)
	return RPC_ERROR_NO_MEMORY;
  stream->ndata = stream_ndata;
  memset(stream_ndata, 0, sizeof(*stream_ndata));
  stream_ndata->stream_id = stream_id;
  id_link(stream_id, stream_ndata);
  stream_ndata->stream = stream;
  stream_ndata->is_plugin_stream = 0;

  uint16 stype = NP_NORMAL;
  NPError ret = g_NPP_NewStream(PLUGIN_INSTANCE_NPP(plugin), type, stream, seekable, &stype);

  if (type)
	free(type);

  return rpc_method_send_reply(connection,
							   RPC_TYPE_INT32, ret,
							   RPC_TYPE_UINT32, (uint32_t)stype,
							   RPC_TYPE_NP_NOTIFY_DATA, stream->notifyData,
							   RPC_TYPE_INVALID);
}

// NPP_DestroyStream
static NPError
g_NPP_DestroyStream(NPP instance, NPStream *stream, NPReason reason)
{
  if (instance == NULL)
	return NPERR_INVALID_INSTANCE_ERROR;

  if (plugin_funcs.destroystream == NULL)
	return NPERR_INVALID_FUNCTABLE_ERROR;

  if (stream == NULL)
	return NPERR_INVALID_PARAM;

  D(bugiI("NPP_DestroyStream instance=%p, stream=%p, reason=%s\n",
		instance, stream, string_of_NPReason(reason)));
  NPError ret = plugin_funcs.destroystream(instance, stream, reason);
  D(bugiD("NPP_DestroyStream return: %d [%s]\n", ret, string_of_NPError(ret)));

  StreamInstance *stream_ndata = stream->ndata;
  if (stream_ndata) {
	id_remove(stream_ndata->stream_id);
	free(stream_ndata);
  }
  free((char *)stream->url);
  free((char *)stream->headers);
  free(stream);

  return ret;
}

static int handle_NPP_DestroyStream(rpc_connection_t *connection)
{
  D(bug("handle_NPP_DestroyStream\n"));

  PluginInstance *plugin;
  NPStream *stream;
  int32_t reason;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
								  RPC_TYPE_NP_STREAM, &stream,
								  RPC_TYPE_INT32, &reason,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_DestroyStream() get args", error);
	return error;
  }

  NPError ret = g_NPP_DestroyStream(PLUGIN_INSTANCE_NPP(plugin), stream, reason);
  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INVALID);
}

// NPP_WriteReady
static int32
g_NPP_WriteReady(NPP instance, NPStream *stream)
{
  if (instance == NULL)
	return 0;

  if (plugin_funcs.writeready == NULL)
	return 0;

  if (stream == NULL)
	return 0;

  D(bugiI("NPP_WriteReady instance=%p, stream=%p\n", instance, stream));
  int32 ret = plugin_funcs.writeready(instance, stream);
  D(bugiD("NPP_WriteReady return: %d\n", ret));
  return ret;
}

static int handle_NPP_WriteReady(rpc_connection_t *connection)
{
  D(bug("handle_NPP_WriteReady\n"));

  PluginInstance *plugin;
  NPStream *stream;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
								  RPC_TYPE_NP_STREAM, &stream,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_WriteReady() get args", error);
	return error;
  }

  int32 ret = g_NPP_WriteReady(PLUGIN_INSTANCE_NPP(plugin), stream);

  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INVALID);
}

// NPP_Write
static int32
g_NPP_Write(NPP instance, NPStream *stream, int32 offset, int32 len, void *buf)
{
  if (instance == NULL)
	return -1;

  if (plugin_funcs.write == NULL)
	return -1;

  if (stream == NULL)
	return -1;

  D(bugiI("NPP_Write instance=%p, stream=%p, offset=%d, len=%d, buf=%p\n", instance, stream, offset, len, buf));
  int32 ret = plugin_funcs.write(instance, stream, offset, len, buf);
  D(bugiD("NPP_Write return: %d\n", ret));
  return ret;
}

static int handle_NPP_Write(rpc_connection_t *connection)
{
  D(bug("handle_NPP_Write\n"));

  PluginInstance *plugin;
  NPStream *stream;
  unsigned char *buf;
  int32_t offset, len;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
								  RPC_TYPE_NP_STREAM, &stream,
								  RPC_TYPE_INT32, &offset,
								  RPC_TYPE_ARRAY, RPC_TYPE_CHAR, &len, &buf,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_Write() get args", error);
	return error;
  }

  int32 ret = g_NPP_Write(PLUGIN_INSTANCE_NPP(plugin), stream, offset, len, buf);

  if (buf)
	free(buf);

  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INVALID);
}

// NPP_StreamAsFile
static void
g_NPP_StreamAsFile(NPP instance, NPStream *stream, const char *fname)
{
  if (instance == NULL)
	return;

  if (plugin_funcs.asfile == NULL)
	return;

  if (stream == NULL)
	return;

  D(bugiI("NPP_StreamAsFile instance=%p, stream=%p, fname='%s'\n", instance, stream, fname));
  plugin_funcs.asfile(instance, stream, fname);
  D(bugiD("NPP_StreamAsFile done\n"));
}

static int handle_NPP_StreamAsFile(rpc_connection_t *connection)
{
  D(bug("handle_NPP_StreamAsFile\n"));

  PluginInstance *plugin;
  NPStream *stream;
  char *fname;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
								  RPC_TYPE_NP_STREAM, &stream,
								  RPC_TYPE_STRING, &fname,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_StreamAsFile() get args", error);
	return error;
  }

  g_NPP_StreamAsFile(PLUGIN_INSTANCE_NPP(plugin), stream, fname);

  if (fname)
	free(fname);

  return rpc_method_send_reply (connection, RPC_TYPE_INVALID);
}

// NPP_Print
static void
g_NPP_Print(NPP instance, NPPrint *printInfo)
{
  if (plugin_funcs.print == NULL)
	return;

  if (printInfo == NULL)
	return;

  D(bugiI("NPP_Print instance=%p, printInfo->mode=%d\n", instance, printInfo->mode));
  plugin_funcs.print(instance, printInfo);
  D(bugiD("NPP_Print done\n"));
}

static void
invoke_NPN_PrintData(PluginInstance *plugin, uint32_t platform_print_id, NPPrintData *printData)
{
  if (printData == NULL)
	return;

  npw_return_if_fail(rpc_method_invoke_possible(g_rpc_connection));

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPN_PRINT_DATA,
								RPC_TYPE_UINT32, platform_print_id,
								RPC_TYPE_NP_PRINT_DATA, printData,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_PrintData() invoke", error);
	return;
  }

  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPN_PrintData() wait for reply", error);
	return;
  }
}

static int handle_NPP_Print(rpc_connection_t *connection)
{
  D(bug("handle_NPP_Print\n"));

  PluginInstance *plugin;
  NPPrint printInfo;
  uint32_t platform_print_id;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
								  RPC_TYPE_UINT32, &platform_print_id,
								  RPC_TYPE_NP_PRINT, &printInfo,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_Print() get args", error);
	return error;
  }

  // reconstruct printer info
  NPPrintCallbackStruct printer;
  printer.type = NP_PRINT;
  printer.fp = platform_print_id ? tmpfile() : NULL;
  switch (printInfo.mode) {
  case NP_FULL:
	printInfo.print.fullPrint.platformPrint = &printer;
	break;
  case NP_EMBED:
	printInfo.print.embedPrint.platformPrint = &printer;
	// XXX the window ID is unlikely to work here as is. The NPWindow
	// is probably only used as a bounding box?
	create_window_attributes(printInfo.print.embedPrint.window.ws_info);
	break;
  }

  g_NPP_Print(PLUGIN_INSTANCE_NPP(plugin), &printInfo);

  // send back the printed data
  if (printer.fp) {
	long file_size = ftell(printer.fp);
	D(bug(" writeback data [%d bytes]\n", file_size));
	rewind(printer.fp);
	if (file_size > 0) {
	  NPPrintData printData;
	  const int printDataMaxSize = sizeof(printData.data);
	  int n = file_size / printDataMaxSize;
	  while (--n >= 0) {
		printData.size = printDataMaxSize;
		if (fread(&printData.data, sizeof(printData.data), 1, printer.fp) != 1) {
		  npw_printf("ERROR: unexpected end-of-file or error condition in NPP_Print\n");
		  break;
		}
		npw_plugin_instance_ref(plugin);
		invoke_NPN_PrintData(plugin, platform_print_id, &printData);
		npw_plugin_instance_unref(plugin);
	  }
	  printData.size = file_size % printDataMaxSize;
	  if (fread(&printData.data, printData.size, 1, printer.fp) != 1)
		npw_printf("ERROR: unexpected end-of-file or error condition in NPP_Print\n");
	  npw_plugin_instance_ref(plugin);
	  invoke_NPN_PrintData(plugin, platform_print_id, &printData);
	  npw_plugin_instance_unref(plugin);
	}
	fclose(printer.fp);
  }

  if (printInfo.mode == NP_EMBED) {
	NPWindow *window = &printInfo.print.embedPrint.window;
	if (window->ws_info) {
	  destroy_window_attributes(window->ws_info);
	  window->ws_info = NULL;
	}
  }

  uint32_t plugin_printed = FALSE;
  if (printInfo.mode == NP_FULL)
	plugin_printed = printInfo.print.fullPrint.pluginPrinted;
  return rpc_method_send_reply(connection, RPC_TYPE_BOOLEAN, plugin_printed, RPC_TYPE_INVALID);
}

// Delivers a platform-specific window event to the instance
static int16
g_NPP_HandleEvent(NPP instance, NPEvent *event)
{
  if (instance == NULL)
	return false;

  if (plugin_funcs.event == NULL)
	return false;

  if (event == NULL)
	return false;

  D(bugiI("NPP_HandleEvent instance=%p, event=%p [%s]\n", instance, event, string_of_NPEvent_type(event->type)));
  int16 ret = plugin_funcs.event(instance, event);
  D(bugiD("NPP_HandleEvent return: %d\n", ret));

  /* XXX: let's have a chance to commit the pixmap before it's gone */
  if (event->type == GraphicsExpose)
	gdk_flush();

  return ret;
}

static int handle_NPP_HandleEvent(rpc_connection_t *connection)
{
  D(bug("handle_NPP_HandleEvent\n"));

  PluginInstance *plugin;
  NPEvent event;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NPW_PLUGIN_INSTANCE, &plugin,
								  RPC_TYPE_NP_EVENT, &event,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPP_HandleEvent() get args", error);
	return error;
  }

  event.xany.display = x_display;
  int16 ret = g_NPP_HandleEvent(PLUGIN_INSTANCE_NPP(plugin), &event);

  return rpc_method_send_reply(connection, RPC_TYPE_INT32, ret, RPC_TYPE_INVALID);
}


/* ====================================================================== */
/* === Events processing                                              === */
/* ====================================================================== */

typedef gboolean (*GSourcePrepare)(GSource *, gint *);
typedef gboolean (*GSourceCheckFunc)(GSource *);
typedef gboolean (*GSourceDispatchFunc)(GSource *, GSourceFunc, gpointer);
typedef void (*GSourceFinalizeFunc)(GSource *);

// Xt events
static GPollFD xt_event_poll_fd;

static gboolean xt_event_prepare(GSource *source, gint *timeout)
{
  int mask = XtAppPending(x_app_context);
  return mask & XtIMXEvent;
}

static gboolean xt_event_check(GSource *source)
{
  if (xt_event_poll_fd.revents & G_IO_IN) {
	int mask = XtAppPending(x_app_context);
	if (mask & XtIMXEvent)
	  return TRUE;
  }
  return FALSE;
}

static gboolean xt_event_dispatch(GSource *source, GSourceFunc callback, gpointer user_data)
{
  int i;
  for (i = 0; i < 5; i++) {
	int mask = XtAppPending(x_app_context);
	if ((mask & XtIMXEvent) == 0)
	  break;
	XtAppProcessEvent(x_app_context, XtIMXEvent);
  }
  return TRUE;
}

static GSourceFuncs xt_event_funcs = {
  xt_event_prepare,
  xt_event_check,
  xt_event_dispatch,
  (GSourceFinalizeFunc)g_free,
  (GSourceFunc)NULL,
  (GSourceDummyMarshal)NULL
};

static gboolean xt_event_polling_timer_callback(gpointer user_data)
{
  int i;
  for (i = 0; i < 5; i++) {
	if ((XtAppPending(x_app_context) & (XtIMAll & ~XtIMXEvent)) == 0)
	  break;
	XtAppProcessEvent(x_app_context, XtIMAll & ~XtIMXEvent);
  }
  return TRUE;
}

// RPC events
static GPollFD rpc_event_poll_fd;

static gboolean rpc_event_prepare(GSource *source, gint *timeout)
{
  *timeout = -1;
  return FALSE;
}

static gboolean rpc_event_check(GSource *source)
{
  return rpc_wait_dispatch(g_rpc_connection, 0) > 0;
}

static gboolean rpc_event_dispatch(GSource *source, GSourceFunc callback, gpointer connection)
{
  return rpc_dispatch(connection) != RPC_ERROR_CONNECTION_CLOSED;
}

static GSourceFuncs rpc_event_funcs = {
  rpc_event_prepare,
  rpc_event_check,
  rpc_event_dispatch,
  (GSourceFinalizeFunc)g_free,
  (GSourceFunc)NULL,
  (GSourceDummyMarshal)NULL
};

// RPC error callback -- kill the plugin
static void rpc_error_callback_cb(rpc_connection_t *connection, void *user_data)
{
  D(bug("RPC connection %p is in a bad state, closing the plugin\n",connection));
  rpc_connection_set_error_callback(connection, NULL, NULL);
  gtk_main_quit();
}


/* ====================================================================== */
/* === Main program                                                   === */
/* ====================================================================== */

static int do_test(void);

static int do_main(int argc, char **argv, const char *connection_path)
{
  if (do_test() != 0)
	return 1;
  if (connection_path == NULL) {
	npw_printf("ERROR: missing connection path argument\n");
	return 1;
  }
  D(bug("  Plugin connection: %s\n", connection_path));

  pid_init();
  D(bug("  Plugin viewer pid: %d\n", g_viewer_pid));
  
  // Cleanup environment, the program may fork/exec a native shell
  // script and having 32-bit libraries in LD_PRELOAD is not right,
  // though not a fatal error
#if defined(__linux__)
  if (getenv("LD_PRELOAD"))
	unsetenv("LD_PRELOAD");
#endif

  // Xt and GTK initialization
  XtToolkitInitialize();
  x_app_context = XtCreateApplicationContext();
  x_display = XtOpenDisplay(x_app_context, NULL, "npw-viewer", "npw-viewer", NULL, 0, &argc, argv);
  g_thread_init(NULL);
  gtk_init(&argc, &argv);

  // Initialize RPC communication channel
  if ((g_rpc_connection = rpc_init_server(connection_path)) == NULL) {
	npw_printf("ERROR: failed to initialize plugin-side RPC server connection\n");
	return 1;
  }
  if (rpc_add_np_marshalers(g_rpc_connection) < 0) {
	npw_printf("ERROR: failed to initialize plugin-side marshalers\n");
	return 1;
  }
  static const rpc_method_descriptor_t vtable[] = {
	{ RPC_METHOD_NP_GET_MIME_DESCRIPTION,		handle_NP_GetMIMEDescription },
	{ RPC_METHOD_NP_GET_VALUE,					handle_NP_GetValue },
	{ RPC_METHOD_NP_INITIALIZE,					handle_NP_Initialize },
	{ RPC_METHOD_NP_SHUTDOWN,					handle_NP_Shutdown },
	{ RPC_METHOD_NPP_NEW,						handle_NPP_New },
	{ RPC_METHOD_NPP_DESTROY,					handle_NPP_Destroy },
	{ RPC_METHOD_NPP_GET_VALUE,					handle_NPP_GetValue },
	{ RPC_METHOD_NPP_SET_WINDOW,				handle_NPP_SetWindow },
	{ RPC_METHOD_NPP_URL_NOTIFY,				handle_NPP_URLNotify },
	{ RPC_METHOD_NPP_NEW_STREAM,				handle_NPP_NewStream },
	{ RPC_METHOD_NPP_DESTROY_STREAM,			handle_NPP_DestroyStream },
	{ RPC_METHOD_NPP_WRITE_READY,				handle_NPP_WriteReady },
	{ RPC_METHOD_NPP_WRITE,						handle_NPP_Write },
	{ RPC_METHOD_NPP_STREAM_AS_FILE,			handle_NPP_StreamAsFile },
	{ RPC_METHOD_NPP_PRINT,						handle_NPP_Print },
	{ RPC_METHOD_NPP_HANDLE_EVENT,				handle_NPP_HandleEvent },
	{ RPC_METHOD_NPCLASS_INVALIDATE,			npclass_handle_Invalidate },
	{ RPC_METHOD_NPCLASS_HAS_METHOD,			npclass_handle_HasMethod },
	{ RPC_METHOD_NPCLASS_INVOKE,				npclass_handle_Invoke },
	{ RPC_METHOD_NPCLASS_INVOKE_DEFAULT,		npclass_handle_InvokeDefault },
	{ RPC_METHOD_NPCLASS_HAS_PROPERTY,			npclass_handle_HasProperty },
	{ RPC_METHOD_NPCLASS_GET_PROPERTY,			npclass_handle_GetProperty },
	{ RPC_METHOD_NPCLASS_SET_PROPERTY,			npclass_handle_SetProperty },
	{ RPC_METHOD_NPCLASS_REMOVE_PROPERTY,		npclass_handle_RemoveProperty },
  };
  if (rpc_connection_add_method_descriptors(g_rpc_connection, vtable, sizeof(vtable) / sizeof(vtable[0])) < 0) {
	npw_printf("ERROR: failed to setup NPP method callbacks\n");
	return 1;
  }

  id_init();

  // Initialize Xt events listener (integrate X events into GTK events loop)
  GSource *xt_source = g_source_new(&xt_event_funcs, sizeof(GSource));
  if (xt_source == NULL) {
	npw_printf("ERROR: failed to initialize Xt events listener\n");
	return 1;
  }
  g_source_set_priority(xt_source, GDK_PRIORITY_EVENTS);
  g_source_set_can_recurse(xt_source, TRUE);
  g_source_attach(xt_source, NULL);
  xt_event_poll_fd.fd = ConnectionNumber(x_display);
  xt_event_poll_fd.events = G_IO_IN;
  xt_event_poll_fd.revents = 0;
  g_source_add_poll(xt_source, &xt_event_poll_fd);

  gint xt_polling_timer_id = g_timeout_add(25,
										   xt_event_polling_timer_callback,
										   NULL);

  // Initialize RPC events listener
  GSource *rpc_source = g_source_new(&rpc_event_funcs, sizeof(GSource));
  if (rpc_source == NULL) {
	npw_printf("ERROR: failed to initialize plugin-side RPC events listener\n");
	return 1;
  }
  g_source_set_priority(rpc_source, G_PRIORITY_LOW);
  g_source_attach(rpc_source, NULL);
  rpc_event_poll_fd.fd = rpc_listen_socket(g_rpc_connection);
  rpc_event_poll_fd.events = G_IO_IN;
  rpc_event_poll_fd.revents = 0;
  g_source_set_callback(rpc_source, (GSourceFunc)rpc_dispatch, g_rpc_connection, NULL);
  g_source_add_poll(rpc_source, &rpc_event_poll_fd);

  // Set error handler - stop plugin if there's a connection error
  rpc_connection_set_error_callback(g_rpc_connection, rpc_error_callback_cb, NULL);
 
  gtk_main();
  D(bug("--- EXIT ---\n"));

  g_source_remove(xt_polling_timer_id);
  g_source_destroy(rpc_source);
  g_source_destroy(xt_source);

  if (g_user_agent)
	free(g_user_agent);
  if (g_rpc_connection)
	rpc_connection_unref(g_rpc_connection);

  id_kill();
  return 0;
}

// Flash Player 9 beta 1 is not stable enough and will generally
// freeze on NP_Shutdown when multiple Flash movies are active
static int is_flash_player9_beta1(void)
{
  const char *plugin_desc = NULL;
  if (g_NP_GetValue(NPPVpluginDescriptionString, &plugin_desc) == NPERR_NO_ERROR
	  && plugin_desc && strcmp(plugin_desc, "Shockwave Flash 9.0 d55") == 0) {
	npw_printf("WARNING: Flash Player 9 beta 1 detected and rejected\n");
	return 1;
  }
  return 0;
}

static int do_test(void)
{
  if (g_plugin_NP_GetMIMEDescription == NULL)
	return 1;
  if (g_plugin_NP_Initialize == NULL)
	return 2;
  if (g_plugin_NP_Shutdown == NULL)
	return 3;
  if (is_flash_player9_beta1())
	return 4;
  return 0;
}

static int do_info(void)
{
  if (do_test() != 0)
	return 1;
  const char *plugin_name = NULL;
  if (g_NP_GetValue(NPPVpluginNameString, &plugin_name) == NPERR_NO_ERROR && plugin_name)
	printf("PLUGIN_NAME %zd\n%s\n", strlen(plugin_name), plugin_name);
  const char *plugin_desc = NULL;
  if (g_NP_GetValue(NPPVpluginDescriptionString, &plugin_desc) == NPERR_NO_ERROR && plugin_desc)
	printf("PLUGIN_DESC %zd\n%s\n", strlen(plugin_desc), plugin_desc);
  const char *mime_info = g_NP_GetMIMEDescription();
  if (mime_info)
	printf("PLUGIN_MIME %zd\n%s\n", strlen(mime_info), mime_info);
  return 0;
}

static int do_help(const char *prog)
{
  printf("%s, NPAPI plugin viewer. Version %s\n", NPW_VIEWER, NPW_VERSION);
  printf("\n");
  printf("usage: %s [GTK flags] [flags]\n", prog);
  printf("   -h --help               print this message\n");
  printf("   -t --test               check plugin is compatible\n");
  printf("   -i --info               print plugin information\n");
  printf("   -p --plugin             set plugin path\n");
  printf("   -c --connection         set connection path\n");
  return 0;
}

int main(int argc, char **argv)
{
  const char *plugin_path = NULL;
  const char *connection_path = NULL;

  enum {
	CMD_RUN,
	CMD_TEST,
	CMD_INFO,
	CMD_HELP
  };
  int cmd = CMD_RUN;
  unset_remote_invocation();
  // Parse command line arguments
  for (int i = 0; i < argc; i++) {
	const char *arg = argv[i];
	if (strcmp(arg, "-h") == 0 || strcmp(arg, "--help") == 0) {
	  argv[i] = NULL;
	  cmd = CMD_HELP;
	}
	else if (strcmp(arg, "-t") == 0 || strcmp(arg, "--test") == 0) {
	  argv[i] = NULL;
	  cmd = CMD_TEST;
	}
	else if (strcmp(arg, "-i") == 0 || strcmp(arg, "--info") == 0) {
	  argv[i] = NULL;
	  cmd = CMD_INFO;
	}
	else if (strcmp(arg, "-p") == 0 || strcmp(arg, "--plugin") == 0) {
	  argv[i] = NULL;
	  if (++i < argc) {
		plugin_path = argv[i];
		argv[i] = NULL;
	  }
	}
	else if (strcmp(arg, "-c") == 0 || strcmp(arg, "--connection") == 0) {
	  argv[i] = NULL;
	  if (++i < argc) {
		connection_path = argv[i];
		argv[i] = NULL;
	  }
	}
	else if (strcmp(arg, "-r") == 0 || strcmp(arg, "--remote-invocation") == 0) {
	  argv[i] = NULL;
	  set_remote_invocation();
	}
  }

  // Remove processed arguments
  for (int i = 1, j = 1, n = argc; i < n; i++) {
	if (argv[i])
	  argv[j++] = argv[i];
	else
	  --argc;
  }

  // Open plug-in and get exported lib functions
  void *handles[10] = { NULL, };
  int n_handles = 0;
  if (plugin_path == NULL)
	cmd = CMD_HELP;
  else {
	void *handle;
	const char *error;
#if defined(__sun)
	/* XXX: check for Flash Player only? */
	const char SunStudio_libCrun[] = "libCrun.so.1";
	D(bug("  trying to open SunStudio C++ runtime '%s'\n", SunStudio_libCrun));
	if ((handle = dlopen(SunStudio_libCrun, RTLD_LAZY|RTLD_GLOBAL)) == NULL) {
	  npw_printf("ERROR: %s\n", dlerror());
	  return 1;
	}
	handles[n_handles++] = handle;
	dlerror();
#endif
	D(bug("  %s\n", plugin_path));
	if ((handle = dlopen(plugin_path, RTLD_LAZY)) == NULL) {
	  npw_printf("ERROR: %s\n", dlerror());
	  return 1;
	}
	handles[n_handles++] = handle;
	dlerror();
	g_plugin_NP_GetMIMEDescription = (NP_GetMIMEDescriptionUPP)dlsym(handle, "NP_GetMIMEDescription");
	if ((error = dlerror()) != NULL) {
	  npw_printf("ERROR: %s\n", error);
	  return 1;
	}
	g_plugin_NP_Initialize = (NP_InitializeUPP)dlsym(handle, "NP_Initialize");
	if ((error = dlerror()) != NULL) {
	  npw_printf("ERROR: %s\n", error);
	  return 1;
	}
	g_plugin_NP_Shutdown = (NP_ShutdownUPP)dlsym(handle, "NP_Shutdown");
	if ((error = dlerror()) != NULL) {
	  npw_printf("ERROR: %s\n", error);
	  return 1;
	}
	g_plugin_NP_GetValue = (NP_GetValueUPP)dlsym(handle, "NP_GetValue");
  }

  int ret = 1;
  switch (cmd) {
  case CMD_RUN:
	ret = do_main(argc, argv, connection_path);
	break;
  case CMD_TEST:
	ret = do_test();
	break;
  case CMD_INFO:
	ret = do_info();
	break;
  case CMD_HELP:
	ret = do_help(argv[0]);
	break;
  }

  while (--n_handles >= 0) {
	void * const handle = handles[n_handles];
	if (handle)
	  dlclose(handle);
  }
  return ret;
}
