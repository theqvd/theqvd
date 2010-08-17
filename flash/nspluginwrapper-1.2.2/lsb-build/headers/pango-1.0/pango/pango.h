#ifndef _PANGO_1_0_PANGO_PANGO_H_
#define _PANGO_1_0_PANGO_PANGO_H_

#include <glib-2.0/glib.h>
#include <glib-2.0/glib-object.h>
#include <atk-1.0/atk/atk.h>

#ifdef __cplusplus
extern "C" {
#endif


#define PANGO_CONTEXT_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), PANGO_TYPE_CONTEXT, \
	PangoContextClass))
#define PANGO_LAYOUT_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), PANGO_TYPE_LAYOUT, \
	PangoLayoutClass))
#define PANGO_RENDERER_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((klass), PANGO_TYPE_RENDERER, \
	PangoRendererClass))
#define PANGO_IS_CONTEXT_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), PANGO_TYPE_CONTEXT))
#define PANGO_IS_LAYOUT_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), PANGO_TYPE_LAYOUT))
#define PANGO_IS_RENDERER_CLASS(klass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((klass), PANGO_TYPE_RENDERER))
#define PANGO_CONTEXT(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_CONTEXT, \
	PangoContext))
#define PANGO_FONT(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_FONT, PangoFont))
#define PANGO_FONTSET(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_FONTSET, \
	PangoFontset))
#define PANGO_FONT_FACE(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_FONT_FACE, \
	PangoFontFace))
#define PANGO_FONT_FAMILY(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_FONT_FAMILY, \
	PangoFontFamily))
#define PANGO_FONT_MAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_FONT_MAP, \
	PangoFontMap))
#define PANGO_LAYOUT(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_LAYOUT, \
	PangoLayout))
#define PANGO_RENDERER(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), PANGO_TYPE_RENDERER, \
	PangoRenderer))
#define PANGO_IS_CONTEXT(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_CONTEXT))
#define PANGO_IS_FONT(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_FONT))
#define PANGO_IS_FONTSET(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_FONTSET))
#define PANGO_IS_FONT_FACE(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_FONT_FACE))
#define PANGO_IS_FONT_FAMILY(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_FONT_FAMILY))
#define PANGO_IS_FONT_MAP(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_FONT_MAP))
#define PANGO_IS_LAYOUT(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_LAYOUT))
#define PANGO_IS_RENDERER(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), PANGO_TYPE_RENDERER))
#define PANGO_CONTEXT_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), PANGO_TYPE_CONTEXT, \
	PangoContextClass))
#define PANGO_LAYOUT_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), PANGO_TYPE_LAYOUT, \
	PangoLayoutClass))
#define PANGO_RENDERER_GET_CLASS(obj)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((obj), PANGO_TYPE_RENDERER, \
	PangoRendererClass))
#define PANGO_PIXELS(d)	(((int)(d) + 512) >> 10)
#define pango_language_to_string(language)	((const char *)language)
#define PANGO_SCALE_XX_SMALL	((double)0.5787037037037)
#define PANGO_SCALE_X_SMALL	((double)0.6444444444444)
#define PANGO_SCALE_SMALL	((double)0.8333333333333)
#define PANGO_SCALE_MEDIUM	((double)1.0)
#define PANGO_SCALE_LARGE	((double)1.2)
#define PANGO_SCALE_X_LARGE	((double)1.4399999999999)
#define PANGO_SCALE_XX_LARGE	((double)1.728)
#define PANGO_RBEARING(rect)	((rect).x + (rect).width)
#define PANGO_LBEARING(rect)	((rect).x)
#define PANGO_DESCENT(rect)	((rect).y + (rect).height)
#define PANGO_ASCENT(rect)	(-(rect).y)
#define PANGO_TYPE_ALIGNMENT	(pango_alignment_get_type())
#define PANGO_TYPE_ATTR_TYPE	(pango_attr_type_get_type())
#define PANGO_TYPE_CONTEXT	(pango_context_get_type ())
#define PANGO_TYPE_COVERAGE_LEVEL	(pango_coverage_level_get_type())
#define PANGO_TYPE_DIRECTION	(pango_direction_get_type())
#define PANGO_TYPE_ELLIPSIZE_MODE	(pango_ellipsize_mode_get_type())
#define PANGO_TYPE_FONTSET	(pango_fontset_get_type ())
#define PANGO_TYPE_FONT_DESCRIPTION	(pango_font_description_get_type ())
#define PANGO_TYPE_FONT_FACE	(pango_font_face_get_type ())
#define PANGO_TYPE_FONT_FAMILY	(pango_font_family_get_type ())
#define PANGO_TYPE_FONT	(pango_font_get_type ())
#define PANGO_TYPE_FONT_MAP	(pango_font_map_get_type ())
#define PANGO_TYPE_FONT_MASK	(pango_font_mask_get_type())
#define PANGO_TYPE_FONT_METRICS	(pango_font_metrics_get_type ())
#define PANGO_TYPE_GLYPH_STRING	(pango_glyph_string_get_type ())
#define PANGO_TYPE_LANGUAGE	(pango_language_get_type ())
#define PANGO_TYPE_LAYOUT	(pango_layout_get_type ())
#define PANGO_TYPE_LAYOUT_ITER	(pango_layout_iter_get_type ())
#define PANGO_TYPE_MATRIX	(pango_matrix_get_type ())
#define PANGO_TYPE_RENDERER	(pango_renderer_get_type())
#define PANGO_TYPE_RENDER_PART	(pango_render_part_get_type())
#define PANGO_TYPE_SCRIPT	(pango_script_get_type())
#define PANGO_TYPE_STRETCH	(pango_stretch_get_type())
#define PANGO_TYPE_STYLE	(pango_style_get_type())
#define PANGO_TYPE_TAB_ALIGN	(pango_tab_align_get_type())
#define PANGO_TYPE_TAB_ARRAY	(pango_tab_array_get_type ())
#define PANGO_TYPE_UNDERLINE	(pango_underline_get_type())
#define PANGO_TYPE_VARIANT	(pango_variant_get_type())
#define PANGO_TYPE_WEIGHT	(pango_weight_get_type())
#define PANGO_TYPE_WRAP_MODE	(pango_wrap_mode_get_type())
#define PANGO_SCALE	1024
#define PANGO_TYPE_ATTR_LIST	pango_attr_list_get_type ()
#define PANGO_TYPE_COLOR	pango_color_get_type ()
#define PANGO_MATRIX_INIT	{ 1., 0., 0., 1., 0., 0. }


    typedef struct _PangoFontFace PangoFontFace;

    typedef enum {
	PANGO_WRAP_WORD = 0,
	PANGO_WRAP_CHAR = 1,
	PANGO_WRAP_WORD_CHAR = 2
    } PangoWrapMode;

    typedef struct _PangoLayout PangoLayout;

    typedef struct _PangoScriptIter PangoScriptIter;

    typedef enum {
	PANGO_SCRIPT_INVALID_CODE = -1,
	PANGO_SCRIPT_COMMON = 0,
	PANGO_SCRIPT_INHERITED = 1,
	PANGO_SCRIPT_ARABIC = 2,
	PANGO_SCRIPT_ARMENIAN = 3,
	PANGO_SCRIPT_BENGALI = 4,
	PANGO_SCRIPT_BOPOMOFO = 5,
	PANGO_SCRIPT_CHEROKEE = 6,
	PANGO_SCRIPT_COPTIC = 7,
	PANGO_SCRIPT_CYRILLIC = 8,
	PANGO_SCRIPT_DESERET = 9,
	PANGO_SCRIPT_DEVANAGARI = 10,
	PANGO_SCRIPT_ETHIOPIC = 11,
	PANGO_SCRIPT_GEORGIAN = 12,
	PANGO_SCRIPT_GOTHIC = 13,
	PANGO_SCRIPT_GREEK = 14,
	PANGO_SCRIPT_GUJARATI = 15,
	PANGO_SCRIPT_GURMUKHI = 16,
	PANGO_SCRIPT_HAN = 17,
	PANGO_SCRIPT_HANGUL = 18,
	PANGO_SCRIPT_HEBREW = 19,
	PANGO_SCRIPT_HIRAGANA = 20,
	PANGO_SCRIPT_KANNADA = 21,
	PANGO_SCRIPT_KATAKANA = 22,
	PANGO_SCRIPT_KHMER = 23,
	PANGO_SCRIPT_LAO = 24,
	PANGO_SCRIPT_LATIN = 25,
	PANGO_SCRIPT_MALAYALAM = 26,
	PANGO_SCRIPT_MONGOLIAN = 27,
	PANGO_SCRIPT_MYANMAR = 28,
	PANGO_SCRIPT_OGHAM = 29,
	PANGO_SCRIPT_OLD_ITALIC = 30,
	PANGO_SCRIPT_ORIYA = 31,
	PANGO_SCRIPT_RUNIC = 32,
	PANGO_SCRIPT_SINHALA = 33,
	PANGO_SCRIPT_SYRIAC = 34,
	PANGO_SCRIPT_TAMIL = 35,
	PANGO_SCRIPT_TELUGU = 36,
	PANGO_SCRIPT_THAANA = 37,
	PANGO_SCRIPT_THAI = 38,
	PANGO_SCRIPT_TIBETAN = 39,
	PANGO_SCRIPT_CANADIAN_ABORIGINAL = 40,
	PANGO_SCRIPT_YI = 41,
	PANGO_SCRIPT_TAGALOG = 42,
	PANGO_SCRIPT_HANUNOO = 43,
	PANGO_SCRIPT_BUHID = 44,
	PANGO_SCRIPT_TAGBANWA = 45,
	PANGO_SCRIPT_BRAILLE = 46,
	PANGO_SCRIPT_CYPRIOT = 47,
	PANGO_SCRIPT_LIMBU = 48,
	PANGO_SCRIPT_OSMANYA = 49,
	PANGO_SCRIPT_SHAVIAN = 50,
	PANGO_SCRIPT_LINEAR_B = 51,
	PANGO_SCRIPT_TAI_LE = 52,
	PANGO_SCRIPT_UGARITIC = 53
    } PangoScript;

    typedef struct _PangoFont PangoFont;

    typedef struct _PangoContext PangoContext;

    typedef struct _PangoFontDescription PangoFontDescription;

    typedef enum {
	PANGO_ATTR_INVALID = 0,
	PANGO_ATTR_LANGUAGE = 1,
	PANGO_ATTR_FAMILY = 2,
	PANGO_ATTR_STYLE = 3,
	PANGO_ATTR_WEIGHT = 4,
	PANGO_ATTR_VARIANT = 5,
	PANGO_ATTR_STRETCH = 6,
	PANGO_ATTR_SIZE = 7,
	PANGO_ATTR_FONT_DESC = 8,
	PANGO_ATTR_FOREGROUND = 9,
	PANGO_ATTR_BACKGROUND = 10,
	PANGO_ATTR_UNDERLINE = 11,
	PANGO_ATTR_STRIKETHROUGH = 12,
	PANGO_ATTR_RISE = 13,
	PANGO_ATTR_SHAPE = 14,
	PANGO_ATTR_SCALE = 15,
	PANGO_ATTR_FALLBACK = 16,
	PANGO_ATTR_LETTER_SPACING = 17,
	PANGO_ATTR_UNDERLINE_COLOR = 18,
	PANGO_ATTR_STRIKETHROUGH_COLOR = 19,
	PANGO_ATTR_ABSOLUTE_SIZE = 20
    } PangoAttrType;

    typedef struct _PangoAttribute PangoAttribute;

    typedef struct _PangoAttrClass PangoAttrClass;

    typedef struct _PangoLanguage PangoLanguage;

    typedef struct _PangoLogAttr PangoLogAttr;

    typedef struct _PangoColor PangoColor;

    typedef struct _PangoMatrix PangoMatrix;

    typedef struct _PangoEngineShape PangoEngineShape;

    typedef struct _PangoEngineLang PangoEngineLang;

    typedef struct _PangoAnalysis PangoAnalysis;

    typedef struct _PangoItem PangoItem;

    typedef guint32 PangoGlyph;

    typedef gint32 PangoGlyphUnit;

    typedef struct _PangoGlyphGeometry PangoGlyphGeometry;

    typedef struct _PangoGlyphVisAttr PangoGlyphVisAttr;

    typedef struct _PangoGlyphInfo PangoGlyphInfo;

    typedef struct _PangoGlyphString PangoGlyphString;

    typedef struct _PangoGlyphItem PangoGlyphItem;

    typedef PangoGlyphItem PangoLayoutRun;

    typedef struct _PangoLayoutIter PangoLayoutIter;

    typedef enum {
	PANGO_UNDERLINE_NONE = 0,
	PANGO_UNDERLINE_SINGLE = 1,
	PANGO_UNDERLINE_DOUBLE = 2,
	PANGO_UNDERLINE_LOW = 3,
	PANGO_UNDERLINE_ERROR = 4
    } PangoUnderline;

    typedef struct _PangoRendererPrivate PangoRendererPrivate;

    typedef struct _PangoRenderer PangoRenderer;

    typedef enum {
	PANGO_RENDER_PART_FOREGROUND = 0,
	PANGO_RENDER_PART_BACKGROUND = 1,
	PANGO_RENDER_PART_UNDERLINE = 2,
	PANGO_RENDER_PART_STRIKETHROUGH = 3
    } PangoRenderPart;

    typedef struct _PangoAttrList PangoAttrList;

    typedef struct _PangoLayoutLine PangoLayoutLine;

    typedef enum {
	PANGO_STRETCH_ULTRA_CONDENSED = 0,
	PANGO_STRETCH_EXTRA_CONDENSED = 1,
	PANGO_STRETCH_CONDENSED = 2,
	PANGO_STRETCH_SEMI_CONDENSED = 3,
	PANGO_STRETCH_NORMAL = 4,
	PANGO_STRETCH_SEMI_EXPANDED = 5,
	PANGO_STRETCH_EXPANDED = 6,
	PANGO_STRETCH_EXTRA_EXPANDED = 7,
	PANGO_STRETCH_ULTRA_EXPANDED = 8
    } PangoStretch;

    typedef struct _PangoRectangle PangoRectangle;

    typedef struct _PangoFontFamily PangoFontFamily;

    typedef struct _PangoFontMetrics PangoFontMetrics;

    typedef struct _PangoTabArray PangoTabArray;

    typedef enum {
	PANGO_TAB_LEFT = 0
    } PangoTabAlign;

    typedef enum {
	PANGO_ALIGN_LEFT = 0,
	PANGO_ALIGN_CENTER = 1,
	PANGO_ALIGN_RIGHT = 2
    } PangoAlignment;

    typedef struct _PangoAttrIterator PangoAttrIterator;

    typedef enum {
	PANGO_FONT_MASK_FAMILY = 1,
	PANGO_FONT_MASK_STYLE = 2,
	PANGO_FONT_MASK_VARIANT = 4,
	PANGO_FONT_MASK_WEIGHT = 8,
	PANGO_FONT_MASK_STRETCH = 16,
	PANGO_FONT_MASK_SIZE = 32
    } PangoFontMask;

    typedef enum {
	PANGO_DIRECTION_LTR = 0,
	PANGO_DIRECTION_RTL = 1,
	PANGO_DIRECTION_TTB_LTR = 2,
	PANGO_DIRECTION_TTB_RTL = 3,
	PANGO_DIRECTION_WEAK_LTR = 4,
	PANGO_DIRECTION_WEAK_RTL = 5,
	PANGO_DIRECTION_NEUTRAL = 6
    } PangoDirection;

    typedef enum {
	PANGO_ELLIPSIZE_NONE = 0,
	PANGO_ELLIPSIZE_START = 1,
	PANGO_ELLIPSIZE_MIDDLE = 2,
	PANGO_ELLIPSIZE_END = 3
    } PangoEllipsizeMode;

    typedef struct _PangoCoverage PangoCoverage;

    typedef enum {
	PANGO_STYLE_NORMAL = 0,
	PANGO_STYLE_OBLIQUE = 1,
	PANGO_STYLE_ITALIC = 2
    } PangoStyle;

    typedef enum {
	PANGO_COVERAGE_NONE = 0,
	PANGO_COVERAGE_FALLBACK = 1,
	PANGO_COVERAGE_APPROXIMATE = 2,
	PANGO_COVERAGE_EXACT = 3
    } PangoCoverageLevel;

    typedef struct _PangoFontMap PangoFontMap;

    typedef gboolean(*PangoAttrFilterFunc) (PangoAttribute *, gpointer);

    typedef struct _PangoFontset PangoFontset;

    typedef enum {
	PANGO_WEIGHT_ULTRALIGHT = 200,
	PANGO_WEIGHT_LIGHT = 300,
	PANGO_WEIGHT_NORMAL = 400,
	PANGO_WEIGHT_SEMIBOLD = 600,
	PANGO_WEIGHT_BOLD = 700,
	PANGO_WEIGHT_ULTRABOLD = 800,
	PANGO_WEIGHT_HEAVY = 900
    } PangoWeight;

    typedef gboolean(*PangoFontsetForeachFunc) (PangoFontset *,
						PangoFont *, gpointer);

    typedef enum {
	PANGO_VARIANT_NORMAL = 0,
	PANGO_VARIANT_SMALL_CAPS = 1
    } PangoVariant;

    typedef gpointer(*PangoAttrDataCopyFunc) (gconstpointer);

    typedef struct _PangoAttrShape PangoAttrShape;

    typedef struct _PangoContextClass PangoContextClass;

    typedef struct _PangoAttrString PangoAttrString;

    typedef struct _PangoAttrColor PangoAttrColor;

    typedef struct _PangoAttrFontDesc PangoAttrFontDesc;

    typedef struct _PangoAttrFloat PangoAttrFloat;

    typedef struct _PangoRendererClass PangoRendererClass;

    typedef struct _PangoAttrLanguage PangoAttrLanguage;

    typedef struct _PangoAttrInt PangoAttrInt;

    typedef struct _PangoAttrSize PangoAttrSize;

    typedef struct _PangoLayoutClass PangoLayoutClass;




















    struct _PangoAttribute {
	const PangoAttrClass *klass;
	guint start_index;
	guint end_index;
    };


    struct _PangoAttrClass {
	PangoAttrType type;
	PangoAttribute *(*copy) (const PangoAttribute *);
	void (*destroy) (PangoAttribute *);
	 gboolean(*equal) (const PangoAttribute *, const PangoAttribute *);
    };





    struct _PangoLogAttr {
	guint is_line_break:1;
	guint is_mandatory_break:1;
	guint is_char_break:1;
	guint is_white:1;
	guint is_cursor_position:1;
	guint is_word_start:1;
	guint is_word_end:1;
	guint is_sentence_boundary:1;
	guint is_sentence_start:1;
	guint is_sentence_end:1;
	guint backspace_deletes_character:1;
    };


    struct _PangoColor {
	guint16 red;
	guint16 green;
	guint16 blue;
    };


    struct _PangoMatrix {
	double xx;
	double xy;
	double yx;
	double yy;
	double x0;
	double y0;
    };








    struct _PangoAnalysis {
	PangoEngineShape *shape_engine;
	PangoEngineLang *lang_engine;
	PangoFont *font;
	guint8 level;
	PangoLanguage *language;
	GSList *extra_attrs;
    };


    struct _PangoItem {
	gint offset;
	gint length;
	gint num_chars;
	PangoAnalysis analysis;
    };


    struct _PangoGlyphGeometry {
	PangoGlyphUnit width;
	PangoGlyphUnit x_offset;
	PangoGlyphUnit y_offset;
    };


    struct _PangoGlyphVisAttr {
	guint is_cluster_start:1;
    };


    struct _PangoGlyphInfo {
	PangoGlyph glyph;
	PangoGlyphGeometry geometry;
	PangoGlyphVisAttr attr;
    };


    struct _PangoGlyphString {
	gint num_glyphs;
	PangoGlyphInfo *glyphs;
	gint *log_clusters;
	gint space;
    };


    struct _PangoGlyphItem {
	PangoItem *item;
	PangoGlyphString *glyphs;
    };








    struct _PangoRenderer {
	GObject parent_instance;
	PangoUnderline underline;
	gboolean strikethrough;
	int active_count;
	PangoMatrix *matrix;
	PangoRendererPrivate *priv;
    };





    struct _PangoLayoutLine {
	PangoLayout *layout;
	gint start_index;
	gint length;
	GSList *runs;
	guint is_paragraph_start:1;
	guint resolved_dir:3;
    };


    struct _PangoRectangle {
	int x;
	int y;
	int width;
	int height;
    };























    struct _PangoAttrShape {
	PangoAttribute attr;
	PangoRectangle ink_rect;
	PangoRectangle logical_rect;
	gpointer data;
	PangoAttrDataCopyFunc copy_func;
	GDestroyNotify destroy_func;
    };





    struct _PangoAttrString {
	PangoAttribute attr;
	char *value;
    };


    struct _PangoAttrColor {
	PangoAttribute attr;
	PangoColor color;
    };


    struct _PangoAttrFontDesc {
	PangoAttribute attr;
	PangoFontDescription *desc;
    };


    struct _PangoAttrFloat {
	PangoAttribute attr;
	double value;
    };


    struct _PangoRendererClass {
	GObjectClass parent_class;
	void (*draw_glyphs) (PangoRenderer *, PangoFont *,
			     PangoGlyphString *, int, int);
	void (*draw_rectangle) (PangoRenderer *, PangoRenderPart, int, int,
				int, int);
	void (*draw_error_underline) (PangoRenderer *, int, int, int, int);
	void (*draw_shape) (PangoRenderer *, PangoAttrShape *, int, int);
	void (*draw_trapezoid) (PangoRenderer *, PangoRenderPart, double,
				double, double, double, double, double);
	void (*draw_glyph) (PangoRenderer *, PangoFont *, PangoGlyph,
			    double, double);
	void (*part_changed) (PangoRenderer *, PangoRenderPart);
	void (*begin) (PangoRenderer *);
	void (*end) (PangoRenderer *);
	void (*prepare_run) (PangoRenderer *, PangoLayoutRun *);
	void (*_pango_reserved1) (void);
	void (*_pango_reserved2) (void);
	void (*_pango_reserved3) (void);
	void (*_pango_reserved4) (void);
    };


    struct _PangoAttrLanguage {
	PangoAttribute attr;
	PangoLanguage *value;
    };


    struct _PangoAttrInt {
	PangoAttribute attr;
	int value;
    };


    struct _PangoAttrSize {
	PangoAttribute attr;
	int size;
	guint absolute:1;
    };





    extern GType pango_script_get_type(void);
    extern const char *pango_font_face_get_face_name(PangoFontFace *);
    extern PangoWrapMode pango_layout_get_wrap(PangoLayout *);
    extern void pango_layout_context_changed(PangoLayout *);
    extern gboolean pango_script_iter_next(PangoScriptIter *);
    extern PangoScript pango_script_for_unichar(gunichar);
    extern PangoFont *pango_context_load_font(PangoContext *,
					      const PangoFontDescription
					      *);
    extern gboolean pango_attribute_equal(const PangoAttribute *,
					  const PangoAttribute *);
    extern void pango_get_log_attrs(const char *, int, int,
				    PangoLanguage *, PangoLogAttr *, int);
    extern gboolean pango_color_parse(PangoColor *, const char *);
    extern gboolean pango_font_description_equal(const PangoFontDescription
						 *,
						 const PangoFontDescription
						 *);
    extern PangoAttribute *pango_attr_rise_new(int);
    extern void pango_matrix_translate(PangoMatrix *, double, double);
    extern PangoLayoutRun *pango_layout_iter_get_run(PangoLayoutIter *);
    extern PangoLayout *pango_layout_new(PangoContext *);
    extern PangoAttribute *pango_attr_size_new(int);
    extern PangoAttribute *pango_attr_family_new(const char *);
    extern void pango_layout_set_markup_with_accel(PangoLayout *,
						   const char *, int,
						   gunichar, gunichar *);
    extern PangoLanguage *pango_script_get_sample_language(PangoScript);
    extern void pango_renderer_draw_trapezoid(PangoRenderer *,
					      PangoRenderPart, double,
					      double, double, double,
					      double, double);
    extern void pango_attr_list_insert_before(PangoAttrList *,
					      PangoAttribute *);
    extern PangoAttribute *pango_attr_underline_new(PangoUnderline);
    extern void pango_layout_line_unref(PangoLayoutLine *);
    extern void pango_glyph_string_get_logical_widths(PangoGlyphString *,
						      const char *, int,
						      int, int *);
    extern PangoStretch pango_font_description_get_stretch(const
							   PangoFontDescription
							   *);
    extern void pango_layout_iter_get_char_extents(PangoLayoutIter *,
						   PangoRectangle *);
    extern PangoAttribute *pango_attr_scale_new(double);
    extern void pango_layout_set_width(PangoLayout *, int);
    extern void pango_layout_line_index_to_x(PangoLayoutLine *, int, int,
					     int *);
    extern gboolean pango_font_family_is_monospace(PangoFontFamily *);
    extern void pango_font_descriptions_free(PangoFontDescription * *,
					     int);
    extern void pango_layout_set_single_paragraph_mode(PangoLayout *,
						       gboolean);
    extern char *pango_font_description_to_filename(const
						    PangoFontDescription
						    *);
    extern PangoLayout *pango_layout_copy(PangoLayout *);
    extern int
	pango_font_metrics_get_approximate_char_width(PangoFontMetrics *);
    extern void pango_shape(const gchar *, gint, PangoAnalysis *,
			    PangoGlyphString *);
    extern void pango_layout_line_get_pixel_extents(PangoLayoutLine *,
						    PangoRectangle *,
						    PangoRectangle *);
    extern void pango_layout_set_wrap(PangoLayout *, PangoWrapMode);
    extern const char *pango_font_description_get_family(const
							 PangoFontDescription
							 *);
    extern void pango_tab_array_get_tabs(PangoTabArray *,
					 PangoTabAlign * *, gint * *);
    extern void pango_script_iter_get_range(PangoScriptIter *,
					    const char **, const char **,
					    PangoScript *);
    extern gboolean pango_layout_iter_next_line(PangoLayoutIter *);
    extern void pango_layout_get_log_attrs(PangoLayout *, PangoLogAttr * *,
					   gint *);
    extern void pango_tab_array_free(PangoTabArray *);
    extern PangoTabArray *pango_layout_get_tabs(PangoLayout *);
    extern PangoFontDescription *pango_font_describe(PangoFont *);
    extern void pango_context_set_font_description(PangoContext *,
						   const
						   PangoFontDescription *);
    extern gint pango_tab_array_get_size(PangoTabArray *);
    extern PangoAlignment pango_layout_get_alignment(PangoLayout *);
    extern const PangoMatrix *pango_renderer_get_matrix(PangoRenderer *);
    extern PangoAttrIterator *pango_attr_iterator_copy(PangoAttrIterator
						       *);
    extern GType pango_style_get_type(void);
    extern PangoFontMask pango_font_description_get_set_fields(const
							       PangoFontDescription
							       *);
    extern gboolean pango_language_matches(PangoLanguage *, const char *);
    extern int pango_font_metrics_get_descent(PangoFontMetrics *);
    extern void pango_layout_get_extents(PangoLayout *, PangoRectangle *,
					 PangoRectangle *);
    extern char *pango_font_description_to_string(const
						  PangoFontDescription *);
    extern void pango_layout_set_justify(PangoLayout *, gboolean);
    extern void pango_find_paragraph_boundary(const gchar *, gint, gint *,
					      gint *);
    extern PangoDirection pango_unichar_direction(gunichar);
    extern GList *pango_reorder_items(GList *);
    extern void pango_glyph_string_set_size(PangoGlyphString *, gint);
    extern PangoFontDescription *pango_font_description_from_string(const
								    char
								    *);
    extern int
	pango_font_metrics_get_strikethrough_position(PangoFontMetrics *);
    extern PangoEngineShape *pango_font_find_shaper(PangoFont *,
						    PangoLanguage *,
						    guint32);
    extern GType pango_glyph_string_get_type(void);
    extern PangoEllipsizeMode pango_layout_get_ellipsize(PangoLayout *);
    extern PangoFontDescription *pango_font_face_describe(PangoFontFace *);
    extern PangoMatrix *pango_matrix_copy(const PangoMatrix *);
    extern const PangoMatrix *pango_context_get_matrix(PangoContext *);
    extern void pango_attr_iterator_range(PangoAttrIterator *, gint *,
					  gint *);
    extern void pango_context_set_language(PangoContext *,
					   PangoLanguage *);
    extern void pango_glyph_item_letter_space(PangoGlyphItem *,
					      const char *, PangoLogAttr *,
					      int);
    extern void pango_coverage_max(PangoCoverage *, PangoCoverage *);
    extern PangoStyle pango_font_description_get_style(const
						       PangoFontDescription
						       *);
    extern void pango_layout_line_get_extents(PangoLayoutLine *,
					      PangoRectangle *,
					      PangoRectangle *);
    extern void pango_attribute_destroy(PangoAttribute *);
    extern PangoLayoutLine *pango_layout_get_line(PangoLayout *, int);
    extern gboolean pango_layout_get_auto_dir(PangoLayout *);
    extern int
	pango_font_metrics_get_approximate_digit_width(PangoFontMetrics *);
    extern void pango_attr_list_splice(PangoAttrList *, PangoAttrList *,
				       gint, gint);
    extern PangoLayoutLine *pango_layout_iter_get_line(PangoLayoutIter *);
    extern PangoFontDescription *pango_font_description_new(void);
    extern PangoAttribute *pango_attr_font_desc_new(const
						    PangoFontDescription
						    *);
    extern PangoFontDescription *pango_font_description_copy_static(const
								    PangoFontDescription
								    *);
    extern void pango_font_metrics_unref(PangoFontMetrics *);
    extern PangoDirection pango_find_base_dir(const gchar *, gint);
    extern void pango_layout_iter_get_run_extents(PangoLayoutIter *,
						  PangoRectangle *,
						  PangoRectangle *);
    extern void pango_layout_index_to_pos(PangoLayout *, int,
					  PangoRectangle *);
    extern const char *pango_font_family_get_name(PangoFontFamily *);
    extern void pango_layout_line_get_x_ranges(PangoLayoutLine *, int, int,
					       int **, int *);
    extern void pango_item_free(PangoItem *);
    extern GType pango_renderer_get_type(void);
    extern void pango_layout_set_indent(PangoLayout *, int);
    extern void pango_layout_set_text(PangoLayout *, const char *, int);
    extern gint pango_font_description_get_size(const PangoFontDescription
						*);
    extern GType pango_fontset_get_type(void);
    extern GType pango_weight_get_type(void);
    extern guint pango_font_description_hash(const PangoFontDescription *);
    extern void pango_renderer_activate(PangoRenderer *);
    extern PangoContext *pango_layout_get_context(PangoLayout *);
    extern PangoCoverage *pango_coverage_new(void);
    extern PangoAttribute *pango_attr_strikethrough_new(gboolean);
    extern void pango_coverage_set(PangoCoverage *, int,
				   PangoCoverageLevel);
    extern PangoFont *pango_font_map_load_font(PangoFontMap *,
					       PangoContext *,
					       const PangoFontDescription
					       *);
    extern int pango_layout_iter_get_baseline(PangoLayoutIter *);
    extern gboolean pango_font_description_better_match(const
							PangoFontDescription
							*,
							const
							PangoFontDescription
							*,
							const
							PangoFontDescription
							*);
    extern void pango_layout_iter_get_line_extents(PangoLayoutIter *,
						   PangoRectangle *,
						   PangoRectangle *);
    extern PangoItem *pango_item_new(void);
    extern GType pango_font_mask_get_type(void);
    extern void pango_tab_array_get_tab(PangoTabArray *, gint,
					PangoTabAlign *, gint *);
    extern gboolean pango_attr_iterator_next(PangoAttrIterator *);
    extern gboolean pango_layout_get_justify(PangoLayout *);
    extern PangoCoverage *pango_coverage_ref(PangoCoverage *);
    extern PangoAttribute *pango_attr_foreground_new(guint16, guint16,
						     guint16);
    extern PangoAttrList *pango_attr_list_filter(PangoAttrList *,
						 PangoAttrFilterFunc,
						 gpointer);
    extern PangoFontDescription
	*pango_context_get_font_description(PangoContext *);
    extern PangoTabArray *pango_tab_array_new_with_positions(gint,
							     gboolean,
							     PangoTabAlign,
							     gint, ...);
    extern GSList *pango_glyph_item_apply_attrs(PangoGlyphItem *,
						const char *,
						PangoAttrList *);
    extern PangoAttribute *pango_attr_shape_new(const PangoRectangle *,
						const PangoRectangle *);
    extern GType pango_variant_get_type(void);
    extern void pango_layout_set_spacing(PangoLayout *, int);
    extern void pango_attr_list_ref(PangoAttrList *);
    extern void
	pango_font_description_set_family_static(PangoFontDescription *,
						 const char *);
    extern gboolean pango_layout_iter_next_char(PangoLayoutIter *);
    extern void pango_glyph_string_index_to_x(PangoGlyphString *, char *,
					      int, PangoAnalysis *, int,
					      gboolean, int *);
    extern PangoAttribute *pango_attr_stretch_new(PangoStretch);
    extern GType pango_attr_type_get_type(void);
    extern GType pango_language_get_type(void);
    extern void pango_font_get_glyph_extents(PangoFont *, PangoGlyph,
					     PangoRectangle *,
					     PangoRectangle *);
    extern PangoAttribute *pango_attr_fallback_new(gboolean);
    extern void pango_font_description_merge_static(PangoFontDescription *,
						    const
						    PangoFontDescription *,
						    gboolean);
    extern PangoAttrList *pango_layout_get_attributes(PangoLayout *);
    extern PangoFontset *pango_font_map_load_fontset(PangoFontMap *,
						     PangoContext *,
						     const
						     PangoFontDescription
						     *, PangoLanguage *);
    extern void pango_layout_set_tabs(PangoLayout *, PangoTabArray *);
    extern GType pango_attr_list_get_type(void);
    extern GType pango_font_family_get_type(void);
    extern void pango_matrix_free(PangoMatrix *);
    extern PangoAttribute *pango_attr_language_new(PangoLanguage *);
    extern void pango_layout_iter_get_cluster_extents(PangoLayoutIter *,
						      PangoRectangle *,
						      PangoRectangle *);
    extern PangoAttrType pango_attr_type_register(const gchar *);
    extern void pango_context_set_matrix(PangoContext *,
					 const PangoMatrix *);
    extern void pango_layout_set_markup(PangoLayout *, const char *, int);
    extern GType pango_coverage_level_get_type(void);
    extern PangoTabArray *pango_tab_array_copy(PangoTabArray *);
    extern void pango_attr_list_change(PangoAttrList *, PangoAttribute *);
    extern PangoColor *pango_renderer_get_color(PangoRenderer *,
						PangoRenderPart);
    extern void pango_renderer_part_changed(PangoRenderer *,
					    PangoRenderPart);
    extern void pango_glyph_string_x_to_index(PangoGlyphString *, char *,
					      int, PangoAnalysis *, int,
					      int *, gboolean *);
    extern void pango_tab_array_resize(PangoTabArray *, gint);
    extern void pango_break(const gchar *, gint, PangoAnalysis *,
			    PangoLogAttr *, int);
    extern void pango_coverage_unref(PangoCoverage *);
    extern void pango_font_map_list_families(PangoFontMap *,
					     PangoFontFamily * **, int *);
    extern void pango_matrix_concat(PangoMatrix *, const PangoMatrix *);
    extern PangoAttrList *pango_attr_list_copy(PangoAttrList *);
    extern GType pango_layout_iter_get_type(void);
    extern void pango_layout_set_attributes(PangoLayout *,
					    PangoAttrList *);
    extern void pango_color_free(PangoColor *);
    extern PangoItem *pango_item_copy(PangoItem *);
    extern void pango_font_description_set_weight(PangoFontDescription *,
						  PangoWeight);
    extern PangoAttribute *pango_attr_letter_spacing_new(int);
    extern PangoLanguage *pango_language_from_string(const char *);
    extern PangoAttribute *pango_attr_strikethrough_color_new(guint16,
							      guint16,
							      guint16);
    extern void pango_attr_list_insert(PangoAttrList *, PangoAttribute *);
    extern gboolean pango_layout_line_x_to_index(PangoLayoutLine *, int,
						 int *, int *);
    extern PangoFontMap *pango_context_get_font_map(PangoContext *);
    extern GType pango_direction_get_type(void);
    extern void pango_layout_iter_get_layout_extents(PangoLayoutIter *,
						     PangoRectangle *,
						     PangoRectangle *);
    extern void pango_glyph_string_free(PangoGlyphString *);
    extern gboolean pango_tab_array_get_positions_in_pixels(PangoTabArray
							    *);
    extern PangoFontMetrics *pango_fontset_get_metrics(PangoFontset *);
    extern int pango_layout_iter_get_index(PangoLayoutIter *);
    extern int pango_layout_get_spacing(PangoLayout *);
    extern gboolean pango_layout_get_single_paragraph_mode(PangoLayout *);
    extern GSList *pango_layout_get_lines(PangoLayout *);
    extern GType pango_underline_get_type(void);
    extern void pango_layout_get_pixel_extents(PangoLayout *,
					       PangoRectangle *,
					       PangoRectangle *);
    extern void pango_matrix_scale(PangoMatrix *, double, double);
    extern void pango_attr_iterator_destroy(PangoAttrIterator *);
    extern void pango_glyph_string_extents(PangoGlyphString *, PangoFont *,
					   PangoRectangle *,
					   PangoRectangle *);
    extern PangoTabArray *pango_tab_array_new(gint, gboolean);
    extern PangoAttribute *pango_attr_weight_new(PangoWeight);
    extern int pango_layout_get_width(PangoLayout *);
    extern gboolean pango_parse_markup(const char *, int, gunichar,
				       PangoAttrList * *, char **,
				       gunichar *, GError * *);
    extern void pango_matrix_rotate(PangoMatrix *, double);
    extern void pango_font_description_set_style(PangoFontDescription *,
						 PangoStyle);
    extern void pango_layout_set_auto_dir(PangoLayout *, gboolean);
    extern GType pango_context_get_type(void);
    extern PangoAttribute *pango_attr_background_new(guint16, guint16,
						     guint16);
    extern void pango_coverage_to_bytes(PangoCoverage *, guchar * *,
					int *);
    extern void pango_font_description_set_size(PangoFontDescription *,
						gint);
    extern void pango_attr_list_unref(PangoAttrList *);
    extern int
	pango_font_metrics_get_strikethrough_thickness(PangoFontMetrics *);
    extern PangoAttribute *pango_attr_size_new_absolute(int);
    extern PangoAttribute *pango_attribute_copy(const PangoAttribute *);
    extern PangoAttribute *pango_attr_iterator_get(PangoAttrIterator *,
						   PangoAttrType);
    extern GType pango_matrix_get_type(void);
    extern PangoDirection pango_context_get_base_dir(PangoContext *);
    extern PangoAttribute *pango_attr_style_new(PangoStyle);
    extern void pango_attr_iterator_get_font(PangoAttrIterator *,
					     PangoFontDescription *,
					     PangoLanguage * *,
					     GSList * *);
    extern void pango_renderer_draw_glyph(PangoRenderer *, PangoFont *,
					  PangoGlyph, double, double);
    extern void pango_glyph_item_free(PangoGlyphItem *);
    extern gboolean pango_language_includes_script(PangoLanguage *,
						   PangoScript);
    extern gboolean pango_font_description_get_size_is_absolute(const
								PangoFontDescription
								*);
    extern GSList *pango_attr_iterator_get_attrs(PangoAttrIterator *);
    extern GType pango_ellipsize_mode_get_type(void);
    extern void pango_font_face_list_sizes(PangoFontFace *, int **, int *);
    extern void pango_layout_get_size(PangoLayout *, int *, int *);
    extern void pango_renderer_draw_glyphs(PangoRenderer *, PangoFont *,
					   PangoGlyphString *, int, int);
    extern GType pango_tab_array_get_type(void);
    extern PangoGlyphItem *pango_glyph_item_split(PangoGlyphItem *,
						  const char *, int);
    extern PangoLayoutIter *pango_layout_get_iter(PangoLayout *);
    extern PangoGlyphString *pango_glyph_string_new(void);
    extern gboolean pango_layout_iter_next_run(PangoLayoutIter *);
    extern void pango_glyph_string_extents_range(PangoGlyphString *, int,
						 int, PangoFont *,
						 PangoRectangle *,
						 PangoRectangle *);
    extern PangoWeight pango_font_description_get_weight(const
							 PangoFontDescription
							 *);
    extern GType pango_font_description_get_type(void);
    extern void pango_renderer_deactivate(PangoRenderer *);
    extern PangoGlyphString *pango_glyph_string_copy(PangoGlyphString *);
    extern void pango_script_iter_free(PangoScriptIter *);
    extern PangoCoverage *pango_coverage_from_bytes(guchar *, int);
    extern void pango_layout_iter_get_line_yrange(PangoLayoutIter *, int *,
						  int *);
    extern GType pango_stretch_get_type(void);
    extern int pango_layout_get_line_count(PangoLayout *);
    extern void pango_layout_set_ellipsize(PangoLayout *,
					   PangoEllipsizeMode);
    extern PangoCoverage *pango_font_get_coverage(PangoFont *,
						  PangoLanguage *);
    extern PangoFontDescription *pango_font_description_copy(const
							     PangoFontDescription
							     *);
    extern void pango_fontset_foreach(PangoFontset *,
				      PangoFontsetForeachFunc, gpointer);
    extern GType pango_font_get_type(void);
    extern void pango_layout_set_alignment(PangoLayout *, PangoAlignment);
    extern GType pango_layout_get_type(void);
    extern void pango_renderer_draw_layout_line(PangoRenderer *,
						PangoLayoutLine *, int,
						int);
    extern GType pango_alignment_get_type(void);
    extern void pango_renderer_draw_rectangle(PangoRenderer *,
					      PangoRenderPart, int, int,
					      int, int);
    extern void pango_context_list_families(PangoContext *,
					    PangoFontFamily * **, int *);
    extern void
	pango_font_description_set_absolute_size(PangoFontDescription *,
						 double);
    extern void pango_layout_iter_free(PangoLayoutIter *);
    extern PangoCoverageLevel pango_coverage_get(PangoCoverage *, int);
    extern void pango_renderer_draw_error_underline(PangoRenderer *, int,
						    int, int, int);
    extern PangoFontset *pango_context_load_fontset(PangoContext *,
						    const
						    PangoFontDescription *,
						    PangoLanguage *);
    extern void pango_layout_line_ref(PangoLayoutLine *);
    extern void pango_font_description_set_family(PangoFontDescription *,
						  const char *);
    extern gboolean pango_layout_iter_at_last_line(PangoLayoutIter *);
    extern GType pango_render_part_get_type(void);
    extern PangoAttrList *pango_attr_list_new(void);
    extern void pango_font_description_set_stretch(PangoFontDescription *,
						   PangoStretch);
    extern void pango_font_description_merge(PangoFontDescription *,
					     const PangoFontDescription *,
					     gboolean);
    extern int pango_font_metrics_get_underline_thickness(PangoFontMetrics
							  *);
    extern const char *pango_layout_get_text(PangoLayout *);
    extern int pango_font_metrics_get_ascent(PangoFontMetrics *);
    extern PangoFont *pango_fontset_get_font(PangoFontset *, guint);
    extern void pango_renderer_draw_layout(PangoRenderer *, PangoLayout *,
					   int, int);
    extern int pango_font_metrics_get_underline_position(PangoFontMetrics
							 *);
    extern GType pango_color_get_type(void);
    extern PangoFontMetrics *pango_context_get_metrics(PangoContext *,
						       const
						       PangoFontDescription
						       *, PangoLanguage *);
    extern gboolean pango_layout_xy_to_index(PangoLayout *, int, int,
					     int *, gint *);
    extern void pango_renderer_set_matrix(PangoRenderer *,
					  const PangoMatrix *);
    extern void pango_font_description_set_variant(PangoFontDescription *,
						   PangoVariant);
    extern GList *pango_itemize(PangoContext *, const char *, int, int,
				PangoAttrList *, PangoAttrIterator *);
    extern void pango_layout_move_cursor_visually(PangoLayout *, gboolean,
						  int, int, int, int *,
						  int *);
    extern int pango_layout_get_indent(PangoLayout *);
    extern PangoAttrIterator *pango_attr_list_get_iterator(PangoAttrList
							   *);
    extern void pango_layout_get_pixel_size(PangoLayout *, int *, int *);
    extern void pango_font_description_unset_fields(PangoFontDescription *,
						    PangoFontMask);
    extern GType pango_tab_align_get_type(void);
    extern PangoItem *pango_item_split(PangoItem *, int, int);
    extern PangoFontMetrics *pango_font_metrics_ref(PangoFontMetrics *);
    extern void pango_context_set_base_dir(PangoContext *, PangoDirection);
    extern PangoAttribute *pango_attr_underline_color_new(guint16, guint16,
							  guint16);
    extern gboolean pango_layout_iter_next_cluster(PangoLayoutIter *);
    extern PangoAttribute *pango_attr_variant_new(PangoVariant);
    extern GType pango_font_face_get_type(void);
    extern void pango_font_family_list_faces(PangoFontFamily *,
					     PangoFontFace * **, int *);
    extern PangoColor *pango_color_copy(const PangoColor *);
    extern GType pango_wrap_mode_get_type(void);
    extern void pango_tab_array_set_tab(PangoTabArray *, gint,
					PangoTabAlign, gint);
    extern PangoAttribute *pango_attr_shape_new_with_data(const
							  PangoRectangle *,
							  const
							  PangoRectangle *,
							  gpointer,
							  PangoAttrDataCopyFunc,
							  GDestroyNotify);
    extern PangoVariant pango_font_description_get_variant(const
							   PangoFontDescription
							   *);
    extern void pango_font_description_free(PangoFontDescription *);
    extern GType pango_font_metrics_get_type(void);
    extern void pango_layout_get_cursor_pos(PangoLayout *, int,
					    PangoRectangle *,
					    PangoRectangle *);
    extern GList *pango_itemize_with_base_dir(PangoContext *,
					      PangoDirection, const char *,
					      int, int, PangoAttrList *,
					      PangoAttrIterator *);
    extern PangoLanguage *pango_context_get_language(PangoContext *);
    extern void pango_renderer_set_color(PangoRenderer *, PangoRenderPart,
					 const PangoColor *);
    extern GType pango_font_map_get_type(void);
    extern const PangoFontDescription
	*pango_layout_get_font_description(PangoLayout *);
    extern void pango_layout_set_font_description(PangoLayout *,
						  const
						  PangoFontDescription *);
    extern PangoFontMetrics *pango_font_get_metrics(PangoFont *,
						    PangoLanguage *);
    extern PangoScriptIter *pango_script_iter_new(const char *, int);
#ifdef __cplusplus
}
#endif
#endif
