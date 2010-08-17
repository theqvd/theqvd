#define _GNU_SOURCE 1 /* RTLD_NEXT */

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <errno.h>
#include <limits.h>
#include <stdarg.h>
#include <unistd.h>

#include <X11/X.h>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Intrinsic.h>
#include <X11/Shell.h>
#include <X11/StringDefs.h>


static int g_debug_level = 1;
static FILE *g_log_file = NULL;

void npw_printf(const char *format, ...)
{
#if 0
  if (g_debug_level < 0) {
	g_debug_level = 0;
	const char *debug_str = getenv("NPW_DEBUG");
	if (debug_str) {
	  errno = 0;
	  long v = strtol(debug_str, NULL, 10);
	  if ((v != LONG_MIN && v != LONG_MAX) || errno != ERANGE)
		g_debug_level = v;
	}
  }

  if (g_log_file == NULL) {
	const char *log_file = getenv("NPW_LOG");
	if (log_file)
	  g_log_file = fopen(log_file, "w");
	if (log_file == NULL)
	  g_log_file = stderr;
  }
#else
  g_log_file = stderr;
#endif

  if (g_debug_level > 0) {
	va_list args;
	va_start(args, format);
	vfprintf(g_log_file, format, args);
	va_end(args);
  }
}

#define PREPARE_FUNC(NAME, RET, ARGS)			\
  static RET (*lib_##NAME) ARGS;				\
  if (lib_##NAME == NULL)						\
    lib_##NAME = dlsym(RTLD_NEXT, #NAME);		\
  assert(lib_##NAME != NULL)

#if 0
char *getenv(const char *name)
{
  PREPARE_FUNC(getenv, char *, (const char *));
  char *str = lib_getenv(name);
  npw_printf("getenv '%s' => '%s'\n", name ? name : "<null>", str ? str : "<null>");
  return str;
}

int putenv(char *string)
{
  PREPARE_FUNC(putenv, int, (char *));
  npw_printf("putenv '%s'\n", string ? string : "<null>");
  return lib_putenv(string);
}
#endif

int XSetClassHints(Display *display, Window w, XClassHint *class_hints)
{
  PREPARE_FUNC(XSetClassHints, int, (Display *, Window, XClassHint *));
  npw_printf("XSetClassHints(window %p, class_hints { %s, '%s' }\n", w, class_hints->res_name, class_hints->res_class);
  return lib_XSetClassHints(display, w, class_hints);
}

static void print_backtrace(void)
{
#if 0
#define N_LEVELS 64
  void *trace[N_LEVELS];
  int n_levels = backtrace(trace, sizeof(trace)/sizeof(trace[0]));
  backtrace_symbols_fd(trace, n_levels, STDERR_FILENO);
#endif
}

Status XSendEvent(Display *display, Window w, Bool propagate, long event_mask, XEvent *event_send)
{
  PREPARE_FUNC(XSendEvent, Status, (Display *, Window, Bool, long, XEvent *));
  if (event_send && (1 || ((XAnyEvent *)event_send)->send_event)) {
	npw_printf("XSendEvent(window %p, propagate %d, event_mask %08x, event type %d, SendEvent %x)\n",
			   w, propagate, event_mask, event_send->type, event_send->xany.send_event);
  }
  print_backtrace();
  if (event_send->xclient.message_type == XInternAtom(display, "_XEMBED", False))
	npw_printf("[X11] Handle XEMBED message %d for window %p\n", event_send->xclient.data.l[1], event_send->xany.window);
  return lib_XSendEvent(display, w, propagate, event_mask, event_send);
}

#if 0
Window XCreateWindow(Display *display, Window parent, int x, int y,
					 unsigned int width, unsigned int height,
					 unsigned int border_width, int depth, unsigned int class, Visual *visual,
					 unsigned long valuemask, XSetWindowAttributes *attributes)
{
  PREPARE_FUNC(XCreateWindow, Window, (Display *, Window, int, int, unsigned int, unsigned int, unsigned int, unsigned int, unsigned int, Visual *, unsigned long, XSetWindowAttributes *));
  Window ret = lib_XCreateWindow(display, parent, x, y, width, height,
								 border_width, depth, class, visual,
								 valuemask, attributes);
  npw_printf("[X11] XCreateWindow() -> %p\n", ret);
  return ret;
}
#endif

#if 0
int XChangeProperty(Display *display, Window w, Atom property, Atom type,
					int format, int mode, const unsigned char *data, int nelements)
{
  PREPARE_FUNC(XChangeProperty, int, (Display *, Window, Atom, Atom, int, int, const unsigned char *, int));
  const char *property_str = XGetAtomName(display, property);
  const char *type_str = XGetAtomName(display, type);
  npw_printf("XChangeProperty(window %p, property %s, type %s, format %d, mode %d)\n",
			 w, property_str, type_str, format, mode);
  int ret = lib_XChangeProperty(display, w, property, type, format, mode, data, nelements);
  if (property == XInternAtom(display, "WM_HINTS", False) && format == 32) {
	XWMHints *hints = XGetWMHints(display, w);
	if (hints) {
	  npw_printf("  InputHint %d\n", hints->input);
	  XFree((void *)hints);
	}
  }
  return ret;
}
#endif

void XtConfigureWidget(Widget w, Position x, Position y, Dimension width, Dimension height, Dimension border_width)
{
  PREPARE_FUNC(XtConfigureWidget, void, (Widget, Position, Position, Dimension, Dimension, Dimension));
  lib_XtConfigureWidget(w, x, y, width, height, border_width);
}

#if 0
Atom XInternAtom(Display *display, const char *atom_name, Bool only_if_exists)
{
  static Atom (*x_XInternAtom)(Display *, const char *, Bool) = NULL;
  if (x_XInternAtom == NULL)
	x_XInternAtom = dlsym(RTLD_NEXT, "XInternAtom");

  npw_printf("[X11] XInternAtom(display=%p, atom_name='%s', only_if_exists=%d)\n", display, atom_name, only_if_exists);
  Atom ret = x_XInternAtom(display, atom_name, only_if_exists);
  return ret;
}
#endif

typedef struct {
  void *client_data;
  XtEventHandler event_handler;
} fake_event_handler_data;

static void fake_event_handler(Widget w, XtPointer client_data, XEvent *event, Boolean *cont)
{
  fake_event_handler_data *pdata = (fake_event_handler_data *)client_data;

  switch (event->type) {
  case ButtonPress:
	npw_printf("ButtonPress\n");
	break;
  case ButtonRelease:
	npw_printf("ButtonRelease\n");
	break;
  case KeyPress:
	npw_printf("KeyPress\n");
	break;
  case KeyRelease:
	npw_printf("KeyRelease\n");
	break;
  case FocusIn:
	npw_printf("[X11] FocusIn for window %p\n", event->xfocus.window);
	break;
  case FocusOut:
	npw_printf("[X11] FocusOut for window %p\n", event->xfocus.window);
	break;
  }
  pdata->event_handler(w, pdata->client_data, event, cont);
}

static const char *dlname(void *addr)
{
  static Dl_info dlinfo;
  if (dladdr(addr, &dlinfo) < 0)
	return NULL;
  return dlinfo.dli_sname;
}

static void print_event_mask(EventMask event_mask)
{
#define P(EVENT) if (event_mask & (EVENT##Mask)) npw_printf("  " #EVENT "\n")
  P(KeyPress);
  P(KeyRelease);
  P(ButtonPress);
  P(ButtonRelease);
  P(EnterWindow);
  P(LeaveWindow);
  P(PointerMotion);
  P(PointerMotionHint);
  P(Button1Motion);
  P(Button2Motion);
  P(Button3Motion);
  P(Button4Motion);
  P(Button5Motion);
  P(ButtonMotion);
  P(KeymapState);
  P(Exposure);
  P(VisibilityChange);
  P(StructureNotify);
  P(ResizeRedirect);
  P(SubstructureNotify);
  P(SubstructureRedirect);
  P(FocusChange);
  P(PropertyChange);
  P(ColormapChange);
  P(OwnerGrabButton);
}

#if 1
void XtAddEventHandler(Widget w, EventMask event_mask, Bool nonmaskable,
					   XtEventHandler proc, XtPointer client_data)
{
  static void (*x_XtAddEventHandler)(Widget, EventMask, Bool, XtEventHandler, XtPointer) = NULL;
  if (x_XtAddEventHandler == NULL)
	x_XtAddEventHandler = dlsym(RTLD_NEXT, "XtAddEventHandler");

  if (0 || (event_mask & (KeyPressMask|KeyReleaseMask))) {
	npw_printf("[X11] XtAddEventHandler(Widget=%p[0x%08x], event_mask=%x, nonmaskable=%d, proc=%p[%s])\n",
			   w, XtWindow(w), event_mask, nonmaskable, proc, dlname(proc));
	print_event_mask(event_mask);
  }
#if 1
  if (event_mask & (KeyPressMask|KeyReleaseMask)) {
	fake_event_handler_data *pdata = malloc(sizeof(*pdata));
	pdata->client_data = client_data;
	pdata->event_handler = proc;
	proc = fake_event_handler;
	client_data = pdata;
  }
#endif
  x_XtAddEventHandler(w, event_mask, nonmaskable, proc, client_data);
#if 0
  if (event_mask & (KeyPressMask|KeyReleaseMask))
	x_XtAddEventHandler(w, event_mask, nonmaskable, fake_event_handler, client_data);
#endif
}
#endif

#if 0
void XtAddCallback(Widget w, _Xconst _XtString callback_name, XtCallbackProc callback, XtPointer client_data)
{
  static void (*x_XtAddCallback)(Widget, _Xconst _XtString, XtCallbackProc, XtPointer);
  if (x_XtAddCallback == NULL)
	x_XtAddCallback = dlsym(RTLD_NEXT, "XtAddCallback");

  npw_printf("[X11] XtAddCallback(widget %p[0x%08x], callback_name '%s', callback %p[%s], client_data %p)\n",
			 w, XtWindow(w), callback_name, callback, dlname(callback), client_data);
  x_XtAddCallback(w, callback_name, callback, client_data);
}
#endif

#if 0
int XtGrabKeyboard(Widget w, _XtBoolean owner_events, int pointer_mode, int keyboard_mode, Time time)
{
  static int (*x_XtGrabKeyboard)(Widget, _XtBoolean, int, int, Time);
  if (x_XtGrabKeyboard == NULL)
	x_XtGrabKeyboard = dlsym(RTLD_NEXT, "XtGrabKeyboard");

  npw_printf("[X11] XtGrabKeyboard(widget %p[0x%08x], owner_events %08x, pointer_mode %08x, keyboard_mode %08x, time %d)\n",
			 w, XtWindow(w), owner_events, pointer_mode, keyboard_mode, time);
  int rc = x_XtGrabKeyboard(w, owner_events, pointer_mode, keyboard_mode, time);
  npw_printf("  returns %d\n", rc);
  return rc;
}

void XtUngrabKeyboard(Widget w, Time time)
{
  static void (*x_XtUngrabKeyboard)(Widget, Time);
  if (x_XtUngrabKeyboard == NULL)
	x_XtUngrabKeyboard = dlsym(RTLD_NEXT, "XtUngrabKeyboard");

  npw_printf("[X11] XtUngrabKeyboard(widget %p[%08x], time %d)\n", w, XtWindow(w), time);
  x_XtUngrabKeyboard(w, time);
}
#endif

#if 0
XtIntervalId XtAppAddTimeOut(XtAppContext app_context, unsigned long
							 interval, XtTimerCallbackProc proc, XtPointer client_data)
{
  static XtIntervalId (*x_XtAppAddTimeOut)(XtAppContext, unsigned long, XtTimerCallbackProc, XtPointer) = NULL;
  if (x_XtAppAddTimeOut == NULL)
	x_XtAppAddTimeOut = dlsym(RTLD_NEXT, "XtAppAddTimeOut");

  static int once = 1;
  if (once)
	npw_printf("[X11] XtAppAddTimeout(ctx=%p, interval=%d, proc=%p[%s], client_data=%p)\n",
		   app_context, interval, proc, dlname(proc), client_data);
  XtIntervalId ret = x_XtAppAddTimeOut(app_context, interval, proc, client_data);
  if (once)
	npw_printf(" return: %d\n", ret);
  if (1)
	once = 0;
  return ret;
}

int XSetForeground(Display *display, GC gc, unsigned long foreground)
{
  static int (*x_XSetForeground)(Display *, GC, unsigned long) = NULL;
  if (x_XSetForeground == NULL)
	x_XSetForeground = dlsym(RTLD_NEXT, "XSetForeground");

  npw_printf("[X11] XSetForeground(display=%p, gc=%p, foreground=%06x)\n", display, gc, foreground);
  int ret = x_XSetForeground(display, gc, foreground);
  npw_printf(" return: %d\n", ret);
  return ret;
}

Status XGetWindowAttributes(Display *display, Window w, XWindowAttributes *attr)
{
  static Status (*x_XGetWindowAttributes)(Display *, Window, XWindowAttributes *) = NULL;
  if (x_XGetWindowAttributes == NULL)
	x_XGetWindowAttributes = dlsym(RTLD_NEXT, "XGetWindowAttributes");

  npw_printf("[X11] XGetWindowAttributes(display=%p, window=0x%08x)\n", display, w);
  Status ret = x_XGetWindowAttributes(display, w, attr);
  npw_printf(" return: %d\n", ret);
  npw_printf(" pos=(%d, %d), size=%dx%d, border=%d\n",
		 attr->x, attr->y, attr->width, attr->height, attr->border_width);
  return ret;
}
#endif

#if 1
Widget XtCreatePopupShell(const char *name, WidgetClass widget_class, Widget
						  parent, ArgList args, Cardinal num_args)
{
  static Widget (*x_XtCreatePopupShell)(const char *, WidgetClass, Widget, ArgList, Cardinal) = NULL;
  if (x_XtCreatePopupShell == NULL)
	x_XtCreatePopupShell = dlsym(RTLD_NEXT, "XtCreatePopupShell");

  npw_printf("[X11] XtCreatePopupShell(name='%s', widget_class=%p, parent=%p[0x%08x])\n", name, widget_class, parent, XtWindow(parent));
  int i;
  for (i = 0; i < num_args; i++)
	npw_printf(" %d: '%s' => %d\n", i, args[i].name, args[i].value);
  Widget ret = x_XtCreatePopupShell(name, widget_class, parent, args, num_args);
  npw_printf(" return: %p [0x%08x]\n", ret, XtWindow(ret));
  return ret;
}
#endif

#if 0
Status XQueryTree(Display *display, Window w, Window *root_return, Window *parent_return,
				  Window **children_return, unsigned int *nchildren_return)
{
  static Status (*x_XQueryTree)(Display *, Window, Window *, Window *, Window **, unsigned int *) = NULL;
  if (x_XQueryTree == NULL)
	x_XQueryTree = dlsym(RTLD_NEXT, "XQueryTree");

  npw_printf("[X11] XQueryTree(display=%p, window=0x%08x)\n", display, w);
  Status ret = x_XQueryTree(display, w, root_return, parent_return, children_return, nchildren_return);
  npw_printf(" return: %d\n", ret);
  npw_printf(" + parent_window=0x%08x, root_window=0x%08x\n", root_return ? *root_return : 0, parent_return ? *parent_return : 0);
  if (children_return && nchildren_return) {
	Window *children = *children_return;
	int i, n = *nchildren_return;
	for (i = 0; i < n; i++)
	  npw_printf(" + child 0x%08x\n", children[i]);
  }
  return ret;
}

Bool XQueryPointer(Display *display, Window w, Window *root_return,
				   Window *child_return, int *root_x_return, int *root_y_return,
				   int *win_x_return, int *win_y_return, unsigned int *mask_return)
{
  static Bool (*x_XQueryPointer)(Display *, Window, Window *, Window *, int *, int *, int *, int *, unsigned int *) = NULL;
  if (x_XQueryPointer == NULL)
	x_XQueryPointer = dlsym(RTLD_NEXT, "XQueryPointer");

  npw_printf("[X11] XQueryPointer(display=%p, window=0x%08x)\n", display, w);
  Bool ret = x_XQueryPointer(display, w, root_return, child_return, root_x_return, root_y_return, win_x_return, win_y_return, mask_return);
  npw_printf(" return: %d\n", ret);
  if (ret) {
	if (win_x_return && win_y_return)
	  npw_printf(" + pos = (%d, %d)\n", *win_x_return, *win_y_return);
	if (child_return)
	  npw_printf(" + child = 0x%08x\n", *child_return);
  }
  return ret;
}
#endif

#if 0
Widget XtWindowToWidget(Display *display, Window window)
{
  static Widget (*fn)(Display *, Window) = NULL;
  if (fn == NULL)
	fn = dlsym(RTLD_NEXT, "XtWindowToWidget");

  npw_printf("[X11] XtWindowToWidget(display=%p, window=0x%08x)\n", display, window);
  Widget ret = fn(display, window);
  npw_printf(" return: %p\n", ret);
  return ret;
}

Widget XtParent(Widget w)
{
  static Widget (*fn)(Widget) = NULL;
  if (fn == NULL)
	fn = dlsym(RTLD_NEXT, "XtParent");

  npw_printf("[X11] XtParent(widget=0x%08x)\n", w);
  Widget ret = fn(w);
  npw_printf(" return: 0x%08x\n", ret);
  return ret;
}
#endif

#if 0
static XErrorHandler app_error_handler = NULL;

static int fake_error_handler(Display *display, XErrorEvent *error_event)
{
  npw_printf("[X11] ERROR code=%d\n", error_event->error_code);
  int ret = app_error_handler(display, error_event);
  return ret;
}

XErrorHandler XSetErrorHandler(XErrorHandler handler)
{
  static XErrorHandler (*fn)(XErrorHandler) = NULL;
  if (fn == NULL)
	fn = dlsym(RTLD_NEXT, "XSetErrorHandler");

  app_error_handler = handler;
  XErrorHandler ret = fn(fake_error_handler);
  return ret;
}
#endif

#if 0
int XPutImage(Display *display, Drawable d, GC gc, XImage *image,
			  int src_x, int src_y, int dest_x, int dest_y, unsigned int width,
              unsigned int height)
{
  static int (*fn)(Display *, Drawable, GC, XImage *, int, int, int, int, unsigned int, unsigned int) = NULL;
  if (fn == NULL)
	fn = dlsym(RTLD_NEXT, "XPutImage");

  npw_printf("[X11] XPutImage(display=%p, drawable=0x%08x, src @ (%d, %d), dst @ (%d, %d), size = %dx%d)\n",
		 display, d, src_x, src_y, dest_x, dest_y, width, height);
  int ret = fn(display, d, gc, image, src_x, src_y, dest_x, dest_y, width, height);
  npw_printf(" return: %d\n", ret);
  if (src_x == dest_x && src_x == 16 && src_y == dest_y && src_y == 17) {
	npw_printf("about to trap into debugger\n");
	getchar();
	asm volatile ("int3");
  }
  return ret;
}

Status XShmPutImage(Display *display, Drawable d, GC gc, XImage *image,
					int src_x, int src_y, int dest_x, int dest_y, unsigned int width,
					unsigned int height, Bool send_event)
{
  static int (*fn)(Display *, Drawable, GC, XImage *, int, int, int, int, unsigned int, unsigned int, Bool) = NULL;
  if (fn == NULL)
	fn = dlsym(RTLD_NEXT, "XShmPutImage");

  npw_printf("[X11] XShmPutImage(display=%p, drawable=0x%08x, src @ (%d, %d), dst @ (%d, %d), size = %dx%d)\n",
		 display, d, src_x, src_y, dest_x, dest_y, width, height);
  int ret = fn(display, d, gc, image, src_x, src_y, dest_x, dest_y, width, height, send_event);
  npw_printf(" return: %d\n", ret);
  return ret;
}
#endif
