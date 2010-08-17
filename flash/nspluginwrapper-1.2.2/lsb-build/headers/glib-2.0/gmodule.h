#ifndef _GLIB_2_0_GMODULE_H_
#define _GLIB_2_0_GMODULE_H_

#include <glib-2.0/glib.h>

#ifdef __cplusplus
extern "C" {
#endif


#define G_MODULE_EXPORT
#define G_MODULE_IMPORT	extern


    typedef struct _GModule GModule;

    typedef enum {
	G_MODULE_BIND_LAZY = 1,
	G_MODULE_BIND_LOCAL = 2,
	G_MODULE_BIND_MASK = 3
    } GModuleFlags;

    typedef void (*GModuleUnload) (GModule *);

    typedef const gchar *(*GModuleCheckInit) (GModule *);





    extern void g_module_make_resident(GModule *);
    extern gchar *g_module_build_path(const gchar *, const gchar *);
    extern gboolean g_module_close(GModule *);
    extern GModule *g_module_open(const gchar *, GModuleFlags);
    extern gboolean g_module_symbol(GModule *, const gchar *, gpointer *);
    extern const gchar *g_module_error(void);
    extern const gchar *g_module_name(GModule *);
    extern gboolean g_module_supported(void);
#ifdef __cplusplus
}
#endif
#endif
