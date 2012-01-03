#ifndef _GLIB_2_0_GLIB_OBJECT_H_
#define _GLIB_2_0_GLIB_OBJECT_H_

#include <stdarg.h>
#include <glib-2.0/glib.h>

#ifdef __cplusplus
extern "C" {
#endif


#define G_CCLOSURE_SWAP_DATA(cclosure)	 \
	(((GClosure*) (closure))->derivative_flag)
#define G_CLOSURE_NEEDS_MARSHAL(closure)	 \
	(((GClosure*) (closure))->marshal == NULL)
#define G_TYPE_FROM_INTERFACE(g_iface)	 \
	(((GTypeInterface*) (g_iface))->g_type)
#define G_CLOSURE_N_NOTIFIERS(cl)	 \
	((cl)->meta_marshal + ((cl)->n_guards << 1L) + (cl)->n_fnotifiers + \
	(cl)->n_inotifiers)
#define _G_TYPE_CCC(cp,gt,ct)	 \
	((ct*) g_type_check_class_cast ((GTypeClass*) cp, gt))
#define _G_TYPE_CIC(ip,gt,ct)	 \
	((ct*) g_type_check_instance_cast ((GTypeInstance*) ip, gt))
#define _G_TYPE_IGI(ip,gt,ct)	 \
	((ct*) g_type_interface_peek (((GTypeInstance*) ip)->g_class, gt))
#define G_TYPE_INSTANCE_GET_PRIVATE(instance,g_type,c_type)	 \
	((c_type*) g_type_instance_get_private ((GTypeInstance*) (instance), \
	(g_type)))
#define G_TYPE_MAKE_FUNDAMENTAL(x)	 \
	((GType) ((x) << G_TYPE_FUNDAMENTAL_SHIFT))
#define _G_TYPE_CCT(cp,gt)	 \
	(G_GNUC_EXTENSION ({ GTypeClass *__class = (GTypeClass*) cp; GType \
	__t = gt; gboolean __r; if (__class && __class->g_type == __t) __r = \
	TRUE; else __r = g_type_check_class_is_a (__class, __t); __r; }))
#define _G_TYPE_CIT(ip,gt)	 \
	(G_GNUC_EXTENSION ({ GTypeInstance *__inst = (GTypeInstance*) ip; \
	GType __t = gt; gboolean __r; if (__inst && __inst->g_class && \
	__inst->g_class->g_type == __t) __r = TRUE; else __r = \
	g_type_check_instance_is_a (__inst, __t); __r; }))
#define _G_TYPE_CVH(vl,gt)	 \
	(G_GNUC_EXTENSION ({ GValue *__val = (GValue*) vl; GType __t = gt; \
	gboolean __r; if (__val && __val->g_type == __t) __r = TRUE; else __r \
	= g_type_check_value_holds (__val, __t); __r; }))
#define G_ENUM_CLASS(class)	 \
	(G_TYPE_CHECK_CLASS_CAST ((class), G_TYPE_ENUM, GEnumClass))
#define G_FLAGS_CLASS(class)	 \
	(G_TYPE_CHECK_CLASS_CAST ((class), G_TYPE_FLAGS, GFlagsClass))
#define G_OBJECT_CLASS(class)	 \
	(G_TYPE_CHECK_CLASS_CAST ((class), G_TYPE_OBJECT, GObjectClass))
#define G_TYPE_MODULE_CLASS(class)	 \
	(G_TYPE_CHECK_CLASS_CAST ((class), G_TYPE_TYPE_MODULE, \
	GTypeModuleClass))
#define G_PARAM_SPEC_CLASS(pclass)	 \
	(G_TYPE_CHECK_CLASS_CAST ((pclass), G_TYPE_PARAM, GParamSpecClass))
#define G_TYPE_PLUGIN_CLASS(vtable)	 \
	(G_TYPE_CHECK_CLASS_CAST ((vtable), G_TYPE_TYPE_PLUGIN, \
	GTypePluginClass))
#define G_IS_ENUM_CLASS(class)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((class), G_TYPE_ENUM))
#define G_IS_FLAGS_CLASS(class)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((class), G_TYPE_FLAGS))
#define G_IS_OBJECT_CLASS(class)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((class), G_TYPE_OBJECT))
#define G_IS_TYPE_MODULE_CLASS(class)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((class), G_TYPE_TYPE_MODULE))
#define G_IS_PARAM_SPEC_CLASS(pclass)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((pclass), G_TYPE_PARAM))
#define G_IS_TYPE_PLUGIN_CLASS(vtable)	 \
	(G_TYPE_CHECK_CLASS_TYPE ((vtable), G_TYPE_TYPE_PLUGIN))
#define G_TYPE_PLUGIN(inst)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((inst), G_TYPE_TYPE_PLUGIN, \
	GTypePlugin))
#define G_TYPE_MODULE(module)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((module), G_TYPE_TYPE_MODULE, \
	GTypeModule))
#define G_OBJECT(object)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((object), G_TYPE_OBJECT, GObject))
#define G_PARAM_SPEC(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM, GParamSpec))
#define G_PARAM_SPEC_BOOLEAN(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_BOOLEAN, \
	GParamSpecBoolean))
#define G_PARAM_SPEC_BOXED(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_BOXED, \
	GParamSpecBoxed))
#define G_PARAM_SPEC_CHAR(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_CHAR, \
	GParamSpecChar))
#define G_PARAM_SPEC_DOUBLE(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_DOUBLE, \
	GParamSpecDouble))
#define G_PARAM_SPEC_ENUM(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_ENUM, \
	GParamSpecEnum))
#define G_PARAM_SPEC_FLAGS(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_FLAGS, \
	GParamSpecFlags))
#define G_PARAM_SPEC_FLOAT(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_FLOAT, \
	GParamSpecFloat))
#define G_PARAM_SPEC_INT(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_INT, \
	GParamSpecInt))
#define G_PARAM_SPEC_INT64(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_INT64, \
	GParamSpecInt64))
#define G_PARAM_SPEC_LONG(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_LONG, \
	GParamSpecLong))
#define G_PARAM_SPEC_OBJECT(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_OBJECT, \
	GParamSpecObject))
#define G_PARAM_SPEC_OVERRIDE(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_OVERRIDE, \
	GParamSpecOverride))
#define G_PARAM_SPEC_PARAM(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_PARAM, \
	GParamSpecParam))
#define G_PARAM_SPEC_POINTER(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_POINTER, \
	GParamSpecPointer))
#define G_PARAM_SPEC_STRING(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_STRING, \
	GParamSpecString))
#define G_PARAM_SPEC_UCHAR(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_UCHAR, \
	GParamSpecUChar))
#define G_PARAM_SPEC_UINT(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_UINT, \
	GParamSpecUInt))
#define G_PARAM_SPEC_UINT64(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_UINT64, \
	GParamSpecUInt64))
#define G_PARAM_SPEC_ULONG(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_ULONG, \
	GParamSpecULong))
#define G_PARAM_SPEC_UNICHAR(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_UNICHAR, \
	GParamSpecUnichar))
#define G_PARAM_SPEC_VALUE_ARRAY(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_CAST ((pspec), G_TYPE_PARAM_VALUE_ARRAY, \
	GParamSpecValueArray))
#define G_IS_TYPE_PLUGIN(inst)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((inst), G_TYPE_TYPE_PLUGIN))
#define G_IS_TYPE_MODULE(module)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((module), G_TYPE_TYPE_MODULE))
#define G_IS_OBJECT(object)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((object), G_TYPE_OBJECT))
#define G_IS_PARAM_SPEC(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM))
#define G_IS_PARAM_SPEC_BOOLEAN(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_BOOLEAN))
#define G_IS_PARAM_SPEC_BOXED(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_BOXED))
#define G_IS_PARAM_SPEC_CHAR(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_CHAR))
#define G_IS_PARAM_SPEC_DOUBLE(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_DOUBLE))
#define G_IS_PARAM_SPEC_ENUM(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_ENUM))
#define G_IS_PARAM_SPEC_FLAGS(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_FLAGS))
#define G_IS_PARAM_SPEC_FLOAT(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_FLOAT))
#define G_IS_PARAM_SPEC_INT(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_INT))
#define G_IS_PARAM_SPEC_INT64(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_INT64))
#define G_IS_PARAM_SPEC_LONG(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_LONG))
#define G_IS_PARAM_SPEC_OBJECT(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_OBJECT))
#define G_IS_PARAM_SPEC_OVERRIDE(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_OVERRIDE))
#define G_IS_PARAM_SPEC_PARAM(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_PARAM))
#define G_IS_PARAM_SPEC_POINTER(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_POINTER))
#define G_IS_PARAM_SPEC_STRING(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_STRING))
#define G_IS_PARAM_SPEC_UCHAR(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_UCHAR))
#define G_IS_PARAM_SPEC_UINT(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_UINT))
#define G_IS_PARAM_SPEC_UINT64(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_UINT64))
#define G_IS_PARAM_SPEC_ULONG(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_ULONG))
#define G_IS_PARAM_SPEC_UNICHAR(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_UNICHAR))
#define G_IS_PARAM_SPEC_VALUE_ARRAY(pspec)	 \
	(G_TYPE_CHECK_INSTANCE_TYPE ((pspec), G_TYPE_PARAM_VALUE_ARRAY))
#define G_VALUE_HOLDS(value,type)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), (type)))
#define G_VALUE_HOLDS_BOOLEAN(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_BOOLEAN))
#define G_VALUE_HOLDS_BOXED(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_BOXED))
#define G_VALUE_HOLDS_CHAR(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_CHAR))
#define G_VALUE_HOLDS_DOUBLE(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_DOUBLE))
#define G_VALUE_HOLDS_ENUM(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_ENUM))
#define G_VALUE_HOLDS_FLAGS(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_FLAGS))
#define G_VALUE_HOLDS_FLOAT(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_FLOAT))
#define G_VALUE_HOLDS_INT(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_INT))
#define G_VALUE_HOLDS_INT64(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_INT64))
#define G_VALUE_HOLDS_LONG(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_LONG))
#define G_VALUE_HOLDS_OBJECT(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_OBJECT))
#define G_VALUE_HOLDS_PARAM(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_PARAM))
#define G_VALUE_HOLDS_POINTER(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_POINTER))
#define G_VALUE_HOLDS_STRING(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_STRING))
#define G_VALUE_HOLDS_UCHAR(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_UCHAR))
#define G_VALUE_HOLDS_UINT(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_UINT))
#define G_VALUE_HOLDS_UINT64(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_UINT64))
#define G_VALUE_HOLDS_ULONG(value)	 \
	(G_TYPE_CHECK_VALUE_TYPE ((value), G_TYPE_ULONG))
#define G_TYPE_FROM_INSTANCE(instance)	 \
	(G_TYPE_FROM_CLASS (((GTypeInstance*) (instance))->g_class))
#define G_TYPE_IS_INTERFACE(type)	 \
	(G_TYPE_FUNDAMENTAL (type) == G_TYPE_INTERFACE)
#define G_TYPE_IS_OBJECT(type)	 \
	(G_TYPE_FUNDAMENTAL (type) == G_TYPE_OBJECT)
#define G_TYPE_MODULE_GET_CLASS(module)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((module), G_TYPE_TYPE_MODULE, \
	GTypeModuleClass))
#define G_OBJECT_GET_CLASS(object)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((object), G_TYPE_OBJECT, GObjectClass))
#define G_PARAM_SPEC_GET_CLASS(pspec)	 \
	(G_TYPE_INSTANCE_GET_CLASS ((pspec), G_TYPE_PARAM, GParamSpecClass))
#define G_TYPE_PLUGIN_GET_CLASS(inst)	 \
	(G_TYPE_INSTANCE_GET_INTERFACE ((inst), G_TYPE_TYPE_PLUGIN, \
	GTypePluginClass))
#define G_ENUM_CLASS_TYPE_NAME(class)	 \
	(g_type_name (G_ENUM_CLASS_TYPE (class)))
#define G_FLAGS_CLASS_TYPE_NAME(class)	 \
	(g_type_name (G_FLAGS_TYPE (class)))
#define G_OBJECT_CLASS_NAME(class)	 \
	(g_type_name (G_OBJECT_CLASS_TYPE (class)))
#define G_PARAM_SPEC_TYPE_NAME(pspec)	 \
	(g_type_name (G_PARAM_SPEC_TYPE (pspec)))
#define G_TYPE_IS_ABSTRACT(type)	 \
	(g_type_test_flags ((type), G_TYPE_FLAG_ABSTRACT))
#define G_TYPE_IS_CLASSED(type)	 \
	(g_type_test_flags ((type), G_TYPE_FLAG_CLASSED))
#define G_TYPE_IS_DEEP_DERIVABLE(type)	 \
	(g_type_test_flags ((type), G_TYPE_FLAG_DEEP_DERIVABLE))
#define G_TYPE_IS_DERIVABLE(type)	 \
	(g_type_test_flags ((type), G_TYPE_FLAG_DERIVABLE))
#define G_TYPE_IS_INSTANTIATABLE(type)	 \
	(g_type_test_flags ((type), G_TYPE_FLAG_INSTANTIATABLE))
#define G_TYPE_IS_VALUE_ABSTRACT(type)	 \
	(g_type_test_flags ((type), G_TYPE_FLAG_VALUE_ABSTRACT))
#define G_TYPE_HAS_VALUE_TABLE(type)	 \
	(g_type_value_table_peek (type) != NULL)
#define G_TYPE_CHECK_CLASS_CAST(g_class,g_type,c_type)	 \
	(_G_TYPE_CCC ((g_class), (g_type), c_type))
#define G_TYPE_CHECK_CLASS_TYPE(g_class,g_type)	 \
	(_G_TYPE_CCT ((g_class), (g_type)))
#define G_TYPE_CHECK_INSTANCE(instance)	 \
	(_G_TYPE_CHI ((GTypeInstance*) (instance)))
#define G_TYPE_CHECK_INSTANCE_CAST(instance,g_type,c_type)	 \
	(_G_TYPE_CIC ((instance), (g_type), c_type))
#define G_TYPE_CHECK_INSTANCE_TYPE(instance,g_type)	 \
	(_G_TYPE_CIT ((instance), (g_type)))
#define G_TYPE_CHECK_VALUE_TYPE(value,g_type)	 \
	(_G_TYPE_CVH ((value), (g_type)))
#define G_TYPE_INSTANCE_GET_CLASS(instance,g_type,c_type)	 \
	(_G_TYPE_IGC ((instance), (g_type), c_type))
#define G_TYPE_INSTANCE_GET_INTERFACE(instance,g_type,c_type)	 \
	(_G_TYPE_IGI ((instance), (g_type), c_type))
#define G_DEFINE_TYPE_WITH_CODE(TN,t_n,T_P,_C_)	 \
	G_DEFINE_TYPE_EXTENDED (TN, t_n, T_P, 0, _C_)
#define G_DEFINE_TYPE(TN,t_n,T_P)	 \
	G_DEFINE_TYPE_EXTENDED (TN, t_n, T_P, 0, {})
#define G_DEFINE_ABSTRACT_TYPE_WITH_CODE(TN,t_n,T_P,_C_)	 \
	G_DEFINE_TYPE_EXTENDED (TN, t_n, T_P, G_TYPE_FLAG_ABSTRACT, _C_)
#define G_DEFINE_ABSTRACT_TYPE(TN,t_n,T_P)	 \
	G_DEFINE_TYPE_EXTENDED (TN, t_n, T_P, G_TYPE_FLAG_ABSTRACT, {})
#define G_OBJECT_WARN_INVALID_PROPERTY_ID(object,property_id,pspec)	 \
	G_OBJECT_WARN_INVALID_PSPEC ((object), "property", (property_id), \
	(pspec))
#define g_signal_connect(instance,detailed_signal,c_handler,data)	 \
	g_signal_connect_data ((instance), (detailed_signal), (c_handler), \
	(data), NULL, (GConnectFlags) 0)
#define g_signal_connect_after(instance,detailed_signal,c_handler,data)	 \
	g_signal_connect_data ((instance), (detailed_signal), (c_handler), \
	(data), NULL, G_CONNECT_AFTER)
#define g_signal_connect_swapped(instance,detailed_signal,c_handler,data)	 \
	g_signal_connect_data ((instance), (detailed_signal), (c_handler), \
	(data), NULL, G_CONNECT_SWAPPED)
#define g_signal_handlers_block_by_func(instance,func,data)	 \
	g_signal_handlers_block_matched ((instance), (GSignalMatchType) \
	(G_SIGNAL_MATCH_FUNC | G_SIGNAL_MATCH_DATA), 0, 0, NULL, (func), \
	(data))
#define g_signal_handlers_disconnect_by_func(instance,func,data)	 \
	g_signal_handlers_disconnect_matched ((instance), (GSignalMatchType) \
	(G_SIGNAL_MATCH_FUNC | G_SIGNAL_MATCH_DATA), 0, 0, NULL, (func), \
	(data))
#define g_signal_handlers_unblock_by_func(instance,func,data)	 \
	g_signal_handlers_unblock_matched ((instance), (GSignalMatchType) \
	(G_SIGNAL_MATCH_FUNC | G_SIGNAL_MATCH_DATA), 0, 0, NULL, (func), \
	(data))
#define G_OBJECT_WARN_INVALID_PSPEC(object,pname,property_id,pspec)	 \
	G_STMT_START { GObject *_object = (GObject*) (object); GParamSpec \
	*_pspec = (GParamSpec*) (pspec); guint _property_id = (property_id); \
	g_warning ("%s: invalid %s id %u for \"%s\" of type `%s' in `%s'", \
	G_STRLOC, (pname), _property_id, _pspec->name, g_type_name \
	(G_PARAM_SPEC_TYPE (_pspec)), G_OBJECT_TYPE_NAME (_object)); } \
	G_STMT_END
#define G_DEFINE_TYPE_EXTENDED(TypeName,type_name,TYPE_PARENT,flags,CODE)	 \
	static void type_name ##_init (TypeName *self); static void type_name \
	##_class_init (TypeName ##Class *klass); static gpointer type_name \
	##_parent_class = NULL; static void type_name ##_class_intern_init \
	(gpointer klass) { type_name ##_parent_class = \
	g_type_class_peek_parent (klass); type_name ##_class_init ((TypeName \
	##Class*) klass); } GType type_name ##_get_type (void) { static GType \
	g_define_type_id = 0; if (G_UNLIKELY (g_define_type_id == 0)) { static \
	const GTypeInfo g_define_type_info = { sizeof (TypeName ##Class), \
	(GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) \
	type_name ##_class_intern_init, (GClassFinalizeFunc) NULL, NULL, \
	sizeof (TypeName), 0, (GInstanceInitFunc) type_name ##_init, NULL }; \
	g_define_type_id = g_type_register_static (TYPE_PARENT, #TypeName, \
	&g_define_type_info, (GTypeFlags) flags); { CODE ; } } return \
	g_define_type_id; }
#define G_IMPLEMENT_INTERFACE(TYPE_IFACE,iface_init)	 \
	{ static const GInterfaceInfo g_implement_interface_info = { \
	(GInterfaceInitFunc) iface_init }; g_type_add_interface_static \
	(g_define_type_id, TYPE_IFACE, &g_implement_interface_info); }
#define G_TYPE_FROM_CLASS(g_class)	(((GTypeClass*) (g_class))->g_type)
#define G_VALUE_TYPE(value)	(((GValue*) (value))->g_type)
#define _G_TYPE_IGC(ip,gt,ct)	((ct*) (((GTypeInstance*) ip)->g_class))
#define G_CALLBACK(f)	((GCallback) (f))
#define G_TYPE_FLAG_RESERVED_ID_BIT	((GType) (1 << 0))
#define G_TYPE_IS_FUNDAMENTAL(type)	((type) <= G_TYPE_FUNDAMENTAL_MAX)
#define G_TYPE_IS_DERIVED(type)	((type) > G_TYPE_FUNDAMENTAL_MAX)
#define G_PARAM_MASK	(0x000000ff)
#define G_VALUE_NOCOPY_CONTENTS	(1 << 27)
#define G_TYPE_FUNDAMENTAL_SHIFT	(2)
#define G_TYPE_RESERVED_GLIB_FIRST	(21)
#define G_TYPE_FUNDAMENTAL_MAX	(255 << G_TYPE_FUNDAMENTAL_SHIFT)
#define G_TYPE_RESERVED_GLIB_LAST	(31)
#define G_TYPE_RESERVED_BSE_FIRST	(32)
#define G_TYPE_RESERVED_BSE_LAST	(48)
#define G_TYPE_RESERVED_USER_FIRST	(49)
#define G_PARAM_USER_SHIFT	(8)
#define G_TYPE_CLOSURE	(g_closure_get_type ())
#define G_TYPE_GSTRING	(g_gstring_get_type ())
#define G_TYPE_IO_CHANNEL	(g_io_channel_get_type ())
#define G_TYPE_IO_CONDITION	(g_io_condition_get_type ())
#define G_PARAM_READWRITE	(G_PARAM_READABLE | G_PARAM_WRITABLE)
#define G_PARAM_SPEC_VALUE_TYPE(pspec)	(G_PARAM_SPEC (pspec)->value_type)
#define G_TYPE_PARAM_CHAR	(g_param_spec_types[0])
#define G_TYPE_PARAM_ENUM	(g_param_spec_types[10])
#define G_TYPE_PARAM_FLAGS	(g_param_spec_types[11])
#define G_TYPE_PARAM_FLOAT	(g_param_spec_types[12])
#define G_TYPE_PARAM_DOUBLE	(g_param_spec_types[13])
#define G_TYPE_PARAM_STRING	(g_param_spec_types[14])
#define G_TYPE_PARAM_PARAM	(g_param_spec_types[15])
#define G_TYPE_PARAM_BOXED	(g_param_spec_types[16])
#define G_TYPE_PARAM_POINTER	(g_param_spec_types[17])
#define G_TYPE_PARAM_VALUE_ARRAY	(g_param_spec_types[18])
#define G_TYPE_PARAM_OBJECT	(g_param_spec_types[19])
#define G_TYPE_PARAM_UCHAR	(g_param_spec_types[1])
#define G_TYPE_PARAM_OVERRIDE	(g_param_spec_types[20])
#define G_TYPE_PARAM_BOOLEAN	(g_param_spec_types[2])
#define G_TYPE_PARAM_INT	(g_param_spec_types[3])
#define G_TYPE_PARAM_UINT	(g_param_spec_types[4])
#define G_TYPE_PARAM_LONG	(g_param_spec_types[5])
#define G_TYPE_PARAM_ULONG	(g_param_spec_types[6])
#define G_TYPE_PARAM_INT64	(g_param_spec_types[7])
#define G_TYPE_PARAM_UINT64	(g_param_spec_types[8])
#define G_TYPE_PARAM_UNICHAR	(g_param_spec_types[9])
#define G_TYPE_STRV	(g_strv_get_type ())
#define _G_TYPE_CHI(ip)	(g_type_check_instance ((GTypeInstance*) ip))
#define G_TYPE_IS_VALUE(type)	(g_type_check_is_value_type (type))
#define G_TYPE_IS_VALUE_TYPE(type)	(g_type_check_is_value_type (type))
#define _G_TYPE_CHV(vl)	(g_type_check_value ((GValue*) vl))
#define G_IS_VALUE(value)	(G_TYPE_CHECK_VALUE (value))
#define G_SIGNAL_TYPE_STATIC_SCOPE	(G_TYPE_FLAG_RESERVED_ID_BIT)
#define G_ENUM_CLASS_TYPE(class)	(G_TYPE_FROM_CLASS (class))
#define G_FLAGS_CLASS_TYPE(class)	(G_TYPE_FROM_CLASS (class))
#define G_OBJECT_CLASS_TYPE(class)	(G_TYPE_FROM_CLASS (class))
#define G_OBJECT_TYPE(object)	(G_TYPE_FROM_INSTANCE (object))
#define G_PARAM_SPEC_TYPE(pspec)	(G_TYPE_FROM_INSTANCE (pspec))
#define G_TYPE_IS_BOXED(type)	(G_TYPE_FUNDAMENTAL (type) == G_TYPE_BOXED)
#define G_TYPE_IS_ENUM(type)	(G_TYPE_FUNDAMENTAL (type) == G_TYPE_ENUM)
#define G_TYPE_IS_FLAGS(type)	(G_TYPE_FUNDAMENTAL (type) == G_TYPE_FLAGS)
#define G_TYPE_IS_PARAM(type)	(G_TYPE_FUNDAMENTAL (type) == G_TYPE_PARAM)
#define G_TYPE_FUNDAMENTAL(type)	(g_type_fundamental (type))
#define G_TYPE_TYPE_MODULE	(g_type_module_get_type ())
#define G_OBJECT_TYPE_NAME(object)	(g_type_name (G_OBJECT_TYPE (object)))
#define G_VALUE_TYPE_NAME(value)	(g_type_name (G_VALUE_TYPE (value)))
#define G_TYPE_TYPE_PLUGIN	(g_type_plugin_get_type ())
#define G_TYPE_VALUE_ARRAY	(g_value_array_get_type ())
#define G_TYPE_VALUE	(g_value_get_type ())
#define G_TYPE_CHECK_VALUE(value)	(_G_TYPE_CHV ((value)))
#define G_SIGNAL_MATCH_MASK	0x3f
#define G_SIGNAL_FLAGS_MASK	0x7f
#define GOBJECT_VAR	extern
#define g_cclosure_marshal_BOOL__FLAGS	g_cclosure_marshal_BOOLEAN__FLAGS
#define G_TYPE_INVALID	G_TYPE_MAKE_FUNDAMENTAL (0)
#define G_TYPE_NONE	G_TYPE_MAKE_FUNDAMENTAL (1)
#define G_TYPE_INT64	G_TYPE_MAKE_FUNDAMENTAL (10)
#define G_TYPE_UINT64	G_TYPE_MAKE_FUNDAMENTAL (11)
#define G_TYPE_ENUM	G_TYPE_MAKE_FUNDAMENTAL (12)
#define G_TYPE_FLAGS	G_TYPE_MAKE_FUNDAMENTAL (13)
#define G_TYPE_FLOAT	G_TYPE_MAKE_FUNDAMENTAL (14)
#define G_TYPE_DOUBLE	G_TYPE_MAKE_FUNDAMENTAL (15)
#define G_TYPE_STRING	G_TYPE_MAKE_FUNDAMENTAL (16)
#define G_TYPE_POINTER	G_TYPE_MAKE_FUNDAMENTAL (17)
#define G_TYPE_BOXED	G_TYPE_MAKE_FUNDAMENTAL (18)
#define G_TYPE_PARAM	G_TYPE_MAKE_FUNDAMENTAL (19)
#define G_TYPE_INTERFACE	G_TYPE_MAKE_FUNDAMENTAL (2)
#define G_TYPE_OBJECT	G_TYPE_MAKE_FUNDAMENTAL (20)
#define G_TYPE_CHAR	G_TYPE_MAKE_FUNDAMENTAL (3)
#define G_TYPE_UCHAR	G_TYPE_MAKE_FUNDAMENTAL (4)
#define G_TYPE_BOOLEAN	G_TYPE_MAKE_FUNDAMENTAL (5)
#define G_TYPE_INT	G_TYPE_MAKE_FUNDAMENTAL (6)
#define G_TYPE_UINT	G_TYPE_MAKE_FUNDAMENTAL (7)
#define G_TYPE_LONG	G_TYPE_MAKE_FUNDAMENTAL (8)
#define G_TYPE_ULONG	G_TYPE_MAKE_FUNDAMENTAL (9)


    typedef gulong GType;

    typedef struct _GTypeClass GTypeClass;

    typedef struct _GTypeInstance GTypeInstance;

    typedef struct _GObject GObject;

    typedef float gfloat;

    typedef struct _GValue GValue;

    typedef enum {
	G_PARAM_READABLE = 1,
	G_PARAM_WRITABLE = 2,
	G_PARAM_CONSTRUCT = 4,
	G_PARAM_CONSTRUCT_ONLY = 8,
	G_PARAM_LAX_VALIDATION = 16,
	G_PARAM_PRIVATE = 32
    } GParamFlags;

    typedef struct _GParamSpec GParamSpec;

    typedef struct _GObjectConstructParam GObjectConstructParam;

    typedef struct _GObjectClass GObjectClass;

    typedef struct _GClosure GClosure;

    typedef void (*GClosureNotify) (gpointer, GClosure *);

    typedef struct _GClosureNotifyData GClosureNotifyData;

    typedef void (*GTypeInterfaceCheckFunc) (gpointer, gpointer);

    typedef struct _GValueArray GValueArray;

    typedef struct _GEnumValue GEnumValue;

    typedef struct _GEnumClass GEnumClass;

    typedef struct _GParamSpecPool GParamSpecPool;

    typedef enum {
	G_TYPE_DEBUG_NONE = 0,
	G_TYPE_DEBUG_OBJECTS = 1,
	G_TYPE_DEBUG_SIGNALS = 2,
	G_TYPE_DEBUG_MASK = 3
    } GTypeDebugFlags;

    typedef struct _GTypePlugin GTypePlugin;

    typedef enum {
	G_SIGNAL_MATCH_ID = 1,
	G_SIGNAL_MATCH_DETAIL = 2,
	G_SIGNAL_MATCH_CLOSURE = 4,
	G_SIGNAL_MATCH_FUNC = 8,
	G_SIGNAL_MATCH_DATA = 16,
	G_SIGNAL_MATCH_UNBLOCKED = 32
    } GSignalMatchType;

    typedef struct _GFlagsValue GFlagsValue;

    typedef void (*GClosureMarshal) (GClosure *, GValue *, guint,
				     const GValue *, gpointer, gpointer);

    typedef void (*GCallback) (void);

    typedef struct _GFlagsClass GFlagsClass;

    typedef gboolean(*GTypeClassCacheFunc) (gpointer, GTypeClass *);

    typedef enum {
	G_SIGNAL_RUN_FIRST = 1,
	G_SIGNAL_RUN_LAST = 2,
	G_SIGNAL_RUN_CLEANUP = 4,
	G_SIGNAL_NO_RECURSE = 8,
	G_SIGNAL_DETAILED = 16,
	G_SIGNAL_ACTION = 32,
	G_SIGNAL_NO_HOOKS = 64
    } GSignalFlags;

    typedef struct _GSignalInvocationHint GSignalInvocationHint;

    typedef void (*GWeakNotify) (gpointer, GObject *);

    typedef void (*GBaseInitFunc) (gpointer);

    typedef void (*GBaseFinalizeFunc) (gpointer);

    typedef void (*GClassInitFunc) (gpointer, gpointer);

    typedef void (*GClassFinalizeFunc) (gpointer, gpointer);

    typedef void (*GInstanceInitFunc) (GTypeInstance *, gpointer);

    typedef union _GTypeCValue GTypeCValue;

    typedef struct _GTypeValueTable GTypeValueTable;

    typedef struct _GTypeInfo GTypeInfo;

    typedef enum {
	G_TYPE_FLAG_ABSTRACT = 16,
	G_TYPE_FLAG_VALUE_ABSTRACT = 32
    } GTypeFlags;

    typedef struct _GTypeModule GTypeModule;

    typedef void (*GInterfaceInitFunc) (gpointer, gpointer);

    typedef void (*GInterfaceFinalizeFunc) (gpointer, gpointer);

    typedef struct _GInterfaceInfo GInterfaceInfo;

    typedef gboolean(*GSignalAccumulator) (GSignalInvocationHint *,
					   GValue *, const GValue *,
					   gpointer);

    typedef GClosureMarshal GSignalCMarshaller;

    typedef enum {
	G_CONNECT_AFTER = 1,
	G_CONNECT_SWAPPED = 2
    } GConnectFlags;

    typedef enum {
	G_TYPE_FLAG_CLASSED = 1,
	G_TYPE_FLAG_INSTANTIATABLE = 2,
	G_TYPE_FLAG_DERIVABLE = 4,
	G_TYPE_FLAG_DEEP_DERIVABLE = 8
    } GTypeFundamentalFlags;

    typedef struct _GTypeFundamentalInfo GTypeFundamentalInfo;

    typedef struct _GTypeQuery GTypeQuery;

    typedef gboolean(*GSignalEmissionHook) (GSignalInvocationHint *, guint,
					    const GValue *, gpointer);

    typedef void (*GValueTransform) (const GValue *, GValue *);

    typedef struct _GParameter GParameter;

    typedef struct _GParamSpecTypeInfo GParamSpecTypeInfo;

    typedef gpointer(*GBoxedCopyFunc) (gpointer);

    typedef void (*GBoxedFreeFunc) (gpointer);

    typedef struct _GSignalQuery GSignalQuery;

    typedef struct _GTypeInterface GTypeInterface;

    typedef void (*GTypePluginCompleteInterfaceInfo) (GTypePlugin *, GType,
						      GType,
						      GInterfaceInfo *);

    typedef struct _GParamSpecObject GParamSpecObject;

    typedef void (*GTypePluginUnuse) (GTypePlugin *);

    typedef void (*GTypePluginUse) (GTypePlugin *);

    typedef void (*GTypePluginCompleteTypeInfo) (GTypePlugin *, GType,
						 GTypeInfo *,
						 GTypeValueTable *);

    typedef struct _GTypePluginClass GTypePluginClass;

    typedef struct _GCClosure GCClosure;

    typedef struct _GParamSpecUnichar GParamSpecUnichar;

    typedef struct _GParamSpecUInt64 GParamSpecUInt64;

    typedef struct _GParamSpecBoxed GParamSpecBoxed;

    typedef struct _GParamSpecOverride GParamSpecOverride;

    typedef struct _GParamSpecClass GParamSpecClass;

    typedef struct _GParamSpecLong GParamSpecLong;

    typedef struct _GParamSpecEnum GParamSpecEnum;

    typedef struct _GParamSpecFloat GParamSpecFloat;

    typedef struct _GParamSpecString GParamSpecString;

    typedef struct _GParamSpecDouble GParamSpecDouble;

    typedef struct _GParamSpecParam GParamSpecParam;

    typedef struct _GParamSpecValueArray GParamSpecValueArray;

    typedef struct _GParamSpecFlags GParamSpecFlags;

    typedef struct _GParamSpecInt64 GParamSpecInt64;

    typedef struct _GParamSpecPointer GParamSpecPointer;

    typedef struct _GParamSpecInt GParamSpecInt;

    typedef struct _GTypeModuleClass GTypeModuleClass;

    typedef struct _GParamSpecUInt GParamSpecUInt;

    typedef struct _GParamSpecUChar GParamSpecUChar;

    typedef struct _GParamSpecULong GParamSpecULong;

    typedef struct _GParamSpecChar GParamSpecChar;

    typedef struct _GParamSpecBoolean GParamSpecBoolean;

    typedef void (*GObjectFinalizeFunc) (GObject *);

    typedef void (*GObjectGetPropertyFunc) (GObject *, guint, GValue *,
					    GParamSpec *);

    typedef void (*GObjectSetPropertyFunc) (GObject *, guint,
					    const GValue *, GParamSpec *);

    typedef gchar *gchararray;

    typedef gchar **GStrv;


    struct _GTypeClass {
	GType g_type;
    };


    struct _GTypeInstance {
	GTypeClass *g_class;
    };


    struct _GObject {
	GTypeInstance g_type_instance;
	guint ref_count;
	GData *qdata;
    };


    struct _GValue {
	GType g_type;
	union {
	    gint v_int;
	    guint v_uint;
	    glong v_long;
	    gulong v_ulong;
	    gint64 v_int64;
	    guint64 v_uint64;
	    gfloat v_float;
	    gdouble v_double;
	    gpointer v_pointer;
	} data[2];
    };


    struct _GParamSpec {
	GTypeInstance g_type_instance;
	gchar *name;
	GParamFlags flags;
	GType value_type;
	GType owner_type;
	gchar *_nick;
	gchar *_blurb;
	GData *qdata;
	guint ref_count;
	guint param_id;
    };


    struct _GObjectConstructParam {
	GParamSpec *pspec;
	GValue *value;
    };


    struct _GObjectClass {
	GTypeClass g_type_class;
	GSList *construct_properties;
	GObject *(*constructor) (GType, guint, GObjectConstructParam *);
	void (*set_property) (GObject *, guint, const GValue *,
			      GParamSpec *);
	void (*get_property) (GObject *, guint, GValue *, GParamSpec *);
	void (*dispose) (GObject *);
	void (*finalize) (GObject *);
	void (*dispatch_properties_changed) (GObject *, guint,
					     GParamSpec * *);
	void (*notify) (GObject *, GParamSpec *);
	gpointer pdummy[8];
    };


    struct _GClosure {
	guint ref_count:15;
	guint meta_marshal:1;
	guint n_guards:1;
	guint n_fnotifiers:2;
	guint n_inotifiers:8;
	guint in_inotify:1;
	guint floating:1;
	guint derivative_flag:1;
	guint in_marshal:1;
	guint is_invalid:1;
	void (*marshal) (GClosure *, GValue *, guint, const GValue *,
			 gpointer, gpointer);
	gpointer data;
	GClosureNotifyData *notifiers;
    };


    struct _GClosureNotifyData {
	gpointer data;
	GClosureNotify notify;
    };


    struct _GValueArray {
	guint n_values;
	GValue *values;
	guint n_prealloced;
    };


    struct _GEnumValue {
	gint value;
	gchar *value_name;
	gchar *value_nick;
    };


    struct _GEnumClass {
	GTypeClass g_type_class;
	gint minimum;
	gint maximum;
	guint n_values;
	GEnumValue *values;
    };








    struct _GFlagsValue {
	guint value;
	gchar *value_name;
	gchar *value_nick;
    };


    struct _GFlagsClass {
	GTypeClass g_type_class;
	guint mask;
	guint n_values;
	GFlagsValue *values;
    };


    struct _GSignalInvocationHint {
	guint signal_id;
	GQuark detail;
	GSignalFlags run_type;
    };





    struct _GTypeValueTable {
	void (*value_init) (GValue *);
	void (*value_free) (GValue *);
	void (*value_copy) (const GValue *, GValue *);
	 gpointer(*value_peek_pointer) (const GValue *);
	gchar *collect_format;
	gchar *(*collect_value) (GValue *, guint, GTypeCValue *, guint);
	gchar *lcopy_format;
	gchar *(*lcopy_value) (const GValue *, guint, GTypeCValue *,
			       guint);
    };


    struct _GTypeInfo {
	guint16 class_size;
	GBaseInitFunc base_init;
	GBaseFinalizeFunc base_finalize;
	GClassInitFunc class_init;
	GClassFinalizeFunc class_finalize;
	gconstpointer class_data;
	guint16 instance_size;
	guint16 n_preallocs;
	GInstanceInitFunc instance_init;
	const GTypeValueTable *value_table;
    };


    struct _GTypeModule {
	GObject parent_instance;
	guint use_count;
	GSList *type_infos;
	GSList *interface_infos;
	gchar *name;
    };


    struct _GInterfaceInfo {
	GInterfaceInitFunc interface_init;
	GInterfaceFinalizeFunc interface_finalize;
	gpointer interface_data;
    };


    struct _GTypeFundamentalInfo {
	GTypeFundamentalFlags type_flags;
    };


    struct _GTypeQuery {
	GType type;
	const gchar *type_name;
	guint class_size;
	guint instance_size;
    };


    struct _GParameter {
	const gchar *name;
	GValue value;
    };


    struct _GParamSpecTypeInfo {
	guint16 instance_size;
	guint16 n_preallocs;
	void (*instance_init) (GParamSpec *);
	GType value_type;
	void (*finalize) (GParamSpec *);
	void (*value_set_default) (GParamSpec *, GValue *);
	 gboolean(*value_validate) (GParamSpec *, GValue *);
	 gint(*values_cmp) (GParamSpec *, const GValue *, const GValue *);
    };


    struct _GSignalQuery {
	guint signal_id;
	const gchar *signal_name;
	GType itype;
	GSignalFlags signal_flags;
	GType return_type;
	guint n_params;
	const GType *param_types;
    };


    struct _GTypeInterface {
	GType g_type;
	GType g_instance_type;
    };


    struct _GParamSpecObject {
	GParamSpec parent_instance;
    };


    struct _GTypePluginClass {
	GTypeInterface base_iface;
	GTypePluginUse use_plugin;
	GTypePluginUnuse unuse_plugin;
	GTypePluginCompleteTypeInfo complete_type_info;
	GTypePluginCompleteInterfaceInfo complete_interface_info;
    };


    struct _GCClosure {
	GClosure closure;
	gpointer callback;
    };


    struct _GParamSpecUnichar {
	GParamSpec parent_instance;
	gunichar default_value;
    };


    struct _GParamSpecUInt64 {
	GParamSpec parent_instance;
	guint64 minimum;
	guint64 maximum;
	guint64 default_value;
    };


    struct _GParamSpecBoxed {
	GParamSpec parent_instance;
    };


    struct _GParamSpecOverride {
	GParamSpec parent_instance;
	GParamSpec *overridden;
    };


    struct _GParamSpecClass {
	GTypeClass g_type_class;
	GType value_type;
	void (*finalize) (GParamSpec *);
	void (*value_set_default) (GParamSpec *, GValue *);
	 gboolean(*value_validate) (GParamSpec *, GValue *);
	 gint(*values_cmp) (GParamSpec *, const GValue *, const GValue *);
	gpointer dummy[4];
    };


    struct _GParamSpecLong {
	GParamSpec parent_instance;
	glong minimum;
	glong maximum;
	glong default_value;
    };


    struct _GParamSpecEnum {
	GParamSpec parent_instance;
	GEnumClass *enum_class;
	gint default_value;
    };


    struct _GParamSpecFloat {
	GParamSpec parent_instance;
	gfloat minimum;
	gfloat maximum;
	gfloat default_value;
	gfloat epsilon;
    };


    struct _GParamSpecString {
	GParamSpec parent_instance;
	gchar *default_value;
	gchar *cset_first;
	gchar *cset_nth;
	gchar substitutor;
	guint null_fold_if_empty:1;
	guint ensure_non_null:1;
    };


    struct _GParamSpecDouble {
	GParamSpec parent_instance;
	gdouble minimum;
	gdouble maximum;
	gdouble default_value;
	gdouble epsilon;
    };


    struct _GParamSpecParam {
	GParamSpec parent_instance;
    };


    struct _GParamSpecValueArray {
	GParamSpec parent_instance;
	GParamSpec *element_spec;
	guint fixed_n_elements;
    };


    struct _GParamSpecFlags {
	GParamSpec parent_instance;
	GFlagsClass *flags_class;
	guint default_value;
    };


    struct _GParamSpecInt64 {
	GParamSpec parent_instance;
	gint64 minimum;
	gint64 maximum;
	gint64 default_value;
    };


    struct _GParamSpecPointer {
	GParamSpec parent_instance;
    };


    struct _GParamSpecInt {
	GParamSpec parent_instance;
	gint minimum;
	gint maximum;
	gint default_value;
    };


    struct _GTypeModuleClass {
	GObjectClass parent_class;
	 gboolean(*load) (GTypeModule *);
	void (*unload) (GTypeModule *);
	void (*reserved1) (void);
	void (*reserved2) (void);
	void (*reserved3) (void);
	void (*reserved4) (void);
    };


    struct _GParamSpecUInt {
	GParamSpec parent_instance;
	guint minimum;
	guint maximum;
	guint default_value;
    };


    struct _GParamSpecUChar {
	GParamSpec parent_instance;
	guint8 minimum;
	guint8 maximum;
	guint8 default_value;
    };


    struct _GParamSpecULong {
	GParamSpec parent_instance;
	gulong minimum;
	gulong maximum;
	gulong default_value;
    };


    struct _GParamSpecChar {
	GParamSpec parent_instance;
	gint8 minimum;
	gint8 maximum;
	gint8 default_value;
    };


    struct _GParamSpecBoolean {
	GParamSpec parent_instance;
	gboolean default_value;
    };


    extern void g_object_set_property(GObject *, const gchar *,
				      const GValue *);
    extern void g_value_set_param(GValue *, GParamSpec *);
    extern gpointer g_object_steal_qdata(GObject *, GQuark);
    extern void g_object_class_override_property(GObjectClass *, guint,
						 const gchar *);
    extern void g_cclosure_marshal_VOID__INT(GClosure *, GValue *, guint,
					     const GValue *, gpointer,
					     gpointer);
    extern void g_closure_sink(GClosure *);
    extern gboolean g_type_check_value_holds(GValue *, GType);
    extern void g_type_remove_interface_check(gpointer,
					      GTypeInterfaceCheckFunc);
    extern GValueArray *g_value_array_remove(GValueArray *, guint);
    extern gboolean g_param_value_defaults(GParamSpec *, GValue *);
    extern GParamSpec *g_param_spec_long(const gchar *, const gchar *,
					 const gchar *, glong, glong,
					 glong, GParamFlags);
    extern gpointer g_param_spec_internal(GType, const gchar *,
					  const gchar *, const gchar *,
					  GParamFlags);
    extern void g_cclosure_marshal_VOID__LONG(GClosure *, GValue *, guint,
					      const GValue *, gpointer,
					      gpointer);
    extern GType g_io_channel_get_type(void);
    extern GEnumValue *g_enum_get_value(GEnumClass *, gint);
    extern GParamSpec *g_param_spec_boolean(const gchar *, const gchar *,
					    const gchar *, gboolean,
					    GParamFlags);
    extern GParamSpec *g_param_spec_pointer(const gchar *, const gchar *,
					    const gchar *, GParamFlags);
    extern GClosure *g_closure_new_object(guint, GObject *);
    extern void g_param_spec_pool_insert(GParamSpecPool *, GParamSpec *,
					 GType);
    extern void g_type_init_with_debug_flags(GTypeDebugFlags);
    extern GType *g_type_interfaces(GType, guint *);
    extern GClosure *g_closure_new_simple(guint, gpointer);
    extern GParamSpec *g_param_spec_string(const gchar *, const gchar *,
					   const gchar *, const gchar *,
					   GParamFlags);
    extern GValueArray *g_value_array_copy(const GValueArray *);
    extern gpointer g_type_instance_get_private(GTypeInstance *, GType);
    extern void g_cclosure_marshal_VOID__FLAGS(GClosure *, GValue *, guint,
					       const GValue *, gpointer,
					       gpointer);
    extern GTypePlugin *g_type_get_plugin(GType);
    extern void g_param_spec_unref(GParamSpec *);
    extern gint g_param_values_cmp(GParamSpec *, const GValue *,
				   const GValue *);
    extern void g_value_set_object(GValue *, gpointer);
    extern GParamSpec *g_param_spec_boxed(const gchar *, const gchar *,
					  const gchar *, GType,
					  GParamFlags);
    extern void g_value_set_int(GValue *, gint);
    extern gboolean g_signal_parse_name(const gchar *, GType, guint *,
					GQuark *, gboolean);
    extern GParamSpec *g_param_spec_pool_lookup(GParamSpecPool *,
						const gchar *, GType,
						gboolean);
    extern GTypeInstance *g_type_create_instance(GType);
    extern void g_signal_override_class_closure(guint, GType, GClosure *);
    extern gboolean g_param_value_validate(GParamSpec *, GValue *);
    extern void g_closure_add_invalidate_notifier(GClosure *, gpointer,
						  GClosureNotify);
    extern gpointer g_type_interface_peek(gpointer, GType);
    extern gboolean g_type_test_flags(GType, guint);
    extern void g_signal_emit_by_name(gpointer, const gchar *, ...);
    extern void g_value_set_int64(GValue *, gint64);
    extern void g_cclosure_marshal_VOID__UINT(GClosure *, GValue *, guint,
					      const GValue *, gpointer,
					      gpointer);
    extern GType g_enum_register_static(const gchar *, const GEnumValue *);
    extern guint g_signal_handlers_disconnect_matched(gpointer,
						      GSignalMatchType,
						      guint, GQuark,
						      GClosure *, gpointer,
						      gpointer);
    extern gpointer g_value_get_pointer(const GValue *);
    extern GType g_flags_register_static(const gchar *,
					 const GFlagsValue *);
    extern gboolean g_value_fits_pointer(const GValue *);
    extern void g_closure_set_marshal(GClosure *, GClosureMarshal);
    extern void g_value_set_float(GValue *, gfloat);
    extern void g_signal_emit(gpointer, guint, GQuark, ...);
    extern GParamSpec *g_param_spec_uint(const gchar *, const gchar *,
					 const gchar *, guint, guint,
					 guint, GParamFlags);
    extern GClosure *g_cclosure_new_object_swap(GCallback, GObject *);
    extern void g_param_spec_set_qdata(GParamSpec *, GQuark, gpointer);
    extern guint *g_signal_list_ids(GType, guint *);
    extern GFlagsValue *g_flags_get_first_value(GFlagsClass *, guint);
    extern void g_type_add_class_cache_func(gpointer, GTypeClassCacheFunc);
    extern void g_object_unref(gpointer);
    extern GParamSpec *g_value_dup_param(const GValue *);
    extern void g_object_get(gpointer, const gchar *, ...);
    extern void g_value_set_uint64(GValue *, guint64);
    extern void g_cclosure_marshal_VOID__OBJECT(GClosure *, GValue *,
						guint, const GValue *,
						gpointer, gpointer);
    extern guint64 g_value_get_uint64(const GValue *);
    extern GType *g_type_children(GType, guint *);
    extern const gchar *g_type_name(GType);
    extern GTypeClass *g_type_check_class_cast(GTypeClass *, GType);
    extern void g_cclosure_marshal_VOID__UCHAR(GClosure *, GValue *, guint,
					       const GValue *, gpointer,
					       gpointer);
    extern gpointer g_object_new(GType, const gchar *, ...);
    extern void g_type_class_unref_uncached(gpointer);
    extern const gchar *g_type_name_from_class(GTypeClass *);
    extern void g_object_set(gpointer, const gchar *, ...);
    extern void g_signal_emit_valist(gpointer, guint, GQuark, va_list);
    extern GSignalInvocationHint *g_signal_get_invocation_hint(gpointer);
    extern void g_closure_invalidate(GClosure *);
    extern void g_cclosure_marshal_VOID__FLOAT(GClosure *, GValue *, guint,
					       const GValue *, gpointer,
					       gpointer);
    extern void g_object_weak_unref(GObject *, GWeakNotify, gpointer);
    extern GParamSpec *g_param_spec_int(const gchar *, const gchar *,
					const gchar *, gint, gint, gint,
					GParamFlags);
    extern void g_value_set_char(GValue *, gchar);
    extern gpointer g_type_default_interface_ref(GType);
    extern GValueArray *g_value_array_sort(GValueArray *, GCompareFunc);
    extern void g_cclosure_marshal_VOID__VOID(GClosure *, GValue *, guint,
					      const GValue *, gpointer,
					      gpointer);
    extern GType *g_param_spec_types;
    extern GClosure *g_cclosure_new_object(GCallback, GObject *);
    extern GType g_type_register_static(GType, const gchar *,
					const GTypeInfo *, GTypeFlags);
    extern GEnumValue *g_enum_get_value_by_name(GEnumClass *,
						const gchar *);
    extern GFlagsValue *g_flags_get_value_by_nick(GFlagsClass *,
						  const gchar *);
    extern guint g_type_depth(GType);
    extern void g_object_class_install_property(GObjectClass *, guint,
						GParamSpec *);
    extern void g_type_plugin_unuse(GTypePlugin *);
    extern void g_type_module_unuse(GTypeModule *);
    extern GParamSpec *g_param_spec_flags(const gchar *, const gchar *,
					  const gchar *, GType, guint,
					  GParamFlags);
    extern GParamSpec *g_param_spec_char(const gchar *, const gchar *,
					 const gchar *, gint8, gint8,
					 gint8, GParamFlags);
    extern void g_closure_remove_invalidate_notifier(GClosure *, gpointer,
						     GClosureNotify);
    extern gint g_value_get_enum(const GValue *);
    extern GParamSpec *g_object_interface_find_property(gpointer,
							const gchar *);
    extern void g_value_copy(const GValue *, GValue *);
    extern gpointer g_type_get_qdata(GType, GQuark);
    extern void g_cclosure_marshal_VOID__DOUBLE(GClosure *, GValue *,
						guint, const GValue *,
						gpointer, gpointer);
    extern gboolean g_value_type_compatible(GType, GType);
    extern void g_object_set_data_full(GObject *, const gchar *, gpointer,
				       GDestroyNotify);
    extern guint g_signal_handlers_block_matched(gpointer,
						 GSignalMatchType, guint,
						 GQuark, GClosure *,
						 gpointer, gpointer);
    extern gpointer g_boxed_copy(GType, gconstpointer);
    extern const gchar *g_value_get_string(const GValue *);
    extern void g_object_thaw_notify(GObject *);
    extern void g_signal_handler_block(gpointer, gulong);
    extern void g_type_plugin_complete_type_info(GTypePlugin *, GType,
						 GTypeInfo *,
						 GTypeValueTable *);
    extern GTypeInstance *g_type_check_instance_cast(GTypeInstance *,
						     GType);
    extern GEnumValue *g_enum_get_value_by_nick(GEnumClass *,
						const gchar *);
    extern GType g_type_from_name(const gchar *);
    extern gboolean g_signal_accumulator_true_handled(GSignalInvocationHint
						      *, GValue *,
						      const GValue *,
						      gpointer);
    extern GType g_type_module_register_enum(GTypeModule *, const gchar *,
					     const GEnumValue *);
    extern void g_closure_unref(GClosure *);
    extern void g_signal_chain_from_overridden(const GValue *, GValue *);
    extern gboolean g_param_value_convert(GParamSpec *, const GValue *,
					  GValue *, gboolean);
    extern void g_type_class_add_private(gpointer, gsize);
    extern gpointer g_type_interface_peek_parent(gpointer);
    extern void g_type_add_interface_check(gpointer,
					   GTypeInterfaceCheckFunc);
    extern void g_cclosure_marshal_VOID__POINTER(GClosure *, GValue *,
						 guint, const GValue *,
						 gpointer, gpointer);
    extern void g_cclosure_marshal_VOID__CHAR(GClosure *, GValue *, guint,
					      const GValue *, gpointer,
					      gpointer);
    extern GParamSpec *g_param_spec_float(const gchar *, const gchar *,
					  const gchar *, gfloat, gfloat,
					  gfloat, GParamFlags);
    extern gboolean g_type_is_a(GType, GType);
    extern GParamSpec *g_param_spec_object(const gchar *, const gchar *,
					   const gchar *, GType,
					   GParamFlags);
    extern gpointer g_type_class_peek_parent(gpointer);
    extern GType g_io_condition_get_type(void);
    extern guchar g_value_get_uchar(const GValue *);
    extern GParamSpec *g_param_spec_double(const gchar *, const gchar *,
					   const gchar *, gdouble, gdouble,
					   gdouble, GParamFlags);
    extern GType g_strv_get_type(void);
    extern void g_cclosure_marshal_STRING__OBJECT_POINTER(GClosure *,
							  GValue *, guint,
							  const GValue *,
							  gpointer,
							  gpointer);
    extern gulong g_signal_handler_find(gpointer, GSignalMatchType, guint,
					GQuark, GClosure *, gpointer,
					gpointer);
    extern GParamSpec *g_param_spec_ref(GParamSpec *);
    extern gboolean g_value_transform(const GValue *, GValue *);
    extern gpointer g_type_class_peek_static(GType);
    extern GObject *g_object_new_valist(GType, const gchar *, va_list);
    extern void g_value_unset(GValue *);
    extern gpointer g_value_dup_boxed(const GValue *);
    extern void g_cclosure_marshal_VOID__STRING(GClosure *, GValue *,
						guint, const GValue *,
						gpointer, gpointer);
    extern void g_param_spec_sink(GParamSpec *);
    extern void g_object_run_dispose(GObject *);
    extern GParamSpec *g_param_spec_override(const gchar *, GParamSpec *);
    extern void g_value_set_instance(GValue *, gpointer);
    extern gpointer g_value_peek_pointer(const GValue *);
    extern GType g_type_module_register_type(GTypeModule *, GType,
					     const gchar *,
					     const GTypeInfo *,
					     GTypeFlags);
    extern void g_signal_handlers_destroy(gpointer);
    extern void g_value_set_boolean(GValue *, gboolean);
    extern void g_type_plugin_complete_interface_info(GTypePlugin *, GType,
						      GType,
						      GInterfaceInfo *);
    extern GParamSpec *g_param_spec_get_redirect_target(GParamSpec *);
    extern GParamSpec **g_object_interface_list_properties(gpointer,
							   guint *);
    extern gint64 g_value_get_int64(const GValue *);
    extern GType g_type_module_register_flags(GTypeModule *, const gchar *,
					      const GFlagsValue *);
    extern void g_cclosure_marshal_BOOLEAN__FLAGS(GClosure *, GValue *,
						  guint, const GValue *,
						  gpointer, gpointer);
    extern gpointer g_param_spec_get_qdata(GParamSpec *, GQuark);
    extern void g_type_init(void);
    extern gulong g_value_get_ulong(const GValue *);
    extern gchar *g_strdup_value_contents(const GValue *);
    extern guint g_signal_new_valist(const gchar *, GType, GSignalFlags,
				     GClosure *, GSignalAccumulator,
				     gpointer, GSignalCMarshaller, GType,
				     guint, va_list);
    extern void g_object_disconnect(gpointer, const gchar *, ...);
    extern void g_object_add_weak_pointer(GObject *, gpointer *);
    extern GParamSpec *g_param_spec_param(const gchar *, const gchar *,
					  const gchar *, GType,
					  GParamFlags);
    extern void g_signal_stop_emission_by_name(gpointer, const gchar *);
    extern GValueArray *g_value_array_sort_with_data(GValueArray *,
						     GCompareDataFunc,
						     gpointer);
    extern GType g_value_array_get_type(void);
    extern void g_value_take_string(GValue *, gchar *);
    extern GType g_closure_get_type(void);
    extern void g_signal_stop_emission(gpointer, guint, GQuark);
    extern void g_object_notify(GObject *, const gchar *);
    extern gfloat g_value_get_float(const GValue *);
    extern gchar g_value_get_char(const GValue *);
    extern void g_value_take_boxed(GValue *, gconstpointer);
    extern void g_cclosure_marshal_VOID__BOOLEAN(GClosure *, GValue *,
						 guint, const GValue *,
						 gpointer, gpointer);
    extern gulong g_signal_connect_data(gpointer, const gchar *, GCallback,
					gpointer, GClosureNotify,
					GConnectFlags);
    extern void g_object_set_data(GObject *, const gchar *, gpointer);
    extern GType g_type_register_fundamental(GType, const gchar *,
					     const GTypeInfo *,
					     const GTypeFundamentalInfo *,
					     GTypeFlags);
    extern GParamSpec **g_object_class_list_properties(GObjectClass *,
						       guint *);
    extern void g_cclosure_marshal_VOID__UINT_POINTER(GClosure *, GValue *,
						      guint,
						      const GValue *,
						      gpointer, gpointer);
    extern void g_type_class_unref(gpointer);
    extern void g_cclosure_marshal_VOID__BOXED(GClosure *, GValue *, guint,
					       const GValue *, gpointer,
					       gpointer);
    extern gboolean g_value_type_transformable(GType, GType);
    extern void g_signal_handler_unblock(gpointer, gulong);
    extern GValue *g_value_init(GValue *, GType);
    extern gpointer g_object_ref(gpointer);
    extern void g_object_get_valist(GObject *, const gchar *, va_list);
    extern gboolean g_value_get_boolean(const GValue *);
    extern void g_type_query(GType, GTypeQuery *);
    extern void g_type_interface_add_prerequisite(GType, GType);
    extern gint g_value_get_int(const GValue *);
    extern void g_cclosure_marshal_VOID__ENUM(GClosure *, GValue *, guint,
					      const GValue *, gpointer,
					      gpointer);
    extern GType g_type_fundamental_next(void);
    extern gboolean g_type_check_value(GValue *);
    extern gpointer g_value_get_boxed(const GValue *);
    extern GClosure *g_signal_type_cclosure_new(GType, guint);
    extern void g_value_set_static_boxed(GValue *, gconstpointer);
    extern GType g_type_plugin_get_type(void);
    extern GType *g_type_interface_prerequisites(GType, guint *);
    extern void g_boxed_free(GType, gpointer);
    extern GParamSpec *g_param_spec_uint64(const gchar *, const gchar *,
					   const gchar *, guint64, guint64,
					   guint64, GParamFlags);
    extern GType g_type_next_base(GType, GType);
    extern const gchar *g_type_name_from_instance(GTypeInstance *);
    extern const gchar *g_param_spec_get_name(GParamSpec *);
    extern gulong g_signal_add_emission_hook(guint, GQuark,
					     GSignalEmissionHook, gpointer,
					     GDestroyNotify);
    extern GParamSpec *g_object_class_find_property(GObjectClass *,
						    const gchar *);
    extern void g_value_set_long(GValue *, glong);
    extern void g_param_spec_pool_remove(GParamSpecPool *, GParamSpec *);
    extern void g_signal_emitv(const GValue *, guint, GQuark, GValue *);
    extern GType g_type_module_get_type(void);
    extern GObject *g_value_dup_object(const GValue *);
    extern void g_flags_complete_type_info(GType, GTypeInfo *,
					   const GFlagsValue *);
    extern gulong g_signal_connect_closure_by_id(gpointer, guint, GQuark,
						 GClosure *, gboolean);
    extern GType g_value_get_type(void);
    extern gulong g_signal_connect_closure(gpointer, const gchar *,
					   GClosure *, gboolean);
    extern gulong g_signal_connect_object(gpointer, const gchar *,
					  GCallback, gpointer,
					  GConnectFlags);
    extern void g_value_take_param(GValue *, GParamSpec *);
    extern void g_value_set_ulong(GValue *, gulong);
    extern void g_value_register_transform_func(GType, GType,
						GValueTransform);
    extern GType g_type_parent(GType);
    extern void g_type_plugin_use(GTypePlugin *);
    extern GType g_type_register_dynamic(GType, const gchar *,
					 GTypePlugin *, GTypeFlags);
    extern GType g_pointer_type_register_static(const gchar *);
    extern void g_closure_add_finalize_notifier(GClosure *, gpointer,
						GClosureNotify);
    extern GFlagsValue *g_flags_get_value_by_name(GFlagsClass *,
						  const gchar *);
    extern void g_cclosure_marshal_VOID__PARAM(GClosure *, GValue *, guint,
					       const GValue *, gpointer,
					       gpointer);
    extern gboolean g_signal_handler_is_connected(gpointer, gulong);
    extern void g_closure_set_meta_marshal(GClosure *, gpointer,
					   GClosureMarshal);
    extern void g_value_set_uchar(GValue *, guchar);
    extern GValueArray *g_value_array_prepend(GValueArray *,
					      const GValue *);
    extern void g_source_set_closure(GSource *, GClosure *);
    extern GParamSpec **g_param_spec_pool_list(GParamSpecPool *, GType,
					       guint *);
    extern GQuark g_type_qname(GType);
    extern gboolean g_type_module_use(GTypeModule *);
    extern void g_type_add_interface_dynamic(GType, GType, GTypePlugin *);
    extern gpointer g_type_class_ref(GType);
    extern void g_closure_remove_finalize_notifier(GClosure *, gpointer,
						   GClosureNotify);
    extern gpointer g_object_connect(gpointer, const gchar *, ...);
    extern void g_type_remove_class_cache_func(gpointer,
					       GTypeClassCacheFunc);
    extern gpointer g_object_newv(GType, guint, GParameter *);
    extern GValueArray *g_value_array_insert(GValueArray *, guint,
					     const GValue *);
    extern gboolean g_signal_has_handler_pending(gpointer, guint, GQuark,
						 gboolean);
    extern guint g_signal_lookup(const gchar *, GType);
    extern void g_type_free_instance(GTypeInstance *);
    extern void g_closure_invoke(GClosure *, GValue *, guint,
				 const GValue *, gpointer);
    extern GType g_type_fundamental(GType);
    extern GTypeValueTable *g_type_value_table_peek(GType);
    extern GList *g_param_spec_pool_list_owned(GParamSpecPool *, GType);
    extern void g_value_set_enum(GValue *, gint);
    extern gchar *g_value_dup_string(const GValue *);
    extern void g_signal_handler_disconnect(gpointer, gulong);
    extern GType g_param_type_register_static(const gchar *,
					      const GParamSpecTypeInfo *);
    extern void g_object_remove_weak_pointer(GObject *, gpointer *);
    extern glong g_value_get_long(const GValue *);
    extern gboolean g_type_check_is_value_type(GType);
    extern void g_value_set_double(GValue *, gdouble);
    extern void g_value_set_static_string(GValue *, const gchar *);
    extern const gchar *g_param_spec_get_nick(GParamSpec *);
    extern GClosure *g_cclosure_new(GCallback, gpointer, GClosureNotify);
    extern guint g_value_get_uint(const GValue *);
    extern GClosure *g_cclosure_new_swap(GCallback, gpointer,
					 GClosureNotify);
    extern GValue *g_value_reset(GValue *);
    extern void g_object_set_qdata(GObject *, GQuark, gpointer);
    extern gpointer g_object_get_data(GObject *, const gchar *);
    extern gpointer g_object_get_qdata(GObject *, GQuark);
    extern void g_object_set_valist(GObject *, const gchar *, va_list);
    extern void g_object_freeze_notify(GObject *);
    extern void g_value_set_pointer(GValue *, gpointer);
    extern gpointer g_object_steal_data(GObject *, const gchar *);
    extern void g_object_interface_install_property(gpointer,
						    GParamSpec *);
    extern void g_object_watch_closure(GObject *, GClosure *);
    extern void g_value_take_object(GValue *, gpointer);
    extern GValueArray *g_value_array_new(guint);
    extern GParamSpec *g_value_get_param(const GValue *);
    extern void g_param_value_set_default(GParamSpec *, GValue *);
    extern void g_closure_add_marshal_guards(GClosure *, gpointer,
					     GClosureNotify, gpointer,
					     GClosureNotify);
    extern gdouble g_value_get_double(const GValue *);
    extern GValue *g_value_array_get_nth(GValueArray *, guint);
    extern GTypePlugin *g_type_interface_get_plugin(GType, GType);
    extern void g_object_weak_ref(GObject *, GWeakNotify, gpointer);
    extern GType g_gstring_get_type(void);
    extern void g_value_set_flags(GValue *, guint);
    extern void g_object_get_property(GObject *, const gchar *, GValue *);
    extern GParamSpec *g_param_spec_unichar(const gchar *, const gchar *,
					    const gchar *, gunichar,
					    GParamFlags);
    extern void g_type_default_interface_unref(gpointer);
    extern GParamSpec *g_param_spec_uchar(const gchar *, const gchar *,
					  const gchar *, guint8, guint8,
					  guint8, GParamFlags);
    extern void g_object_set_qdata_full(GObject *, GQuark, gpointer,
					GDestroyNotify);
    extern void g_type_set_qdata(GType, GQuark, gpointer);
    extern void g_value_set_string(GValue *, const gchar *);
    extern gpointer g_type_class_peek(GType);
    extern void g_value_set_boxed(GValue *, gconstpointer);
    extern void g_type_module_set_name(GTypeModule *, const gchar *);
    extern GClosure *g_closure_ref(GClosure *);
    extern guint g_signal_handlers_unblock_matched(gpointer,
						   GSignalMatchType, guint,
						   GQuark, GClosure *,
						   gpointer, gpointer);
    extern GParamSpec *g_param_spec_value_array(const gchar *,
						const gchar *,
						const gchar *,
						GParamSpec *, GParamFlags);
    extern GParamSpec *g_param_spec_enum(const gchar *, const gchar *,
					 const gchar *, GType, gint,
					 GParamFlags);
    extern void g_param_spec_set_qdata_full(GParamSpec *, GQuark, gpointer,
					    GDestroyNotify);
    extern GParamSpec *g_param_spec_ulong(const gchar *, const gchar *,
					  const gchar *, gulong, gulong,
					  gulong, GParamFlags);
    extern guint g_value_get_flags(const GValue *);
    extern void g_type_module_add_interface(GTypeModule *, GType, GType,
					    const GInterfaceInfo *);
    extern gboolean g_type_check_instance(GTypeInstance *);
    extern GValueArray *g_value_array_append(GValueArray *,
					     const GValue *);
    extern void g_type_add_interface_static(GType, GType,
					    const GInterfaceInfo *);
    extern gpointer g_param_spec_steal_qdata(GParamSpec *, GQuark);
    extern gboolean g_type_check_class_is_a(GTypeClass *, GType);
    extern const gchar *g_param_spec_get_blurb(GParamSpec *);
    extern void g_value_set_uint(GValue *, guint);
    extern GParamSpecPool *g_param_spec_pool_new(gboolean);
    extern const gchar *g_signal_name(guint);
    extern GParamSpec *g_param_spec_int64(const gchar *, const gchar *,
					  const gchar *, gint64, gint64,
					  gint64, GParamFlags);
    extern guint g_signal_newv(const gchar *, GType, GSignalFlags,
			       GClosure *, GSignalAccumulator, gpointer,
			       GSignalCMarshaller, GType, guint, GType *);
    extern guint g_signal_new(const gchar *, GType, GSignalFlags, guint,
			      GSignalAccumulator, gpointer,
			      GSignalCMarshaller, GType, guint, ...);
    extern GType g_boxed_type_register_static(const gchar *,
					      GBoxedCopyFunc,
					      GBoxedFreeFunc);
    extern void g_value_array_free(GValueArray *);
    extern void g_cclosure_marshal_VOID__ULONG(GClosure *, GValue *, guint,
					       const GValue *, gpointer,
					       gpointer);
    extern void g_signal_remove_emission_hook(guint, gulong);
    extern void g_enum_complete_type_info(GType, GTypeInfo *,
					  const GEnumValue *);
    extern gpointer g_value_get_object(const GValue *);
    extern gpointer g_type_default_interface_peek(GType);
    extern void g_signal_query(guint, GSignalQuery *);
    extern gboolean g_type_check_instance_is_a(GTypeInstance *, GType);
#ifdef __cplusplus
}
#endif
#endif
