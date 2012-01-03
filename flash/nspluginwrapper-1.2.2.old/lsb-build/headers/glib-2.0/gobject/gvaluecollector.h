#ifndef _GLIB_2_0_GOBJECT_GVALUECOLLECTOR_H_
#define _GLIB_2_0_GOBJECT_GVALUECOLLECTOR_H_


#ifdef __cplusplus
extern "C" {
#endif


#define G_VALUE_LCOPY(value,var_args,flags,__error)	 \
	G_STMT_START { const GValue *_value = (value); guint _flags = \
	(flags); GType _value_type = G_VALUE_TYPE (_value); GTypeValueTable \
	*_vtable = g_type_value_table_peek (_value_type); gchar *_lcopy_format \
	= _vtable->lcopy_format; GTypeCValue \
	_cvalues[G_VALUE_COLLECT_FORMAT_MAX_LENGTH] = { { 0, }, }; guint \
	_n_values = 0; while (*_lcopy_format) { GTypeCValue *_cvalue = \
	_cvalues + _n_values++; switch (*_lcopy_format++) { case \
	G_VALUE_COLLECT_INT: _cvalue->v_int = va_arg ((var_args), gint); \
	break; case G_VALUE_COLLECT_LONG: _cvalue->v_long = va_arg \
	((var_args), glong); break; case G_VALUE_COLLECT_INT64: \
	_cvalue->v_int64 = va_arg ((var_args), gint64); break; case \
	G_VALUE_COLLECT_DOUBLE: _cvalue->v_double = va_arg ((var_args), \
	gdouble); break; case G_VALUE_COLLECT_POINTER: _cvalue->v_pointer = \
	va_arg ((var_args), gpointer); break; default: g_assert_not_reached \
	(); } } *(__error) = _vtable->lcopy_value (_value, _n_values, \
	_cvalues, _flags); } G_STMT_END
#define G_VALUE_COLLECT(value,var_args,flags,__error)	 \
	G_STMT_START { GValue *_value = (value); guint _flags = (flags); \
	GType _value_type = G_VALUE_TYPE (_value); GTypeValueTable *_vtable = \
	g_type_value_table_peek (_value_type); gchar *_collect_format = \
	_vtable->collect_format; GTypeCValue \
	_cvalues[G_VALUE_COLLECT_FORMAT_MAX_LENGTH] = { { 0, }, }; guint \
	_n_values = 0; if (_vtable->value_free) _vtable->value_free (_value); \
	_value->g_type = _value_type; memset (_value->data, 0, sizeof \
	(_value->data)); while (*_collect_format) { GTypeCValue *_cvalue = \
	_cvalues + _n_values++; switch (*_collect_format++) { case \
	G_VALUE_COLLECT_INT: _cvalue->v_int = va_arg ((var_args), gint); \
	break; case G_VALUE_COLLECT_LONG: _cvalue->v_long = va_arg \
	((var_args), glong); break; case G_VALUE_COLLECT_INT64: \
	_cvalue->v_int64 = va_arg ((var_args), gint64); break; case \
	G_VALUE_COLLECT_DOUBLE: _cvalue->v_double = va_arg ((var_args), \
	gdouble); break; case G_VALUE_COLLECT_POINTER: _cvalue->v_pointer = \
	va_arg ((var_args), gpointer); break; default: g_assert_not_reached \
	(); } } *(__error) = _vtable->collect_value (_value, _n_values, \
	_cvalues, _flags); } G_STMT_END
#define G_VALUE_COLLECT_FORMAT_MAX_LENGTH	(8)


    enum {
	G_VALUE_COLLECT_INT = 'i',
	G_VALUE_COLLECT_LONG = 'l',
	G_VALUE_COLLECT_INT64 = 'q',
	G_VALUE_COLLECT_DOUBLE = 'd',
	G_VALUE_COLLECT_POINTER = 'p'
    };


#ifdef __cplusplus
}
#endif
#endif
