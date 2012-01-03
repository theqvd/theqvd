#ifndef _PANGO_1_0_PANGO_PANGOFC_FONTMAP_H_
#define _PANGO_1_0_PANGO_PANGOFC_FONTMAP_H_

#include <fontconfig/fontconfig.h>
#include <glib-2.0/glib.h>
#include <glib-2.0/glib-object.h>
#include <pango-1.0/pango/pango.h>
#include <pango-1.0/pango/pangofc-decoder.h>

#ifdef __cplusplus
extern "C" {
#endif


#define PANGO_FC_FONT_MAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_FC_FONT_MAP, \
	PangoFcFontMap))
#define PANGO_IS_FC_FONT_MAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_FC_FONT_MAP))
#define PANGO_TYPE_FC_FONT_MAP	(pango_fc_font_map_get_type ())


    typedef struct _PangoFcFontMap PangoFcFontMap;

    typedef PangoFcDecoder *(*PangoFcDecoderFindFunc) (FcPattern *,
						       gpointer);

    typedef struct _PangoFcFontMapClass PangoFcFontMapClass;








    extern void pango_fc_font_map_add_decoder_find_func(PangoFcFontMap *,
							PangoFcDecoderFindFunc,
							gpointer,
							GDestroyNotify);
    extern PangoFontDescription
	*pango_fc_font_description_from_pattern(FcPattern *, gboolean);
    extern GType pango_fc_font_map_get_type(void);
#ifdef __cplusplus
}
#endif
#endif
