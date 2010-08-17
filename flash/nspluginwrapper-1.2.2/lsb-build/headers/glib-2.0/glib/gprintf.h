#ifndef _GLIB_2_0_GLIB_GPRINTF_H_
#define _GLIB_2_0_GLIB_GPRINTF_H_

#include <stdio.h>
#include <stdarg.h>
#include <glib-2.0/glib.h>

#ifdef __cplusplus
extern "C" {
#endif





    extern gint g_sprintf(gchar *, const gchar *, ...);
    extern gint g_fprintf(FILE *, const gchar *, ...);
    extern gint g_vasprintf(gchar * *, const gchar *, va_list);
    extern gint g_vprintf(const gchar *, va_list);
    extern gint g_printf(const gchar *, ...);
    extern gint g_vfprintf(FILE *, const gchar *, va_list);
    extern gint g_vsnprintf(gchar *, gulong, const gchar *, va_list);
    extern gint g_vsprintf(gchar *, const gchar *, va_list);
    extern gint g_snprintf(gchar *, gulong, const gchar *, ...);
#ifdef __cplusplus
}
#endif
#endif
