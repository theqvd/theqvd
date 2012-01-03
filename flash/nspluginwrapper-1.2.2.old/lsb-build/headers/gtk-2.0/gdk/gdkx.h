#ifndef _GTK_2_0_GDK_GDKX_H_
#define _GTK_2_0_GDK_GDKX_H_

#include <X11/Xlib.h>
#include <X11/X.h>
#include <glib-2.0/glib.h>
#include <glib-2.0/glib-object.h>
#include <gtk-2.0/gdk/gdk.h>

#ifdef __cplusplus
extern "C" {
#endif


#define GDK_WINDOW_DESTROYED(d)	 \
	(((GdkWindowObject*)(GDK_WINDOW (d)))->destroyed)
#define GDK_WINDOW_TYPE(d)	 \
	(((GdkWindowObject*)(GDK_WINDOW (d)))->window_type)
#define GDK_COLORMAP_XCOLORMAP(cmap)	 \
	(gdk_x11_colormap_get_xcolormap (cmap))
#define GDK_DISPLAY_XDISPLAY(display)	 \
	(gdk_x11_display_get_xdisplay (display))
#define GDK_SCREEN_XDISPLAY(screen)	 \
	(gdk_x11_display_get_xdisplay (gdk_screen_get_display (screen)))
#define GDK_PIXMAP_XDISPLAY(win)	 \
	(gdk_x11_drawable_get_xdisplay (((GdkPixmapObject *)win)->impl))
#define GDK_WINDOW_XDISPLAY(win)	 \
	(gdk_x11_drawable_get_xdisplay (((GdkWindowObject *)win)->impl))
#define GDK_SCREEN_XNUMBER(screen)	 \
	(gdk_x11_screen_get_screen_number (screen))
#define GDK_PARENT_RELATIVE_BG	((GdkPixmap *)1L)
#define GDK_NO_BG	((GdkPixmap *)2L)
#define GDK_COLORMAP_XDISPLAY(cmap)	(gdk_x11_colormap_get_xdisplay (cmap))
#define GDK_CURSOR_XCURSOR(cursor)	(gdk_x11_cursor_get_xcursor (cursor))
#define GDK_CURSOR_XDISPLAY(cursor)	(gdk_x11_cursor_get_xdisplay (cursor))
#define GDK_DRAWABLE_XDISPLAY(win)	(gdk_x11_drawable_get_xdisplay (win))
#define GDK_DRAWABLE_XID(win)	(gdk_x11_drawable_get_xid (win))
#define GDK_PIXMAP_XID(win)	(gdk_x11_drawable_get_xid (win))
#define GDK_WINDOW_XID(win)	(gdk_x11_drawable_get_xid (win))
#define GDK_WINDOW_XWINDOW(win)	(gdk_x11_drawable_get_xid (win))
#define GDK_GC_XDISPLAY(gc)	(gdk_x11_gc_get_xdisplay (gc))
#define GDK_GC_XGC(gc)	(gdk_x11_gc_get_xgc (gc))
#define GDK_ROOT_WINDOW()	(gdk_x11_get_default_root_xwindow ())
#define GDK_IMAGE_XDISPLAY(image)	(gdk_x11_image_get_xdisplay (image))
#define GDK_IMAGE_XIMAGE(image)	(gdk_x11_image_get_ximage (image))
#define GDK_SCREEN_XSCREEN(screen)	(gdk_x11_screen_get_xscreen (screen))
#define GDK_VISUAL_XVISUAL(visual)	(gdk_x11_visual_get_xvisual (visual))
#define GDK_DISPLAY()	gdk_display



    extern guint32 gdk_x11_get_server_time(GdkWindow *);
    extern gpointer gdk_xid_table_lookup_for_display(GdkDisplay *, XID);
    extern GdkVisual *gdk_x11_screen_lookup_visual(GdkScreen *, VisualID);
    extern Window gdk_x11_get_default_root_xwindow(void);
    extern Visual *gdk_x11_visual_get_xvisual(GdkVisual *);
    extern void gdk_x11_display_ungrab(GdkDisplay *);
    extern void gdk_x11_register_standard_event_type(GdkDisplay *, gint,
						     gint);
    extern void gdk_window_destroy_notify(GdkWindow *);
    extern const gchar *gdk_x11_get_xatom_name(Atom);
    extern Atom gdk_x11_get_xatom_by_name_for_display(GdkDisplay *,
						      const gchar *);
    extern GdkColormap *gdk_x11_colormap_foreign_new(GdkVisual *,
						     Colormap);
    extern gboolean gdk_net_wm_supports(GdkAtom);
    extern const gchar *gdk_x11_get_xatom_name_for_display(GdkDisplay *,
							   Atom);
    extern GdkVisual *gdkx_visual_get(VisualID);
    extern Atom gdk_x11_get_xatom_by_name(const gchar *);
    extern gpointer gdk_xid_table_lookup(XID);
    extern XID gdk_x11_drawable_get_xid(GdkDrawable *);
    extern Display *gdk_x11_gc_get_xdisplay(GdkGC *);
    extern Colormap gdk_x11_colormap_get_xcolormap(GdkColormap *);
    extern GdkDisplay *gdk_x11_lookup_xdisplay(Display *);
    extern GC gdk_x11_gc_get_xgc(GdkGC *);
    extern void gdk_x11_grab_server(void);
    extern int gdk_x11_screen_get_screen_number(GdkScreen *);
    extern const char *gdk_x11_screen_get_window_manager_name(GdkScreen *);
    extern GdkAtom gdk_x11_xatom_to_atom_for_display(GdkDisplay *, Atom);
    extern Screen *gdk_x11_screen_get_xscreen(GdkScreen *);
    extern void gdk_x11_ungrab_server(void);
    extern gint gdk_x11_get_default_screen(void);
    extern Display *gdk_x11_drawable_get_xdisplay(GdkDrawable *);
    extern GdkAtom gdk_x11_xatom_to_atom(Atom);
    extern Display *gdk_x11_colormap_get_xdisplay(GdkColormap *);
    extern void gdk_x11_window_set_user_time(GdkWindow *, guint32);
    extern Atom gdk_x11_atom_to_xatom(GdkAtom);
    extern XImage *gdk_x11_image_get_ximage(GdkImage *);
    extern Display *gdk_x11_cursor_get_xdisplay(GdkCursor *);
    extern void gdk_x11_display_grab(GdkDisplay *);
    extern Display *gdk_display;
    extern Display *gdk_x11_image_get_xdisplay(GdkImage *);
    extern Display *gdk_x11_get_default_xdisplay(void);
    extern gboolean gdk_x11_screen_supports_net_wm_hint(GdkScreen *,
							GdkAtom);
    extern void gdk_synthesize_window_state(GdkWindow *, GdkWindowState,
					    GdkWindowState);
    extern Display *gdk_x11_display_get_xdisplay(GdkDisplay *);
    extern Atom gdk_x11_atom_to_xatom_for_display(GdkDisplay *, GdkAtom);
    extern Cursor gdk_x11_cursor_get_xcursor(GdkCursor *);
#ifdef __cplusplus
}
#endif
#endif
