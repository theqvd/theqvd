#ifndef _PANGO_1_0_PANGO_PANGOFC_DECODER_H_
#define _PANGO_1_0_PANGO_PANGOFC_DECODER_H_

#include <fontconfig/fontconfig.h>
#include <glib-2.0/glib.h>
#include <glib-2.0/glib-object.h>
#include <pango-1.0/pango/pango.h>
#include <pango-1.0/pango/pangoxft.h>
#include <pango-1.0/pango/pangoft2.h>

#ifdef __cplusplus
extern "C" {
#endif


#define PANGO_FC_DECODER_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), PANGO_TYPE_FC_DECODER, \
	PangoFcDecoderClass))
#define PANGO_IS_FC_DECODER_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), PANGO_TYPE_FC_DECODER))
#define PANGO_FC_DECODER(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_FC_DECODER, \
	PangoFcDecoder))
#define PANGO_IS_FC_DECODER(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_FC_DECODER))
#define PANGO_FC_DECODER_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), PANGO_TYPE_FC_DECODER, \
	PangoFcDecoderClass))
#define PANGO_TYPE_FC_DECODER	(pango_fc_decoder_get_type())


    typedef struct _PangoFcDecoder PangoFcDecoder;

    typedef struct _PangoFcDecoderClass PangoFcDecoderClass;


    struct _PangoFcDecoder {
	GObject parent_instance;
    };


    struct _PangoFcDecoderClass {
	GObjectClass parent_class;
	FcCharSet *(*get_charset) (PangoFcDecoder *, PangoFcFont *);
	 PangoGlyph(*get_glyph) (PangoFcDecoder *, PangoFcFont *, guint32);
	void (*_pango_reserved1) (void);
	void (*_pango_reserved2) (void);
	void (*_pango_reserved3) (void);
	void (*_pango_reserved4) (void);
    };


    extern FcCharSet *pango_fc_decoder_get_charset(PangoFcDecoder *,
						   PangoFcFont *);
    extern PangoGlyph pango_fc_decoder_get_glyph(PangoFcDecoder *,
						 PangoFcFont *, guint32);
    extern GType pango_fc_decoder_get_type(void);
#ifdef __cplusplus
}
#endif
#endif
