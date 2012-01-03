#ifndef _GTK_2_0_GDK_PIXBUF_GDK_PIXDATA_H_
#define _GTK_2_0_GDK_PIXBUF_GDK_PIXDATA_H_

#include <glib-2.0/glib.h>
#include <glib-2.0/glib-object.h>
#include <gtk-2.0/gdk-pixbuf/gdk-pixbuf.h>

#ifdef __cplusplus
extern "C" {
#endif


#define GDK_PIXBUF_MAGIC_NUMBER	(0x47646b50)
#define GDK_PIXDATA_HEADER_LENGTH	(4 + 4 + 4 + 4 + 4 + 4)


    typedef struct _GdkPixdata GdkPixdata;

    typedef enum {
	GDK_PIXDATA_DUMP_PIXDATA_STREAM = 0,
	GDK_PIXDATA_DUMP_PIXDATA_STRUCT = 1,
	GDK_PIXDATA_DUMP_MACROS = 2,
	GDK_PIXDATA_DUMP_GTYPES = 0,
	GDK_PIXDATA_DUMP_CTYPES = 256,
	GDK_PIXDATA_DUMP_STATIC = 512,
	GDK_PIXDATA_DUMP_CONST = 1024,
	GDK_PIXDATA_DUMP_RLE_DECODER = 65536
    } GdkPixdataDumpType;

    typedef enum {
	GDK_PIXDATA_COLOR_TYPE_RGB = 0x01,
	GDK_PIXDATA_COLOR_TYPE_RGBA = 0x02,
	GDK_PIXDATA_COLOR_TYPE_MASK = 0xff,
	GDK_PIXDATA_SAMPLE_WIDTH_8 = 0x01 << 16,
	GDK_PIXDATA_SAMPLE_WIDTH_MASK = 0x0f << 16,
	GDK_PIXDATA_ENCODING_RAW = 0x01 << 24,
	GDK_PIXDATA_ENCODING_RLE = 0x02 << 24,
	GDK_PIXDATA_ENCODING_MASK = 0x0f << 24
    } GdkPixdataType;


    struct _GdkPixdata {
	guint32 magic;
	gint32 length;
	guint32 pixdata_type;
	guint32 rowstride;
	guint32 width;
	guint32 height;
	guint8 *pixel_data;
    };


    extern gboolean gdk_pixdata_deserialize(GdkPixdata *, guint,
					    const guint8 *, GError * *);
    extern gpointer gdk_pixdata_from_pixbuf(GdkPixdata *,
					    const GdkPixbuf *, gboolean);
    extern guint8 *gdk_pixdata_serialize(const GdkPixdata *, guint *);
    extern GString *gdk_pixdata_to_csource(GdkPixdata *, const gchar *,
					   GdkPixdataDumpType);
    extern GdkPixbuf *gdk_pixbuf_from_pixdata(const GdkPixdata *, gboolean,
					      GError * *);
#ifdef __cplusplus
}
#endif
#endif
