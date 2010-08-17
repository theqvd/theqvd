#ifndef _ATK_1_0_ATK_ATK_ENUM_TYPES_H_
#define _ATK_1_0_ATK_ATK_ENUM_TYPES_H_

#include <glib-2.0/glib.h>
#include <glib-2.0/glib-object.h>

#ifdef __cplusplus
extern "C" {
#endif


#define ATK_TYPE_HYPERLINK_STATE_FLAGS	 \
	(atk_hyperlink_state_flags_get_type())
#define ATK_TYPE_COORD_TYPE	(atk_coord_type_get_type())
#define ATK_TYPE_KEY_EVENT_TYPE	(atk_key_event_type_get_type())
#define ATK_TYPE_LAYER	(atk_layer_get_type())
#define ATK_TYPE_RELATION_TYPE	(atk_relation_type_get_type())
#define ATK_TYPE_ROLE	(atk_role_get_type())
#define ATK_TYPE_STATE_TYPE	(atk_state_type_get_type())
#define ATK_TYPE_TEXT_ATTRIBUTE	(atk_text_attribute_get_type())
#define ATK_TYPE_TEXT_BOUNDARY	(atk_text_boundary_get_type())
#define ATK_TYPE_TEXT_CLIP_TYPE	(atk_text_clip_type_get_type())



    extern GType atk_state_type_get_type(void);
    extern GType atk_role_get_type(void);
    extern GType atk_text_boundary_get_type(void);
    extern GType atk_relation_type_get_type(void);
    extern GType atk_layer_get_type(void);
    extern GType atk_hyperlink_state_flags_get_type(void);
    extern GType atk_text_clip_type_get_type(void);
    extern GType atk_key_event_type_get_type(void);
    extern GType atk_coord_type_get_type(void);
    extern GType atk_text_attribute_get_type(void);
#ifdef __cplusplus
}
#endif
#endif
