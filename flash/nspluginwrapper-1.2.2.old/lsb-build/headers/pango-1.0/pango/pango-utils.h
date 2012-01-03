#ifndef _PANGO_1_0_PANGO_PANGO_UTILS_H_
#define _PANGO_1_0_PANGO_PANGO_UTILS_H_

#include <stdio.h>
#include <glib-2.0/glib.h>
#include <pango-1.0/pango/pango.h>

#ifdef __cplusplus
extern "C" {
#endif





    extern char *pango_trim_string(const char *);
    extern gboolean pango_scan_word(const char **, GString *);
    extern gboolean pango_skip_space(const char **);
    extern gboolean pango_parse_stretch(const char *, PangoStretch *,
					gboolean);
    extern gboolean pango_scan_int(const char **, int *);
    extern gboolean pango_parse_weight(const char *, PangoWeight *,
				       gboolean);
    extern gint pango_read_line(FILE *, GString *);
    extern gboolean pango_log2vis_get_embedding_levels(gunichar *, gint,
						       PangoDirection *,
						       guint8 *);
    extern const char *pango_language_get_sample_string(PangoLanguage *);
    extern gboolean pango_parse_style(const char *, PangoStyle *,
				      gboolean);
    extern gboolean pango_scan_string(const char **, GString *);
    extern gboolean pango_parse_variant(const char *, PangoVariant *,
					gboolean);
    extern char **pango_split_file_list(const char *);
#ifdef __cplusplus
}
#endif
#endif
