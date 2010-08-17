#ifndef _GTK_2_0_GDK_GDK_H_
#define _GTK_2_0_GDK_GDK_H_

#include <glib-2.0/glib.h>
#include <glib-2.0/glib-object.h>
#include <atk-1.0/atk/atk.h>
#include <pango-1.0/pango/pango.h>
#include <gtk-2.0/gdk-pixbuf/gdk-pixbuf.h>
#include <gtk-2.0/gdk-pixbuf-xlib/gdk-pixbuf-xlib.h>

#ifdef __cplusplus
extern "C" {
#endif


#define GDK_WINDOWING_X11
#define GDK_PIXMAP_OBJECT(object)	 \
	((GdkPixmapObject *) GDK_PIXMAP (object))
#define GDK_WINDOW_OBJECT(object)	 \
	((GdkWindowObject *) GDK_WINDOW (object))
#define GDK_TYPE_WINDOW_ATTRIBUTES_TYPE	 \
	(gdk_window_attributes_type_get_type())
#define GDK_COLORMAP_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_COLORMAP, \
	GdkColormapClass))
#define GDK_DEVICE_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_DEVICE, GdkDeviceClass))
#define GDK_DISPLAY_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_DISPLAY, \
	GdkDisplayClass))
#define GDK_DISPLAY_MANAGER_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_DISPLAY_MANAGER, \
	GdkDisplayManagerClass))
#define GDK_DRAG_CONTEXT_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_DRAG_CONTEXT, \
	GdkDragContextClass))
#define GDK_DRAWABLE_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_DRAWABLE, \
	GdkDrawableClass))
#define GDK_GC_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_GC, GdkGCClass))
#define GDK_IMAGE_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_IMAGE, GdkImageClass))
#define GDK_KEYMAP_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_KEYMAP, GdkKeymapClass))
#define GDK_PANGO_RENDERER_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_PANGO_RENDERER, \
	GdkPangoRendererClass))
#define GDK_PIXMAP_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_PIXMAP, \
	GdkPixmapObjectClass))
#define GDK_SCREEN_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_SCREEN, GdkScreenClass))
#define GDK_VISUAL_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_VISUAL, GdkVisualClass))
#define GDK_WINDOW_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), GDK_TYPE_WINDOW, \
	GdkWindowObjectClass))
#define GDK_IS_COLORMAP_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_COLORMAP))
#define GDK_IS_DEVICE_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_DEVICE))
#define GDK_IS_DISPLAY_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_DISPLAY))
#define GDK_IS_DISPLAY_MANAGER_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_DISPLAY_MANAGER))
#define GDK_IS_DRAG_CONTEXT_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_DRAG_CONTEXT))
#define GDK_IS_DRAWABLE_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_DRAWABLE))
#define GDK_IS_GC_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_GC))
#define GDK_IS_IMAGE_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_IMAGE))
#define GDK_IS_KEYMAP_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_KEYMAP))
#define GDK_IS_PANGO_RENDERER_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_PANGO_RENDERER))
#define GDK_IS_PIXMAP_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_PIXMAP))
#define GDK_IS_SCREEN_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_SCREEN))
#define GDK_IS_VISUAL_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_VISUAL))
#define GDK_IS_WINDOW_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), GDK_TYPE_WINDOW))
#define GDK_COLORMAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_COLORMAP, \
	GdkColormap))
#define GDK_DEVICE(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_DEVICE, GdkDevice))
#define GDK_DISPLAY_OBJECT(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_DISPLAY, GdkDisplay))
#define GDK_DISPLAY_MANAGER(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_DISPLAY_MANAGER, \
	GdkDisplayManager))
#define GDK_DRAG_CONTEXT(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_DRAG_CONTEXT, \
	GdkDragContext))
#define GDK_DRAWABLE(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_DRAWABLE, \
	GdkDrawable))
#define GDK_GC(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_GC, GdkGC))
#define GDK_IMAGE(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_IMAGE, GdkImage))
#define GDK_KEYMAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_KEYMAP, GdkKeymap))
#define GDK_PANGO_RENDERER(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_PANGO_RENDERER, \
	GdkPangoRenderer))
#define GDK_PIXMAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_PIXMAP, GdkPixmap))
#define GDK_SCREEN(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_SCREEN, GdkScreen))
#define GDK_VISUAL(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_VISUAL, GdkVisual))
#define GDK_WINDOW(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), GDK_TYPE_WINDOW, GdkWindow))
#define GDK_IS_COLORMAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_COLORMAP))
#define GDK_IS_DEVICE(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_DEVICE))
#define GDK_IS_DISPLAY(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_DISPLAY))
#define GDK_IS_DISPLAY_MANAGER(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_DISPLAY_MANAGER))
#define GDK_IS_DRAG_CONTEXT(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_DRAG_CONTEXT))
#define GDK_IS_DRAWABLE(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_DRAWABLE))
#define GDK_IS_GC(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_GC))
#define GDK_IS_IMAGE(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_IMAGE))
#define GDK_IS_KEYMAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_KEYMAP))
#define GDK_IS_PANGO_RENDERER(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_PANGO_RENDERER))
#define GDK_IS_PIXMAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_PIXMAP))
#define GDK_IS_SCREEN(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_SCREEN))
#define GDK_IS_VISUAL(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_VISUAL))
#define GDK_IS_WINDOW(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), GDK_TYPE_WINDOW))
#define GDK_COLORMAP_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_COLORMAP, \
	GdkColormapClass))
#define GDK_DEVICE_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_DEVICE, GdkDeviceClass))
#define GDK_DISPLAY_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_DISPLAY, \
	GdkDisplayClass))
#define GDK_DISPLAY_MANAGER_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_DISPLAY_MANAGER, \
	GdkDisplayManagerClass))
#define GDK_DRAG_CONTEXT_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_DRAG_CONTEXT, \
	GdkDragContextClass))
#define GDK_DRAWABLE_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_DRAWABLE, \
	GdkDrawableClass))
#define GDK_GC_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_GC, GdkGCClass))
#define GDK_IMAGE_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_IMAGE, GdkImageClass))
#define GDK_KEYMAP_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_KEYMAP, GdkKeymapClass))
#define GDK_PANGO_RENDERER_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_PANGO_RENDERER, \
	GdkPangoRendererClass))
#define GDK_PIXMAP_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_PIXMAP, \
	GdkPixmapObjectClass))
#define GDK_SCREEN_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_SCREEN, GdkScreenClass))
#define GDK_VISUAL_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_VISUAL, GdkVisualClass))
#define GDK_WINDOW_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), GDK_TYPE_WINDOW, \
	GdkWindowObjectClass))
#define GDK_THREADS_ENTER()	 \
	G_STMT_START { if (gdk_threads_lock) (*gdk_threads_lock) (); } \
	G_STMT_END
#define GDK_THREADS_LEAVE()	 \
	G_STMT_START { if (gdk_threads_unlock) (*gdk_threads_unlock) (); } \
	G_STMT_END
#define GDK_POINTER_TO_ATOM(ptr)	((GdkAtom)(ptr))
#define _GDK_MAKE_ATOM(val)	((GdkAtom)GUINT_TO_POINTER(val))
#define GDK_ATOM_TO_POINTER(atom)	(atom)
#define GDK_TYPE_AXIS_USE	(gdk_axis_use_get_type())
#define GDK_TYPE_BYTE_ORDER	(gdk_byte_order_get_type())
#define GDK_TYPE_CAP_STYLE	(gdk_cap_style_get_type())
#define GDK_TYPE_COLORMAP	(gdk_colormap_get_type ())
#define GDK_TYPE_COLOR	(gdk_color_get_type ())
#define GDK_TYPE_CROSSING_MODE	(gdk_crossing_mode_get_type())
#define GDK_TYPE_CURSOR	(gdk_cursor_get_type ())
#define GDK_TYPE_CURSOR_TYPE	(gdk_cursor_type_get_type())
#define GDK_TYPE_DEVICE	(gdk_device_get_type ())
#define GDK_TYPE_DISPLAY	(gdk_display_get_type ())
#define GDK_TYPE_DISPLAY_MANAGER	(gdk_display_manager_get_type ())
#define GDK_TYPE_DRAG_ACTION	(gdk_drag_action_get_type())
#define GDK_TYPE_DRAG_CONTEXT	(gdk_drag_context_get_type ())
#define GDK_TYPE_DRAG_PROTOCOL	(gdk_drag_protocol_get_type())
#define GDK_TYPE_DRAWABLE	(gdk_drawable_get_type ())
#define GDK_TYPE_EVENT	(gdk_event_get_type ())
#define GDK_TYPE_EVENT_MASK	(gdk_event_mask_get_type())
#define GDK_TYPE_EVENT_TYPE	(gdk_event_type_get_type())
#define GDK_TYPE_EXTENSION_MODE	(gdk_extension_mode_get_type())
#define GDK_TYPE_FILL	(gdk_fill_get_type())
#define GDK_TYPE_FILL_RULE	(gdk_fill_rule_get_type())
#define GDK_TYPE_FILTER_RETURN	(gdk_filter_return_get_type())
#define GDK_TYPE_FONT_TYPE	(gdk_font_type_get_type())
#define GDK_TYPE_FUNCTION	(gdk_function_get_type())
#define GDK_TYPE_GC	(gdk_gc_get_type ())
#define GDK_TYPE_GC_VALUES_MASK	(gdk_gc_values_mask_get_type())
#define GDK_TYPE_GRAB_STATUS	(gdk_grab_status_get_type())
#define GDK_TYPE_GRAVITY	(gdk_gravity_get_type())
#define GDK_TYPE_IMAGE	(gdk_image_get_type ())
#define GDK_TYPE_IMAGE_TYPE	(gdk_image_type_get_type())
#define GDK_TYPE_INPUT_CONDITION	(gdk_input_condition_get_type())
#define GDK_TYPE_INPUT_MODE	(gdk_input_mode_get_type())
#define GDK_TYPE_INPUT_SOURCE	(gdk_input_source_get_type())
#define GDK_TYPE_JOIN_STYLE	(gdk_join_style_get_type())
#define GDK_TYPE_KEYMAP	(gdk_keymap_get_type ())
#define GDK_TYPE_LINE_STYLE	(gdk_line_style_get_type())
#define GDK_TYPE_MODIFIER_TYPE	(gdk_modifier_type_get_type())
#define GDK_TYPE_NOTIFY_TYPE	(gdk_notify_type_get_type())
#define GDK_TYPE_OVERLAP_TYPE	(gdk_overlap_type_get_type())
#define GDK_TYPE_OWNER_CHANGE	(gdk_owner_change_get_type())
#define GDK_TYPE_PANGO_RENDERER	(gdk_pango_renderer_get_type())
#define GDK_TYPE_PIXMAP	(gdk_pixmap_get_type ())
#define GDK_TYPE_PROPERTY_STATE	(gdk_property_state_get_type())
#define GDK_TYPE_PROP_MODE	(gdk_prop_mode_get_type())
#define GDK_TYPE_RECTANGLE	(gdk_rectangle_get_type ())
#define GDK_TYPE_RGB_DITHER	(gdk_rgb_dither_get_type())
#define GDK_TYPE_SCREEN	(gdk_screen_get_type ())
#define GDK_TYPE_SCROLL_DIRECTION	(gdk_scroll_direction_get_type())
#define GDK_TYPE_SETTING_ACTION	(gdk_setting_action_get_type())
#define GDK_TYPE_STATUS	(gdk_status_get_type())
#define GDK_TYPE_SUBWINDOW_MODE	(gdk_subwindow_mode_get_type())
#define GDK_TYPE_VISIBILITY_STATE	(gdk_visibility_state_get_type())
#define GDK_TYPE_VISUAL	(gdk_visual_get_type ())
#define GDK_TYPE_VISUAL_TYPE	(gdk_visual_type_get_type())
#define GDK_TYPE_WINDOW_CLASS	(gdk_window_class_get_type())
#define GDK_TYPE_WINDOW_EDGE	(gdk_window_edge_get_type())
#define GDK_TYPE_WINDOW_HINTS	(gdk_window_hints_get_type())
#define GDK_TYPE_WINDOW	(gdk_window_object_get_type ())
#define GDK_TYPE_WINDOW_STATE	(gdk_window_state_get_type())
#define GDK_TYPE_WINDOW_TYPE	(gdk_window_type_get_type())
#define GDK_TYPE_WINDOW_TYPE_HINT	(gdk_window_type_hint_get_type())
#define GDK_TYPE_WM_DECORATION	(gdk_wm_decoration_get_type())
#define GDK_TYPE_WM_FUNCTION	(gdk_wm_function_get_type())
#define GDK_PRIORITY_EVENTS	(G_PRIORITY_DEFAULT)
#define GDK_PRIORITY_REDRAW	(G_PRIORITY_HIGH_IDLE + 20)
#define GDK_CURRENT_TIME	0L
#define GDK_HAVE_WCHAR_H	1
#define GDK_HAVE_WCTYPE_H	1
#define GDK_MAX_TIMECOORD_AXES	128
#define GDK_PARENT_RELATIVE	1L
#define GDKVAR	extern
#define gdk_draw_bitmap	gdk_draw_drawable
#define GDK_NONE	_GDK_MAKE_ATOM (0)
#define GDK_SELECTION_PRIMARY	_GDK_MAKE_ATOM (1)
#define GDK_SELECTION_TYPE_DRAWABLE	_GDK_MAKE_ATOM (17)
#define GDK_TARGET_DRAWABLE	_GDK_MAKE_ATOM (17)
#define GDK_SELECTION_TYPE_INTEGER	_GDK_MAKE_ATOM (19)
#define GDK_SELECTION_SECONDARY	_GDK_MAKE_ATOM (2)
#define GDK_SELECTION_TYPE_PIXMAP	_GDK_MAKE_ATOM (20)
#define GDK_TARGET_PIXMAP	_GDK_MAKE_ATOM (20)
#define GDK_SELECTION_TYPE_STRING	_GDK_MAKE_ATOM (31)
#define GDK_TARGET_STRING	_GDK_MAKE_ATOM (31)
#define GDK_SELECTION_TYPE_WINDOW	_GDK_MAKE_ATOM (33)
#define GDK_SELECTION_TYPE_ATOM	_GDK_MAKE_ATOM (4)
#define GDK_SELECTION_TYPE_BITMAP	_GDK_MAKE_ATOM (5)
#define GDK_TARGET_BITMAP	_GDK_MAKE_ATOM (5)
#define GDK_SELECTION_CLIPBOARD	_GDK_MAKE_ATOM (69)
#define GDK_SELECTION_TYPE_COLORMAP	_GDK_MAKE_ATOM (7)
#define GDK_TARGET_COLORMAP	_GDK_MAKE_ATOM (7)


    typedef struct _GdkDrawable GdkWindow;

    typedef struct _GdkColor GdkColor;

    typedef enum {
	GDK_VISUAL_STATIC_GRAY = 0,
	GDK_VISUAL_GRAYSCALE = 1,
	GDK_VISUAL_STATIC_COLOR = 2,
	GDK_VISUAL_PSEUDO_COLOR = 3,
	GDK_VISUAL_TRUE_COLOR = 4,
	GDK_VISUAL_DIRECT_COLOR = 5
    } GdkVisualType;

    typedef enum {
	GDK_LSB_FIRST = 0,
	GDK_MSB_FIRST = 1
    } GdkByteOrder;

    typedef struct _GdkVisual GdkVisual;

    typedef struct _GdkColormap GdkColormap;

    typedef struct _GdkGC GdkGC;

    typedef struct _GdkDrawable GdkDrawable;

    typedef enum {
	GDK_SOURCE_MOUSE = 0,
	GDK_SOURCE_PEN = 1,
	GDK_SOURCE_ERASER = 2,
	GDK_SOURCE_CURSOR = 3
    } GdkInputSource;

    typedef enum {
	GDK_MODE_DISABLED = 0,
	GDK_MODE_SCREEN = 1,
	GDK_MODE_WINDOW = 2
    } GdkInputMode;

    typedef enum {
	GDK_AXIS_IGNORE = 0,
	GDK_AXIS_X = 1,
	GDK_AXIS_Y = 2,
	GDK_AXIS_PRESSURE = 3,
	GDK_AXIS_XTILT = 4,
	GDK_AXIS_YTILT = 5,
	GDK_AXIS_WHEEL = 6,
	GDK_AXIS_LAST = 7
    } GdkAxisUse;

    typedef struct _GdkDeviceAxis GdkDeviceAxis;

    typedef enum {
	GDK_SHIFT_MASK = 1,
	GDK_LOCK_MASK = 2,
	GDK_CONTROL_MASK = 4,
	GDK_MOD1_MASK = 8,
	GDK_MOD2_MASK = 16,
	GDK_MOD3_MASK = 32,
	GDK_MOD4_MASK = 64,
	GDK_MOD5_MASK = 128,
	GDK_BUTTON1_MASK = 256,
	GDK_BUTTON2_MASK = 512,
	GDK_BUTTON3_MASK = 1024,
	GDK_BUTTON4_MASK = 2048,
	GDK_BUTTON5_MASK = 4096,
	GDK_RELEASE_MASK = 1073741824,
	GDK_MODIFIER_MASK = 1073750015
    } GdkModifierType;

    typedef struct _GdkDeviceKey GdkDeviceKey;

    typedef struct _GdkDevice GdkDevice;

    typedef struct _GdkDisplay GdkDisplay;

    typedef struct _GdkScreen GdkScreen;

    typedef struct _GdkDisplayPointerHooks GdkDisplayPointerHooks;

    typedef enum {
	GDK_EXPOSURE_MASK = 2,
	GDK_POINTER_MOTION_MASK = 4,
	GDK_POINTER_MOTION_HINT_MASK = 8,
	GDK_BUTTON_MOTION_MASK = 16,
	GDK_BUTTON1_MOTION_MASK = 32,
	GDK_BUTTON2_MOTION_MASK = 64,
	GDK_BUTTON3_MOTION_MASK = 128,
	GDK_BUTTON_PRESS_MASK = 256,
	GDK_BUTTON_RELEASE_MASK = 512,
	GDK_KEY_PRESS_MASK = 1024,
	GDK_KEY_RELEASE_MASK = 2048,
	GDK_ENTER_NOTIFY_MASK = 4096,
	GDK_LEAVE_NOTIFY_MASK = 8192,
	GDK_FOCUS_CHANGE_MASK = 16384,
	GDK_STRUCTURE_MASK = 32768,
	GDK_PROPERTY_CHANGE_MASK = 65536,
	GDK_VISIBILITY_NOTIFY_MASK = 131072,
	GDK_PROXIMITY_IN_MASK = 262144,
	GDK_PROXIMITY_OUT_MASK = 524288,
	GDK_SUBSTRUCTURE_MASK = 1048576,
	GDK_SCROLL_MASK = 2097152,
	GDK_ALL_EVENTS_MASK = 4194302
    } GdkEventMask;

    typedef enum {
	GDK_X_CURSOR = 0,
	GDK_ARROW = 2,
	GDK_BASED_ARROW_DOWN = 4,
	GDK_BASED_ARROW_UP = 6,
	GDK_BOAT = 8,
	GDK_BOGOSITY = 10,
	GDK_BOTTOM_LEFT_CORNER = 12,
	GDK_BOTTOM_RIGHT_CORNER = 14,
	GDK_BOTTOM_SIDE = 16,
	GDK_BOTTOM_TEE = 18,
	GDK_BOX_SPIRAL = 20,
	GDK_CENTER_PTR = 22,
	GDK_CIRCLE = 24,
	GDK_CLOCK = 26,
	GDK_COFFEE_MUG = 28,
	GDK_CROSS = 30,
	GDK_CROSS_REVERSE = 32,
	GDK_CROSSHAIR = 34,
	GDK_DIAMOND_CROSS = 36,
	GDK_DOT = 38,
	GDK_DOTBOX = 40,
	GDK_DOUBLE_ARROW = 42,
	GDK_DRAFT_LARGE = 44,
	GDK_DRAFT_SMALL = 46,
	GDK_DRAPED_BOX = 48,
	GDK_EXCHANGE = 50,
	GDK_FLEUR = 52,
	GDK_GOBBLER = 54,
	GDK_GUMBY = 56,
	GDK_HAND1 = 58,
	GDK_HAND2 = 60,
	GDK_HEART = 62,
	GDK_ICON = 64,
	GDK_IRON_CROSS = 66,
	GDK_LEFT_PTR = 68,
	GDK_LEFT_SIDE = 70,
	GDK_LEFT_TEE = 72,
	GDK_LEFTBUTTON = 74,
	GDK_LL_ANGLE = 76,
	GDK_LR_ANGLE = 78,
	GDK_MAN = 80,
	GDK_MIDDLEBUTTON = 82,
	GDK_MOUSE = 84,
	GDK_PENCIL = 86,
	GDK_PIRATE = 88,
	GDK_PLUS = 90,
	GDK_QUESTION_ARROW = 92,
	GDK_RIGHT_PTR = 94,
	GDK_RIGHT_SIDE = 96,
	GDK_RIGHT_TEE = 98,
	GDK_RIGHTBUTTON = 100,
	GDK_RTL_LOGO = 102,
	GDK_SAILBOAT = 104,
	GDK_SB_DOWN_ARROW = 106,
	GDK_SB_H_DOUBLE_ARROW = 108,
	GDK_SB_LEFT_ARROW = 110,
	GDK_SB_RIGHT_ARROW = 112,
	GDK_SB_UP_ARROW = 114,
	GDK_SB_V_DOUBLE_ARROW = 116,
	GDK_SHUTTLE = 118,
	GDK_SIZING = 120,
	GDK_SPIDER = 122,
	GDK_SPRAYCAN = 124,
	GDK_STAR = 126,
	GDK_TARGET = 128,
	GDK_TCROSS = 130,
	GDK_TOP_LEFT_ARROW = 132,
	GDK_TOP_LEFT_CORNER = 134,
	GDK_TOP_RIGHT_CORNER = 136,
	GDK_TOP_SIDE = 138,
	GDK_TOP_TEE = 140,
	GDK_TREK = 142,
	GDK_UL_ANGLE = 144,
	GDK_UMBRELLA = 146,
	GDK_UR_ANGLE = 148,
	GDK_WATCH = 150,
	GDK_XTERM = 152,
	GDK_LAST_CURSOR = 153,
	GDK_CURSOR_IS_PIXMAP = -1
    } GdkCursorType;

    typedef struct _GdkCursor GdkCursor;

    typedef struct _GdkKeymap GdkKeymap;

    typedef struct _GdkAtom *GdkAtom;

    typedef enum {
	GDK_FILTER_CONTINUE = 0,
	GDK_FILTER_TRANSLATE = 1,
	GDK_FILTER_REMOVE = 2
    } GdkFilterReturn;

    typedef void GdkXEvent;

    typedef enum {
	GDK_NOTHING = -1,
	GDK_DELETE = 0,
	GDK_DESTROY = 1,
	GDK_EXPOSE = 2,
	GDK_MOTION_NOTIFY = 3,
	GDK_BUTTON_PRESS = 4,
	GDK_2BUTTON_PRESS = 5,
	GDK_3BUTTON_PRESS = 6,
	GDK_BUTTON_RELEASE = 7,
	GDK_KEY_PRESS = 8,
	GDK_KEY_RELEASE = 9,
	GDK_ENTER_NOTIFY = 10,
	GDK_LEAVE_NOTIFY = 11,
	GDK_FOCUS_CHANGE = 12,
	GDK_CONFIGURE = 13,
	GDK_MAP = 14,
	GDK_UNMAP = 15,
	GDK_PROPERTY_NOTIFY = 16,
	GDK_SELECTION_CLEAR = 17,
	GDK_SELECTION_REQUEST = 18,
	GDK_SELECTION_NOTIFY = 19,
	GDK_PROXIMITY_IN = 20,
	GDK_PROXIMITY_OUT = 21,
	GDK_DRAG_ENTER = 22,
	GDK_DRAG_LEAVE = 23,
	GDK_DRAG_MOTION = 24,
	GDK_DRAG_STATUS = 25,
	GDK_DROP_START = 26,
	GDK_DROP_FINISHED = 27,
	GDK_CLIENT_EVENT = 28,
	GDK_VISIBILITY_NOTIFY = 29,
	GDK_NO_EXPOSE = 30,
	GDK_SCROLL = 31,
	GDK_WINDOW_STATE = 32,
	GDK_SETTING = 33,
	GDK_OWNER_CHANGE = 34
    } GdkEventType;

    typedef struct _GdkEventAny GdkEventAny;

    typedef struct _GdkRectangle GdkRectangle;

    typedef struct _GdkRegion GdkRegion;

    typedef struct _GdkEventExpose GdkEventExpose;

    typedef struct _GdkEventNoExpose GdkEventNoExpose;

    typedef enum {
	GDK_VISIBILITY_UNOBSCURED = 0,
	GDK_VISIBILITY_PARTIAL = 1,
	GDK_VISIBILITY_FULLY_OBSCURED = 2
    } GdkVisibilityState;

    typedef struct _GdkEventVisibility GdkEventVisibility;

    typedef struct _GdkEventMotion GdkEventMotion;

    typedef struct _GdkEventButton GdkEventButton;

    typedef enum {
	GDK_SCROLL_UP = 0,
	GDK_SCROLL_DOWN = 1,
	GDK_SCROLL_LEFT = 2,
	GDK_SCROLL_RIGHT = 3
    } GdkScrollDirection;

    typedef struct _GdkEventScroll GdkEventScroll;

    typedef struct _GdkEventKey GdkEventKey;

    typedef enum {
	GDK_CROSSING_NORMAL = 0,
	GDK_CROSSING_GRAB = 1,
	GDK_CROSSING_UNGRAB = 2
    } GdkCrossingMode;

    typedef enum {
	GDK_NOTIFY_ANCESTOR = 0,
	GDK_NOTIFY_VIRTUAL = 1,
	GDK_NOTIFY_INFERIOR = 2,
	GDK_NOTIFY_NONLINEAR = 3,
	GDK_NOTIFY_NONLINEAR_VIRTUAL = 4,
	GDK_NOTIFY_UNKNOWN = 5
    } GdkNotifyType;

    typedef struct _GdkEventCrossing GdkEventCrossing;

    typedef struct _GdkEventFocus GdkEventFocus;

    typedef struct _GdkEventConfigure GdkEventConfigure;

    typedef struct _GdkEventProperty GdkEventProperty;

    typedef guint32 GdkNativeWindow;

    typedef struct _GdkEventSelection GdkEventSelection;

    typedef enum {
	GDK_OWNER_CHANGE_NEW_OWNER = 0,
	GDK_OWNER_CHANGE_DESTROY = 1,
	GDK_OWNER_CHANGE_CLOSE = 2
    } GdkOwnerChange;

    typedef struct _GdkEventOwnerChange GdkEventOwnerChange;

    typedef struct _GdkEventProximity GdkEventProximity;

    typedef struct _GdkEventClient GdkEventClient;

    typedef enum {
	GDK_DRAG_PROTO_MOTIF = 0,
	GDK_DRAG_PROTO_XDND = 1,
	GDK_DRAG_PROTO_ROOTWIN = 2,
	GDK_DRAG_PROTO_NONE = 3,
	GDK_DRAG_PROTO_WIN32_DROPFILES = 4,
	GDK_DRAG_PROTO_OLE2 = 5,
	GDK_DRAG_PROTO_LOCAL = 6
    } GdkDragProtocol;

    typedef enum {
	GDK_ACTION_DEFAULT = 1,
	GDK_ACTION_COPY = 2,
	GDK_ACTION_MOVE = 4,
	GDK_ACTION_LINK = 8,
	GDK_ACTION_PRIVATE = 16,
	GDK_ACTION_ASK = 32
    } GdkDragAction;

    typedef struct _GdkDragContext GdkDragContext;

    typedef short int gshort;

    typedef struct _GdkEventDND GdkEventDND;

    typedef enum {
	GDK_WINDOW_STATE_WITHDRAWN = 1,
	GDK_WINDOW_STATE_ICONIFIED = 2,
	GDK_WINDOW_STATE_MAXIMIZED = 4,
	GDK_WINDOW_STATE_STICKY = 8,
	GDK_WINDOW_STATE_FULLSCREEN = 16,
	GDK_WINDOW_STATE_ABOVE = 32,
	GDK_WINDOW_STATE_BELOW = 64
    } GdkWindowState;

    typedef struct _GdkEventWindowState GdkEventWindowState;

    typedef enum {
	GDK_SETTING_ACTION_NEW = 0,
	GDK_SETTING_ACTION_CHANGED = 1,
	GDK_SETTING_ACTION_DELETED = 2
    } GdkSettingAction;

    typedef struct _GdkEventSetting GdkEventSetting;

    typedef union _GdkEvent GdkEvent;

    typedef GdkFilterReturn(*GdkFilterFunc) (GdkXEvent *, GdkEvent *,
					     gpointer);

    typedef struct _GdkDrawable GdkPixmap;

    typedef struct _GdkDrawable GdkBitmap;

    typedef struct _GdkDisplayManager GdkDisplayManager;

    typedef enum {
	GDK_CLIP_BY_CHILDREN = 0,
	GDK_INCLUDE_INFERIORS = 1
    } GdkSubwindowMode;

    typedef enum {
	GDK_WINDOW_EDGE_NORTH_WEST = 0,
	GDK_WINDOW_EDGE_NORTH = 1,
	GDK_WINDOW_EDGE_NORTH_EAST = 2,
	GDK_WINDOW_EDGE_WEST = 3,
	GDK_WINDOW_EDGE_EAST = 4,
	GDK_WINDOW_EDGE_SOUTH_WEST = 5,
	GDK_WINDOW_EDGE_SOUTH = 6,
	GDK_WINDOW_EDGE_SOUTH_EAST = 7
    } GdkWindowEdge;

    typedef enum {
	GDK_IMAGE_NORMAL = 0,
	GDK_IMAGE_SHARED = 1,
	GDK_IMAGE_FASTEST = 2
    } GdkImageType;

    typedef struct _GdkImage GdkImage;

    typedef struct _GdkPangoRendererPrivate GdkPangoRendererPrivate;

    typedef struct _GdkPangoRenderer GdkPangoRenderer;

    typedef enum {
	GDK_GRAB_SUCCESS = 0,
	GDK_GRAB_ALREADY_GRABBED = 1,
	GDK_GRAB_INVALID_TIME = 2,
	GDK_GRAB_NOT_VIEWABLE = 3,
	GDK_GRAB_FROZEN = 4
    } GdkGrabStatus;

    typedef enum {
	GDK_SOLID = 0,
	GDK_TILED = 1,
	GDK_STIPPLED = 2,
	GDK_OPAQUE_STIPPLED = 3
    } GdkFill;

    typedef enum {
	GDK_WINDOW_TYPE_HINT_NORMAL = 0,
	GDK_WINDOW_TYPE_HINT_DIALOG = 1,
	GDK_WINDOW_TYPE_HINT_MENU = 2,
	GDK_WINDOW_TYPE_HINT_TOOLBAR = 3,
	GDK_WINDOW_TYPE_HINT_SPLASHSCREEN = 4,
	GDK_WINDOW_TYPE_HINT_UTILITY = 5,
	GDK_WINDOW_TYPE_HINT_DOCK = 6,
	GDK_WINDOW_TYPE_HINT_DESKTOP = 7
    } GdkWindowTypeHint;

    typedef struct _GdkTimeCoord GdkTimeCoord;

    typedef struct _GdkPoint GdkPoint;

    typedef struct _GdkFont GdkFont;

    typedef enum {
	GDK_DECOR_ALL = 1,
	GDK_DECOR_BORDER = 2,
	GDK_DECOR_RESIZEH = 4,
	GDK_DECOR_TITLE = 8,
	GDK_DECOR_MENU = 16,
	GDK_DECOR_MINIMIZE = 32,
	GDK_DECOR_MAXIMIZE = 64
    } GdkWMDecoration;

    typedef enum {
	GDK_FUNC_ALL = 1,
	GDK_FUNC_RESIZE = 2,
	GDK_FUNC_MOVE = 4,
	GDK_FUNC_MINIMIZE = 8,
	GDK_FUNC_MAXIMIZE = 16,
	GDK_FUNC_CLOSE = 32
    } GdkWMFunction;

    typedef struct _GdkKeymapKey GdkKeymapKey;

    typedef enum {
	GDK_RGB_DITHER_NONE = 0,
	GDK_RGB_DITHER_NORMAL = 1,
	GDK_RGB_DITHER_MAX = 2
    } GdkRgbDither;

    typedef struct _GdkRgbCmap GdkRgbCmap;

    typedef enum {
	GDK_COPY = 0,
	GDK_INVERT = 1,
	GDK_XOR = 2,
	GDK_CLEAR = 3,
	GDK_AND = 4,
	GDK_AND_REVERSE = 5,
	GDK_AND_INVERT = 6,
	GDK_NOOP = 7,
	GDK_OR = 8,
	GDK_EQUIV = 9,
	GDK_OR_REVERSE = 10,
	GDK_COPY_INVERT = 11,
	GDK_OR_INVERT = 12,
	GDK_NAND = 13,
	GDK_NOR = 14,
	GDK_SET = 15
    } GdkFunction;

    typedef enum {
	GDK_LINE_SOLID = 0,
	GDK_LINE_ON_OFF_DASH = 1,
	GDK_LINE_DOUBLE_DASH = 2
    } GdkLineStyle;

    typedef enum {
	GDK_CAP_NOT_LAST = 0,
	GDK_CAP_BUTT = 1,
	GDK_CAP_ROUND = 2,
	GDK_CAP_PROJECTING = 3
    } GdkCapStyle;

    typedef enum {
	GDK_JOIN_MITER = 0,
	GDK_JOIN_ROUND = 1,
	GDK_JOIN_BEVEL = 2
    } GdkJoinStyle;

    typedef struct _GdkGCValues GdkGCValues;

    typedef enum {
	GDK_GC_FOREGROUND = 1,
	GDK_GC_BACKGROUND = 2,
	GDK_GC_FONT = 4,
	GDK_GC_FUNCTION = 8,
	GDK_GC_FILL = 16,
	GDK_GC_TILE = 32,
	GDK_GC_STIPPLE = 64,
	GDK_GC_CLIP_MASK = 128,
	GDK_GC_SUBWINDOW = 256,
	GDK_GC_TS_X_ORIGIN = 512,
	GDK_GC_TS_Y_ORIGIN = 1024,
	GDK_GC_CLIP_X_ORIGIN = 2048,
	GDK_GC_CLIP_Y_ORIGIN = 4096,
	GDK_GC_EXPOSURES = 8192,
	GDK_GC_LINE_WIDTH = 16384,
	GDK_GC_LINE_STYLE = 32768,
	GDK_GC_CAP_STYLE = 65536,
	GDK_GC_JOIN_STYLE = 131072
    } GdkGCValuesMask;

    typedef enum {
	GDK_WINDOW_ROOT = 0,
	GDK_WINDOW_TOPLEVEL = 1,
	GDK_WINDOW_CHILD = 2,
	GDK_WINDOW_DIALOG = 3,
	GDK_WINDOW_TEMP = 4,
	GDK_WINDOW_FOREIGN = 5
    } GdkWindowType;

    typedef struct _GdkSpan GdkSpan;

    typedef void (*GdkSpanFunc) (GdkSpan *, gpointer);

    typedef enum {
	GDK_GRAVITY_NORTH_WEST = 1,
	GDK_GRAVITY_NORTH = 2,
	GDK_GRAVITY_NORTH_EAST = 3,
	GDK_GRAVITY_WEST = 4,
	GDK_GRAVITY_CENTER = 5,
	GDK_GRAVITY_EAST = 6,
	GDK_GRAVITY_SOUTH_WEST = 7,
	GDK_GRAVITY_SOUTH = 8,
	GDK_GRAVITY_SOUTH_EAST = 9,
	GDK_GRAVITY_STATIC = 10
    } GdkGravity;

    typedef struct _GdkGeometry GdkGeometry;

    typedef enum {
	GDK_HINT_POS = 1,
	GDK_HINT_MIN_SIZE = 2,
	GDK_HINT_MAX_SIZE = 4,
	GDK_HINT_BASE_SIZE = 8,
	GDK_HINT_ASPECT = 16,
	GDK_HINT_RESIZE_INC = 32,
	GDK_HINT_WIN_GRAVITY = 64,
	GDK_HINT_USER_POS = 128,
	GDK_HINT_USER_SIZE = 256
    } GdkWindowHints;

    typedef void (*GdkEventFunc) (GdkEvent *, gpointer);

    typedef enum {
	GDK_OVERLAP_RECTANGLE_IN = 0,
	GDK_OVERLAP_RECTANGLE_OUT = 1,
	GDK_OVERLAP_RECTANGLE_PART = 2
    } GdkOverlapType;

    typedef struct _GdkSegment GdkSegment;

    typedef enum {
	GDK_PROP_MODE_REPLACE = 0,
	GDK_PROP_MODE_PREPEND = 1,
	GDK_PROP_MODE_APPEND = 2
    } GdkPropMode;

    typedef enum {
	GDK_INPUT_OUTPUT = 0,
	GDK_INPUT_ONLY = 1
    } GdkWindowClass;

    typedef struct _GdkWindowAttr GdkWindowAttr;

    typedef struct _GdkTrapezoid GdkTrapezoid;

    typedef enum {
	GDK_EVEN_ODD_RULE = 0,
	GDK_WINDING_RULE = 1
    } GdkFillRule;

    typedef struct _GdkPointerHooks GdkPointerHooks;

    typedef enum {
	GDK_EXTENSION_EVENTS_NONE = 0,
	GDK_EXTENSION_EVENTS_ALL = 1,
	GDK_EXTENSION_EVENTS_CURSOR = 2
    } GdkExtensionMode;

    typedef struct _GdkWindowObject GdkWindowObject;

    typedef struct _GdkScreenClass GdkScreenClass;

    typedef guint32 GdkWChar;

    typedef struct _GdkPixmapObject GdkPixmapObject;

    typedef enum {
	GDK_INPUT_READ = 1,
	GDK_INPUT_WRITE = 2,
	GDK_INPUT_EXCEPTION = 4
    } GdkInputCondition;

    typedef void (*GdkInputFunction) (gpointer, gint, GdkInputCondition);

    typedef struct _GdkImageClass GdkImageClass;

    typedef void (*GdkDestroyNotify) (gpointer);

    typedef struct _GdkKeymapClass GdkKeymapClass;

    typedef struct _GdkDrawableClass GdkDrawableClass;

    typedef struct _GdkPangoAttrEmbossed GdkPangoAttrEmbossed;

    typedef struct _GdkDisplayManagerClass GdkDisplayManagerClass;

    typedef struct _GdkPixmapObjectClass GdkPixmapObjectClass;

    typedef struct _GdkPangoRendererClass GdkPangoRendererClass;

    typedef struct _GdkDisplayClass GdkDisplayClass;

    typedef struct _GdkPangoAttrStipple GdkPangoAttrStipple;

    typedef struct _GdkColormapClass GdkColormapClass;

    typedef struct _GdkDragContextClass GdkDragContextClass;

    typedef struct _GdkWindowObjectClass GdkWindowObjectClass;

    typedef struct _GdkGCClass GdkGCClass;

    typedef struct _GdkDeviceClass GdkDeviceClass;

    typedef struct _GdkVisualClass GdkVisualClass;

    typedef enum {
	GDK_OK = 0,
	GDK_ERROR = -1,
	GDK_ERROR_PARAM = -2,
	GDK_ERROR_FILE = -3,
	GDK_ERROR_MEM = -4
    } GdkStatus;

    typedef enum {
	GDK_PROPERTY_NEW_VALUE,
	GDK_PROPERTY_DELETE
    } GdkPropertyState;

    typedef enum {
	GDK_WA_TITLE = 1 << 1,
	GDK_WA_X = 1 << 2,
	GDK_WA_Y = 1 << 3,
	GDK_WA_CURSOR = 1 << 4,
	GDK_WA_COLORMAP = 1 << 5,
	GDK_WA_VISUAL = 1 << 6,
	GDK_WA_WMCLASS = 1 << 7,
	GDK_WA_NOREDIR = 1 << 8
    } GdkWindowAttributesType;


    struct _GdkDrawable {
	GObject parent_instance;
    };


    struct _GdkColor {
	guint32 pixel;
	guint16 red;
	guint16 green;
	guint16 blue;
    };


    struct _GdkVisual {
	GObject parent_instance;
	GdkVisualType type;
	gint depth;
	GdkByteOrder byte_order;
	gint colormap_size;
	gint bits_per_rgb;
	guint32 red_mask;
	gint red_shift;
	gint red_prec;
	guint32 green_mask;
	gint green_shift;
	gint green_prec;
	guint32 blue_mask;
	gint blue_shift;
	gint blue_prec;
    };


    struct _GdkColormap {
	GObject parent_instance;
	gint size;
	GdkColor *colors;
	GdkVisual *visual;
	gpointer windowing_data;
    };


    struct _GdkGC {
	GObject parent_instance;
	gint clip_x_origin;
	gint clip_y_origin;
	gint ts_x_origin;
	gint ts_y_origin;
	GdkColormap *colormap;
    };


    struct _GdkDeviceAxis {
	GdkAxisUse use;
	gdouble min;
	gdouble max;
    };


    struct _GdkDeviceKey {
	guint keyval;
	GdkModifierType modifiers;
    };


    struct _GdkDevice {
	GObject parent_instance;
	gchar *name;
	GdkInputSource source;
	GdkInputMode mode;
	gboolean has_cursor;
	gint num_axes;
	GdkDeviceAxis *axes;
	gint num_keys;
	GdkDeviceKey *keys;
    };


    struct _GdkDisplay {
	GObject parent_instance;
	GList *queued_events;
	GList *queued_tail;
	guint32 button_click_time[2];
	GdkWindow *button_window[2];
	gint button_number[2];
	guint double_click_time;
	GdkDevice *core_pointer;
	const GdkDisplayPointerHooks *pointer_hooks;
	guint closed:1;
	guint double_click_distance;
	gint button_x[2];
	gint button_y[2];
    };


    struct _GdkScreen {
	GObject parent_instance;
	guint closed:1;
	GdkGC *normal_gcs[32];
	GdkGC *exposure_gcs[32];
    };


    struct _GdkDisplayPointerHooks {
	void (*get_pointer) (GdkDisplay *, GdkScreen * *, gint *, gint *,
			     GdkModifierType *);
	GdkWindow *(*window_get_pointer) (GdkDisplay *, GdkWindow *,
					  gint *, gint *,
					  GdkModifierType *);
	GdkWindow *(*window_at_pointer) (GdkDisplay *, gint *, gint *);
    };


    struct _GdkCursor {
	GdkCursorType type;
	guint ref_count;
    };


    struct _GdkKeymap {
	GObject parent_instance;
	GdkDisplay *display;
    };


    struct _GdkEventAny {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
    };


    struct _GdkRectangle {
	gint x;
	gint y;
	gint width;
	gint height;
    };





    struct _GdkEventExpose {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkRectangle area;
	GdkRegion *region;
	gint count;
    };


    struct _GdkEventNoExpose {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
    };


    struct _GdkEventVisibility {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkVisibilityState state;
    };


    struct _GdkEventMotion {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	guint32 time;
	gdouble x;
	gdouble y;
	gdouble *axes;
	guint state;
	gint16 is_hint;
	GdkDevice *device;
	gdouble x_root;
	gdouble y_root;
    };


    struct _GdkEventButton {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	guint32 time;
	gdouble x;
	gdouble y;
	gdouble *axes;
	guint state;
	guint button;
	GdkDevice *device;
	gdouble x_root;
	gdouble y_root;
    };


    struct _GdkEventScroll {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	guint32 time;
	gdouble x;
	gdouble y;
	guint state;
	GdkScrollDirection direction;
	GdkDevice *device;
	gdouble x_root;
	gdouble y_root;
    };


    struct _GdkEventKey {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	guint32 time;
	guint state;
	guint keyval;
	gint length;
	gchar *string;
	guint16 hardware_keycode;
	guint8 group;
    };


    struct _GdkEventCrossing {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkWindow *subwindow;
	guint32 time;
	gdouble x;
	gdouble y;
	gdouble x_root;
	gdouble y_root;
	GdkCrossingMode mode;
	GdkNotifyType detail;
	gboolean focus;
	guint state;
    };


    struct _GdkEventFocus {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	gint16 in;
    };


    struct _GdkEventConfigure {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	gint x;
	gint y;
	gint width;
	gint height;
    };


    struct _GdkEventProperty {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkAtom atom;
	guint32 time;
	guint state;
    };


    struct _GdkEventSelection {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkAtom selection;
	GdkAtom target;
	GdkAtom property;
	guint32 time;
	GdkNativeWindow requestor;
    };


    struct _GdkEventOwnerChange {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkNativeWindow owner;
	GdkOwnerChange reason;
	GdkAtom selection;
	guint32 time;
	guint32 selection_time;
    };


    struct _GdkEventProximity {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	guint32 time;
	GdkDevice *device;
    };


    struct _GdkEventClient {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkAtom message_type;
	gushort data_format;
	union {
	    char b[20];
	    short int s[10];
	    long int l[5];
	} data;
    };


    struct _GdkDragContext {
	GObject parent_instance;
	GdkDragProtocol protocol;
	gboolean is_source;
	GdkWindow *source_window;
	GdkWindow *dest_window;
	GList *targets;
	GdkDragAction actions;
	GdkDragAction suggested_action;
	GdkDragAction action;
	guint32 start_time;
	gpointer windowing_data;
    };


    struct _GdkEventDND {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkDragContext *context;
	guint32 time;
	gshort x_root;
	gshort y_root;
    };


    struct _GdkEventWindowState {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkWindowState changed_mask;
	GdkWindowState new_window_state;
    };


    struct _GdkEventSetting {
	GdkEventType type;
	GdkWindow *window;
	gint8 send_event;
	GdkSettingAction action;
	char *name;
    };

    union _GdkEvent {
	GdkEventType type;
	GdkEventAny any;
	GdkEventExpose expose;
	GdkEventNoExpose no_expose;
	GdkEventVisibility visibility;
	GdkEventMotion motion;
	GdkEventButton button;
	GdkEventScroll scroll;
	GdkEventKey key;
	GdkEventCrossing crossing;
	GdkEventFocus focus_change;
	GdkEventConfigure configure;
	GdkEventProperty property;
	GdkEventSelection selection;
	GdkEventOwnerChange owner_change;
	GdkEventProximity proximity;
	GdkEventClient client;
	GdkEventDND dnd;
	GdkEventWindowState window_state;
	GdkEventSetting setting;
    };





    struct _GdkImage {
	GObject parent_instance;
	GdkImageType type;
	GdkVisual *visual;
	GdkByteOrder byte_order;
	gint width;
	gint height;
	guint16 depth;
	guint16 bpp;
	guint16 bpl;
	guint16 bits_per_pixel;
	gpointer mem;
	GdkColormap *colormap;
	gpointer windowing_data;
    };





    struct _GdkPangoRenderer {
	PangoRenderer parent_instance;
	GdkPangoRendererPrivate *priv;
    };


    struct _GdkTimeCoord {
	guint32 time;
	gdouble axes[128];
    };


    struct _GdkPoint {
	gint x;
	gint y;
    };





    struct _GdkKeymapKey {
	guint keycode;
	gint group;
	gint level;
    };


    struct _GdkRgbCmap {
	guint32 colors[256];
	gint n_colors;
	GSList *info_list;
    };


    struct _GdkGCValues {
	GdkColor foreground;
	GdkColor background;
	GdkFont *font;
	GdkFunction function;
	GdkFill fill;
	GdkPixmap *tile;
	GdkPixmap *stipple;
	GdkPixmap *clip_mask;
	GdkSubwindowMode subwindow_mode;
	gint ts_x_origin;
	gint ts_y_origin;
	gint clip_x_origin;
	gint clip_y_origin;
	gint graphics_exposures;
	gint line_width;
	GdkLineStyle line_style;
	GdkCapStyle cap_style;
	GdkJoinStyle join_style;
    };


    struct _GdkSpan {
	gint x;
	gint y;
	gint width;
    };


    struct _GdkGeometry {
	gint min_width;
	gint min_height;
	gint max_width;
	gint max_height;
	gint base_width;
	gint base_height;
	gint width_inc;
	gint height_inc;
	gdouble min_aspect;
	gdouble max_aspect;
	GdkGravity win_gravity;
    };


    struct _GdkSegment {
	gint x1;
	gint y1;
	gint x2;
	gint y2;
    };


    struct _GdkWindowAttr {
	gchar *title;
	gint event_mask;
	gint x;
	gint y;
	gint width;
	gint height;
	GdkWindowClass wclass;
	GdkVisual *visual;
	GdkColormap *colormap;
	GdkWindowType window_type;
	GdkCursor *cursor;
	gchar *wmclass_name;
	gchar *wmclass_class;
	gboolean override_redirect;
    };


    struct _GdkTrapezoid {
	double y1;
	double x11;
	double x21;
	double y2;
	double x12;
	double x22;
    };


    struct _GdkPointerHooks {
	GdkWindow *(*get_pointer) (GdkWindow *, gint *, gint *,
				   GdkModifierType *);
	GdkWindow *(*window_at_pointer) (GdkScreen *, gint *, gint *);
    };


    struct _GdkWindowObject {
	GdkDrawable parent_instance;
	GdkDrawable *impl;
	GdkWindowObject *parent;
	gpointer user_data;
	gint x;
	gint y;
	gint extension_events;
	GList *filters;
	GList *children;
	GdkColor bg_color;
	GdkPixmap *bg_pixmap;
	GSList *paint_stack;
	GdkRegion *update_area;
	guint update_freeze_count;
	guint8 window_type;
	guint8 depth;
	guint8 resize_count;
	GdkWindowState state;
	guint guffaw_gravity:1;
	guint input_only:1;
	guint modal_hint:1;
	guint destroyed:2;
	guint accept_focus:1;
	guint focus_on_map:1;
	GdkEventMask event_mask;
    };


    struct _GdkScreenClass {
	GObjectClass parent_class;
	void (*size_changed) (GdkScreen *);
    };


    struct _GdkPixmapObject {
	GdkDrawable parent_instance;
	GdkDrawable *impl;
	gint depth;
    };


    struct _GdkImageClass {
	GObjectClass parent_class;
    };


    struct _GdkKeymapClass {
	GObjectClass parent_class;
	void (*direction_changed) (GdkKeymap *);
	void (*keys_changed) (GdkKeymap *);
    };


    struct _GdkDrawableClass {
	GObjectClass parent_class;
	GdkGC *(*create_gc) (GdkDrawable *, GdkGCValues *,
			     GdkGCValuesMask);
	void (*draw_rectangle) (GdkDrawable *, GdkGC *, gboolean, gint,
				gint, gint, gint);
	void (*draw_arc) (GdkDrawable *, GdkGC *, gboolean, gint, gint,
			  gint, gint, gint, gint);
	void (*draw_polygon) (GdkDrawable *, GdkGC *, gboolean, GdkPoint *,
			      gint);
	void (*draw_text) (GdkDrawable *, GdkFont *, GdkGC *, gint, gint,
			   const gchar *, gint);
	void (*draw_text_wc) (GdkDrawable *, GdkFont *, GdkGC *, gint,
			      gint, const GdkWChar *, gint);
	void (*draw_drawable) (GdkDrawable *, GdkGC *, GdkDrawable *, gint,
			       gint, gint, gint, gint, gint);
	void (*draw_points) (GdkDrawable *, GdkGC *, GdkPoint *, gint);
	void (*draw_segments) (GdkDrawable *, GdkGC *, GdkSegment *, gint);
	void (*draw_lines) (GdkDrawable *, GdkGC *, GdkPoint *, gint);
	void (*draw_glyphs) (GdkDrawable *, GdkGC *, PangoFont *, gint,
			     gint, PangoGlyphString *);
	void (*draw_image) (GdkDrawable *, GdkGC *, GdkImage *, gint, gint,
			    gint, gint, gint, gint);
	 gint(*get_depth) (GdkDrawable *);
	void (*get_size) (GdkDrawable *, gint *, gint *);
	void (*set_colormap) (GdkDrawable *, GdkColormap *);
	GdkColormap *(*get_colormap) (GdkDrawable *);
	GdkVisual *(*get_visual) (GdkDrawable *);
	GdkScreen *(*get_screen) (GdkDrawable *);
	GdkImage *(*get_image) (GdkDrawable *, gint, gint, gint, gint);
	GdkRegion *(*get_clip_region) (GdkDrawable *);
	GdkRegion *(*get_visible_region) (GdkDrawable *);
	GdkDrawable *(*get_composite_drawable) (GdkDrawable *, gint, gint,
						gint, gint, gint *,
						gint *);
	void (*draw_pixbuf) (GdkDrawable *, GdkGC *, GdkPixbuf *, gint,
			     gint, gint, gint, gint, gint, GdkRgbDither,
			     gint, gint);
	GdkImage *(*_copy_to_image) (GdkDrawable *, GdkImage *, gint, gint,
				     gint, gint, gint, gint);
	void (*draw_glyphs_transformed) (GdkDrawable *, GdkGC *,
					 PangoMatrix *, PangoFont *, gint,
					 gint, PangoGlyphString *);
	void (*draw_trapezoids) (GdkDrawable *, GdkGC *, GdkTrapezoid *,
				 gint);
	void (*_gdk_reserved3) (void);
	void (*_gdk_reserved4) (void);
	void (*_gdk_reserved5) (void);
	void (*_gdk_reserved6) (void);
	void (*_gdk_reserved7) (void);
	void (*_gdk_reserved9) (void);
	void (*_gdk_reserved10) (void);
	void (*_gdk_reserved11) (void);
	void (*_gdk_reserved12) (void);
	void (*_gdk_reserved13) (void);
	void (*_gdk_reserved14) (void);
	void (*_gdk_reserved15) (void);
	void (*_gdk_reserved16) (void);
    };


    struct _GdkPangoAttrEmbossed {
	PangoAttribute attr;
	gboolean embossed;
    };


    struct _GdkDisplayManagerClass {
	GObjectClass parent_class;
	void (*display_opened) (GdkDisplayManager *, GdkDisplay *);
    };


    struct _GdkPixmapObjectClass {
	GdkDrawableClass parent_class;
    };


    struct _GdkPangoRendererClass {
	PangoRendererClass parent_class;
    };


    struct _GdkDisplayClass {
	GObjectClass parent_class;
	const gchar *(*get_display_name) (GdkDisplay *);
	 gint(*get_n_screens) (GdkDisplay *);
	GdkScreen *(*get_screen) (GdkDisplay *, gint);
	GdkScreen *(*get_default_screen) (GdkDisplay *);
	void (*closed) (GdkDisplay *, gboolean);
    };


    struct _GdkPangoAttrStipple {
	PangoAttribute attr;
	GdkBitmap *stipple;
    };


    struct _GdkColormapClass {
	GObjectClass parent_class;
    };


    struct _GdkDragContextClass {
	GObjectClass parent_class;
    };


    struct _GdkWindowObjectClass {
	GdkDrawableClass parent_class;
    };


    struct _GdkGCClass {
	GObjectClass parent_class;
	void (*get_values) (GdkGC *, GdkGCValues *);
	void (*set_values) (GdkGC *, GdkGCValues *, GdkGCValuesMask);
	void (*set_dashes) (GdkGC *, gint, gint8 *, gint);
	void (*_gdk_reserved1) (void);
	void (*_gdk_reserved2) (void);
	void (*_gdk_reserved3) (void);
	void (*_gdk_reserved4) (void);
    };








    extern void gdk_window_deiconify(GdkWindow *);
    extern GType gdk_device_get_type(void);
    extern void gdk_gc_set_clip_origin(GdkGC *, gint, gint);
    extern GdkColormap *gdk_drawable_get_colormap(GdkDrawable *);
    extern void gdk_flush(void);
    extern gint gdk_screen_height_mm(void);
    extern void gdk_display_get_pointer(GdkDisplay *, GdkScreen * *,
					gint *, gint *, GdkModifierType *);
    extern GdkEventMask gdk_window_get_events(GdkWindow *);
    extern void gdk_window_scroll(GdkWindow *, gint, gint);
    extern GType gdk_window_object_get_type(void);
    extern GdkCursor *gdk_cursor_new_from_pixbuf(GdkDisplay *, GdkPixbuf *,
						 gint, gint);
    extern GType gdk_axis_use_get_type(void);
    extern GType gdk_fill_get_type(void);
    extern void gdk_window_resize(GdkWindow *, gint, gint);
    extern GdkKeymap *gdk_keymap_get_for_display(GdkDisplay *);
    extern void gdk_display_add_client_message_filter(GdkDisplay *,
						      GdkAtom,
						      GdkFilterFunc,
						      gpointer);
    extern GdkPixmap *gdk_pixmap_create_from_xpm_d(GdkDrawable *,
						   GdkBitmap * *,
						   const GdkColor *,
						   gchar * *);
    extern gboolean gdk_display_supports_selection_notification(GdkDisplay
								*);
    extern GSList *gdk_display_manager_list_displays(GdkDisplayManager *);
    extern void gdk_gc_set_subwindow(GdkGC *, GdkSubwindowMode);
    extern void gdk_gc_set_colormap(GdkGC *, GdkColormap *);
    extern GType gdk_grab_status_get_type(void);
    extern GType gdk_visual_get_type(void);
    extern GdkVisual *gdk_rgb_get_visual(void);
    extern GType gdk_event_get_type(void);
    extern void gdk_display_set_double_click_time(GdkDisplay *, guint);
    extern GList *gdk_devices_list(void);
    extern void gdk_draw_layout_line(GdkDrawable *, GdkGC *, gint, gint,
				     PangoLayoutLine *);
    extern gboolean gdk_init_check(int *, char ***);
    extern gboolean gdk_event_get_root_coords(GdkEvent *, gdouble *,
					      gdouble *);
    extern void gdk_window_begin_resize_drag(GdkWindow *, GdkWindowEdge,
					     gint, gint, gint, guint32);
    extern guint gdk_keyval_from_name(const gchar *);
    extern gboolean gdk_display_request_selection_notification(GdkDisplay
							       *, GdkAtom);
    extern void gdk_window_raise(GdkWindow *);
    extern GdkImage *gdk_image_new(GdkImageType, GdkVisual *, gint, gint);
    extern GdkAtom gdk_atom_intern(const gchar *, gboolean);
    extern void gdk_window_get_frame_extents(GdkWindow *, GdkRectangle *);
    extern gboolean gdk_rectangle_intersect(GdkRectangle *, GdkRectangle *,
					    GdkRectangle *);
    extern GdkWindow *gdk_selection_owner_get_for_display(GdkDisplay *,
							  GdkAtom);
    extern PangoRenderer *gdk_pango_renderer_get_default(GdkScreen *);
    extern gchar *gdk_get_display(void);
    extern void gdk_gc_set_dashes(GdkGC *, gint, gint8 *, gint);
    extern void gdk_device_set_key(GdkDevice *, guint, guint,
				   GdkModifierType);
    extern void gdk_pango_renderer_set_override_color(GdkPangoRenderer *,
						      PangoRenderPart,
						      const GdkColor *);
    extern void gdk_window_iconify(GdkWindow *);
    extern void gdk_display_set_double_click_distance(GdkDisplay *, guint);
    extern GdkWindow *gdk_window_get_group(GdkWindow *);
    extern GdkDevice *gdk_device_get_core_pointer(void);
    extern guint gdk_color_hash(const GdkColor *);
    extern void gdk_screen_get_monitor_geometry(GdkScreen *, gint,
						GdkRectangle *);
    extern void gdk_device_set_source(GdkDevice *, GdkInputSource);
    extern GType gdk_input_mode_get_type(void);
    extern GdkWindow *gdk_get_default_root_window(void);
    extern gchar *gdk_screen_make_display_name(GdkScreen *);
    extern GdkGrabStatus gdk_pointer_grab(GdkWindow *, gboolean,
					  GdkEventMask, GdkWindow *,
					  GdkCursor *, guint32);
    extern void gdk_window_set_title(GdkWindow *, const gchar *);
    extern void gdk_property_delete(GdkWindow *, GdkAtom);
    extern GdkColormap *gdk_rgb_get_colormap(void);
    extern void gdk_free_text_list(gchar * *);
    extern gint gdk_colormap_alloc_colors(GdkColormap *, GdkColor *, gint,
					  gboolean, gboolean, gboolean *);
    extern void gdk_window_process_all_updates(void);
    extern guint32 gdk_event_get_time(GdkEvent *);
    extern gint gdk_text_property_to_text_list_for_display(GdkDisplay *,
							   GdkAtom, gint,
							   const guchar *,
							   gint,
							   gchar * **);
    extern GdkAtom gdk_drag_get_selection(GdkDragContext *);
    extern GdkScreen *gdk_screen_get_default(void);
    extern void gdk_window_set_skip_pager_hint(GdkWindow *, gboolean);
    extern GdkPixmap *gdk_pixmap_foreign_new(GdkNativeWindow);
    extern GType gdk_window_hints_get_type(void);
    extern void gdk_drag_drop(GdkDragContext *, guint32);
    extern void gdk_gc_set_fill(GdkGC *, GdkFill);
    extern void gdk_init(int *, char ***);
    extern gboolean gdk_property_get(GdkWindow *, GdkAtom, GdkAtom, gulong,
				     gulong, gint, GdkAtom *, gint *,
				     gint *, guchar * *);
    extern void gdk_gc_set_rgb_fg_color(GdkGC *, const GdkColor *);
    extern void gdk_window_set_transient_for(GdkWindow *, GdkWindow *);
    extern GdkRegion *gdk_pango_layout_line_get_clip_region(PangoLayoutLine
							    *, gint, gint,
							    gint *, gint);
    extern GdkVisual *gdk_screen_get_system_visual(GdkScreen *);
    extern GdkDisplay
	*gdk_display_manager_get_default_display(GdkDisplayManager *);
    extern gint gdk_text_property_to_utf8_list(GdkAtom, gint,
					       const guchar *, gint,
					       gchar * **);
    extern void gdk_window_set_type_hint(GdkWindow *, GdkWindowTypeHint);
    extern void gdk_parse_args(int *, char ***);
    extern GdkPixmap *gdk_pixmap_create_from_xpm(GdkDrawable *,
						 GdkBitmap * *,
						 const GdkColor *,
						 const gchar *);
    extern void gdk_window_set_group(GdkWindow *, GdkWindow *);
    extern void gdk_window_focus(GdkWindow *, guint32);
    extern void gdk_event_set_screen(GdkEvent *, GdkScreen *);
    extern void gdk_display_flush(GdkDisplay *);
    extern GType gdk_owner_change_get_type(void);
    extern void gdk_region_subtract(GdkRegion *, GdkRegion *);
    extern GType gdk_cap_style_get_type(void);
    extern void gdk_window_unstick(GdkWindow *);
    extern void gdk_draw_glyphs(GdkDrawable *, GdkGC *, PangoFont *, gint,
				gint, PangoGlyphString *);
    extern gint gdk_text_property_to_utf8_list_for_display(GdkDisplay *,
							   GdkAtom, gint,
							   const guchar *,
							   gint,
							   gchar * **);
    extern void gdk_drag_abort(GdkDragContext *, guint32);
    extern GdkWindow *gdk_display_get_window_at_pointer(GdkDisplay *,
							gint *, gint *);
    extern GdkDisplayPointerHooks *gdk_display_set_pointer_hooks(GdkDisplay
								 *,
								 const
								 GdkDisplayPointerHooks
								 *);
    extern void gdk_window_set_debug_updates(gboolean);
    extern gboolean gdk_spawn_command_line_on_screen(GdkScreen *,
						     const gchar *,
						     GError * *);
    extern GdkRegion *gdk_region_copy(GdkRegion *);
    extern GdkEvent *gdk_display_peek_event(GdkDisplay *);
    extern GdkColormap *gdk_gc_get_colormap(GdkGC *);
    extern void gdk_selection_send_notify(guint32, GdkAtom, GdkAtom,
					  GdkAtom, guint32);
    extern const char *gdk_get_program_class(void);
    extern GType gdk_filter_return_get_type(void);
    extern void gdk_drop_reply(GdkDragContext *, gboolean, guint32);
    extern void gdk_threads_enter(void);
    extern void gdk_device_free_history(GdkTimeCoord * *, gint);
    extern GdkImage *gdk_drawable_get_image(GdkDrawable *, gint, gint,
					    gint, gint);
    extern GType gdk_event_mask_get_type(void);
    extern void gdk_set_program_class(const char *);
    extern void gdk_draw_polygon(GdkDrawable *, GdkGC *, gboolean,
				 GdkPoint *, gint);
    extern GType gdk_function_get_type(void);
    extern void gdk_display_close(GdkDisplay *);
    extern gint gdk_screen_get_n_monitors(GdkScreen *);
    extern gboolean gdk_keymap_translate_keyboard_state(GdkKeymap *, guint,
							GdkModifierType,
							gint, guint *,
							gint *, gint *,
							GdkModifierType *);
    extern GType gdk_rectangle_get_type(void);
    extern GdkDisplay *gdk_screen_get_display(GdkScreen *);
    extern GList *gdk_window_get_toplevels(void);
    extern GdkVisual *gdk_visual_get_best_with_depth(gint);
    extern gboolean gdk_display_supports_cursor_alpha(GdkDisplay *);
    extern void gdk_window_set_decorations(GdkWindow *, GdkWMDecoration);
    extern PangoContext *gdk_pango_context_get_for_screen(GdkScreen *);
    extern GdkVisual *gdk_colormap_get_visual(GdkColormap *);
    extern void gdk_error_trap_push(void);
    extern void gdk_display_beep(GdkDisplay *);
    extern gboolean gdk_spawn_on_screen(GdkScreen *, const gchar *,
					gchar * *, gchar * *, GSpawnFlags,
					GSpawnChildSetupFunc, gpointer,
					gint *, GError * *);
    extern void gdk_add_client_message_filter(GdkAtom, GdkFilterFunc,
					      gpointer);
    extern PangoDirection gdk_keymap_get_direction(GdkKeymap *);
    extern PangoAttribute *gdk_pango_attr_stipple_new(GdkBitmap *);
    extern void gdk_window_lower(GdkWindow *);
    extern gboolean gdk_rgb_ditherable(void);
    extern gboolean gdk_colormap_alloc_color(GdkColormap *, GdkColor *,
					     gboolean, gboolean);
    extern GdkWindow *gdk_display_get_default_group(GdkDisplay *);
    extern GType gdk_event_type_get_type(void);
    extern GType gdk_color_get_type(void);
    extern GType gdk_drag_protocol_get_type(void);
    extern GType gdk_gravity_get_type(void);
    extern gboolean gdk_events_pending(void);
    extern GType gdk_input_condition_get_type(void);
    extern GType gdk_input_source_get_type(void);
    extern gchar *gdk_utf8_to_string_target(const gchar *);
    extern void gdk_threads_init(void);
    extern void gdk_gc_set_foreground(GdkGC *, const GdkColor *);
    extern gint gdk_string_to_compound_text_for_display(GdkDisplay *,
							const gchar *,
							GdkAtom *, gint *,
							guchar * *,
							gint *);
    extern GdkWindow *gdk_window_get_toplevel(GdkWindow *);
    extern void gdk_drop_finish(GdkDragContext *, gboolean, guint32);
    extern void gdk_window_set_functions(GdkWindow *, GdkWMFunction);
    extern void gdk_window_invalidate_maybe_recurse(GdkWindow *,
						    GdkRegion *,
						    gboolean(*)(GdkWindow
								*,
								gpointer)
						    , gpointer);
    extern gint gdk_screen_get_height(GdkScreen *);
    extern gboolean gdk_keymap_get_entries_for_keyval(GdkKeymap *, guint,
						      GdkKeymapKey * *,
						      gint *);
    extern GdkDragContext *gdk_drag_context_new(void);
    extern void gdk_colormap_query_color(GdkColormap *, gulong,
					 GdkColor *);
    extern void gdk_pixbuf_render_pixmap_and_mask_for_colormap(GdkPixbuf *,
							       GdkColormap
							       *,
							       GdkPixmap *
							       *,
							       GdkBitmap *
							       *, int);
    extern void gdk_region_intersect(GdkRegion *, GdkRegion *);
    extern GdkWindow *gdk_selection_owner_get(GdkAtom);
    extern void gdk_draw_pixbuf(GdkDrawable *, GdkGC *, GdkPixbuf *, gint,
				gint, gint, gint, gint, gint, GdkRgbDither,
				gint, gint);
    extern void gdk_rgb_cmap_free(GdkRgbCmap *);
    extern GdkDisplay *gdk_display_open(const gchar *);
    extern GdkPixmap *gdk_pixmap_colormap_create_from_xpm_d(GdkDrawable *,
							    GdkColormap *,
							    GdkBitmap * *,
							    const GdkColor
							    *, gchar * *);
    extern gboolean gdk_keyval_is_lower(guint);
    extern GCallback gdk_threads_unlock;
    extern GType gdk_modifier_type_get_type(void);
    extern gint gdk_visual_get_best_depth(void);
    extern gboolean gdk_setting_get(const gchar *, GValue *);
    extern GType gdk_screen_get_type(void);
    extern guint32 gdk_drag_get_protocol_for_display(GdkDisplay *, guint32,
						     GdkDragProtocol *);
    extern GList *gdk_screen_get_toplevel_windows(GdkScreen *);
    extern GdkGC *gdk_gc_new_with_values(GdkDrawable *, GdkGCValues *,
					 GdkGCValuesMask);
    extern GdkScreen *gdk_display_get_default_screen(GdkDisplay *);
    extern gboolean gdk_drag_motion(GdkDragContext *, GdkWindow *,
				    GdkDragProtocol, gint, gint,
				    GdkDragAction, GdkDragAction, guint32);
    extern GdkRegion *gdk_drawable_get_visible_region(GdkDrawable *);
    extern void gdk_pango_renderer_set_stipple(GdkPangoRenderer *,
					       PangoRenderPart,
					       GdkBitmap *);
    extern void gdk_display_get_maximal_cursor_size(GdkDisplay *, guint *,
						    guint *);
    extern GdkRegion *gdk_window_get_update_area(GdkWindow *);
    extern void gdk_drag_status(GdkDragContext *, GdkDragAction, guint32);
    extern gboolean gdk_keyval_is_upper(guint);
    extern void gdk_window_begin_paint_region(GdkWindow *, GdkRegion *);
    extern void gdk_pango_renderer_set_drawable(GdkPangoRenderer *,
						GdkDrawable *);
    extern gint gdk_screen_get_monitor_at_point(GdkScreen *, gint, gint);
    extern gboolean gdk_utf8_to_compound_text_for_display(GdkDisplay *,
							  const gchar *,
							  GdkAtom *,
							  gint *,
							  guchar * *,
							  gint *);
    extern GdkColormap *gdk_image_get_colormap(GdkImage *);
    extern gint gdk_window_get_origin(GdkWindow *, gint *, gint *);
    extern void gdk_set_double_click_time(guint);
    extern void gdk_gc_get_values(GdkGC *, GdkGCValues *);
    extern GdkColor *gdk_color_copy(const GdkColor *);
    extern void gdk_gc_set_tile(GdkGC *, GdkPixmap *);
    extern gboolean gdk_event_get_coords(GdkEvent *, gdouble *, gdouble *);
    extern void gdk_gc_set_ts_origin(GdkGC *, gint, gint);
    extern GdkWindowType gdk_window_get_window_type(GdkWindow *);
    extern void gdk_window_set_focus_on_map(GdkWindow *, gboolean);
    extern void gdk_region_union_with_rect(GdkRegion *, GdkRectangle *);
    extern gboolean gdk_keymap_get_entries_for_keycode(GdkKeymap *, guint,
						       GdkKeymapKey * *,
						       guint * *, gint *);
    extern gboolean gdk_selection_property_get(GdkWindow *, guchar * *,
					       GdkAtom *, gint *);
    extern void gdk_display_keyboard_ungrab(GdkDisplay *, guint32);
    extern GdkDisplay *gdk_drawable_get_display(GdkDrawable *);
    extern void gdk_gc_set_stipple(GdkGC *, GdkPixmap *);
    extern void gdk_window_clear_area_e(GdkWindow *, gint, gint, gint,
					gint);
    extern void gdk_window_set_keep_below(GdkWindow *, gboolean);
    extern GType gdk_font_type_get_type(void);
    extern GType gdk_visual_type_get_type(void);
    extern GdkEvent *gdk_display_get_event(GdkDisplay *);
    extern void gdk_pixbuf_render_pixmap_and_mask(GdkPixbuf *,
						  GdkPixmap * *,
						  GdkBitmap * *, int);
    extern GdkVisual *gdk_drawable_get_visual(GdkDrawable *);
    extern void gdk_image_set_colormap(GdkImage *, GdkColormap *);
    extern guint gdk_keyval_to_upper(guint);
    extern void gdk_set_show_events(gboolean);
    extern GdkWindow *gdk_window_lookup_for_display(GdkDisplay *,
						    GdkNativeWindow);
    extern GdkPixmap *gdk_pixmap_new(GdkDrawable *, gint, gint, gint);
    extern GdkColormap *gdk_screen_get_rgb_colormap(GdkScreen *);
    extern void gdk_rgb_find_color(GdkColormap *, GdkColor *);
    extern void gdk_window_set_override_redirect(GdkWindow *, gboolean);
    extern void gdk_window_set_accept_focus(GdkWindow *, gboolean);
    extern GdkEvent *gdk_event_peek(void);
    extern void gdk_window_show(GdkWindow *);
    extern GType gdk_overlap_type_get_type(void);
    extern void gdk_window_show_unraised(GdkWindow *);
    extern GType gdk_gc_values_mask_get_type(void);
    extern void gdk_screen_broadcast_client_message(GdkScreen *,
						    GdkEvent *);
    extern void gdk_window_set_events(GdkWindow *, GdkEventMask);
    extern void gdk_window_set_icon(GdkWindow *, GdkWindow *, GdkPixmap *,
				    GdkBitmap *);
    extern GType gdk_join_style_get_type(void);
    extern gboolean gdk_utf8_to_compound_text(const gchar *, GdkAtom *,
					      gint *, guchar * *, gint *);
    extern void gdk_display_put_event(GdkDisplay *, GdkEvent *);
    extern GList *gdk_window_peek_children(GdkWindow *);
    extern void gdk_window_enable_synchronized_configure(GdkWindow *);
    extern void gdk_window_set_role(GdkWindow *, const gchar *);
    extern GdkDisplay *gdk_display_get_default(void);
    extern void gdk_window_remove_filter(GdkWindow *, GdkFilterFunc,
					 gpointer);
    extern void gdk_gc_set_function(GdkGC *, GdkFunction);
    extern GList *gdk_list_visuals(void);
    extern void gdk_pixbuf_render_threshold_alpha(GdkPixbuf *, GdkBitmap *,
						  int, int, int, int, int,
						  int, int);
    extern void gdk_region_spans_intersect_foreach(GdkRegion *, GdkSpan *,
						   int, gboolean,
						   GdkSpanFunc, gpointer);
    extern void gdk_display_pointer_ungrab(GdkDisplay *, guint32);
    extern GdkColormap *gdk_screen_get_default_colormap(GdkScreen *);
    extern gboolean gdk_rgb_colormap_ditherable(GdkColormap *);
    extern void gdk_window_move(GdkWindow *, gint, gint);
    extern GdkImage *gdk_drawable_copy_to_image(GdkDrawable *, GdkImage *,
						gint, gint, gint, gint,
						gint, gint);
    extern void gdk_window_reparent(GdkWindow *, GdkWindow *, gint, gint);
    extern GList *gdk_display_list_devices(GdkDisplay *);
    extern GdkVisual *gdk_screen_get_rgb_visual(GdkScreen *);
    extern void gdk_set_sm_client_id(const gchar *);
    extern void gdk_region_destroy(GdkRegion *);
    extern void gdk_display_manager_set_default_display(GdkDisplayManager
							*, GdkDisplay *);
    extern void gdk_beep(void);
    extern GdkColormap *gdk_colormap_get_system(void);
    extern void gdk_display_store_clipboard(GdkDisplay *, GdkWindow *,
					    guint32, GdkAtom *, gint);
    extern gint gdk_error_trap_pop(void);
    extern PangoAttribute *gdk_pango_attr_embossed_new(gboolean);
    extern void gdk_drawable_set_colormap(GdkDrawable *, GdkColormap *);
    extern GdkDisplay *gdk_cursor_get_display(GdkCursor *);
    extern void gdk_window_add_filter(GdkWindow *, GdkFilterFunc,
				      gpointer);
    extern void gdk_draw_line(GdkDrawable *, GdkGC *, gint, gint, gint,
			      gint);
    extern gboolean gdk_event_send_client_message(GdkEvent *,
						  GdkNativeWindow);
    extern void gdk_window_set_geometry_hints(GdkWindow *, GdkGeometry *,
					      GdkWindowHints);
    extern GType gdk_window_class_get_type(void);
    extern guint gdk_unicode_to_keyval(guint32);
    extern void gdk_draw_arc(GdkDrawable *, GdkGC *, gboolean, gint, gint,
			     gint, gint, gint, gint);
    extern void gdk_event_handler_set(GdkEventFunc, gpointer,
				      GDestroyNotify);
    extern void gdk_region_get_clipbox(GdkRegion *, GdkRectangle *);
    extern GType gdk_drawable_get_type(void);
    extern void gdk_window_clear_area(GdkWindow *, gint, gint, gint, gint);
    extern void gdk_draw_layout(GdkDrawable *, GdkGC *, int, int,
				PangoLayout *);
    extern void gdk_window_get_root_origin(GdkWindow *, gint *, gint *);
    extern gint gdk_color_parse(const gchar *, GdkColor *);
    extern void gdk_window_set_skip_taskbar_hint(GdkWindow *, gboolean);
    extern GType gdk_gc_get_type(void);
    extern GdkRegion *gdk_pango_layout_get_clip_region(PangoLayout *, gint,
						       gint, gint *, gint);
    extern void gdk_window_fullscreen(GdkWindow *);
    extern gchar *gdk_keyval_name(guint);
    extern GdkCursor *gdk_cursor_new(GdkCursorType);
    extern PangoContext *gdk_pango_context_get(void);
    extern GType gdk_rgb_dither_get_type(void);
    extern void gdk_window_hide(GdkWindow *);
    extern void gdk_window_register_dnd(GdkWindow *);
    extern GType gdk_notify_type_get_type(void);
    extern void gdk_window_invalidate_rect(GdkWindow *, GdkRectangle *,
					   gboolean);
    extern void gdk_window_unmaximize(GdkWindow *);
    extern void gdk_gc_copy(GdkGC *, GdkGC *);
    extern guint gdk_display_get_default_cursor_size(GdkDisplay *);
    extern void gdk_window_set_cursor(GdkWindow *, GdkCursor *);
    extern void gdk_keyval_convert_case(guint, guint *, guint *);
    extern GdkVisual *gdk_visual_get_best_with_type(GdkVisualType);
    extern void gdk_gc_set_exposures(GdkGC *, gboolean);
    extern GdkDisplayManager *gdk_display_manager_get(void);
    extern void gdk_gc_set_background(GdkGC *, const GdkColor *);
    extern void gdk_draw_point(GdkDrawable *, GdkGC *, gint, gint);
    extern GdkVisual *gdk_visual_get_best(void);
    extern GList *gdk_window_get_children(GdkWindow *);
    extern gint gdk_screen_height(void);
    extern void gdk_selection_convert(GdkWindow *, GdkAtom, GdkAtom,
				      guint32);
    extern GdkWindow *gdk_window_get_pointer(GdkWindow *, gint *, gint *,
					     GdkModifierType *);
    extern void gdk_window_end_paint(GdkWindow *);
    extern GType gdk_pixmap_get_type(void);
    extern GType gdk_property_state_get_type(void);
    extern void gdk_window_maximize(GdkWindow *);
    extern void gdk_window_get_user_data(GdkWindow *, gpointer *);
    extern GdkGrabStatus gdk_keyboard_grab(GdkWindow *, gboolean, guint32);
    extern GType gdk_visibility_state_get_type(void);
    extern void gdk_draw_indexed_image(GdkDrawable *, GdkGC *, gint, gint,
				       gint, gint, GdkRgbDither, guchar *,
				       gint, GdkRgbCmap *);
    extern gboolean gdk_color_equal(const GdkColor *, const GdkColor *);
    extern gboolean gdk_region_empty(GdkRegion *);
    extern void gdk_region_offset(GdkRegion *, gint, gint);
    extern gint gdk_string_to_compound_text(const gchar *, GdkAtom *,
					    gint *, guchar * *, gint *);
    extern GdkScreen *gdk_gc_get_screen(GdkGC *);
    extern GdkOverlapType gdk_region_rect_in(GdkRegion *, GdkRectangle *);
    extern GType gdk_cursor_type_get_type(void);
    extern gboolean gdk_window_set_static_gravities(GdkWindow *, gboolean);
    extern gint gdk_screen_get_number(GdkScreen *);
    extern void gdk_draw_segments(GdkDrawable *, GdkGC *, GdkSegment *,
				  gint);
    extern guint32 gdk_keyval_to_unicode(guint);
    extern void gdk_draw_layout_line_with_colors(GdkDrawable *, GdkGC *,
						 gint, gint,
						 PangoLayoutLine *,
						 const GdkColor *,
						 const GdkColor *);
    extern void gdk_property_change(GdkWindow *, GdkAtom, GdkAtom, gint,
				    GdkPropMode, const guchar *, gint);
    extern gboolean gdk_event_send_client_message_for_display(GdkDisplay *,
							      GdkEvent *,
							      GdkNativeWindow);
    extern gboolean gdk_screen_get_setting(GdkScreen *, const gchar *,
					   GValue *);
    extern GList *gdk_screen_list_visuals(GdkScreen *);
    extern GType gdk_window_attributes_type_get_type(void);
    extern GdkWindow *gdk_window_new(GdkWindow *, GdkWindowAttr *, gint);
    extern void gdk_window_begin_move_drag(GdkWindow *, gint, gint, gint,
					   guint32);
    extern void gdk_device_get_state(GdkDevice *, GdkWindow *, gdouble *,
				     GdkModifierType *);
    extern void gdk_window_set_modal_hint(GdkWindow *, gboolean);
    extern GdkEvent *gdk_event_new(GdkEventType);
    extern void gdk_window_destroy(GdkWindow *);
    extern GType gdk_wm_function_get_type(void);
    extern GdkColormap *gdk_colormap_new(GdkVisual *, gboolean);
    extern void gdk_draw_rgb_32_image(GdkDrawable *, GdkGC *, gint, gint,
				      gint, gint, GdkRgbDither, guchar *,
				      gint);
    extern void gdk_window_set_background(GdkWindow *, const GdkColor *);
    extern void gdk_window_stick(GdkWindow *);
    extern GType gdk_pango_renderer_get_type(void);
    extern void gdk_window_set_back_pixmap(GdkWindow *, GdkPixmap *,
					   gboolean);
    extern gboolean gdk_display_supports_cursor_color(GdkDisplay *);
    extern GdkDragContext *gdk_drag_begin(GdkWindow *, GList *);
    extern void gdk_notify_startup_complete(void);
    extern void gdk_display_sync(GdkDisplay *);
    extern gboolean gdk_event_get_state(GdkEvent *, GdkModifierType *);
    extern void gdk_gc_set_values(GdkGC *, GdkGCValues *, GdkGCValuesMask);
    extern GdkEvent *gdk_event_get_graphics_expose(GdkWindow *);
    extern void gdk_color_free(GdkColor *);
    extern void gdk_rectangle_union(GdkRectangle *, GdkRectangle *,
				    GdkRectangle *);
    extern void gdk_window_configure_finished(GdkWindow *);
    extern gboolean gdk_drag_drop_succeeded(GdkDragContext *);
    extern gint gdk_display_get_n_screens(GdkDisplay *);
    extern void gdk_draw_layout_with_colors(GdkDrawable *, GdkGC *, int,
					    int, PangoLayout *,
					    const GdkColor *,
					    const GdkColor *);
    extern gint gdk_drawable_get_depth(GdkDrawable *);
    extern GdkPixmap *gdk_pixmap_foreign_new_for_display(GdkDisplay *,
							 GdkNativeWindow);
    extern void gdk_event_send_clientmessage_toall(GdkEvent *);
    extern GdkPixbuf *gdk_pixbuf_get_from_drawable(GdkPixbuf *,
						   GdkDrawable *,
						   GdkColormap *, int, int,
						   int, int, int, int);
    extern void gdk_draw_gray_image(GdkDrawable *, GdkGC *, gint, gint,
				    gint, gint, GdkRgbDither, guchar *,
				    gint);
    extern gint gdk_text_property_to_text_list(GdkAtom, gint,
					       const guchar *, gint,
					       gchar * **);
    extern GCallback gdk_threads_lock;
    extern gboolean gdk_region_equal(GdkRegion *, GdkRegion *);
    extern GdkEvent *gdk_event_get(void);
    extern void gdk_window_freeze_updates(GdkWindow *);
    extern GdkScreen *gdk_visual_get_screen(GdkVisual *);
    extern gboolean gdk_device_get_history(GdkDevice *, GdkWindow *,
					   guint32, guint32,
					   GdkTimeCoord * **, gint *);
    extern void gdk_image_put_pixel(GdkImage *, gint, gint, guint32);
    extern void gdk_screen_set_default_colormap(GdkScreen *,
						GdkColormap *);
    extern GType gdk_wm_decoration_get_type(void);
    extern void gdk_draw_image(GdkDrawable *, GdkGC *, GdkImage *, gint,
			       gint, gint, gint, gint, gint);
    extern void gdk_window_shape_combine_region(GdkWindow *, GdkRegion *,
						gint, gint);
    extern GdkGC *gdk_gc_new(GdkDrawable *);
    extern GType gdk_status_get_type(void);
    extern void gdk_window_set_keep_above(GdkWindow *, gboolean);
    extern gboolean gdk_selection_owner_set_for_display(GdkDisplay *,
							GdkWindow *,
							GdkAtom, guint32,
							gboolean);
    extern GdkDevice *gdk_display_get_core_pointer(GdkDisplay *);
    extern void gdk_cursor_unref(GdkCursor *);
    extern GType gdk_display_manager_get_type(void);
    extern const gchar *gdk_get_display_arg_name(void);
    extern gboolean gdk_window_is_visible(GdkWindow *);
    extern void gdk_region_union(GdkRegion *, GdkRegion *);
    extern gint gdk_screen_get_width_mm(GdkScreen *);
    extern void gdk_draw_lines(GdkDrawable *, GdkGC *, GdkPoint *, gint);
    extern GType gdk_colormap_get_type(void);
    extern guint32 gdk_drag_get_protocol(guint32, GdkDragProtocol *);
    extern gint gdk_screen_get_width(GdkScreen *);
    extern void gdk_selection_send_notify_for_display(GdkDisplay *,
						      guint32, GdkAtom,
						      GdkAtom, GdkAtom,
						      guint32);
    extern gchar *gdk_set_locale(void);
    extern GdkKeymap *gdk_keymap_get_default(void);
    extern GdkScreen *gdk_colormap_get_screen(GdkColormap *);
    extern GType gdk_byte_order_get_type(void);
    extern void gdk_window_constrain_size(GdkGeometry *, guint, gint, gint,
					  gint *, gint *);
    extern GdkWindow *gdk_screen_get_root_window(GdkScreen *);
    extern void gdk_window_set_user_data(GdkWindow *, gpointer);
    extern void gdk_colormap_free_colors(GdkColormap *, GdkColor *, gint);
    extern void gdk_window_get_internal_paint_info(GdkWindow *,
						   GdkDrawable * *, gint *,
						   gint *);
    extern gboolean gdk_window_is_viewable(GdkWindow *);
    extern struct _GdkDrawable *gdk_bitmap_create_from_data(GdkDrawable *,
							    const gchar *,
							    gint, gint);
    extern void gdk_window_unfullscreen(GdkWindow *);
    extern void gdk_drag_find_window(GdkDragContext *, GdkWindow *, gint,
				     gint, GdkWindow * *,
				     GdkDragProtocol *);
    extern GType gdk_keymap_get_type(void);
    extern GType gdk_window_type_hint_get_type(void);
    extern void gdk_gc_set_clip_mask(GdkGC *, GdkBitmap *);
    extern gchar *gdk_atom_name(GdkAtom);
    extern void gdk_rgb_set_verbose(gboolean);
    extern void gdk_draw_rgb_image(GdkDrawable *, GdkGC *, gint, gint,
				   gint, gint, GdkRgbDither, guchar *,
				   gint);
    extern void gdk_query_visual_types(GdkVisualType * *, gint *);
    extern GType gdk_crossing_mode_get_type(void);
    extern void gdk_draw_trapezoids(GdkDrawable *, GdkGC *, GdkTrapezoid *,
				    gint);
    extern GdkPixmap *gdk_pixmap_create_from_data(GdkDrawable *,
						  const gchar *, gint,
						  gint, gint,
						  const GdkColor *,
						  const GdkColor *);
    extern GType gdk_line_style_get_type(void);
    extern gboolean gdk_window_get_decorations(GdkWindow *,
					       GdkWMDecoration *);
    extern GType gdk_window_state_get_type(void);
    extern void gdk_gc_offset(GdkGC *, gint, gint);
    extern void gdk_event_free(GdkEvent *);
    extern void gdk_gc_set_clip_region(GdkGC *, GdkRegion *);
    extern gboolean gdk_device_set_mode(GdkDevice *, GdkInputMode);
    extern void gdk_query_depths(gint * *, gint *);
    extern void gdk_draw_rgb_32_image_dithalign(GdkDrawable *, GdkGC *,
						gint, gint, gint, gint,
						GdkRgbDither, guchar *,
						gint, gint, gint);
    extern GType gdk_subwindow_mode_get_type(void);
    extern void gdk_rgb_set_install(gboolean);
    extern guint gdk_keyval_to_lower(guint);
    extern GType gdk_window_edge_get_type(void);
    extern GdkPixmap *gdk_pixmap_lookup_for_display(GdkDisplay *,
						    GdkNativeWindow);
    extern gboolean gdk_display_pointer_is_grabbed(GdkDisplay *);
    extern GType gdk_prop_mode_get_type(void);
    extern void gdk_window_withdraw(GdkWindow *);
    extern void gdk_drawable_get_size(GdkDrawable *, gint *, gint *);
    extern void gdk_window_merge_child_shapes(GdkWindow *);
    extern guint gdk_keymap_lookup_key(GdkKeymap *, const GdkKeymapKey *);
    extern GdkRegion *gdk_region_polygon(GdkPoint *, gint, GdkFillRule);
    extern void gdk_window_clear(GdkWindow *);
    extern const gchar *gdk_display_get_name(GdkDisplay *);
    extern void gdk_pango_renderer_set_gc(GdkPangoRenderer *, GdkGC *);
    extern gboolean gdk_spawn_on_screen_with_pipes(GdkScreen *,
						   const gchar *,
						   gchar * *, gchar * *,
						   GSpawnFlags,
						   GSpawnChildSetupFunc,
						   gpointer, gint *,
						   gint *, gint *, gint *,
						   GError * *);
    extern void gdk_event_put(GdkEvent *);
    extern GType gdk_window_type_get_type(void);
    extern GdkScreen *gdk_event_get_screen(GdkEvent *);
    extern GdkPointerHooks *gdk_set_pointer_hooks(const GdkPointerHooks *);
    extern void gdk_draw_glyphs_transformed(GdkDrawable *, GdkGC *,
					    PangoMatrix *, PangoFont *,
					    gint, gint,
					    PangoGlyphString *);
    extern void gdk_draw_rgb_image_dithalign(GdkDrawable *, GdkGC *, gint,
					     gint, gint, gint,
					     GdkRgbDither, guchar *, gint,
					     gint, gint);
    extern void gdk_window_process_updates(GdkWindow *, gboolean);
    extern GType gdk_extension_mode_get_type(void);
    extern gboolean gdk_event_get_axis(GdkEvent *, GdkAxisUse, gdouble *);
    extern void gdk_gc_set_clip_rectangle(GdkGC *, GdkRectangle *);
    extern void gdk_gc_set_rgb_bg_color(GdkGC *, const GdkColor *);
    extern void gdk_region_xor(GdkRegion *, GdkRegion *);
    extern GdkCursor *gdk_cursor_ref(GdkCursor *);
    extern GdkVisual *gdk_visual_get_best_with_both(gint, GdkVisualType);
    extern GType gdk_scroll_direction_get_type(void);
    extern void gdk_draw_points(GdkDrawable *, GdkGC *, GdkPoint *, gint);
    extern GdkRgbCmap *gdk_rgb_cmap_new(guint32 *, gint);
    extern GdkWindow *gdk_window_foreign_new(GdkNativeWindow);
    extern GdkWindow *gdk_window_get_parent(GdkWindow *);
    extern void gdk_draw_drawable(GdkDrawable *, GdkGC *, GdkDrawable *,
				  gint, gint, gint, gint, gint, gint);
    extern void gdk_threads_set_lock_functions(GCallback, GCallback);
    extern gint gdk_screen_get_height_mm(GdkScreen *);
    extern gboolean gdk_device_get_axis(GdkDevice *, gdouble *, GdkAxisUse,
					gdouble *);
    extern gboolean gdk_get_show_events(void);
    extern void gdk_window_begin_paint_rect(GdkWindow *, GdkRectangle *);
    extern void gdk_pointer_ungrab(guint32);
    extern GdkPixmap *gdk_pixmap_lookup(GdkNativeWindow);
    extern void gdk_threads_leave(void);
    extern gboolean gdk_pointer_is_grabbed(void);
    extern gboolean gdk_region_point_in(GdkRegion *, int, int);
    extern GdkWindowState gdk_window_get_state(GdkWindow *);
    extern void gdk_region_get_rectangles(GdkRegion *, GdkRectangle * *,
					  gint *);
    extern void gdk_draw_rectangle(GdkDrawable *, GdkGC *, gboolean, gint,
				   gint, gint, gint);
    extern void gdk_gc_set_line_attributes(GdkGC *, gint, GdkLineStyle,
					   GdkCapStyle, GdkJoinStyle);
    extern void gdk_window_get_geometry(GdkWindow *, gint *, gint *,
					gint *, gint *, gint *);
    extern void gdk_rgb_set_min_colors(gint);
    extern gint gdk_screen_get_monitor_at_window(GdkScreen *, GdkWindow *);
    extern GdkWindow *gdk_window_foreign_new_for_display(GdkDisplay *,
							 GdkNativeWindow);
    extern GdkRegion *gdk_region_rectangle(GdkRectangle *);
    extern void gdk_window_set_icon_list(GdkWindow *, GList *);
    extern GdkPixbuf *gdk_pixbuf_get_from_image(GdkPixbuf *, GdkImage *,
						GdkColormap *, int, int,
						int, int, int, int);
    extern void gdk_device_set_axis_use(GdkDevice *, guint, GdkAxisUse);
    extern void gdk_keyboard_ungrab(guint32);
    extern GdkWindow *gdk_window_at_pointer(gint *, gint *);
    extern GdkVisual *gdk_visual_get_system(void);
    extern void gdk_drag_find_window_for_screen(GdkDragContext *,
						GdkWindow *, GdkScreen *,
						gint, gint, GdkWindow * *,
						GdkDragProtocol *);
    extern GdkRegion *gdk_region_new(void);
    extern GType gdk_image_type_get_type(void);
    extern GType gdk_image_get_type(void);
    extern gboolean gdk_display_supports_clipboard_persistence(GdkDisplay
							       *);
    extern gint gdk_screen_width(void);
    extern void gdk_input_set_extension_events(GdkWindow *, gint,
					       GdkExtensionMode);
    extern GType gdk_display_get_type(void);
    extern GdkCursor *gdk_cursor_new_for_display(GdkDisplay *,
						 GdkCursorType);
    extern GdkRegion *gdk_drawable_get_clip_region(GdkDrawable *);
    extern GdkScreen *gdk_display_get_screen(GdkDisplay *, gint);
    extern GdkColormap *gdk_screen_get_system_colormap(GdkScreen *);
    extern GdkVisualType gdk_visual_get_best_type(void);
    extern GType gdk_setting_action_get_type(void);
    extern GdkCursor *gdk_cursor_new_from_pixmap(GdkPixmap *, GdkPixmap *,
						 const GdkColor *,
						 const GdkColor *, gint,
						 gint);
    extern GType gdk_fill_rule_get_type(void);
    extern void gdk_window_invalidate_region(GdkWindow *, GdkRegion *,
					     gboolean);
    extern gint gdk_screen_width_mm(void);
    extern void gdk_window_set_child_shapes(GdkWindow *);
    extern void gdk_window_move_resize(GdkWindow *, gint, gint, gint,
				       gint);
    extern GType gdk_cursor_get_type(void);
    extern void gdk_free_compound_text(guchar *);
    extern PangoRenderer *gdk_pango_renderer_new(GdkScreen *);
    extern GdkScreen *gdk_drawable_get_screen(GdkDrawable *);
    extern GdkWindow *gdk_window_lookup(GdkNativeWindow);
    extern void gdk_window_set_icon_name(GdkWindow *, const gchar *);
    extern GType gdk_drag_context_get_type(void);
    extern void gdk_window_thaw_updates(GdkWindow *);
    extern GdkPixmap *gdk_pixmap_colormap_create_from_xpm(GdkDrawable *,
							  GdkColormap *,
							  GdkBitmap * *,
							  const GdkColor *,
							  const gchar *);
    extern GdkEvent *gdk_event_copy(GdkEvent *);
    extern gboolean gdk_selection_owner_set(GdkWindow *, GdkAtom, guint32,
					    gboolean);
    extern void gdk_window_get_position(GdkWindow *, gint *, gint *);
    extern GType gdk_drag_action_get_type(void);
    extern guint32 gdk_image_get_pixel(GdkImage *, gint, gint);
    extern void gdk_window_shape_combine_mask(GdkWindow *, GdkBitmap *,
					      gint, gint);
    extern void gdk_region_shrink(GdkRegion *, int, int);
#ifdef __cplusplus
}
#endif
#endif
