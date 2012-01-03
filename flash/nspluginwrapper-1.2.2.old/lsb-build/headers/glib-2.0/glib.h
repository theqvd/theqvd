#ifndef _GLIB_2_0_GLIB_H_
#define _GLIB_2_0_GLIB_H_

#include <time.h>
#include <stddef.h>
#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif


#define GLIB_HAVE_ALLOCA_H
#define GLIB_HAVE_SYS_POLL_H
#define G_GINT32_MODIFIER	""
#define G_GNUC_FUNCTION	""
#define G_GNUC_PRETTY_FUNCTION	""
#if __i386__
#define G_GSIZE_MODIFIER	""
#endif
#if __powerpc__ && !__powerpc64__
#define G_GSIZE_MODIFIER	""
#endif
#if __s390__ && !__s390x__
#define G_GSIZE_MODIFIER	""
#endif
#define G_OPTION_REMAINING	""
#define G_OS_UNIX
#define G_THREADS_ENABLED
#define G_THREADS_IMPL_POSIX
#define G_WIN32_DLLMAIN_FOR_DLL_NAME(static,dll_name)
#define G_CSET_LATINC	 \
	"\300\301\302\303\304\305\306" \
	"\307\310\311\312\313\314\315\316\317\320" "\321\322\323\324\325\326" \
	"\330\331\332\333\334\335\336"
#define G_CSET_LATINS	 \
	"\337\340\341\342\343\344\345\346" \
	"\347\350\351\352\353\354\355\356\357\360" "\361\362\363\364\365\366" \
	"\370\371\372\373\374\375\376\377"
#define g_mem_chunk_create(type,pre_alloc,alloc_type)	 \
	( g_mem_chunk_new (#type " mem chunks (" #pre_alloc ")", sizeof \
	(type), sizeof (type) * (pre_alloc), (alloc_type)) )
#define G_NODE_IS_ROOT(node)	 \
	(((GNode*) (node))->parent == NULL && ((GNode*) (node))->prev == NULL \
	&& ((GNode*) (node))->next == NULL)
#define g_once(once,func,arg)	 \
	(((once)->status == G_ONCE_STATUS_READY) ? (once)->retval : \
	g_once_impl ((once), (func), (arg)))
#define CLAMP(x,low,high)	 \
	(((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))
#define G_STRUCT_OFFSET(struct_type,member)	 \
	((glong) ((guint8*) &((struct_type*) 0)->member))
#define G_STRUCT_MEMBER_P(struct_p,struct_offset)	 \
	((gpointer) ((guint8*) (struct_p) + (glong) (struct_offset)))
#define GUINT16_SWAP_LE_BE_CONSTANT(val)	 \
	((guint16) ( (guint16) ((guint16) (val) >> 8) | (guint16) ((guint16) \
	(val) << 8)))
#define GUINT32_SWAP_LE_BE_CONSTANT(val)	 \
	((guint32) ( (((guint32) (val) & (guint32) 0x000000ffU) << 24) | \
	(((guint32) (val) & (guint32) 0x0000ff00U) << 8) | (((guint32) (val) & \
	(guint32) 0x00ff0000U) >> 8) | (((guint32) (val) & (guint32) \
	0xff000000U) >> 24)))
#define GUINT32_SWAP_LE_PDP(val)	 \
	((guint32) ( (((guint32) (val) & (guint32) 0x0000ffffU) << 16) | \
	(((guint32) (val) & (guint32) 0xffff0000U) >> 16)))
#define GUINT32_SWAP_BE_PDP(val)	 \
	((guint32) ( (((guint32) (val) & (guint32) 0x00ff00ffU) << 8) | \
	(((guint32) (val) & (guint32) 0xff00ff00U) >> 8)))
#define GUINT64_SWAP_LE_BE_CONSTANT(val)	 \
	((guint64) ( (((guint64) (val) & (guint64) G_GINT64_CONSTANT \
	(0x00000000000000ffU)) << 56) | (((guint64) (val) & (guint64) \
	G_GINT64_CONSTANT (0x000000000000ff00U)) << 40) | (((guint64) (val) & \
	(guint64) G_GINT64_CONSTANT (0x0000000000ff0000U)) << 24) | \
	(((guint64) (val) & (guint64) G_GINT64_CONSTANT (0x00000000ff000000U)) \
	<< 8) | (((guint64) (val) & (guint64) G_GINT64_CONSTANT \
	(0x000000ff00000000U)) >> 8) | (((guint64) (val) & (guint64) \
	G_GINT64_CONSTANT (0x0000ff0000000000U)) >> 24) | (((guint64) (val) & \
	(guint64) G_GINT64_CONSTANT (0x00ff000000000000U)) >> 40) | \
	(((guint64) (val) & (guint64) G_GINT64_CONSTANT (0xff00000000000000U)) \
	>> 56)))
#define g_ascii_isalnum(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_ALNUM) != 0)
#define g_ascii_isalpha(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_ALPHA) != 0)
#define g_ascii_iscntrl(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_CNTRL) != 0)
#define g_ascii_isdigit(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_DIGIT) != 0)
#define g_ascii_isgraph(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_GRAPH) != 0)
#define g_ascii_islower(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_LOWER) != 0)
#define g_ascii_isprint(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_PRINT) != 0)
#define g_ascii_ispunct(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_PUNCT) != 0)
#define g_ascii_isspace(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_SPACE) != 0)
#define g_ascii_isupper(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_UPPER) != 0)
#define g_ascii_isxdigit(c)	 \
	((g_ascii_table[(guchar) (c)] & G_ASCII_XDIGIT) != 0)
#define G_HOOK_ACTIVE(hook)	 \
	((G_HOOK_FLAGS (hook) & G_HOOK_FLAG_ACTIVE) != 0)
#define G_HOOK_IN_CALL(hook)	 \
	((G_HOOK_FLAGS (hook) & G_HOOK_FLAG_IN_CALL) != 0)
#define g_node_first_child(node)	 \
	((node) ? ((GNode*) (node))->children : NULL)
#define g_node_next_sibling(node)	 \
	((node) ? ((GNode*) (node))->next : NULL)
#define g_node_prev_sibling(node)	 \
	((node) ? ((GNode*) (node))->prev : NULL)
#define g_new(struct_type,n_structs)	 \
	((struct_type *) g_malloc (((gsize) sizeof (struct_type)) * ((gsize) \
	(n_structs))))
#define g_new0(struct_type,n_structs)	 \
	((struct_type *) g_malloc0 (((gsize) sizeof (struct_type)) * ((gsize) \
	(n_structs))))
#define g_renew(struct_type,mem,n_structs)	 \
	((struct_type *) g_realloc ((mem), ((gsize) sizeof (struct_type)) * \
	((gsize) (n_structs))))
#define g_newa(struct_type,n_structs)	 \
	((struct_type*) g_alloca (sizeof (struct_type) * (gsize) \
	(n_structs)))
#define G_STRUCT_MEMBER(member_type,struct_p,struct_offset)	 \
	(*(member_type*) G_STRUCT_MEMBER_P ((struct_p), (struct_offset)))
#define G_THREAD_UF(op,arglist)	 \
	(*g_thread_functions_for_glib_use . op) arglist
#define GLIB_CHECK_VERSION(major,minor,micro)	 \
	(GLIB_MAJOR_VERSION > (major) || (GLIB_MAJOR_VERSION == (major) && \
	GLIB_MINOR_VERSION > (minor)) || (GLIB_MAJOR_VERSION == (major) && \
	GLIB_MINOR_VERSION == (minor) && GLIB_MICRO_VERSION >= (micro)))
#define g_atomic_int_dec_and_test(atomic)	 \
	(g_atomic_int_exchange_and_add ((atomic), -1) == 1)
#define g_static_mutex_get_mutex_impl_shortcut(mutex)	 \
	(g_atomic_pointer_get ((gpointer*)mutex) ? *(mutex) : \
	g_static_mutex_get_mutex_impl (mutex))
#define g_datalist_get_data(dl,k)	 \
	(g_datalist_id_get_data ((dl), g_quark_try_string (k)))
#define g_dataset_get_data(l,k)	 \
	(g_dataset_id_get_data ((l), g_quark_try_string (k)))
#define G_HOOK_IS_VALID(hook)	 \
	(G_HOOK (hook)->hook_id != 0 && (G_HOOK_FLAGS (hook) & \
	G_HOOK_FLAG_ACTIVE))
#define G_HOOK_IS_UNLINKED(hook)	 \
	(G_HOOK (hook)->next == NULL && G_HOOK (hook)->prev == NULL && G_HOOK \
	(hook)->hook_id == 0 && G_HOOK (hook)->ref_count == 0)
#define g_thread_create(func,data,joinable,error)	 \
	(g_thread_create_full (func, data, 0, joinable, FALSE, \
	G_THREAD_PRIORITY_NORMAL, error))
#define G_THREAD_ECF(op,fail,mutex,type)	 \
	(g_thread_supported () ? ((type(*)(GMutex*, gulong, gchar*)) \
	(*g_thread_functions_for_glib_use . op)) (mutex, G_MUTEX_DEBUG_MAGIC, \
	G_STRLOC) : (fail))
#define G_THREAD_CF(op,fail,arg)	 \
	(g_thread_supported () ? G_THREAD_UF (op, arg) : (fail))
#define g_static_mutex_get_mutex(mutex)	 \
	(g_thread_use_default_impl ? ((GMutex*) &((mutex)->static_mutex)) : \
	g_static_mutex_get_mutex_impl_shortcut (&((mutex)->runtime_mutex)))
#define G_LOCK_DEFINE(name)	 \
	GStaticMutex G_LOCK_NAME (name) = G_STATIC_MUTEX_INIT
#define g_datalist_remove_no_notify(dl,k)	 \
	g_datalist_id_remove_no_notify ((dl), g_quark_try_string (k))
#define g_datalist_id_remove_data(dl,q)	 \
	g_datalist_id_set_data ((dl), (q), NULL)
#define g_datalist_remove_data(dl,k)	 \
	g_datalist_id_set_data ((dl), g_quark_try_string (k), NULL)
#define g_datalist_id_set_data(dl,q,d)	 \
	g_datalist_id_set_data_full ((dl), (q), (d), NULL)
#define g_datalist_set_data_full(dl,k,d,f)	 \
	g_datalist_id_set_data_full ((dl), g_quark_from_string (k), (d), (f))
#define g_datalist_set_data(dl,k,d)	 \
	g_datalist_set_data_full ((dl), (k), (d), NULL)
#define g_dataset_remove_no_notify(l,k)	 \
	g_dataset_id_remove_no_notify ((l), g_quark_try_string (k))
#define g_dataset_id_remove_data(l,k)	 \
	g_dataset_id_set_data ((l), (k), NULL)
#define g_dataset_remove_data(l,k)	 \
	g_dataset_id_set_data ((l), g_quark_try_string (k), NULL)
#define g_dataset_id_set_data(l,k,d)	 \
	g_dataset_id_set_data_full ((l), (k), (d), NULL)
#define g_dataset_set_data_full(l,k,d,f)	 \
	g_dataset_id_set_data_full ((l), g_quark_from_string (k), (d), (f))
#define g_dataset_set_data(l,k,d)	 \
	g_dataset_set_data_full ((l), (k), (d), NULL)
#define g_hook_append(hook_list,hook)	 \
	g_hook_insert_before ((hook_list), NULL, (hook))
#define g_critical(...)	 \
	g_log (G_LOG_DOMAIN, G_LOG_LEVEL_CRITICAL, __VA_ARGS__)
#define g_message(...)	 \
	g_log (G_LOG_DOMAIN, G_LOG_LEVEL_MESSAGE, __VA_ARGS__)
#define g_warning(...)	 \
	g_log (G_LOG_DOMAIN, G_LOG_LEVEL_WARNING, __VA_ARGS__)
#define g_static_mutex_lock(mutex)	 \
	g_mutex_lock (g_static_mutex_get_mutex (mutex))
#define g_static_mutex_trylock(mutex)	 \
	g_mutex_trylock (g_static_mutex_get_mutex (mutex))
#define g_static_mutex_unlock(mutex)	 \
	g_mutex_unlock (g_static_mutex_get_mutex (mutex))
#define g_node_insert_data(parent,position,data)	 \
	g_node_insert ((parent), (position), g_node_new (data))
#define g_node_insert_data_before(parent,sibling,data)	 \
	g_node_insert_before ((parent), (sibling), g_node_new (data))
#define g_node_append(parent,node)	 \
	g_node_insert_before ((parent), NULL, (node))
#define g_node_append_data(parent,data)	 \
	g_node_insert_before ((parent), NULL, g_node_new (data))
#define g_node_prepend_data(parent,data)	 \
	g_node_prepend ((parent), g_node_new (data))
#define g_chunk_free(mem,mem_chunk)	 \
	G_STMT_START { g_mem_chunk_free ((mem_chunk), (mem)); } G_STMT_END
#define g_memmove(d,s,n)	 \
	G_STMT_START { memmove ((d), (s), (n)); } G_STMT_END
#define g_assert_not_reached()	 \
	G_STMT_START{ g_assert_warning (G_LOG_DOMAIN, __FILE__, __LINE__, \
	__PRETTY_FUNCTION__, NULL); }G_STMT_END
#define g_return_val_if_reached(val)	 \
	G_STMT_START{ g_log (G_LOG_DOMAIN, G_LOG_LEVEL_CRITICAL, "file %s: \
	line %d (%s): should not be reached", __FILE__, __LINE__, \
	__PRETTY_FUNCTION__); return (val); }G_STMT_END
#define g_return_if_reached()	 \
	G_STMT_START{ g_log (G_LOG_DOMAIN, G_LOG_LEVEL_CRITICAL, "file %s: \
	line %d (%s): should not be reached", __FILE__, __LINE__, \
	__PRETTY_FUNCTION__); return; }G_STMT_END
#define g_assert(expr)	 \
	G_STMT_START{ if G_LIKELY(expr) { } else g_assert_warning \
	(G_LOG_DOMAIN, __FILE__, __LINE__, __PRETTY_FUNCTION__, #expr); \
	}G_STMT_END
#define g_return_val_if_fail(expr,val)	 \
	G_STMT_START{ if G_LIKELY(expr) { } else { g_return_if_fail_warning \
	(G_LOG_DOMAIN, __PRETTY_FUNCTION__, #expr); return (val); }; \
	}G_STMT_END
#define g_return_if_fail(expr)	 \
	G_STMT_START{ if G_LIKELY(expr) { } else { g_return_if_fail_warning \
	(G_LOG_DOMAIN, __PRETTY_FUNCTION__, #expr); return; }; }G_STMT_END
#define G_BREAKPOINT()	 \
	G_STMT_START{ __asm__ __volatile__ ("int $03"); }G_STMT_END
#define g_cond_broadcast(cond)	 \
	G_THREAD_CF (cond_broadcast, (void)0, (cond))
#define g_cond_timed_wait(cond,mutex,abs_time)	 \
	G_THREAD_CF (cond_timed_wait, TRUE, (cond, mutex, abs_time))
#define g_cond_wait(cond,mutex)	 \
	G_THREAD_CF (cond_wait, (void)0, (cond, mutex))
#define g_private_get(private_key)	 \
	G_THREAD_CF (private_get, ((gpointer)private_key), (private_key))
#define g_private_set(private_key,value)	 \
	G_THREAD_CF (private_set, (void) (private_key = (GPrivate*) (value)), \
	(private_key, value))
#define G_GNUC_PRINTF(format_idx,arg_idx)	 \
	__attribute__((__format__ (__printf__, format_idx, arg_idx)))
#define G_GNUC_SCANF(format_idx,arg_idx)	 \
	__attribute__((__format__ (__scanf__, format_idx, arg_idx)))
#define G_STATIC_RW_LOCK_INIT	 \
	{ G_STATIC_MUTEX_INIT, NULL, NULL, 0, FALSE, 0, 0 }
#if __ia64__
#define G_STATIC_MUTEX_INIT	 \
	{ NULL, { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} } }
#endif
#if __powerpc64__
#define G_STATIC_MUTEX_INIT	 \
	{ NULL, { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} } }
#endif
#if __x86_64__
#define G_STATIC_MUTEX_INIT	 \
	{ NULL, { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} } }
#endif
#if __s390x__
#define G_STATIC_MUTEX_INIT	 \
	{ NULL, { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} } }
#endif
#if __i386__
#define G_STATIC_MUTEX_INIT	 \
	{ NULL, { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} } }
#endif
#if __powerpc__ && !__powerpc64__
#define G_STATIC_MUTEX_INIT	 \
	{ NULL, { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} } }
#endif
#if __s390__ && !__s390x__
#define G_STATIC_MUTEX_INIT	 \
	{ NULL, { { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0} } }
#endif
#define G_STRINGIFY_ARG(contents)	#contents
#define G_DIR_SEPARATOR	'/'
#define g_chunk_new(type,chunk)	( (type *) g_mem_chunk_alloc (chunk) )
#define g_chunk_new0(type,chunk)	( (type *) g_mem_chunk_alloc0 (chunk) )
#define MIN(a,b)	(((a) < (b)) ? (a) : (b))
#define ABS(a)	(((a) < 0) ? -(a) : (a))
#define MAX(a,b)	(((a) > (b)) ? (a) : (b))
#define G_NODE_IS_LEAF(node)	(((GNode*) (node))->children == NULL)
#define g_array_index(a,t,i)	(((t*) (a)->data) [(i)])
#define g_ptr_array_index(array,index_)	((array)->pdata)[index_]
#define G_IS_DIR_SEPARATOR(c)	((c) == G_DIR_SEPARATOR)
#define G_STRFUNC	((const char*) (__PRETTY_FUNCTION__))
#define G_LOG_DOMAIN	((gchar*) 0)
#define G_HOOK(hook)	((GHook*) (hook))
#if __i386__
#define GPOINTER_TO_INT(p)	((gint) (p))
#endif
#if __powerpc__ && !__powerpc64__
#define GPOINTER_TO_INT(p)	((gint) (p))
#endif
#if __s390__ && !__s390x__
#define GPOINTER_TO_INT(p)	((gint) (p))
#endif
#define GINT_TO_BE(val)	((gint) GINT32_TO_BE (val))
#define GINT_TO_LE(val)	((gint) GINT32_TO_LE (val))
#define GINT16_TO_LE(val)	((gint16) (val))
#define G_MAXINT16	((gint16) 0x7fff)
#define G_MININT16	((gint16) 0x8000)
#define GINT16_TO_BE(val)	((gint16) GUINT16_SWAP_LE_BE (val))
#define GINT32_TO_LE(val)	((gint32) (val))
#define G_MAXINT32	((gint32) 0x7fffffff)
#define G_MININT32	((gint32) 0x80000000)
#define GINT32_TO_BE(val)	((gint32) GUINT32_SWAP_LE_BE (val))
#define GINT64_TO_LE(val)	((gint64) (val))
#define GINT64_TO_BE(val)	((gint64) GUINT64_SWAP_LE_BE (val))
#define G_MAXINT8	((gint8) 0x7f)
#define G_MININT8	((gint8) 0x80)
#if __ia64__
#define GPOINTER_TO_INT(p)	((glong) (p))
#endif
#if __powerpc64__
#define GPOINTER_TO_INT(p)	((glong) (p))
#endif
#if __x86_64__
#define GPOINTER_TO_INT(p)	((glong) (p))
#endif
#if __s390x__
#define GPOINTER_TO_INT(p)	((glong) (p))
#endif
#if __i386__
#define GLONG_TO_BE(val)	((glong) GINT32_TO_BE (val))
#endif
#if __powerpc__ && !__powerpc64__
#define GLONG_TO_BE(val)	((glong) GINT32_TO_BE (val))
#endif
#if __s390__ && !__s390x__
#define GLONG_TO_BE(val)	((glong) GINT32_TO_BE (val))
#endif
#if __i386__
#define GLONG_TO_LE(val)	((glong) GINT32_TO_LE (val))
#endif
#if __powerpc__ && !__powerpc64__
#define GLONG_TO_LE(val)	((glong) GINT32_TO_LE (val))
#endif
#if __s390__ && !__s390x__
#define GLONG_TO_LE(val)	((glong) GINT32_TO_LE (val))
#endif
#if __ia64__
#define GLONG_TO_BE(val)	((glong) GINT64_TO_BE (val))
#endif
#if __powerpc64__
#define GLONG_TO_BE(val)	((glong) GINT64_TO_BE (val))
#endif
#if __x86_64__
#define GLONG_TO_BE(val)	((glong) GINT64_TO_BE (val))
#endif
#if __s390x__
#define GLONG_TO_BE(val)	((glong) GINT64_TO_BE (val))
#endif
#if __ia64__
#define GLONG_TO_LE(val)	((glong) GINT64_TO_LE (val))
#endif
#if __powerpc64__
#define GLONG_TO_LE(val)	((glong) GINT64_TO_LE (val))
#endif
#if __x86_64__
#define GLONG_TO_LE(val)	((glong) GINT64_TO_LE (val))
#endif
#if __s390x__
#define GLONG_TO_LE(val)	((glong) GINT64_TO_LE (val))
#endif
#if __ia64__
#define GINT_TO_POINTER(i)	((gpointer) (glong) (i))
#endif
#if __powerpc64__
#define GINT_TO_POINTER(i)	((gpointer) (glong) (i))
#endif
#if __x86_64__
#define GINT_TO_POINTER(i)	((gpointer) (glong) (i))
#endif
#if __s390x__
#define GINT_TO_POINTER(i)	((gpointer) (glong) (i))
#endif
#define GSIZE_TO_POINTER(s)	((gpointer) (gsize) (s))
#if __ia64__
#define GUINT_TO_POINTER(u)	((gpointer) (gulong) (u))
#endif
#if __powerpc64__
#define GUINT_TO_POINTER(u)	((gpointer) (gulong) (u))
#endif
#if __x86_64__
#define GUINT_TO_POINTER(u)	((gpointer) (gulong) (u))
#endif
#if __s390x__
#define GUINT_TO_POINTER(u)	((gpointer) (gulong) (u))
#endif
#if __i386__
#define GINT_TO_POINTER(i)	((gpointer) (i))
#endif
#if __powerpc__ && !__powerpc64__
#define GINT_TO_POINTER(i)	((gpointer) (i))
#endif
#if __s390__ && !__s390x__
#define GINT_TO_POINTER(i)	((gpointer) (i))
#endif
#if __i386__
#define GUINT_TO_POINTER(u)	((gpointer) (u))
#endif
#if __powerpc__ && !__powerpc64__
#define GUINT_TO_POINTER(u)	((gpointer) (u))
#endif
#if __s390__ && !__s390x__
#define GUINT_TO_POINTER(u)	((gpointer) (u))
#endif
#define GPOINTER_TO_SIZE(p)	((gsize) (p))
#if __i386__
#define GPOINTER_TO_UINT(p)	((guint) (p))
#endif
#if __powerpc__ && !__powerpc64__
#define GPOINTER_TO_UINT(p)	((guint) (p))
#endif
#if __s390__ && !__s390x__
#define GPOINTER_TO_UINT(p)	((guint) (p))
#endif
#define GUINT_TO_BE(val)	((guint) GUINT32_TO_BE (val))
#define GUINT_TO_LE(val)	((guint) GUINT32_TO_LE (val))
#define GUINT16_SWAP_LE_PDP(val)	((guint16) (val))
#define GUINT16_TO_LE(val)	((guint16) (val))
#define G_MAXUINT16	((guint16) 0xffff)
#define GUINT32_TO_LE(val)	((guint32) (val))
#define G_MAXUINT32	((guint32) 0xffffffff)
#define GUINT64_TO_LE(val)	((guint64) (val))
#define G_MAXUINT8	((guint8) 0xff)
#if __ia64__
#define GPOINTER_TO_UINT(p)	((gulong) (p))
#endif
#if __powerpc64__
#define GPOINTER_TO_UINT(p)	((gulong) (p))
#endif
#if __x86_64__
#define GPOINTER_TO_UINT(p)	((gulong) (p))
#endif
#if __s390x__
#define GPOINTER_TO_UINT(p)	((gulong) (p))
#endif
#if __i386__
#define GULONG_TO_BE(val)	((gulong) GUINT32_TO_BE (val))
#endif
#if __powerpc__ && !__powerpc64__
#define GULONG_TO_BE(val)	((gulong) GUINT32_TO_BE (val))
#endif
#if __s390__ && !__s390x__
#define GULONG_TO_BE(val)	((gulong) GUINT32_TO_BE (val))
#endif
#if __i386__
#define GULONG_TO_LE(val)	((gulong) GUINT32_TO_LE (val))
#endif
#if __powerpc__ && !__powerpc64__
#define GULONG_TO_LE(val)	((gulong) GUINT32_TO_LE (val))
#endif
#if __s390__ && !__s390x__
#define GULONG_TO_LE(val)	((gulong) GUINT32_TO_LE (val))
#endif
#if __ia64__
#define GULONG_TO_BE(val)	((gulong) GUINT64_TO_BE (val))
#endif
#if __powerpc64__
#define GULONG_TO_BE(val)	((gulong) GUINT64_TO_BE (val))
#endif
#if __x86_64__
#define GULONG_TO_BE(val)	((gulong) GUINT64_TO_BE (val))
#endif
#if __s390x__
#define GULONG_TO_BE(val)	((gulong) GUINT64_TO_BE (val))
#endif
#if __ia64__
#define GULONG_TO_LE(val)	((gulong) GUINT64_TO_LE (val))
#endif
#if __powerpc64__
#define GULONG_TO_LE(val)	((gulong) GUINT64_TO_LE (val))
#endif
#if __x86_64__
#define GULONG_TO_LE(val)	((gulong) GUINT64_TO_LE (val))
#endif
#if __s390x__
#define GULONG_TO_LE(val)	((gulong) GUINT64_TO_LE (val))
#endif
#define g_random_boolean()	((g_random_int () & (1 << 15)) != 0)
#define g_rand_boolean(rand_)	((g_rand_int (rand_) & (1 << 15)) != 0)
#define g_list_next(list)	((list) ? (((GList *)(list))->next) : NULL)
#define g_list_previous(list)	((list) ? (((GList *)(list))->prev) : NULL)
#define g_slist_next(slist)	((slist) ? (((GSList *)(slist))->next) : NULL)
#define g_atomic_int_get(atomic)	(*(atomic))
#define g_atomic_pointer_get(atomic)	(*(atomic))
#define G_LOG_2_BASE_10	(0.30102999566398119521)
#define G_ALLOCATOR_LIST	(1)
#define G_IEEE754_DOUBLE_BIAS	(1023)
#define G_IEEE754_FLOAT_BIAS	(127)
#define G_ALLOCATOR_SLIST	(2)
#define G_ASCII_DTOSTR_BUF_SIZE	(29 + 10)
#define G_ALLOCATOR_NODE	(3)
#define G_HOOK_FLAG_USER_SHIFT	(4)
#define G_LOG_LEVEL_USER_SHIFT	(8)
#define g_ATEXIT(proc)	(atexit (proc))
#define g_utf8_next_char(p)	(char *)((p) + g_utf8_skip[*(guchar *)(p)])
#define G_LIKELY(expr)	(expr)
#define G_UNLIKELY(expr)	(expr)
#define GINT16_FROM_BE(val)	(GINT16_TO_BE (val))
#define GINT16_FROM_LE(val)	(GINT16_TO_LE (val))
#define GINT32_FROM_BE(val)	(GINT32_TO_BE (val))
#define GINT32_FROM_LE(val)	(GINT32_TO_LE (val))
#define GINT64_FROM_BE(val)	(GINT64_TO_BE (val))
#define GINT64_FROM_LE(val)	(GINT64_TO_LE (val))
#define GINT_FROM_BE(val)	(GINT_TO_BE (val))
#define GINT_FROM_LE(val)	(GINT_TO_LE (val))
#define GLONG_FROM_BE(val)	(GLONG_TO_BE (val))
#define GLONG_FROM_LE(val)	(GLONG_TO_LE (val))
#define g_ntohs(val)	(GUINT16_FROM_BE (val))
#define GUINT16_SWAP_BE_PDP(val)	(GUINT16_SWAP_LE_BE (val))
#define GUINT16_TO_BE(val)	(GUINT16_SWAP_LE_BE (val))
#define GUINT16_SWAP_LE_BE(val)	(GUINT16_SWAP_LE_BE_CONSTANT (val))
#define GUINT16_FROM_BE(val)	(GUINT16_TO_BE (val))
#define g_htons(val)	(GUINT16_TO_BE (val))
#define GUINT16_FROM_LE(val)	(GUINT16_TO_LE (val))
#define g_ntohl(val)	(GUINT32_FROM_BE (val))
#define GUINT32_TO_BE(val)	(GUINT32_SWAP_LE_BE (val))
#define GUINT32_SWAP_LE_BE(val)	(GUINT32_SWAP_LE_BE_CONSTANT (val))
#define GUINT32_FROM_BE(val)	(GUINT32_TO_BE (val))
#define g_htonl(val)	(GUINT32_TO_BE (val))
#define GUINT32_FROM_LE(val)	(GUINT32_TO_LE (val))
#define GUINT64_TO_BE(val)	(GUINT64_SWAP_LE_BE (val))
#define GUINT64_SWAP_LE_BE(val)	(GUINT64_SWAP_LE_BE_CONSTANT (val))
#define GUINT64_FROM_BE(val)	(GUINT64_TO_BE (val))
#define GUINT64_FROM_LE(val)	(GUINT64_TO_LE (val))
#define GUINT_FROM_BE(val)	(GUINT_TO_BE (val))
#define GUINT_FROM_LE(val)	(GUINT_TO_LE (val))
#define GULONG_FROM_BE(val)	(GULONG_TO_BE (val))
#define GULONG_FROM_LE(val)	(GULONG_TO_LE (val))
#define g_atomic_int_inc(atomic)	(g_atomic_int_add ((atomic), 1))
#if __ia64__
#define G_GINT64_CONSTANT(val)	(G_GNUC_EXTENSION (val ##L))
#endif
#if __powerpc64__
#define G_GINT64_CONSTANT(val)	(G_GNUC_EXTENSION (val ##L))
#endif
#if __x86_64__
#define G_GINT64_CONSTANT(val)	(G_GNUC_EXTENSION (val ##L))
#endif
#if __s390x__
#define G_GINT64_CONSTANT(val)	(G_GNUC_EXTENSION (val ##L))
#endif
#if __i386__
#define G_GINT64_CONSTANT(val)	(G_GNUC_EXTENSION (val ##LL))
#endif
#if __powerpc__ && !__powerpc64__
#define G_GINT64_CONSTANT(val)	(G_GNUC_EXTENSION (val ##LL))
#endif
#if __s390__ && !__s390x__
#define G_GINT64_CONSTANT(val)	(G_GNUC_EXTENSION (val ##LL))
#endif
#define G_HOOK_FLAGS(hook)	(G_HOOK (hook)->flags)
#define G_LOG_FATAL_MASK	(G_LOG_FLAG_RECURSION | G_LOG_LEVEL_ERROR)
#define G_OPTION_ERROR	(g_option_error_quark ())
#define g_thread_supported()	(g_threads_got_initialized)
#define G_N_ELEMENTS(arr)	(sizeof (arr) / sizeof ((arr)[0]))
#define G_STMT_START	(void) __extension__ (
#define G_STMT_END	)
#define G_PRIORITY_HIGH	-100
#define G_DIR_SEPARATOR_S	"/"
#define G_HAVE_GROWING_STACK	0
#define G_PRIORITY_DEFAULT	0
#define G_LN2	0.69314718055994530941723212145817656807550013436026
#define G_PI_4	0.78539816339744830961566084581987572104929234984378
#define G_CSET_DIGITS	"0123456789"
#define G_DATE_BAD_DAY	0U
#define G_DATE_BAD_JULIAN	0U
#define G_DATE_BAD_YEAR	0U
#define G_MUTEX_DEBUG_MAGIC	0xf8e18ad7
#define G_ALLOC_ONLY	1
#define G_CAN_INLINE	1
#define G_HAVE_GINT64	1
#define G_HAVE_GNUC_VARARGS	1
#define G_HAVE_GNUC_VISIBILITY	1
#define G_HAVE_INLINE	1
#define G_HAVE_ISO_VARARGS	1
#define G_HAVE___INLINE	1
#define G_HAVE___INLINE__	1
#if __ia64__
#define G_VA_COPY_AS_ARRAY	1
#endif
#if __powerpc__ && !__powerpc64__
#define G_VA_COPY_AS_ARRAY	1
#endif
#if __powerpc64__
#define G_VA_COPY_AS_ARRAY	1
#endif
#if __s390__ && !__s390x__
#define G_VA_COPY_AS_ARRAY	1
#endif
#if __x86_64__
#define G_VA_COPY_AS_ARRAY	1
#endif
#if __s390x__
#define G_VA_COPY_AS_ARRAY	1
#endif
#define G_SQRT2	1.4142135623730950488016887242096980785696718753769
#define G_PI_2	1.5707963267948966192313216916397514420985846996876
#define G_PRIORITY_HIGH_IDLE	100
#define G_USEC_PER_SEC	1000000
#define G_LITTLE_ENDIAN	1234
#define GLIB_MAJOR_VERSION	2
#define G_ALLOC_AND_FREE	2
#define G_LN10	2.3025850929940456840179914546843642076011014886288
#define G_E	2.7182818284590452353602874713526624977572470937000
#define G_PRIORITY_DEFAULT_IDLE	200
#if __i386__
#define GLIB_LSB_PADDING_SIZE	24
#endif
#if __powerpc__ && !__powerpc64__
#define GLIB_LSB_PADDING_SIZE	24
#endif
#if __s390__ && !__s390x__
#define GLIB_LSB_PADDING_SIZE	24
#endif
#define G_PI	3.1415926535897932384626433832795028841971693993751
#define G_PRIORITY_LOW	300
#define G_PDP_ENDIAN	3412
#if __i386__
#define GLIB_LSB_DATA_SIZE	4
#endif
#if __powerpc__ && !__powerpc64__
#define GLIB_LSB_DATA_SIZE	4
#endif
#if __s390__ && !__s390x__
#define GLIB_LSB_DATA_SIZE	4
#endif
#if __i386__
#define GLIB_SIZEOF_LONG	4
#endif
#if __powerpc__ && !__powerpc64__
#define GLIB_SIZEOF_LONG	4
#endif
#if __s390__ && !__s390x__
#define GLIB_SIZEOF_LONG	4
#endif
#if __i386__
#define GLIB_SIZEOF_SIZE_T	4
#endif
#if __powerpc__ && !__powerpc64__
#define GLIB_SIZEOF_SIZE_T	4
#endif
#if __s390__ && !__s390x__
#define GLIB_SIZEOF_SIZE_T	4
#endif
#if __i386__
#define GLIB_SIZEOF_VOID_P	4
#endif
#if __powerpc__ && !__powerpc64__
#define GLIB_SIZEOF_VOID_P	4
#endif
#if __s390__ && !__s390x__
#define GLIB_SIZEOF_VOID_P	4
#endif
#if __ia64__
#define GLIB_LSB_PADDING_SIZE	40
#endif
#if __powerpc64__
#define GLIB_LSB_PADDING_SIZE	40
#endif
#if __x86_64__
#define GLIB_LSB_PADDING_SIZE	40
#endif
#if __s390x__
#define GLIB_LSB_PADDING_SIZE	40
#endif
#define G_BIG_ENDIAN	4321
#define GLIB_MICRO_VERSION	6
#define GLIB_MINOR_VERSION	6
#if __ia64__
#define GLIB_LSB_DATA_SIZE	8
#endif
#if __powerpc64__
#define GLIB_LSB_DATA_SIZE	8
#endif
#if __x86_64__
#define GLIB_LSB_DATA_SIZE	8
#endif
#if __s390x__
#define GLIB_LSB_DATA_SIZE	8
#endif
#if __ia64__
#define GLIB_SIZEOF_LONG	8
#endif
#if __powerpc64__
#define GLIB_SIZEOF_LONG	8
#endif
#if __x86_64__
#define GLIB_SIZEOF_LONG	8
#endif
#if __s390x__
#define GLIB_SIZEOF_LONG	8
#endif
#if __ia64__
#define GLIB_SIZEOF_SIZE_T	8
#endif
#if __powerpc64__
#define GLIB_SIZEOF_SIZE_T	8
#endif
#if __x86_64__
#define GLIB_SIZEOF_SIZE_T	8
#endif
#if __s390x__
#define GLIB_SIZEOF_SIZE_T	8
#endif
#if __ia64__
#define GLIB_SIZEOF_VOID_P	8
#endif
#if __powerpc64__
#define GLIB_SIZEOF_VOID_P	8
#endif
#if __x86_64__
#define GLIB_SIZEOF_VOID_P	8
#endif
#if __s390x__
#define GLIB_SIZEOF_VOID_P	8
#endif
#define G_SEARCHPATH_SEPARATOR	:
#define G_SEARCHPATH_SEPARATOR_S	":"
#define GLIB_SYSDEF_POLLIN	=1
#define GLIB_SYSDEF_POLLHUP	=16
#define GLIB_SYSDEF_POLLPRI	=2
#define GLIB_SYSDEF_POLLNVAL	=32
#define GLIB_SYSDEF_POLLOUT	=4
#define GLIB_SYSDEF_POLLERR	=8
#define G_CSET_A_2_Z	"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define G_CSET_a_2_z	"abcdefghijklmnopqrstuvwxyz"
#define g_alloca(size)	alloca (size)
#define G_CONST_RETURN	const
#define G_MAXDOUBLE	DBL_MAX
#define G_MINDOUBLE	DBL_MIN
#define GLIB_VAR	extern
#define G_LOCK_EXTERN(name)	extern GStaticMutex G_LOCK_NAME (name)
#define G_INLINE_FUNC	extern inline
#define G_MAXFLOAT	FLT_MAX
#define G_MINFLOAT	FLT_MIN
#define G_MEM_ALIGN	GLIB_SIZEOF_LONG
#define g_array_append_val(a,v)	g_array_append_vals (a, &(v), 1)
#define g_array_insert_val(a,i,v)	g_array_insert_vals (a, i, &(v), 1)
#define g_array_prepend_val(a,v)	g_array_prepend_vals (a, &(v), 1)
#define ATEXIT(proc)	g_ATEXIT(proc)
#if __powerpc__ && !__powerpc64__
#define G_BYTE_ORDER	G_BIG_ENDIAN
#endif
#if __powerpc64__
#define G_BYTE_ORDER	G_BIG_ENDIAN
#endif
#if __s390__ && !__s390x__
#define G_BYTE_ORDER	G_BIG_ENDIAN
#endif
#if __s390x__
#define G_BYTE_ORDER	G_BIG_ENDIAN
#endif
#define G_CONVERT_ERROR	g_convert_error_quark()
#define g_date_day	g_date_get_day
#define g_date_days_in_month	g_date_get_days_in_month
#define g_date_day_of_year	g_date_get_day_of_year
#define g_date_julian	g_date_get_julian
#define g_date_monday_weeks_in_year	g_date_get_monday_weeks_in_year
#define g_date_monday_week_of_year	g_date_get_monday_week_of_year
#define g_date_month	g_date_get_month
#define g_date_sunday_weeks_in_year	g_date_get_sunday_weeks_in_year
#define g_date_sunday_week_of_year	g_date_get_sunday_week_of_year
#define g_date_weekday	g_date_get_weekday
#define g_date_year	g_date_get_year
#define G_FILE_ERROR	g_file_error_quark ()
#define G_MAXINT64	G_GINT64_CONSTANT(0x7fffffffffffffff)
#define G_MININT64	G_GINT64_CONSTANT(0x8000000000000000)
#define G_MAXUINT64	G_GINT64_CONSTANT(0xffffffffffffffffU)
#define G_IO_CHANNEL_ERROR	g_io_channel_error_quark()
#define G_KEY_FILE_ERROR	g_key_file_error_quark()
#if __i386__
#define G_BYTE_ORDER	G_LITTLE_ENDIAN
#endif
#if __ia64__
#define G_BYTE_ORDER	G_LITTLE_ENDIAN
#endif
#if __x86_64__
#define G_BYTE_ORDER	G_LITTLE_ENDIAN
#endif
#define g_debug(...)	g_log (G_LOG_DOMAIN, G_LOG_LEVEL_DEBUG, __VA_ARGS__)
#define g_error(...)	g_log (G_LOG_DOMAIN, G_LOG_LEVEL_ERROR, __VA_ARGS__)
#define G_MARKUP_ERROR	g_markup_error_quark ()
#if __i386__
#define G_MAXSIZE	G_MAXUINT
#endif
#if __powerpc__ && !__powerpc64__
#define G_MAXSIZE	G_MAXUINT
#endif
#if __s390__ && !__s390x__
#define G_MAXSIZE	G_MAXUINT
#endif
#if __ia64__
#define G_MAXSIZE	G_MAXULONG
#endif
#if __powerpc64__
#define G_MAXSIZE	G_MAXULONG
#endif
#if __x86_64__
#define G_MAXSIZE	G_MAXULONG
#endif
#if __s390x__
#define G_MAXSIZE	G_MAXULONG
#endif
#define G_SHELL_ERROR	g_shell_error_quark ()
#define G_SPAWN_ERROR	g_spawn_error_quark ()
#define G_LOCK(name)	g_static_mutex_lock (&G_LOCK_NAME (name))
#define G_TRYLOCK(name)	g_static_mutex_trylock (&G_LOCK_NAME (name))
#define G_UNLOCK(name)	g_static_mutex_unlock (&G_LOCK_NAME (name))
#define g_strstrip(string)	g_strchomp (g_strchug (string))
#define G_STRINGIFY(macro_or_string)	G_STRINGIFY_ARG (macro_or_string)
#define g_cond_free(cond)	G_THREAD_CF (cond_free, (void)0, (cond))
#define g_cond_signal(cond)	G_THREAD_CF (cond_signal, (void)0, (cond))
#define g_mutex_free(mutex)	G_THREAD_CF (mutex_free, (void)0, (mutex))
#define g_mutex_lock(mutex)	G_THREAD_CF (mutex_lock, (void)0, (mutex))
#define g_mutex_trylock(mutex)	G_THREAD_CF (mutex_trylock, TRUE, (mutex))
#define g_mutex_unlock(mutex)	G_THREAD_CF (mutex_unlock, (void)0, (mutex))
#define g_thread_yield()	G_THREAD_CF (thread_yield, (void)0, ())
#define G_THREAD_ERROR	g_thread_error_quark ()
#define g_cond_new()	G_THREAD_UF (cond_new, ())
#define g_mutex_new()	G_THREAD_UF (mutex_new, ())
#define g_private_new(destructor)	G_THREAD_UF (private_new, (destructor))
#define G_LOCK_NAME(name)	g__ ## name ## _lock
#define G_GINT16_MODIFIER	"h"
#define G_GINT16_FORMAT	"hi"
#define G_GUINT16_FORMAT	"hu"
#define G_GINT32_FORMAT	"i"
#if __i386__
#define G_GSSIZE_FORMAT	"i"
#endif
#if __powerpc__ && !__powerpc64__
#define G_GSSIZE_FORMAT	"i"
#endif
#if __s390__ && !__s390x__
#define G_GSSIZE_FORMAT	"i"
#endif
#define G_MAXINT	INT_MAX
#define G_MININT	INT_MIN
#if __ia64__
#define G_GINT64_MODIFIER	"l"
#endif
#if __powerpc64__
#define G_GINT64_MODIFIER	"l"
#endif
#if __x86_64__
#define G_GINT64_MODIFIER	"l"
#endif
#if __s390x__
#define G_GINT64_MODIFIER	"l"
#endif
#if __ia64__
#define G_GSIZE_MODIFIER	"l"
#endif
#if __powerpc64__
#define G_GSIZE_MODIFIER	"l"
#endif
#if __x86_64__
#define G_GSIZE_MODIFIER	"l"
#endif
#if __s390x__
#define G_GSIZE_MODIFIER	"l"
#endif
#if __ia64__
#define G_GINT64_FORMAT	"li"
#endif
#if __powerpc64__
#define G_GINT64_FORMAT	"li"
#endif
#if __x86_64__
#define G_GINT64_FORMAT	"li"
#endif
#if __s390x__
#define G_GINT64_FORMAT	"li"
#endif
#if __ia64__
#define G_GSSIZE_FORMAT	"li"
#endif
#if __powerpc64__
#define G_GSSIZE_FORMAT	"li"
#endif
#if __x86_64__
#define G_GSSIZE_FORMAT	"li"
#endif
#if __s390x__
#define G_GSSIZE_FORMAT	"li"
#endif
#if __i386__
#define G_GINT64_MODIFIER	"ll"
#endif
#if __powerpc__ && !__powerpc64__
#define G_GINT64_MODIFIER	"ll"
#endif
#if __s390__ && !__s390x__
#define G_GINT64_MODIFIER	"ll"
#endif
#if __i386__
#define G_GINT64_FORMAT	"lli"
#endif
#if __powerpc__ && !__powerpc64__
#define G_GINT64_FORMAT	"lli"
#endif
#if __s390__ && !__s390x__
#define G_GINT64_FORMAT	"lli"
#endif
#if __i386__
#define G_GUINT64_FORMAT	"llu"
#endif
#if __powerpc__ && !__powerpc64__
#define G_GUINT64_FORMAT	"llu"
#endif
#if __s390__ && !__s390x__
#define G_GUINT64_FORMAT	"llu"
#endif
#define G_MAXLONG	LONG_MAX
#define G_MINLONG	LONG_MIN
#if __ia64__
#define G_GSIZE_FORMAT	"lu"
#endif
#if __powerpc64__
#define G_GSIZE_FORMAT	"lu"
#endif
#if __x86_64__
#define G_GSIZE_FORMAT	"lu"
#endif
#if __s390x__
#define G_GSIZE_FORMAT	"lu"
#endif
#if __ia64__
#define G_GUINT64_FORMAT	"lu"
#endif
#if __powerpc64__
#define G_GUINT64_FORMAT	"lu"
#endif
#if __x86_64__
#define G_GUINT64_FORMAT	"lu"
#endif
#if __s390x__
#define G_GUINT64_FORMAT	"lu"
#endif
#define G_MAXSHORT	SHRT_MAX
#define G_MINSHORT	SHRT_MIN
#define G_MODULE_SUFFIX	"so"
#define G_LOCK_DEFINE_STATIC(name)	static G_LOCK_DEFINE (name)
#if __i386__
#define G_GSIZE_FORMAT	"u"
#endif
#if __powerpc__ && !__powerpc64__
#define G_GSIZE_FORMAT	"u"
#endif
#if __s390__ && !__s390x__
#define G_GSIZE_FORMAT	"u"
#endif
#define G_GUINT32_FORMAT	"u"
#define G_MAXUINT	UINT_MAX
#define G_MAXULONG	ULONG_MAX
#define G_MAXUSHORT	USHRT_MAX
#define G_VA_COPY	va_copy
#define G_STR_DELIMITERS	"_-|> <."
#define G_GNUC_INTERNAL	__attribute__((visibility("hidden")))
#define G_GNUC_CONST	__attribute__((__const__))
#define G_GNUC_DEPRECATED	__attribute__((__deprecated__))
#define G_GNUC_FORMAT(arg_idx)	__attribute__((__format_arg__ (arg_idx)))
#define G_GNUC_MALLOC	__attribute__((__malloc__))
#define G_GNUC_NORETURN	__attribute__((__noreturn__))
#define G_GNUC_NO_INSTRUMENT	__attribute__((__no_instrument_function__))
#define G_GNUC_PURE	__attribute__((__pure__))
#define G_GNUC_UNUSED	__attribute__((__unused__))
#define alloca(size)	__builtin_alloca (size)
#define G_GNUC_EXTENSION	__extension__
#define G_STRLOC	__FILE__ ":" G_STRINGIFY (__LINE__)
#define G_STATIC_PRIVATE_INIT	{ 0 }
#define G_ONCE_INIT	{ G_ONCE_STATUS_NOTCALLED, NULL }
#define G_STATIC_REC_MUTEX_INIT	{ G_STATIC_MUTEX_INIT }



/* Arch Specific HeaderGroup for glib-2.0/glib.h*/


#if __i386__
/* IA32 */
    typedef int gssize;

#endif
#if __i386__
/* IA32 */
    typedef long long int gint64;

#endif
#if __i386__
/* IA32 */
    typedef long long unsigned int guint64;

#endif
#if __ia64__
/* IA64 */
    typedef long int gint64;

#endif
#if __powerpc__ && !__powerpc64__
/* PPC32 */
    typedef long long int gint64;

#endif
#if __powerpc64__
/* PPC64 */
    typedef long int gint64;

#endif
#if __s390__ && !__s390x__
/* S390 */
    typedef long long int gint64;

#endif
#if __x86_64__
/* x86-64 */
    typedef long int gint64;

#endif
#if __s390x__
/* S390X */
    typedef long int gint64;

#endif
#if __ia64__
/* IA64 */
    typedef unsigned long int guint64;

#endif
#if __powerpc__ && !__powerpc64__
/* PPC32 */
    typedef long long unsigned int guint64;

#endif
#if __powerpc64__
/* PPC64 */
    typedef unsigned long int guint64;

#endif
#if __s390__ && !__s390x__
/* S390 */
    typedef long long unsigned int guint64;

#endif
#if __x86_64__
/* x86-64 */
    typedef unsigned long int guint64;

#endif
#if __s390x__
/* S390X */
    typedef unsigned long int guint64;

#endif
#if __ia64__
/* IA64 */
    typedef long int gssize;

#endif
#if __powerpc__ && !__powerpc64__
/* PPC32 */
    typedef int gssize;

#endif
#if __powerpc64__
/* PPC64 */
    typedef long int gssize;

#endif
#if __s390__ && !__s390x__
/* S390 */
    typedef int gssize;

#endif
#if __x86_64__
/* x86-64 */
    typedef long int gssize;

#endif
#if __s390x__
/* S390X */
    typedef long int gssize;

#endif
#if __ia64__
/* IA64 */
    typedef unsigned long int gsize;

#endif
#if __powerpc__ && !__powerpc64__
/* PPC32 */
    typedef unsigned int gsize;

#endif
#if __powerpc64__
/* PPC64 */
    typedef unsigned long int gsize;

#endif
#if __s390__ && !__s390x__
/* S390 */
    typedef unsigned int gsize;

#endif
#if __x86_64__
/* x86-64 */
    typedef unsigned long int gsize;

#endif
#if __s390x__
/* S390X */
    typedef unsigned long int gsize;

#endif

/* Default HeaderGroup for glib-2.0/glib.h*/


    typedef short unsigned int guint16;

    typedef int gint;

    typedef gint gboolean;

    typedef unsigned int guint;

    typedef void *gpointer;

    typedef gpointer(*GThreadFunc) (gpointer);

    typedef enum {
	G_THREAD_PRIORITY_LOW = 0,
	G_THREAD_PRIORITY_NORMAL = 1,
	G_THREAD_PRIORITY_HIGH = 2,
	G_THREAD_PRIORITY_URGENT = 3
    } GThreadPriority;

    typedef struct _GThread GThread;

    typedef unsigned int guint32;

    typedef guint32 GQuark;

    typedef char gchar;

    typedef struct _GError GError;

    typedef void (*GPrintFunc) (const gchar *);

    typedef struct _GMemChunk GMemChunk;

    typedef long unsigned int gulong;

    typedef struct _GList GList;

    typedef struct _GMainLoop GMainLoop;

    typedef struct _GHook GHook;

    typedef void (*GDestroyNotify) (gpointer);

    typedef struct _GHookList GHookList;

    typedef void (*GHookFinalizeFunc) (GHookList *, GHook *);

    typedef struct _GQueue GQueue;

    typedef struct _GSList GSList;

#if __i386__
/* IA32 */
    typedef unsigned int gsize;

#endif
    typedef struct _GString GString;

    typedef struct _GPtrArray GPtrArray;

    typedef struct _GRand GRand;

    typedef struct _GDir GDir;

    typedef struct _GRelation GRelation;

    typedef struct _GOptionContext GOptionContext;

    typedef struct _GKeyFile GKeyFile;

    typedef struct _GPatternSpec GPatternSpec;

    typedef guint32 gunichar;

    typedef gchar *(*GCompletionFunc) (gpointer);

    typedef gint(*GCompletionStrncmpFunc) (const gchar *, const gchar *,
					   gsize);

    typedef struct _GCompletion GCompletion;

    typedef struct _GTimer GTimer;

    typedef struct _GHashTable GHashTable;

    typedef const void *gconstpointer;

    typedef guint(*GHashFunc) (gconstpointer);

    typedef gboolean(*GEqualFunc) (gconstpointer, gconstpointer);

    typedef struct _GStaticMutex GStaticMutex;

    typedef union _GSystemThread GSystemThread;

    typedef struct _GStaticRecMutex GStaticRecMutex;

    typedef struct _GMarkupParseContext GMarkupParseContext;

    typedef struct _GData GData;

    typedef enum {
	G_IO_STATUS_ERROR = 0,
	G_IO_STATUS_NORMAL = 1,
	G_IO_STATUS_EOF = 2,
	G_IO_STATUS_AGAIN = 3
    } GIOStatus;

    typedef struct _GIOChannel GIOChannel;

    typedef enum {
	G_SEEK_CUR = 0,
	G_SEEK_SET = 1,
	G_SEEK_END = 2
    } GSeekType;

    typedef struct _GSource GSource;

    typedef gboolean(*GSourceFunc) (gpointer);

    typedef struct _GSourceCallbackFuncs GSourceCallbackFuncs;

    typedef void (*GSourceDummyMarshal) (void);

    typedef struct _GSourceFuncs GSourceFuncs;

    typedef struct _GMainContext GMainContext;

    typedef enum {
	G_IO_IN = 1,
	G_IO_OUT = 4,
	G_IO_PRI = 2,
	G_IO_ERR = 8,
	G_IO_HUP = 16,
	G_IO_NVAL = 32
    } GIOCondition;

    typedef enum {
	G_IO_FLAG_APPEND = 1,
	G_IO_FLAG_NONBLOCK = 2,
	G_IO_FLAG_IS_READABLE = 4,
	G_IO_FLAG_IS_WRITEABLE = 8,
	G_IO_FLAG_IS_SEEKABLE = 16,
	G_IO_FLAG_MASK = 31,
	G_IO_FLAG_GET_MASK = 31,
	G_IO_FLAG_SET_MASK = 3
    } GIOFlags;

    typedef struct _GIOFuncs GIOFuncs;

    typedef struct _GIConv *GIConv;

    typedef struct _GOptionGroup GOptionGroup;

    typedef enum {
	G_SPAWN_LEAVE_DESCRIPTORS_OPEN = 1,
	G_SPAWN_DO_NOT_REAP_CHILD = 2,
	G_SPAWN_SEARCH_PATH = 4,
	G_SPAWN_STDOUT_TO_DEV_NULL = 8,
	G_SPAWN_STDERR_TO_DEV_NULL = 16,
	G_SPAWN_CHILD_INHERITS_STDIN = 32,
	G_SPAWN_FILE_AND_ARGV_ZERO = 64
    } GSpawnFlags;

    typedef void (*GSpawnChildSetupFunc) (gpointer);

    typedef int GPid;

    typedef void (*GFunc) (gpointer, gpointer);

    typedef struct _GThreadPool GThreadPool;

    typedef struct _GDate GDate;

    typedef enum {
	G_DATE_BAD_MONTH = 0,
	G_DATE_JANUARY = 1,
	G_DATE_FEBRUARY = 2,
	G_DATE_MARCH = 3,
	G_DATE_APRIL = 4,
	G_DATE_MAY = 5,
	G_DATE_JUNE = 6,
	G_DATE_JULY = 7,
	G_DATE_AUGUST = 8,
	G_DATE_SEPTEMBER = 9,
	G_DATE_OCTOBER = 10,
	G_DATE_NOVEMBER = 11,
	G_DATE_DECEMBER = 12
    } GDateMonth;

    typedef struct _GAsyncQueue GAsyncQueue;

    typedef short unsigned int gushort;

    typedef struct _GPollFD GPollFD;

    typedef double gdouble;

    typedef struct _GTree GTree;

    typedef gint(*GCompareDataFunc) (gconstpointer, gconstpointer,
				     gpointer);

    typedef unsigned char guint8;

    typedef guint16 GDateYear;

    typedef struct _GCache GCache;

    typedef void (*GHFunc) (gpointer, gpointer, gpointer);

    typedef struct _GScannerConfig GScannerConfig;

    typedef enum {
	G_TOKEN_EOF = 0,
	G_TOKEN_LEFT_PAREN = 40,
	G_TOKEN_RIGHT_PAREN = 41,
	G_TOKEN_LEFT_CURLY = 123,
	G_TOKEN_RIGHT_CURLY = 125,
	G_TOKEN_LEFT_BRACE = 91,
	G_TOKEN_RIGHT_BRACE = 93,
	G_TOKEN_EQUAL_SIGN = 61,
	G_TOKEN_COMMA = 44,
	G_TOKEN_NONE = 256,
	G_TOKEN_ERROR = 257,
	G_TOKEN_CHAR = 258,
	G_TOKEN_BINARY = 259,
	G_TOKEN_OCTAL = 260,
	G_TOKEN_INT = 261,
	G_TOKEN_HEX = 262,
	G_TOKEN_FLOAT = 263,
	G_TOKEN_STRING = 264,
	G_TOKEN_SYMBOL = 265,
	G_TOKEN_IDENTIFIER = 266,
	G_TOKEN_IDENTIFIER_NULL = 267,
	G_TOKEN_COMMENT_SINGLE = 268,
	G_TOKEN_COMMENT_MULTI = 269,
	G_TOKEN_LAST = 270
    } GTokenType;

    typedef unsigned char guchar;

    typedef union _GTokenValue GTokenValue;

    typedef struct _GScanner GScanner;

    typedef void (*GScannerMsgFunc) (GScanner *, gchar *, gboolean);

    typedef struct _GByteArray GByteArray;

    typedef enum {
	G_KEY_FILE_NONE = 0,
	G_KEY_FILE_KEEP_COMMENTS = 1,
	G_KEY_FILE_KEEP_TRANSLATIONS = 2
    } GKeyFileFlags;

    typedef struct _GTrashStack GTrashStack;

    typedef guint16 gunichar2;

    typedef long int glong;

    typedef struct _GArray GArray;

    typedef struct _GNode GNode;

    typedef gboolean(*GHRFunc) (gpointer, gpointer, gpointer);

    typedef gint(*GCompareFunc) (gconstpointer, gconstpointer);

    typedef int gint32;

    typedef gint32 GTime;

    typedef gint(*GPollFunc) (GPollFD *, guint, gint);

    typedef guint8 GDateDay;

    typedef enum {
	G_UNICODE_BREAK_MANDATORY = 0,
	G_UNICODE_BREAK_CARRIAGE_RETURN = 1,
	G_UNICODE_BREAK_LINE_FEED = 2,
	G_UNICODE_BREAK_COMBINING_MARK = 3,
	G_UNICODE_BREAK_SURROGATE = 4,
	G_UNICODE_BREAK_ZERO_WIDTH_SPACE = 5,
	G_UNICODE_BREAK_INSEPARABLE = 6,
	G_UNICODE_BREAK_NON_BREAKING_GLUE = 7,
	G_UNICODE_BREAK_CONTINGENT = 8,
	G_UNICODE_BREAK_SPACE = 9,
	G_UNICODE_BREAK_AFTER = 10,
	G_UNICODE_BREAK_BEFORE = 11,
	G_UNICODE_BREAK_BEFORE_AND_AFTER = 12,
	G_UNICODE_BREAK_HYPHEN = 13,
	G_UNICODE_BREAK_NON_STARTER = 14,
	G_UNICODE_BREAK_OPEN_PUNCTUATION = 15,
	G_UNICODE_BREAK_CLOSE_PUNCTUATION = 16,
	G_UNICODE_BREAK_QUOTATION = 17,
	G_UNICODE_BREAK_EXCLAMATION = 18,
	G_UNICODE_BREAK_IDEOGRAPHIC = 19,
	G_UNICODE_BREAK_NUMERIC = 20,
	G_UNICODE_BREAK_INFIX_SEPARATOR = 21,
	G_UNICODE_BREAK_SYMBOL = 22,
	G_UNICODE_BREAK_ALPHABETIC = 23,
	G_UNICODE_BREAK_PREFIX = 24,
	G_UNICODE_BREAK_POSTFIX = 25,
	G_UNICODE_BREAK_COMPLEX_CONTEXT = 26,
	G_UNICODE_BREAK_AMBIGUOUS = 27,
	G_UNICODE_BREAK_UNKNOWN = 28,
	G_UNICODE_BREAK_NEXT_LINE = 29,
	G_UNICODE_BREAK_WORD_JOINER = 30
    } GUnicodeBreakType;

    typedef struct _GStringChunk GStringChunk;

    typedef struct _GCond GCond;

    typedef struct _GStaticRWLock GStaticRWLock;

    typedef void (*GChildWatchFunc) (GPid, gint, gpointer);

    typedef struct _GTimeVal GTimeVal;

    typedef enum {
	G_LOG_FLAG_RECURSION = 1,
	G_LOG_FLAG_FATAL = 2,
	G_LOG_LEVEL_ERROR = 4,
	G_LOG_LEVEL_CRITICAL = 8,
	G_LOG_LEVEL_WARNING = 16,
	G_LOG_LEVEL_MESSAGE = 32,
	G_LOG_LEVEL_INFO = 64,
	G_LOG_LEVEL_DEBUG = 128,
	G_LOG_LEVEL_MASK = -4
    } GLogLevelFlags;

    typedef enum {
	G_DATE_BAD_WEEKDAY = 0,
	G_DATE_MONDAY = 1,
	G_DATE_TUESDAY = 2,
	G_DATE_WEDNESDAY = 3,
	G_DATE_THURSDAY = 4,
	G_DATE_FRIDAY = 5,
	G_DATE_SATURDAY = 6,
	G_DATE_SUNDAY = 7
    } GDateWeekday;

    typedef enum {
	G_IN_ORDER = 0,
	G_PRE_ORDER = 1,
	G_POST_ORDER = 2,
	G_LEVEL_ORDER = 3
    } GTraverseType;

    typedef enum {
	G_TRAVERSE_LEAVES = 1,
	G_TRAVERSE_NON_LEAVES = 2,
	G_TRAVERSE_ALL = 3,
	G_TRAVERSE_MASK = 3,
	G_TRAVERSE_LEAFS = 1,
	G_TRAVERSE_NON_LEAFS = 2
    } GTraverseFlags;

    typedef struct _GMarkupParser GMarkupParser;

    typedef enum {
	G_MARKUP_DO_NOT_USE_THIS_UNSUPPORTED_FLAG = 1
    } GMarkupParseFlags;

    typedef gboolean(*GHookCheckMarshaller) (GHook *, gpointer);

    typedef gboolean(*GNodeTraverseFunc) (GNode *, gpointer);

    typedef enum {
	G_NORMALIZE_DEFAULT = 0,
	G_NORMALIZE_NFD = 0,
	G_NORMALIZE_DEFAULT_COMPOSE = 1,
	G_NORMALIZE_NFC = 1,
	G_NORMALIZE_ALL = 2,
	G_NORMALIZE_NFKD = 2,
	G_NORMALIZE_ALL_COMPOSE = 3,
	G_NORMALIZE_NFKC = 3
    } GNormalizeMode;

    typedef struct _GMutex GMutex;

    typedef struct _GStaticPrivate GStaticPrivate;

    typedef enum {
	G_FILE_ERROR_EXIST = 0,
	G_FILE_ERROR_ISDIR = 1,
	G_FILE_ERROR_ACCES = 2,
	G_FILE_ERROR_NAMETOOLONG = 3,
	G_FILE_ERROR_NOENT = 4,
	G_FILE_ERROR_NOTDIR = 5,
	G_FILE_ERROR_NXIO = 6,
	G_FILE_ERROR_NODEV = 7,
	G_FILE_ERROR_ROFS = 8,
	G_FILE_ERROR_TXTBSY = 9,
	G_FILE_ERROR_FAULT = 10,
	G_FILE_ERROR_LOOP = 11,
	G_FILE_ERROR_NOSPC = 12,
	G_FILE_ERROR_NOMEM = 13,
	G_FILE_ERROR_MFILE = 14,
	G_FILE_ERROR_NFILE = 15,
	G_FILE_ERROR_BADF = 16,
	G_FILE_ERROR_INVAL = 17,
	G_FILE_ERROR_PIPE = 18,
	G_FILE_ERROR_AGAIN = 19,
	G_FILE_ERROR_INTR = 20,
	G_FILE_ERROR_IO = 21,
	G_FILE_ERROR_PERM = 22,
	G_FILE_ERROR_NOSYS = 23,
	G_FILE_ERROR_FAILED = 24
    } GFileError;

    typedef void (*GDataForeachFunc) (GQuark, gpointer, gpointer);

    typedef struct _GMemVTable GMemVTable;

    typedef enum {
	G_OPTION_ARG_NONE = 0,
	G_OPTION_ARG_STRING = 1,
	G_OPTION_ARG_INT = 2,
	G_OPTION_ARG_CALLBACK = 3,
	G_OPTION_ARG_FILENAME = 4,
	G_OPTION_ARG_STRING_ARRAY = 5,
	G_OPTION_ARG_FILENAME_ARRAY = 6
    } GOptionArg;

    typedef struct _GOptionEntry GOptionEntry;

    typedef enum {
	G_UNICODE_CONTROL = 0,
	G_UNICODE_FORMAT = 1,
	G_UNICODE_UNASSIGNED = 2,
	G_UNICODE_PRIVATE_USE = 3,
	G_UNICODE_SURROGATE = 4,
	G_UNICODE_LOWERCASE_LETTER = 5,
	G_UNICODE_MODIFIER_LETTER = 6,
	G_UNICODE_OTHER_LETTER = 7,
	G_UNICODE_TITLECASE_LETTER = 8,
	G_UNICODE_UPPERCASE_LETTER = 9,
	G_UNICODE_COMBINING_MARK = 10,
	G_UNICODE_ENCLOSING_MARK = 11,
	G_UNICODE_NON_SPACING_MARK = 12,
	G_UNICODE_DECIMAL_NUMBER = 13,
	G_UNICODE_LETTER_NUMBER = 14,
	G_UNICODE_OTHER_NUMBER = 15,
	G_UNICODE_CONNECT_PUNCTUATION = 16,
	G_UNICODE_DASH_PUNCTUATION = 17,
	G_UNICODE_CLOSE_PUNCTUATION = 18,
	G_UNICODE_FINAL_PUNCTUATION = 19,
	G_UNICODE_INITIAL_PUNCTUATION = 20,
	G_UNICODE_OTHER_PUNCTUATION = 21,
	G_UNICODE_OPEN_PUNCTUATION = 22,
	G_UNICODE_CURRENCY_SYMBOL = 23,
	G_UNICODE_MODIFIER_SYMBOL = 24,
	G_UNICODE_MATH_SYMBOL = 25,
	G_UNICODE_OTHER_SYMBOL = 26,
	G_UNICODE_LINE_SEPARATOR = 27,
	G_UNICODE_PARAGRAPH_SEPARATOR = 28,
	G_UNICODE_SPACE_SEPARATOR = 29
    } GUnicodeType;

    typedef void (*GLogFunc) (const gchar *, GLogLevelFlags, const gchar *,
			      gpointer);

    typedef struct _GAllocator GAllocator;

    typedef const gchar *(*GTranslateFunc) (const gchar *, gpointer);

    typedef gboolean(*GOptionParseFunc) (GOptionContext *, GOptionGroup *,
					 gpointer, GError * *);

    typedef void (*GVoidFunc) (void);

    typedef gboolean(*GHookFindFunc) (GHook *, gpointer);

    typedef struct _GTuples GTuples;

    typedef gpointer(*GCopyFunc) (gconstpointer, gpointer);

    typedef void (*GOptionErrorFunc) (GOptionContext *, GOptionGroup *,
				      gpointer, GError * *);

    typedef gpointer(*GCacheNewFunc) (gpointer);

    typedef void (*GCacheDestroyFunc) (gpointer);

    typedef gpointer(*GCacheDupFunc) (gpointer);

    typedef enum {
	G_FILE_TEST_IS_REGULAR = 1,
	G_FILE_TEST_IS_SYMLINK = 2,
	G_FILE_TEST_IS_DIR = 4,
	G_FILE_TEST_IS_EXECUTABLE = 8,
	G_FILE_TEST_EXISTS = 16
    } GFileTest;

    typedef enum {
	G_ONCE_STATUS_NOTCALLED = 0,
	G_ONCE_STATUS_PROGRESS = 1,
	G_ONCE_STATUS_READY = 2
    } GOnceStatus;

    typedef struct _GOnce GOnce;

    typedef gboolean(*GTraverseFunc) (gpointer, gpointer, gpointer);

    typedef gint(*GHookCompareFunc) (GHook *, GHook *);

    typedef void (*GNodeForeachFunc) (GNode *, gpointer);

    typedef struct _GDebugKey GDebugKey;

    typedef struct _GPrivate GPrivate;

    typedef struct _GThreadFunctions GThreadFunctions;

    typedef void (*GHookMarshaller) (GHook *, gpointer);

    typedef enum {
	G_IO_CHANNEL_ERROR_FBIG = 0,
	G_IO_CHANNEL_ERROR_INVAL = 1,
	G_IO_CHANNEL_ERROR_IO = 2,
	G_IO_CHANNEL_ERROR_ISDIR = 3,
	G_IO_CHANNEL_ERROR_NOSPC = 4,
	G_IO_CHANNEL_ERROR_NXIO = 5,
	G_IO_CHANNEL_ERROR_OVERFLOW = 6,
	G_IO_CHANNEL_ERROR_PIPE = 7,
	G_IO_CHANNEL_ERROR_FAILED = 8
    } GIOChannelError;

    typedef gboolean(*GIOFunc) (GIOChannel *, GIOCondition, gpointer);

    typedef void (*GFreeFunc) (gpointer);

    typedef gboolean(*GHookCheckFunc) (gpointer);

    typedef void (*GHookFunc) (gpointer);

    typedef short int gint16;

    typedef enum {
	G_DATE_DAY = 0,
	G_DATE_MONTH = 1,
	G_DATE_YEAR = 2
    } GDateDMY;

    typedef signed char gint8;

    typedef enum {
	G_MARKUP_ERROR_BAD_UTF8 = 0,
	G_MARKUP_ERROR_EMPTY = 1,
	G_MARKUP_ERROR_PARSE = 2,
	G_MARKUP_ERROR_UNKNOWN_ELEMENT = 3,
	G_MARKUP_ERROR_UNKNOWN_ATTRIBUTE = 4,
	G_MARKUP_ERROR_INVALID_CONTENT = 5
    } GMarkupError;

    typedef enum {
	G_IO_ERROR_NONE = 0,
	G_IO_ERROR_AGAIN = 1,
	G_IO_ERROR_INVAL = 2,
	G_IO_ERROR_UNKNOWN = 3
    } GIOError;

    typedef gboolean(*GOptionArgFunc) (const gchar *, const gchar *,
				       gpointer, GError * *);

    typedef enum {
	G_OPTION_FLAG_HIDDEN = 1 << 0,
	G_OPTION_FLAG_IN_MAIN = 1 << 1,
	G_OPTION_FLAG_REVERSE = 1 << 2
    } GOptionFlags;

    typedef enum {
	G_CONVERT_ERROR_NO_CONVERSION,
	G_CONVERT_ERROR_ILLEGAL_SEQUENCE,
	G_CONVERT_ERROR_FAILED,
	G_CONVERT_ERROR_PARTIAL_INPUT,
	G_CONVERT_ERROR_BAD_URI,
	G_CONVERT_ERROR_NOT_ABSOLUTE_PATH
    } GConvertError;

    typedef enum {
	G_ERR_UNKNOWN,
	G_ERR_UNEXP_EOF,
	G_ERR_UNEXP_EOF_IN_STRING,
	G_ERR_UNEXP_EOF_IN_COMMENT,
	G_ERR_NON_DIGIT_IN_CONST,
	G_ERR_DIGIT_RADIX,
	G_ERR_FLOAT_RADIX,
	G_ERR_FLOAT_MALFORMED
    } GErrorType;

    typedef enum {
	G_KEY_FILE_ERROR_UNKNOWN_ENCODING,
	G_KEY_FILE_ERROR_PARSE,
	G_KEY_FILE_ERROR_NOT_FOUND,
	G_KEY_FILE_ERROR_KEY_NOT_FOUND,
	G_KEY_FILE_ERROR_GROUP_NOT_FOUND,
	G_KEY_FILE_ERROR_INVALID_VALUE
    } GKeyFileError;

    typedef enum {
	G_SPAWN_ERROR_FORK,
	G_SPAWN_ERROR_READ,
	G_SPAWN_ERROR_CHDIR,
	G_SPAWN_ERROR_ACCES,
	G_SPAWN_ERROR_PERM,
	G_SPAWN_ERROR_2BIG,
	G_SPAWN_ERROR_NOEXEC,
	G_SPAWN_ERROR_NAMETOOLONG,
	G_SPAWN_ERROR_NOENT,
	G_SPAWN_ERROR_NOMEM,
	G_SPAWN_ERROR_NOTDIR,
	G_SPAWN_ERROR_LOOP,
	G_SPAWN_ERROR_TXTBUSY,
	G_SPAWN_ERROR_IO,
	G_SPAWN_ERROR_NFILE,
	G_SPAWN_ERROR_MFILE,
	G_SPAWN_ERROR_INVAL,
	G_SPAWN_ERROR_ISDIR,
	G_SPAWN_ERROR_LIBBAD,
	G_SPAWN_ERROR_FAILED
    } GSpawnError;

    typedef enum {
	G_HOOK_FLAG_ACTIVE = 1 << 0,
	G_HOOK_FLAG_IN_CALL = 1 << 1,
	G_HOOK_FLAG_MASK = 0x0f
    } GHookFlagMask;

    typedef enum {
	G_THREAD_ERROR_AGAIN
    } GThreadError;

    typedef enum {
	G_OPTION_ERROR_UNKNOWN_OPTION,
	G_OPTION_ERROR_BAD_VALUE,
	G_OPTION_ERROR_FAILED
    } GOptionError;

    typedef enum {
	G_ASCII_ALNUM = 1 << 0,
	G_ASCII_ALPHA = 1 << 1,
	G_ASCII_CNTRL = 1 << 2,
	G_ASCII_DIGIT = 1 << 3,
	G_ASCII_GRAPH = 1 << 4,
	G_ASCII_LOWER = 1 << 5,
	G_ASCII_PRINT = 1 << 6,
	G_ASCII_PUNCT = 1 << 7,
	G_ASCII_SPACE = 1 << 8,
	G_ASCII_UPPER = 1 << 9,
	G_ASCII_XDIGIT = 1 << 10
    } GAsciiType;

    typedef enum {
	G_SHELL_ERROR_BAD_QUOTING,
	G_SHELL_ERROR_EMPTY_STRING,
	G_SHELL_ERROR_FAILED
    } GShellError;


    struct _GThread {
	GThreadFunc func;
	gpointer data;
	gboolean joinable;
	GThreadPriority priority;
    };


    struct _GError {
	GQuark domain;
	gint code;
	gchar *message;
    };





    struct _GList {
	gpointer data;
	GList *next;
	GList *prev;
    };





    struct _GHook {
	gpointer data;
	GHook *next;
	GHook *prev;
	guint ref_count;
	gulong hook_id;
	guint flags;
	gpointer func;
	GDestroyNotify destroy;
    };


    struct _GHookList {
	gulong seq_id;
	guint hook_size:16;
	guint is_setup:1;
	GHook *hooks;
	GMemChunk *hook_memchunk;
	GHookFinalizeFunc finalize_hook;
	gpointer dummy[2];
    };


    struct _GQueue {
	GList *head;
	GList *tail;
	guint length;
    };


    struct _GSList {
	gpointer data;
	GSList *next;
    };


    struct _GString {
	gchar *str;
	gsize len;
	gsize allocated_len;
    };


    struct _GPtrArray {
	gpointer *pdata;
	guint len;
    };




















    struct _GCompletion {
	GList *items;
	GCompletionFunc func;
	gchar *prefix;
	GList *cache;
	GCompletionStrncmpFunc strncmp_func;
    };








    struct _GStaticMutex {
	struct _GMutex *runtime_mutex;
	union {
	    char pad[GLIB_LSB_PADDING_SIZE];
	    double dummy_double;
	    void *dummy_pointer;
	    long int dummy_long;
	} static_mutex;
    };

    union _GSystemThread {
	char data[GLIB_LSB_DATA_SIZE];
	double dummy_double;
	void *dummy_pointer;
	long int dummy_long;
    };


    struct _GStaticRecMutex {
	GStaticMutex mutex;
	guint depth;
	GSystemThread owner;
    };








    struct _GIOChannel {
	guint ref_count;
	GIOFuncs *funcs;
	gchar *encoding;
	GIConv read_cd;
	GIConv write_cd;
	gchar *line_term;
	guint line_term_len;
	gsize buf_size;
	GString *read_buf;
	GString *encoded_read_buf;
	GString *write_buf;
	gchar partial_write_buf[6];
	guint use_buffer:1;
	guint do_encode:1;
	guint close_on_unref:1;
	guint is_readable:1;
	guint is_writeable:1;
	guint is_seekable:1;
	gpointer reserved1;
	gpointer reserved2;
    };


    struct _GSource {
	gpointer callback_data;
	GSourceCallbackFuncs *callback_funcs;
	GSourceFuncs *source_funcs;
	guint ref_count;
	GMainContext *context;
	gint priority;
	guint flags;
	guint source_id;
	GSList *poll_fds;
	GSource *prev;
	GSource *next;
	gpointer reserved1;
	gpointer reserved2;
    };


    struct _GSourceCallbackFuncs {
	void (*ref) (gpointer);
	void (*unref) (gpointer);
	void (*get) (gpointer, GSource *, GSourceFunc *, gpointer *);
    };


    struct _GSourceFuncs {
	gboolean(*prepare) (GSource *, gint *);
	gboolean(*check) (GSource *);
	gboolean(*dispatch) (GSource *, GSourceFunc, gpointer);
	void (*finalize) (GSource *);
	GSourceFunc closure_callback;
	GSourceDummyMarshal closure_marshal;
    };





    struct _GIOFuncs {
	GIOStatus(*io_read) (GIOChannel *, gchar *, gsize, gsize *,
			     GError * *);
	GIOStatus(*io_write) (GIOChannel *, const gchar *, gsize, gsize *,
			      GError * *);
	GIOStatus(*io_seek) (GIOChannel *, gint64, GSeekType, GError * *);
	GIOStatus(*io_close) (GIOChannel *, GError * *);
	GSource *(*io_create_watch) (GIOChannel *, GIOCondition);
	void (*io_free) (GIOChannel *);
	 GIOStatus(*io_set_flags) (GIOChannel *, GIOFlags, GError * *);
	 GIOFlags(*io_get_flags) (GIOChannel *);
    };





    struct _GThreadPool {
	GFunc func;
	gpointer user_data;
	gboolean exclusive;
    };


    struct _GDate {
	guint julian_days:32;
	guint julian:1;
	guint dmy:1;
	guint day:6;
	guint month:4;
	guint year:16;
    };





    struct _GPollFD {
	gint fd;
	gushort events;
	gushort revents;
    };








    struct _GScannerConfig {
	gchar *cset_skip_characters;
	gchar *cset_identifier_first;
	gchar *cset_identifier_nth;
	gchar *cpair_comment_single;
	guint case_sensitive:1;
	guint skip_comment_multi:1;
	guint skip_comment_single:1;
	guint scan_comment_multi:1;
	guint scan_identifier:1;
	guint scan_identifier_1char:1;
	guint scan_identifier_NULL:1;
	guint scan_symbols:1;
	guint scan_binary:1;
	guint scan_octal:1;
	guint scan_float:1;
	guint scan_hex:1;
	guint scan_hex_dollar:1;
	guint scan_string_sq:1;
	guint scan_string_dq:1;
	guint numbers_2_int:1;
	guint int_2_float:1;
	guint identifier_2_string:1;
	guint char_2_token:1;
	guint symbol_2_token:1;
	guint scope_0_fallback:1;
	guint store_int64:1;
	guint padding_dummy;
    };

    union _GTokenValue {
	gpointer v_symbol;
	gchar *v_identifier;
	gulong v_binary;
	gulong v_octal;
	gulong v_int;
	guint64 v_int64;
	gdouble v_float;
	gulong v_hex;
	gchar *v_string;
	gchar *v_comment;
	guchar v_char;
	guint v_error;
    };


    struct _GScanner {
	gpointer user_data;
	guint max_parse_errors;
	guint parse_errors;
	const gchar *input_name;
	GData *qdata;
	GScannerConfig *config;
	GTokenType token;
	GTokenValue value;
	guint line;
	guint position;
	GTokenType next_token;
	GTokenValue next_value;
	guint next_line;
	guint next_position;
	GHashTable *symbol_table;
	gint input_fd;
	const gchar *text;
	const gchar *text_end;
	gchar *buffer;
	guint scope_id;
	GScannerMsgFunc msg_handler;
    };


    struct _GByteArray {
	guint8 *data;
	guint len;
    };


    struct _GTrashStack {
	GTrashStack *next;
    };


    struct _GArray {
	gchar *data;
	guint len;
    };


    struct _GNode {
	gpointer data;
	GNode *next;
	GNode *prev;
	GNode *parent;
	GNode *children;
    };








    struct _GStaticRWLock {
	GStaticMutex mutex;
	GCond *read_cond;
	GCond *write_cond;
	guint read_counter;
	gboolean have_writer;
	guint want_to_read;
	guint want_to_write;
    };


    struct _GTimeVal {
	glong tv_sec;
	glong tv_usec;
    };


    struct _GMarkupParser {
	void (*start_element) (GMarkupParseContext *, const gchar *,
			       const gchar * *, const gchar * *, gpointer,
			       GError * *);
	void (*end_element) (GMarkupParseContext *, const gchar *,
			     gpointer, GError * *);
	void (*text) (GMarkupParseContext *, const gchar *, gsize,
		      gpointer, GError * *);
	void (*passthrough) (GMarkupParseContext *, const gchar *, gsize,
			     gpointer, GError * *);
	void (*error) (GMarkupParseContext *, GError *, gpointer);
    };





    struct _GStaticPrivate {
	guint index;
    };


    struct _GMemVTable {
	gpointer(*malloc) (gsize);
	gpointer(*realloc) (gpointer, gsize);
	void (*free) (gpointer);
	 gpointer(*calloc) (gsize, gsize);
	 gpointer(*try_malloc) (gsize);
	 gpointer(*try_realloc) (gpointer, gsize);
    };


    struct _GOptionEntry {
	const gchar *long_name;
	gchar short_name;
	gint flags;
	GOptionArg arg;
	gpointer arg_data;
	const gchar *description;
	const gchar *arg_description;
    };





    struct _GTuples {
	guint len;
    };


    struct _GOnce {
	volatile GOnceStatus status;
	volatile gpointer retval;
    };


    struct _GDebugKey {
	gchar *key;
	guint value;
    };





    struct _GThreadFunctions {
	GMutex *(*mutex_new) (void);
	void (*mutex_lock) (GMutex *);
	 gboolean(*mutex_trylock) (GMutex *);
	void (*mutex_unlock) (GMutex *);
	void (*mutex_free) (GMutex *);
	GCond *(*cond_new) (void);
	void (*cond_signal) (GCond *);
	void (*cond_broadcast) (GCond *);
	void (*cond_wait) (GCond *, GMutex *);
	 gboolean(*cond_timed_wait) (GCond *, GMutex *, GTimeVal *);
	void (*cond_free) (GCond *);
	GPrivate *(*private_new) (GDestroyNotify);
	 gpointer(*private_get) (GPrivate *);
	void (*private_set) (GPrivate *, gpointer);
	void (*thread_create) (GThreadFunc, gpointer, gulong, gboolean,
			       gboolean, GThreadPriority, gpointer,
			       GError * *);
	void (*thread_yield) (void);
	void (*thread_join) (gpointer);
	void (*thread_exit) (void);
	void (*thread_set_priority) (gpointer, GThreadPriority);
	void (*thread_self) (gpointer);
	 gboolean(*thread_equal) (gpointer, gpointer);
    };


    extern const guint16 *const g_ascii_table;
    extern gboolean g_source_remove(guint);
    extern void g_thread_set_priority(GThread *, GThreadPriority);
    extern GError *g_error_copy(const GError *);
    extern gchar *g_utf8_prev_char(const gchar *);
    extern void g_node_pop_allocator(void);
    extern GPrintFunc g_set_printerr_handler(GPrintFunc);
    extern GMemChunk *g_mem_chunk_new(const gchar *, gint, gulong, gint);
    extern void g_on_error_stack_trace(const gchar *);
    extern void g_mem_chunk_print(GMemChunk *);
    extern guint g_list_length(GList *);
    extern void g_main_loop_quit(GMainLoop *);
    extern void g_hook_insert_before(GHookList *, GHook *, GHook *);
    extern gboolean g_get_filename_charsets(const gchar * **);
    extern GList *g_queue_pop_nth_link(GQueue *, guint);
    extern GSList *g_slist_copy(GSList *);
    extern gint g_mkstemp(gchar *);
    extern GError *g_error_new(GQuark, gint, const gchar *, ...);
    extern GString *g_string_set_size(GString *, gsize);
    extern gchar *g_get_prgname(void);
    extern gpointer g_ptr_array_remove_index_fast(GPtrArray *, guint);
    extern GRand *g_rand_new_with_seed_array(const guint32 *, guint);
    extern void g_dir_close(GDir *);
    extern const gchar *const *g_get_system_config_dirs(void);
    extern void g_relation_insert(GRelation *, ...);
    extern void g_option_context_free(GOptionContext *);
    extern gchar *g_strcanon(gchar *, const gchar *, gchar);
    extern guint g_slist_length(GSList *);
    extern gchar *g_key_file_to_data(GKeyFile *, gsize *, GError * *);
    extern GPatternSpec *g_pattern_spec_new(const gchar *);
    extern gchar **g_strdupv(gchar * *);
    extern gboolean g_unichar_isupper(gunichar);
    extern void g_completion_free(GCompletion *);
    extern void g_timer_reset(GTimer *);
    extern GHashTable *g_hash_table_new_full(GHashFunc, GEqualFunc,
					     GDestroyNotify,
					     GDestroyNotify);
    extern void g_static_rec_mutex_init(GStaticRecMutex *);
    extern gint g_atomic_int_exchange_and_add(gint *, gint);
    extern gchar *g_strjoin(const gchar *, ...);
    extern GSList *g_slist_last(GSList *);
    extern void g_key_file_set_string(GKeyFile *, const gchar *,
				      const gchar *, const gchar *);
    extern GPtrArray *g_ptr_array_new(void);
    extern gboolean g_markup_parse_context_end_parse(GMarkupParseContext *,
						     GError * *);
    extern gboolean g_key_file_get_boolean(GKeyFile *, const gchar *,
					   const gchar *, GError * *);
    extern gchar *g_strrstr_len(const gchar *, gssize, const gchar *);
    extern gint g_hook_compare_ids(GHook *, GHook *);
    extern gchar *g_utf8_strup(const gchar *, gssize);
    extern gchar *g_build_filename(const gchar *, ...);
    extern void g_datalist_init(GData * *);
    extern GIOStatus g_io_channel_set_flags(GIOChannel *, GIOFlags,
					    GError * *);
    extern const gchar *const g_utf8_skip;
    extern void g_option_group_free(GOptionGroup *);
    extern void g_completion_clear_items(GCompletion *);
    extern gboolean g_hash_table_steal(GHashTable *, gconstpointer);
    extern gboolean g_spawn_async_with_pipes(const gchar *, gchar * *,
					     gchar * *, GSpawnFlags,
					     GSpawnChildSetupFunc,
					     gpointer, GPid *, gint *,
					     gint *, gint *, GError * *);
    extern void g_clear_error(GError * *);
    extern gpointer g_queue_pop_head(GQueue *);
    extern GThreadPool *g_thread_pool_new(GFunc, gpointer, gint, gboolean,
					  GError * *);
    extern void g_static_rec_mutex_lock(GStaticRecMutex *);
    extern guint g_thread_pool_get_num_threads(GThreadPool *);
    extern void g_date_set_month(GDate *, GDateMonth);
    extern gchar *g_filename_to_uri(const gchar *, const gchar *,
				    GError * *);
    extern gboolean g_date_valid_julian(guint32);
    extern GQuark g_option_error_quark(void);
    extern gchar **g_key_file_get_keys(GKeyFile *, const gchar *, gsize *,
				       GError * *);
    extern gchar g_ascii_tolower(gchar);
    extern GMainLoop *g_main_loop_new(GMainContext *, gboolean);
    extern gint g_relation_count(GRelation *, gconstpointer, gint);
    extern void g_ptr_array_add(GPtrArray *, gpointer);
    extern void g_async_queue_unlock(GAsyncQueue *);
    extern gboolean g_pattern_match_string(GPatternSpec *, const gchar *);
    extern void g_key_file_free(GKeyFile *);
    extern GMainContext *g_main_context_default(void);
    extern GIOStatus g_io_channel_read_line_string(GIOChannel *, GString *,
						   gsize *, GError * *);
    extern GSource *g_source_ref(GSource *);
    extern gint g_slist_index(GSList *, gconstpointer);
    extern GSList *g_slist_find(GSList *, gconstpointer);
    extern gboolean g_main_context_prepare(GMainContext *, gint *);
    extern char *g_markup_vprintf_escaped(const char *, va_list);
    extern void g_ptr_array_set_size(GPtrArray *, gint);
    extern void g_set_application_name(const gchar *);
    extern gint g_main_context_query(GMainContext *, gint, gint *,
				     GPollFD *, gint);
    extern void g_rand_set_seed(GRand *, guint32);
    extern GList *g_list_last(GList *);
    extern gchar *g_ascii_dtostr(gchar *, gint, gdouble);
    extern gboolean g_main_loop_is_running(GMainLoop *);
    extern void g_pattern_spec_free(GPatternSpec *);
    extern GTree *g_tree_new_full(GCompareDataFunc, gpointer,
				  GDestroyNotify, GDestroyNotify);
    extern guint8 g_date_get_monday_weeks_in_year(GDateYear);
    extern guint g_idle_add(GSourceFunc, gpointer);
    extern void g_main_context_release(GMainContext *);
    extern int g_main_depth(void);
    extern void g_cache_key_foreach(GCache *, GHFunc, gpointer);
    extern void g_static_rec_mutex_free(GStaticRecMutex *);
    extern guint g_date_get_monday_week_of_year(const GDate *);
    extern const gchar *g_io_channel_get_line_term(GIOChannel *, gint *);
    extern guint g_scanner_set_scope(GScanner *, guint);
    extern gchar *g_string_free(GString *, gboolean);
    extern void g_source_set_priority(GSource *, gint);
    extern void g_async_queue_unref(GAsyncQueue *);
    extern void g_hook_prepend(GHookList *, GHook *);
    extern gpointer g_queue_peek_head(GQueue *);
    extern void g_byte_array_sort_with_data(GByteArray *, GCompareDataFunc,
					    gpointer);
    extern gboolean g_key_file_load_from_data_dirs(GKeyFile *,
						   const gchar *,
						   gchar * *,
						   GKeyFileFlags,
						   GError * *);
    extern guint g_trash_stack_height(GTrashStack * *);
    extern void g_markup_parse_context_free(GMarkupParseContext *);
    extern GString *g_string_append_len(GString *, const gchar *, gssize);
    extern const gchar *g_getenv(const gchar *);
    extern gint *g_key_file_get_integer_list(GKeyFile *, const gchar *,
					     const gchar *, gsize *,
					     GError * *);
    extern gunichar2 *g_ucs4_to_utf16(const gunichar *, glong, glong *,
				      glong *, GError * *);
    extern GList *g_list_remove(GList *, gconstpointer);
    extern gboolean g_hook_destroy(GHookList *, gulong);
    extern GRand *g_rand_copy(GRand *);
    extern GString *g_string_ascii_up(GString *);
    extern const gchar *g_io_channel_get_encoding(GIOChannel *);
    extern void g_random_set_seed(guint32);
    extern GOptionGroup *g_option_context_get_main_group(GOptionContext *);
    extern guint g_idle_add_full(gint, GSourceFunc, gpointer,
				 GDestroyNotify);
    extern GArray *g_array_append_vals(GArray *, gconstpointer, guint);
    extern GHook *g_hook_next_valid(GHookList *, GHook *, gboolean);
    extern gchar *g_path_get_basename(const gchar *);
    extern gchar *g_key_file_get_value(GKeyFile *, const gchar *,
				       const gchar *, GError * *);
    extern void g_slist_pop_allocator(void);
    extern void g_node_unlink(GNode *);
    extern gpointer g_hash_table_find(GHashTable *, GHRFunc, gpointer);
    extern GList *g_list_sort(GList *, GCompareFunc);
    extern void g_date_set_time(GDate *, GTime);
    extern GPollFunc g_main_context_get_poll_func(GMainContext *);
    extern gchar *g_strndup(const gchar *, gsize);
    extern GSList *g_slist_remove(GSList *, gconstpointer);
    extern void g_date_order(GDate *, GDate *);
    extern gdouble g_timer_elapsed(GTimer *, gulong *);
    extern gchar *g_strchug(gchar *);
    extern GQuark g_io_channel_error_quark(void);
    extern void g_cache_remove(GCache *, gconstpointer);
    extern GArray *g_array_remove_index_fast(GArray *, guint);
    extern GAsyncQueue *g_async_queue_ref(GAsyncQueue *);
    extern GQuark g_key_file_error_quark(void);
    extern gboolean g_atomic_pointer_compare_and_exchange(gpointer *,
							  gpointer,
							  gpointer);
    extern gboolean g_date_valid_dmy(GDateDay, GDateMonth, GDateYear);
    extern gpointer g_mem_chunk_alloc0(GMemChunk *);
    extern gint g_async_queue_length_unlocked(GAsyncQueue *);
    extern GUnicodeBreakType g_unichar_break_type(gunichar);
    extern gboolean g_date_valid_year(GDateYear);
    extern void g_thread_pool_set_max_unused_threads(gint);
    extern GArray *g_array_remove_index(GArray *, guint);
    extern void g_key_file_remove_group(GKeyFile *, const gchar *,
					GError * *);
    extern gchar *g_key_file_get_comment(GKeyFile *, const gchar *,
					 const gchar *, GError * *);
    extern gboolean g_io_channel_get_buffered(GIOChannel *);
    extern GList *g_list_delete_link(GList *, GList *);
    extern GList *g_completion_complete(GCompletion *, const gchar *,
					gchar * *);
    extern gboolean g_unichar_isdigit(gunichar);
    extern void g_date_subtract_years(GDate *, guint);
    extern gchar *g_utf8_strchr(const char *, gssize, gunichar);
    extern void g_queue_push_head(GQueue *, gpointer);
    extern guint g_queue_get_length(GQueue *);
    extern gchar *g_string_chunk_insert_const(GStringChunk *,
					      const gchar *);
    extern void g_static_rw_lock_init(GStaticRWLock *);
    extern guint g_bit_storage(gulong);
    extern GSList *g_slist_sort(GSList *, GCompareFunc);
    extern gint g_relation_delete(GRelation *, gconstpointer, gint);
    extern GIOStatus g_io_channel_write_chars(GIOChannel *, const gchar *,
					      gssize, gsize *, GError * *);
    extern GList *g_list_find(GList *, gconstpointer);
    extern gpointer g_queue_peek_tail(GQueue *);
    extern GIOStatus g_io_channel_write_unichar(GIOChannel *, gunichar,
						GError * *);
    extern void g_hook_list_clear(GHookList *);
    extern guint g_child_watch_add(GPid, GChildWatchFunc, gpointer);
    extern void g_hook_list_init(GHookList *, guint);
    extern gpointer g_realloc(gpointer, gulong);
    extern void g_queue_push_nth(GQueue *, gpointer, gint);
    extern gpointer g_trash_stack_peek(GTrashStack * *);
    extern const gchar *g_get_application_name(void);
    extern gint g_main_context_check(GMainContext *, gint, GPollFD *,
				     gint);
    extern gunichar *g_unicode_canonical_decomposition(gunichar, gsize *);
    extern gpointer g_async_queue_timed_pop_unlocked(GAsyncQueue *,
						     GTimeVal *);
    extern gboolean g_option_context_get_help_enabled(GOptionContext *);
    extern void g_log_default_handler(const gchar *, GLogLevelFlags,
				      const gchar *, gpointer);
    extern gpointer g_async_queue_try_pop(GAsyncQueue *);
    extern void g_option_group_set_translation_domain(GOptionGroup *,
						      const gchar *);
    extern void g_source_destroy(GSource *);
    extern gchar *g_filename_to_utf8(const gchar *, gssize, gsize *,
				     gsize *, GError * *);
    extern gboolean g_key_file_load_from_data(GKeyFile *, const gchar *,
					      gsize, GKeyFileFlags,
					      GError * *);
    extern GKeyFile *g_key_file_new(void);
    extern GDateYear g_date_get_year(const GDate *);
    extern const gchar *g_get_user_config_dir(void);
    extern gint g_slist_position(GSList *, GSList *);
    extern const guint glib_minor_version;
    extern GSList *g_slist_delete_link(GSList *, GSList *);
    extern GDateWeekday g_date_get_weekday(const GDate *);
    extern gchar *g_convert_with_iconv(const gchar *, gssize, GIConv,
				       gsize *, gsize *, GError * *);
    extern GNode *g_node_insert(GNode *, gint, GNode *);
    extern void g_source_set_callback(GSource *, GSourceFunc, gpointer,
				      GDestroyNotify);
    extern void g_source_add_poll(GSource *, GPollFD *);
    extern void g_slist_free_1(GSList *);
    extern GByteArray *g_byte_array_remove_index_fast(GByteArray *, guint);
    extern GHook *g_hook_find_data(GHookList *, gboolean, gpointer);
    extern void g_ptr_array_foreach(GPtrArray *, GFunc, gpointer);
    extern void g_scanner_scope_add_symbol(GScanner *, guint,
					   const gchar *, gpointer);
    extern GMainContext *g_main_context_ref(GMainContext *);
    extern void g_hook_list_invoke(GHookList *, gboolean);
    extern gint g_source_get_priority(GSource *);
    extern void g_list_free_1(GList *);
    extern gint g_key_file_get_integer(GKeyFile *, const gchar *,
				       const gchar *, GError * *);
    extern GSList *g_slist_nth(GSList *, guint);
    extern gchar *g_shell_unquote(const gchar *, GError * *);
    extern void g_option_context_add_group(GOptionContext *,
					   GOptionGroup *);
    extern gboolean g_unichar_isprint(gunichar);
    extern GList *g_list_copy(GList *);
    extern void g_cache_value_foreach(GCache *, GHFunc, gpointer);
    extern void g_key_file_set_comment(GKeyFile *, const gchar *,
				       const gchar *, const gchar *,
				       GError * *);
    extern gint g_ascii_digit_value(gchar);
    extern void g_main_context_dispatch(GMainContext *);
    extern GIOChannel *g_io_channel_new_file(const gchar *, const gchar *,
					     GError * *);
    extern gint g_unichar_digit_value(gunichar);
    extern void g_source_set_can_recurse(GSource *, gboolean);
    extern void g_main_loop_unref(GMainLoop *);
    extern GNode *g_node_first_sibling(GNode *);
    extern gint g_date_days_between(const GDate *, const GDate *);
    extern void g_mem_chunk_free(GMemChunk *, gpointer);
    extern gchar *g_markup_escape_text(const gchar *, gssize);
    extern gunichar g_unichar_tolower(gunichar);
    extern void g_queue_push_nth_link(GQueue *, gint, GList *);
    extern char *g_markup_printf_escaped(const char *, ...);
    extern void g_hook_unref(GHookList *, GHook *);
    extern GNode *g_node_find(GNode *, GTraverseType, GTraverseFlags,
			      gpointer);
    extern gchar *g_ascii_formatd(gchar *, gint, const gchar *, gdouble);
    extern gpointer g_scanner_scope_lookup_symbol(GScanner *, guint,
						  const gchar *);
    extern gpointer g_dataset_id_remove_no_notify(gconstpointer, GQuark);
    extern GQueue *g_queue_new(void);
    extern GQuark g_markup_error_quark(void);
    extern void g_option_context_set_ignore_unknown_options(GOptionContext
							    *, gboolean);
    extern void g_completion_remove_items(GCompletion *, GList *);
    extern void g_datalist_id_set_data_full(GData * *, GQuark, gpointer,
					    GDestroyNotify);
    extern void g_trash_stack_push(GTrashStack * *, gpointer);
    extern void g_async_queue_lock(GAsyncQueue *);
    extern void g_ptr_array_sort(GPtrArray *, GCompareFunc);
    extern void g_queue_free(GQueue *);
    extern void g_array_sort_with_data(GArray *, GCompareDataFunc,
				       gpointer);
    extern gboolean g_relation_exists(GRelation *, ...);
    extern gboolean g_utf8_validate(const char *, gssize, const gchar * *);
    extern void g_static_rw_lock_writer_unlock(GStaticRWLock *);
    extern GByteArray *g_byte_array_remove_index(GByteArray *, guint);
    extern guint g_hash_table_foreach_remove(GHashTable *, GHRFunc,
					     gpointer);
    extern GString *g_string_insert_unichar(GString *, gssize, gunichar);
    extern GSList *g_slist_prepend(GSList *, gpointer);
    extern GList *g_list_first(GList *);
    extern GMarkupParseContext *g_markup_parse_context_new(const
							   GMarkupParser *,
							   GMarkupParseFlags,
							   gpointer,
							   GDestroyNotify);
    extern void g_io_channel_init(GIOChannel *);
    extern GQuark g_convert_error_quark(void);
    extern GNode *g_node_get_root(GNode *);
    extern gchar *g_filename_display_name(const gchar *);
    extern gint g_io_channel_unix_get_fd(GIOChannel *);
    extern gboolean g_int_equal(gconstpointer, gconstpointer);
    extern void g_hook_list_marshal_check(GHookList *, gboolean,
					  GHookCheckMarshaller, gpointer);
    extern void g_static_mutex_init(GStaticMutex *);
    extern GString *g_string_prepend_unichar(GString *, gunichar);
    extern GList *g_queue_find_custom(GQueue *, gconstpointer,
				      GCompareFunc);
    extern void g_key_file_set_string_list(GKeyFile *, const gchar *,
					   const gchar *,
					   const gchar * const *, gsize);
    extern const guint glib_micro_version;
    extern guint32 g_date_get_julian(const GDate *);
    extern gpointer g_dataset_id_get_data(gconstpointer, GQuark);
    extern gboolean g_date_valid_day(GDateDay);
    extern GHook *g_hook_first_valid(GHookList *, gboolean);
    extern GIOStatus g_io_channel_read_to_end(GIOChannel *, gchar * *,
					      gsize *, GError * *);
    extern void g_scanner_destroy(GScanner *);
    extern GString *g_string_insert_c(GString *, gssize, gchar);
    extern void g_queue_push_head_link(GQueue *, GList *);
    extern GIOChannel *g_io_channel_ref(GIOChannel *);
    extern gpointer g_try_realloc(gpointer, gulong);
    extern GRelation *g_relation_new(gint);
    extern GNode *g_node_nth_child(GNode *, guint);
    extern GByteArray *g_byte_array_sized_new(guint);
    extern void g_queue_push_tail(GQueue *, gpointer);
    extern gboolean g_unichar_validate(gunichar);
    extern GSource *g_idle_source_new(void);
    extern gchar **g_key_file_get_groups(GKeyFile *, gsize *);
    extern void g_scanner_sync_file_offset(GScanner *);
    extern GLogLevelFlags g_log_set_always_fatal(GLogLevelFlags);
    extern gpointer *g_ptr_array_free(GPtrArray *, gboolean);
    extern gint g_utf8_collate(const gchar *, const gchar *);
    extern GPrintFunc g_set_print_handler(GPrintFunc);
    extern const guint glib_interface_age;
    extern void g_hook_list_invoke_check(GHookList *, gboolean);
    extern gchar *g_utf8_offset_to_pointer(const gchar *, glong);
    extern void g_scanner_input_file(GScanner *, gint);
    extern gboolean g_source_get_can_recurse(GSource *);
    extern GHook *g_hook_find_func_data(GHookList *, gboolean, gpointer,
					gpointer);
    extern void g_logv(const gchar *, GLogLevelFlags, const gchar *,
		       va_list);
    extern gboolean g_error_matches(const GError *, GQuark, gint);
    extern gpointer g_async_queue_pop(GAsyncQueue *);
    extern gchar **g_uri_list_extract_uris(const gchar *);
    extern gboolean g_static_rw_lock_writer_trylock(GStaticRWLock *);
    extern void g_date_add_months(GDate *, guint);
    extern void g_date_add_days(GDate *, guint);
    extern gchar **g_strsplit(const gchar *, const gchar *, gint);
    extern GSList *g_slist_remove_all(GSList *, gconstpointer);
    extern gdouble g_random_double(void);
    extern gdouble g_strtod(const gchar *, gchar * *);
    extern void g_queue_sort(GQueue *, GCompareDataFunc, gpointer);
    extern gboolean g_str_has_suffix(const gchar *, const gchar *);
    extern GList *g_queue_pop_head_link(GQueue *);
    extern gint32 g_rand_int_range(GRand *, gint32, gint32);
    extern gint g_unichar_to_utf8(gunichar, gchar *);
    extern gchar *g_strnfill(gsize, gchar);
    extern void g_relation_print(GRelation *);
    extern void g_key_file_set_integer_list(GKeyFile *, const gchar *,
					    const gchar *, gint *, gsize);
    extern GSource
	*g_main_context_find_source_by_funcs_user_data(GMainContext *,
						       GSourceFuncs *,
						       gpointer);
    extern GDate *g_date_new_julian(guint32);
    extern void g_node_traverse(GNode *, GTraverseType, GTraverseFlags,
				gint, GNodeTraverseFunc, gpointer);
    extern gchar *g_key_file_get_start_group(GKeyFile *);
    extern void g_key_file_set_locale_string(GKeyFile *, const gchar *,
					     const gchar *, const gchar *,
					     const gchar *);
    extern GHashTable *g_hash_table_new(GHashFunc, GEqualFunc);
    extern const gchar *g_dir_read_name(GDir *);
    extern gboolean g_hash_table_remove(GHashTable *, gconstpointer);
    extern gchar *g_utf8_strdown(const gchar *, gssize);
    extern GIOCondition g_io_channel_get_buffer_condition(GIOChannel *);
    extern GSource *g_child_watch_source_new(GPid);
    extern void g_static_rec_mutex_unlock(GStaticRecMutex *);
    extern glong g_utf8_strlen(const gchar *, gssize);
    extern GSList *g_slist_insert(GSList *, gpointer, gint);
    extern GNode *g_node_prepend(GNode *, GNode *);
    extern void g_propagate_error(GError * *, GError *);
    extern GTokenType g_scanner_peek_next_token(GScanner *);
    extern GArray *g_array_set_size(GArray *, guint);
    extern GString *g_string_erase(GString *, gssize, gssize);
    extern gchar *g_strcompress(const gchar *);
    extern gint g_async_queue_length(GAsyncQueue *);
    extern gboolean g_unichar_isdefined(gunichar);
    extern GString *g_string_prepend(GString *, const gchar *);
    extern guint32 g_rand_int(GRand *);
    extern void g_set_error(GError * *, GQuark, gint, const gchar *, ...);
    extern gboolean g_markup_parse_context_parse(GMarkupParseContext *,
						 const gchar *, gssize,
						 GError * *);
    extern gboolean g_main_context_pending(GMainContext *);
    extern gint g_tree_nnodes(GTree *);
    extern gpointer g_datalist_id_get_data(GData * *, GQuark);
    extern void g_ptr_array_sort_with_data(GPtrArray *, GCompareDataFunc,
					   gpointer);
    extern void g_queue_unlink(GQueue *, GList *);
    extern guint g_source_get_id(GSource *);
    extern void g_thread_pool_set_max_threads(GThreadPool *, gint,
					      GError * *);
    extern gchar *g_utf8_normalize(const gchar *, gssize, GNormalizeMode);
    extern GTree *g_tree_new_with_data(GCompareDataFunc, gpointer);
    extern gchar *g_path_get_dirname(const gchar *);
    extern gint g_thread_pool_get_max_threads(GThreadPool *);
    extern GArray *g_array_sized_new(gboolean, gboolean, guint, guint);
    extern gboolean g_unichar_islower(gunichar);
    extern GString *g_string_assign(GString *, const gchar *);
    extern gchar *g_strstr_len(const gchar *, gssize, const gchar *);
    extern GArray *g_array_prepend_vals(GArray *, gconstpointer, guint);
    extern gdouble g_rand_double_range(GRand *, gdouble, gdouble);
    extern void g_key_file_set_list_separator(GKeyFile *, gchar);
    extern gboolean g_atomic_int_compare_and_exchange(gint *, gint, gint);
    extern void g_mem_profile(void);
    extern void g_io_channel_set_buffered(GIOChannel *, gboolean);
    extern GMutex *g_static_mutex_get_mutex_impl(GMutex * *);
    extern GList *g_list_remove_all(GList *, gconstpointer);
    extern void g_static_private_set(GStaticPrivate *, gpointer,
				     GDestroyNotify);
    extern void g_timer_start(GTimer *);
    extern void g_array_sort(GArray *, GCompareFunc);
    extern gchar *g_build_path(const gchar *, const gchar *, ...);
    extern gchar *g_key_file_get_string(GKeyFile *, const gchar *,
					const gchar *, GError * *);
    extern void g_return_if_fail_warning(const char *, const char *,
					 const char *);
    extern GAsyncQueue *g_async_queue_new(void);
    extern GTokenType g_scanner_get_next_token(GScanner *);
    extern gchar *g_strescape(const gchar *, const gchar *);
    extern void g_tree_remove(GTree *, gconstpointer);
    extern GFileError g_file_error_from_errno(gint);
    extern GByteArray *g_byte_array_set_size(GByteArray *, guint);
    extern GSList *g_slist_insert_before(GSList *, GSList *, gpointer);
    extern void g_main_context_unref(GMainContext *);
    extern void g_on_error_query(const gchar *);
    extern gchar *g_find_program_in_path(const gchar *);
    extern GNode *g_node_insert_before(GNode *, GNode *, GNode *);
    extern void g_key_file_set_boolean(GKeyFile *, const gchar *,
				       const gchar *, gboolean);
    extern void g_key_file_remove_key(GKeyFile *, const gchar *,
				      const gchar *, GError * *);
    extern void g_dataset_foreach(gconstpointer, GDataForeachFunc,
				  gpointer);
    extern const gchar *g_get_user_data_dir(void);
    extern void g_date_subtract_months(GDate *, guint);
    extern gboolean g_unichar_iscntrl(gunichar);
    extern guint g_timeout_add_full(gint, guint, GSourceFunc, gpointer,
				    GDestroyNotify);
    extern GIOStatus g_io_channel_read_chars(GIOChannel *, gchar *, gsize,
					     gsize *, GError * *);
    extern gint g_bit_nth_msf(gulong, gint);
    extern void g_tree_steal(GTree *, gconstpointer);
    extern gboolean g_date_valid(const GDate *);
    extern void g_io_channel_set_close_on_unref(GIOChannel *, gboolean);
    extern void g_tree_replace(GTree *, gpointer, gpointer);
    extern void g_async_queue_push_unlocked(GAsyncQueue *, gpointer);
    extern GNode *g_node_new(gpointer);
    extern void g_mem_set_vtable(GMemVTable *);
    extern void g_option_context_add_main_entries(GOptionContext *,
						  const GOptionEntry *,
						  const gchar *);
    extern void g_hash_table_foreach(GHashTable *, GHFunc, gpointer);
    extern GUnicodeType g_unichar_type(gunichar);
    extern GPtrArray *g_ptr_array_sized_new(guint);
    extern GList *g_list_insert_sorted(GList *, gpointer, GCompareFunc);
    extern GLogFunc g_log_set_default_handler(GLogFunc, gpointer);
    extern gsize g_date_strftime(gchar *, gsize, const gchar *,
				 const GDate *);
    extern gboolean
	g_option_context_get_ignore_unknown_options(GOptionContext *);
    extern gpointer g_static_private_get(GStaticPrivate *);
    extern void g_completion_add_items(GCompletion *, GList *);
    extern gchar *g_stpcpy(gchar *, const gchar *);
    extern gchar *g_utf8_find_prev_char(const char *, const char *);
    extern GOptionContext *g_option_context_new(const gchar *);
    extern gchar *g_locale_to_utf8(const gchar *, gssize, gsize *, gsize *,
				   GError * *);
    extern gint g_ascii_strncasecmp(const gchar *, const gchar *, gsize);
    extern void g_slist_push_allocator(GAllocator *);
    extern gboolean g_main_context_acquire(GMainContext *);
    extern GSourceFuncs g_idle_funcs;
    extern guint g_thread_pool_get_num_unused_threads(void);
    extern void g_thread_pool_free(GThreadPool *, gboolean, gboolean);
    extern guint g_date_get_sunday_week_of_year(const GDate *);
    extern gdouble g_rand_double(GRand *);
    extern gint g_ascii_strcasecmp(const gchar *, const gchar *);
    extern void g_string_printf(GString *, const gchar *, ...);
    extern GQuark g_quark_from_string(const gchar *);
    extern void g_hash_table_replace(GHashTable *, gpointer, gpointer);
    extern const gchar *g_strip_context(const gchar *, const gchar *);
    extern const gchar *g_strerror(gint);
    extern void g_mem_chunk_clean(GMemChunk *);
    extern GString *g_string_prepend_len(GString *, const gchar *, gssize);
    extern GArray *g_array_remove_range(GArray *, guint, guint);
    extern void g_queue_remove_all(GQueue *, gconstpointer);
    extern gint g_file_open_tmp(const gchar *, gchar * *, GError * *);
    extern const gchar *g_get_user_name(void);
    extern void g_timer_continue(GTimer *);
    extern void g_main_context_set_poll_func(GMainContext *, GPollFunc);
    extern void g_timer_destroy(GTimer *);
    extern void g_main_context_add_poll(GMainContext *, GPollFD *, gint);
    extern GSList *g_slist_alloc(void);
    extern GSList *g_slist_reverse(GSList *);
    extern GList *g_list_concat(GList *, GList *);
    extern gunichar g_utf8_get_char(const gchar *);
    extern gchar *g_shell_quote(const gchar *);
    extern void g_get_current_time(GTimeVal *);
    extern void g_option_group_set_translate_func(GOptionGroup *,
						  GTranslateFunc, gpointer,
						  GDestroyNotify);
    extern gunichar g_unichar_totitle(gunichar);
    extern gboolean g_spawn_async(const gchar *, gchar * *, gchar * *,
				  GSpawnFlags, GSpawnChildSetupFunc,
				  gpointer, GPid *, GError * *);
    extern gchar *g_utf16_to_utf8(const gunichar2 *, glong, glong *,
				  glong *, GError * *);
    extern void g_queue_insert_before(GQueue *, GList *, gpointer);
    extern GSource *g_main_context_find_source_by_id(GMainContext *,
						     guint);
    extern void g_mem_chunk_destroy(GMemChunk *);
    extern void g_thread_exit(gpointer);
    extern void g_option_group_set_parse_hooks(GOptionGroup *,
					       GOptionParseFunc,
					       GOptionParseFunc);
    extern GSList *g_slist_insert_sorted(GSList *, gpointer, GCompareFunc);
    extern void g_source_set_callback_indirect(GSource *, gpointer,
					       GSourceCallbackFuncs *);
    extern GSList *g_slist_sort_with_data(GSList *, GCompareDataFunc,
					  gpointer);
    extern void g_node_reverse_children(GNode *);
    extern gpointer g_queue_peek_nth(GQueue *, guint);
    extern void g_list_free(GList *);
    extern GList *g_list_nth_prev(GList *, guint);
    extern void g_strfreev(gchar * *);
    extern gboolean g_ptr_array_remove(GPtrArray *, gpointer);
    extern const guint glib_major_version;
    extern glong g_utf8_pointer_to_offset(const gchar *, const gchar *);
    extern gpointer g_tree_lookup(GTree *, gconstpointer);
    extern gchar *g_strdup_printf(const gchar *, ...);
    extern gboolean g_source_remove_by_user_data(gpointer);
    extern gunichar2 *g_utf8_to_utf16(const gchar *, glong, glong *,
				      glong *, GError * *);
    extern gunichar *g_utf8_to_ucs4(const gchar *, glong, glong *, glong *,
				    GError * *);
    extern void g_date_set_day(GDate *, GDateDay);
    extern gsize g_io_channel_get_buffer_size(GIOChannel *);
    extern void g_hash_table_insert(GHashTable *, gpointer, gpointer);
    extern guint g_spaced_primes_closest(guint);
    extern void g_option_group_add_entries(GOptionGroup *,
					   const GOptionEntry *);
    extern gboolean g_key_file_load_from_file(GKeyFile *, const gchar *,
					      GKeyFileFlags, GError * *);
    extern gint32 g_random_int_range(gint32, gint32);
    extern gpointer g_hash_table_lookup(GHashTable *, gconstpointer);
    extern void g_relation_index(GRelation *, gint, GHashFunc, GEqualFunc);
    extern GByteArray *g_byte_array_remove_range(GByteArray *, guint,
						 guint);
    extern gchar *g_filename_from_utf8(const gchar *, gssize, gsize *,
				       gsize *, GError * *);
    extern GQuark g_thread_error_quark(void);
    extern void g_hook_destroy_link(GHookList *, GHook *);
    extern gdouble g_random_double_range(gdouble, gdouble);
    extern gchar *g_filename_from_uri(const gchar *, gchar * *,
				      GError * *);
    extern gboolean g_tree_lookup_extended(GTree *, gconstpointer,
					   gpointer *, gpointer *);
    extern gboolean g_unichar_iswide(gunichar);
    extern gboolean g_unichar_isxdigit(gunichar);
    extern void g_queue_push_tail_link(GQueue *, GList *);
    extern void g_spawn_close_pid(GPid);
    extern GRand *g_rand_new(void);
    extern void g_date_set_julian(GDate *, guint32);
    extern GNode *g_node_insert_after(GNode *, GNode *, GNode *);
    extern const guint glib_binary_age;
    extern void g_static_rec_mutex_lock_full(GStaticRecMutex *, guint);
    extern GString *g_string_append_unichar(GString *, gunichar);
    extern GStringChunk *g_string_chunk_new(gsize);
    extern void g_atexit(GVoidFunc);
    extern void g_scanner_scope_remove_symbol(GScanner *, guint,
					      const gchar *);
    extern void g_main_context_remove_poll(GMainContext *, GPollFD *);
    extern gchar *g_locale_from_utf8(const gchar *, gssize, gsize *,
				     gsize *, GError * *);
    extern GMainContext *g_source_get_context(GSource *);
    extern GSourceFuncs g_io_watch_funcs;
    extern gint g_thread_pool_get_max_unused_threads(void);
    extern gboolean g_unichar_isspace(gunichar);
    extern GList *g_list_alloc(void);
    extern gpointer g_queue_pop_tail(GQueue *);
    extern gpointer g_thread_join(GThread *);
    extern GSList *g_slist_append(GSList *, gpointer);
    extern GNode *g_node_copy(GNode *);
    extern void g_time_val_add(GTimeVal *, glong);
    extern gboolean g_pattern_match(GPatternSpec *, guint, const gchar *,
				    const gchar *);
    extern void g_source_remove_poll(GSource *, GPollFD *);
    extern gsize g_printf_string_upper_bound(const gchar *, va_list);
    extern GCompletion *g_completion_new(GCompletionFunc);
    extern gboolean g_date_is_last_of_month(const GDate *);
    extern GHook *g_hook_find(GHookList *, gboolean, GHookFindFunc,
			      gpointer);
    extern gboolean g_static_rec_mutex_trylock(GStaticRecMutex *);
    extern GError *g_error_new_literal(GQuark, gint, const gchar *);
    extern void g_date_set_dmy(GDate *, GDateDay, GDateMonth, GDateYear);
    extern guint g_node_max_height(GNode *);
    extern gboolean g_unichar_isgraph(gunichar);
    extern gint g_list_position(GList *, GList *);
    extern gboolean g_pattern_match_simple(const gchar *, const gchar *);
    extern const gchar *g_get_real_name(void);
    extern void g_string_append_printf(GString *, const gchar *, ...);
    extern void g_static_private_init(GStaticPrivate *);
    extern gunichar *g_utf16_to_ucs4(const gunichar2 *, glong, glong *,
				     glong *, GError * *);
    extern void g_rand_free(GRand *);
    extern GList *g_queue_peek_tail_link(GQueue *);
    extern gchar *g_convert_with_fallback(const gchar *, gssize,
					  const gchar *, const gchar *,
					  gchar *, gsize *, gsize *,
					  GError * *);
    extern GSource *g_timeout_source_new(guint);
    extern guint g_child_watch_add_full(gint, GPid, GChildWatchFunc,
					gpointer, GDestroyNotify);
    extern void g_node_push_allocator(GAllocator *);
    extern void g_queue_foreach(GQueue *, GFunc, gpointer);
    extern gchar *g_strdup(const gchar *);
    extern gint g_queue_index(GQueue *, gconstpointer);
    extern gpointer g_datalist_id_remove_no_notify(GData * *, GQuark);
    extern guint8 *g_byte_array_free(GByteArray *, gboolean);
    extern void g_date_clamp(GDate *, const GDate *, const GDate *);
    extern void g_list_push_allocator(GAllocator *);
    extern void g_queue_insert_after(GQueue *, GList *, gpointer);
    extern gpointer g_try_malloc(gulong);
    extern GIOFlags g_io_channel_get_flags(GIOChannel *);
    extern gchar *g_filename_display_basename(const gchar *);
    extern GList *g_list_append(GList *, gpointer);
    extern gchar *g_utf8_strncpy(gchar *, const gchar *, gsize);
    extern gchar **g_key_file_get_string_list(GKeyFile *, const gchar *,
					      const gchar *, gsize *,
					      GError * *);
    extern guint g_log_set_handler(const gchar *, GLogLevelFlags, GLogFunc,
				   gpointer);
    extern gboolean g_queue_is_empty(GQueue *);
    extern GList *g_queue_peek_nth_link(GQueue *, guint);
    extern void g_list_foreach(GList *, GFunc, gpointer);
    extern gint g_ascii_xdigit_value(gchar);
    extern GQuark g_shell_error_quark(void);
    extern gpointer g_ptr_array_remove_index(GPtrArray *, guint);
    extern GList *g_list_insert(GList *, gpointer, gint);
    extern void g_log(const gchar *, GLogLevelFlags, const gchar *, ...);
    extern gchar *g_utf8_strrchr(const char *, gssize, gunichar);
    extern guint g_string_hash(const GString *);
    extern gchar **g_key_file_get_locale_string_list(GKeyFile *,
						     const gchar *,
						     const gchar *,
						     const gchar *,
						     gsize *, GError * *);
    extern void g_queue_insert_sorted(GQueue *, gpointer, GCompareDataFunc,
				      gpointer);
    extern void g_hook_free(GHookList *, GHook *);
    extern gpointer g_tree_search(GTree *, GCompareFunc, gconstpointer);
    extern void g_scanner_scope_foreach_symbol(GScanner *, guint, GHFunc,
					       gpointer);
    extern GDir *g_dir_open(const gchar *, guint, GError * *);
    extern gchar *g_utf8_casefold(const gchar *, gssize);
    extern void g_rand_set_seed_array(GRand *, const guint32 *, guint);
    extern void g_date_to_struct_tm(const GDate *, struct tm *);
    extern gboolean g_key_file_has_group(GKeyFile *, const gchar *);
    extern GList *g_list_remove_link(GList *, GList *);
    extern gboolean g_date_valid_month(GDateMonth);
    extern gboolean g_spawn_command_line_sync(const gchar *, gchar * *,
					      gchar * *, gint *,
					      GError * *);
    extern gpointer g_slist_nth_data(GSList *, guint);
    extern gchar *g_convert(const gchar *, gssize, const gchar *,
			    const gchar *, gsize *, gsize *, GError * *);
    extern void g_io_channel_unref(GIOChannel *);
    extern void g_markup_parse_context_get_position(GMarkupParseContext *,
						    gint *, gint *);
    extern void g_datalist_foreach(GData * *, GDataForeachFunc, gpointer);
    extern void g_tuples_destroy(GTuples *);
    extern guint g_strv_length(gchar * *);
    extern gunichar g_unichar_toupper(gunichar);
    extern void g_tree_insert(GTree *, gpointer, gpointer);
    extern GNode *g_node_copy_deep(GNode *, GCopyFunc, gpointer);
    extern gint g_node_child_position(GNode *, GNode *);
    extern void g_list_pop_allocator(void);
    extern gboolean g_mem_is_system_malloc(void);
    extern const gchar *g_get_home_dir(void);
    extern void g_async_queue_push(GAsyncQueue *, gpointer);
    extern gboolean g_key_file_has_key(GKeyFile *, const gchar *,
				       const gchar *, GError * *);
    extern gboolean g_file_get_contents(const gchar *, gchar * *, gsize *,
					GError * *);
    extern gboolean g_path_is_absolute(const gchar *);
    extern void g_printerr(const gchar *, ...);
    extern void g_completion_set_compare(GCompletion *,
					 GCompletionStrncmpFunc);
    extern guint g_timeout_add(guint32, GSourceFunc, gpointer);
    extern void g_slist_foreach(GSList *, GFunc, gpointer);
    extern GArray *g_array_insert_vals(GArray *, guint, gconstpointer,
				       guint);
    extern gchar *g_utf8_collate_key(const gchar *, gssize);
    extern void g_static_rw_lock_reader_lock(GStaticRWLock *);
    extern void g_mem_chunk_info(void);
    extern gchar *g_utf8_strreverse(const gchar *, gssize);
    extern GByteArray *g_byte_array_new(void);
    extern gboolean g_setenv(const gchar *, const gchar *, gboolean);
    extern gchar *g_get_current_dir(void);
    extern GTree *g_tree_new(GCompareFunc);
    extern gboolean g_unichar_isalpha(gunichar);
    extern gsize g_strlcat(gchar *, const gchar *, gsize);
    extern gboolean g_main_context_iteration(GMainContext *, gboolean);
    extern GHook *g_hook_ref(GHookList *, GHook *);
    extern GNode *g_node_find_child(GNode *, GTraverseFlags, gpointer);
    extern void g_option_group_set_error_hook(GOptionGroup *,
					      GOptionErrorFunc);
    extern gint g_bit_nth_lsf(gulong, gint);
    extern gpointer g_async_queue_try_pop_unlocked(GAsyncQueue *);
    extern GCache *g_cache_new(GCacheNewFunc, GCacheDestroyFunc,
			       GCacheDupFunc, GCacheDestroyFunc, GHashFunc,
			       GHashFunc, GEqualFunc);
    extern void g_print(const gchar *, ...);
    extern gint g_unichar_xdigit_value(gunichar);
    extern GTimer *g_timer_new(void);
    extern gchar *g_string_chunk_insert(GStringChunk *, const gchar *);
    extern gchar *g_file_read_link(const gchar *, GError * *);
    extern void g_assert_warning(const char *, const char *, const int,
				 const char *, const char *);
    extern guint g_str_hash(gconstpointer);
    extern void g_key_file_set_locale_string_list(GKeyFile *,
						  const gchar *,
						  const gchar *,
						  const gchar *,
						  const gchar * const *,
						  gsize);
    extern GString *g_string_sized_new(gsize);
    extern void g_hash_table_destroy(GHashTable *);
    extern void g_static_mutex_free(GStaticMutex *);
    extern gchar *g_ascii_strup(const gchar *, gssize);
    extern gchar g_ascii_toupper(gchar);
    extern guint g_date_get_iso8601_week_of_year(const GDate *);
    extern void g_slist_free(GSList *);
    extern gboolean g_string_equal(const GString *, const GString *);
    extern guint g_scanner_cur_line(GScanner *);
    extern gint g_date_compare(const GDate *, const GDate *);
    extern GString *g_string_insert_len(GString *, gssize, const gchar *,
					gssize);
    extern gchar *g_strdelimit(gchar *, const gchar *, gchar);
    extern guint g_node_n_children(GNode *);
    extern GNode *g_node_last_sibling(GNode *);
    extern const gchar *const *g_get_language_names(void);
    extern GHook *g_hook_alloc(GHookList *);
    extern GDateMonth g_date_get_month(const GDate *);
    extern gboolean g_date_is_leap_year(GDateYear);
    extern gpointer g_queue_pop_nth(GQueue *, guint);
    extern gchar *g_strreverse(gchar *);
    extern guint g_hash_table_size(GHashTable *);
    extern gpointer g_mem_chunk_alloc(GMemChunk *);
    extern GList *g_queue_peek_head_link(GQueue *);
    extern GList *g_queue_find(GQueue *, gconstpointer);
    extern void g_dataset_id_set_data_full(gconstpointer, GQuark, gpointer,
					   GDestroyNotify);
    extern void g_unsetenv(const gchar *);
    extern guint64 g_ascii_strtoull(const gchar *, gchar * *, guint);
    extern gboolean g_spawn_command_line_async(const gchar *, GError * *);
    extern GHook *g_hook_find_func(GHookList *, gboolean, gpointer);
    extern gchar *g_array_free(GArray *, gboolean);
    extern gpointer g_malloc0(gulong);
    extern gint g_node_child_index(GNode *, gpointer);
    extern GIOStatus g_io_channel_shutdown(GIOChannel *, gboolean,
					   GError * *);
    extern GQuark g_quark_try_string(const gchar *);
    extern GIOStatus g_io_channel_set_encoding(GIOChannel *, const gchar *,
					       GError * *);
    extern gboolean g_scanner_eof(GScanner *);
    extern void g_cache_destroy(GCache *);
    extern gboolean g_spawn_sync(const gchar *, gchar * *, gchar * *,
				 GSpawnFlags, GSpawnChildSetupFunc,
				 gpointer, gchar * *, gchar * *, gint *,
				 GError * *);
    extern gboolean g_static_rw_lock_reader_trylock(GStaticRWLock *);
    extern void g_byte_array_sort(GByteArray *, GCompareFunc);
    extern void g_atomic_int_add(gint *, gint);
    extern gpointer g_async_queue_timed_pop(GAsyncQueue *, GTimeVal *);
    extern GHook *g_hook_get(GHookList *, gulong);
    extern void g_option_context_set_help_enabled(GOptionContext *,
						  gboolean);
    extern guint g_static_rec_mutex_unlock_full(GStaticRecMutex *);
    extern gboolean g_hash_table_lookup_extended(GHashTable *,
						 gconstpointer, gpointer *,
						 gpointer *);
    extern void g_date_add_years(GDate *, guint);
    extern void g_static_private_free(GStaticPrivate *);
    extern const gchar *g_quark_to_string(GQuark);
    extern GList *g_list_prepend(GList *, gpointer);
    extern gchar *g_utf8_find_next_char(const gchar *, const gchar *);
    extern void g_static_rw_lock_writer_lock(GStaticRWLock *);
    extern GIOStatus g_io_channel_read_line(GIOChannel *, gchar * *,
					    gsize *, gsize *, GError * *);
    extern void g_thread_pool_stop_unused_threads(void);
    extern const gchar *const *g_get_system_data_dirs(void);
    extern GLogLevelFlags g_log_set_fatal_mask(const gchar *,
					       GLogLevelFlags);
    extern GMainContext *g_main_loop_get_context(GMainLoop *);
    extern gpointer g_malloc(gulong);
    extern GIOStatus g_io_channel_flush(GIOChannel *, GError * *);
    extern gboolean g_file_test(const gchar *, GFileTest);
    extern void g_key_file_set_integer(GKeyFile *, const gchar *,
				       const gchar *, gint);
    extern void g_date_set_year(GDate *, GDateYear);
    extern gpointer g_once_impl(GOnce *, GThreadFunc, gpointer);
    extern void g_usleep(gulong);
    extern void g_thread_pool_push(GThreadPool *, gpointer, GError * *);
    extern void g_key_file_remove_comment(GKeyFile *, const gchar *,
					  const gchar *, GError * *);
    extern GTuples *g_relation_select(GRelation *, gconstpointer, gint);
    extern gboolean g_unichar_istitle(gunichar);
    extern gchar *g_strrstr(const gchar *, const gchar *);
    extern GQuark g_spawn_error_quark(void);
    extern GTokenType g_scanner_cur_token(GScanner *);
    extern void g_date_free(GDate *);
    extern gboolean g_io_channel_get_close_on_unref(GIOChannel *);
    extern GScanner *g_scanner_new(const GScannerConfig *);
    extern guint g_node_n_nodes(GNode *, GTraverseFlags);
    extern gint g_tree_height(GTree *);
    extern gboolean g_str_has_prefix(const gchar *, const gchar *);
    extern gunichar g_utf8_get_char_validated(const gchar *, gssize);
    extern void g_scanner_unexp_token(GScanner *, GTokenType,
				      const gchar *, const gchar *,
				      const gchar *, const gchar *, gint);
    extern GString *g_string_prepend_c(GString *, gchar);
    extern void g_relation_destroy(GRelation *);
    extern guint g_hash_table_foreach_steal(GHashTable *, GHRFunc,
					    gpointer);
    extern void g_free(gpointer);
    extern guint g_int_hash(gconstpointer);
    extern gboolean g_threads_got_initialized;
    extern void g_source_get_current_time(GSource *, GTimeVal *);
    extern GList *g_queue_pop_tail_link(GQueue *);
    extern GString *g_string_new(const gchar *);
    extern void g_key_file_set_boolean_list(GKeyFile *, const gchar *,
					    const gchar *, gboolean *,
					    gsize);
    extern GString *g_string_append(GString *, const gchar *);
    extern GByteArray *g_byte_array_append(GByteArray *, const guint8 *,
					   guint);
    extern void g_key_file_set_value(GKeyFile *, const gchar *,
				     const gchar *, const gchar *);
    extern gboolean g_pattern_spec_equal(GPatternSpec *, GPatternSpec *);
    extern GMainContext *g_main_context_new(void);
    extern gboolean g_unichar_ispunct(gunichar);
    extern guint8 g_date_get_sunday_weeks_in_year(GDateYear);
    extern void g_date_subtract_days(GDate *, guint);
    extern gboolean g_date_valid_weekday(GDateWeekday);
    extern gchar **g_strsplit_set(const gchar *, const gchar *, gint);
    extern void g_dataset_destroy(gconstpointer);
    extern gpointer g_async_queue_pop_unlocked(GAsyncQueue *);
    extern guint g_scanner_cur_position(GScanner *);
    extern guint g_date_get_day_of_year(const GDate *);
    extern GList *g_list_find_custom(GList *, gconstpointer, GCompareFunc);
    extern void g_source_unref(GSource *);
    extern GSList *g_slist_remove_link(GSList *, GSList *);
    extern GDateDay g_date_get_day(const GDate *);
    extern gboolean g_option_context_parse(GOptionContext *, gint *,
					   gchar * **, GError * *);
    extern void g_tree_foreach(GTree *, GTraverseFunc, gpointer);
    extern void g_string_chunk_free(GStringChunk *);
    extern gchar *g_strjoinv(const gchar *, gchar * *);
    extern GString *g_string_append_c(GString *, gchar);
    extern GString *g_string_truncate(GString *, gsize);
    extern const gchar *g_get_tmp_dir(void);
    extern void g_scanner_input_text(GScanner *, const gchar *, guint);
    extern gpointer g_list_nth_data(GList *, guint);
    extern GNode *g_node_last_child(GNode *);
    extern gboolean g_node_is_ancestor(GNode *, GNode *);
    extern GString *g_string_ascii_down(GString *);
    extern void g_blow_chunks(void);
    extern gboolean g_unichar_get_mirror_char(gunichar, gunichar *);
    extern GOptionGroup *g_option_group_new(const gchar *, const gchar *,
					    const gchar *, gpointer,
					    GDestroyNotify);
    extern const gchar *g_get_user_cache_dir(void);
    extern gboolean *g_key_file_get_boolean_list(GKeyFile *, const gchar *,
						 const gchar *, gsize *,
						 GError * *);
    extern void g_scanner_warn(GScanner *, const gchar *, ...);
    extern void g_queue_delete_link(GQueue *, GList *);
    extern guint g_direct_hash(gconstpointer);
    extern GSList *g_slist_find_custom(GSList *, gconstpointer,
				       GCompareFunc);
    extern GTokenValue g_scanner_cur_value(GScanner *);
    extern guint8 g_date_get_days_in_month(GDateMonth, GDateYear);
    extern gboolean g_get_charset(const char **);
    extern gboolean g_unichar_isalnum(gunichar);
    extern GList *g_list_reverse(GList *);
    extern void g_hook_insert_sorted(GHookList *, GHook *,
				     GHookCompareFunc);
    extern guint g_source_attach(GSource *, GMainContext *);
    extern gchar *g_strconcat(const gchar *, ...);
    extern void g_nullify_pointer(gpointer *);
    extern void g_ptr_array_remove_range(GPtrArray *, guint, guint);
    extern void g_static_rw_lock_free(GStaticRWLock *);
    extern GString *g_string_new_len(const gchar *, gssize);
    extern GList *g_list_insert_before(GList *, GList *, gpointer);
    extern void g_date_set_parse(GDate *, const gchar *);
    extern void g_log_remove_handler(const gchar *, guint);
    extern gboolean g_str_equal(gconstpointer, gconstpointer);
    extern GMainLoop *g_main_loop_ref(GMainLoop *);
    extern gchar *g_ucs4_to_utf8(const gunichar *, glong, glong *, glong *,
				 GError * *);
    extern gpointer g_memdup(gconstpointer, guint);
    extern GAllocator *g_allocator_new(const gchar *, guint);
    extern GList *g_completion_complete_utf8(GCompletion *, const gchar *,
					     gchar * *);
    extern void g_main_loop_run(GMainLoop *);
    extern void g_scanner_error(GScanner *, const gchar *, ...);
    extern void g_mem_chunk_reset(GMemChunk *);
    extern GThread *g_thread_create_full(GThreadFunc, gpointer, gulong,
					 gboolean, gboolean,
					 GThreadPriority, GError * *);
    extern gboolean g_date_is_first_of_month(const GDate *);
    extern gunichar *g_utf8_to_ucs4_fast(const gchar *, glong, glong *);
    extern void g_queue_reverse(GQueue *);
    extern void g_node_children_foreach(GNode *, GTraverseFlags,
					GNodeForeachFunc, gpointer);
    extern void g_timer_stop(GTimer *);
    extern GSourceFuncs g_timeout_funcs;
    extern gboolean g_main_context_wait(GMainContext *, GCond *, GMutex *);
    extern void g_set_prgname(const gchar *);
    extern void g_allocator_free(GAllocator *);
    extern const gchar
	*g_markup_parse_context_get_element(GMarkupParseContext *);
    extern guint g_parse_debug_string(const gchar *, const GDebugKey *,
				      guint);
    extern void g_error_free(GError *);
    extern gchar *g_string_chunk_insert_len(GStringChunk *, const gchar *,
					    gssize);
    extern GArray *g_array_new(gboolean, gboolean, guint);
    extern GDate *g_date_new_dmy(GDateDay, GDateMonth, GDateYear);
    extern GMemVTable *glib_mem_profiler_table;
    extern void g_qsort_with_data(gconstpointer, gint, gsize,
				  GCompareDataFunc, gpointer);
    extern gboolean g_shell_parse_argv(const gchar *, gint *, gchar * **,
				       GError * *);
    extern gchar *g_strchomp(gchar *);
    extern guint32 g_random_int(void);
    extern void g_option_context_set_main_group(GOptionContext *,
						GOptionGroup *);
    extern void g_date_clear(GDate *, guint);
    extern GIOStatus g_io_channel_read_unichar(GIOChannel *, gunichar *,
					       GError * *);
    extern GList *g_list_nth(GList *, guint);
    extern void g_node_destroy(GNode *);
    extern const gchar *glib_check_version(guint, guint, guint);
    extern GThread *g_thread_self(void);
    extern GList *g_list_sort_with_data(GList *, GCompareDataFunc,
					gpointer);
    extern void g_io_channel_set_line_term(GIOChannel *, const gchar *,
					   gint);
    extern GIOChannel *g_io_channel_unix_new(gint);
    extern GThreadFunctions g_thread_functions_for_glib_use;
    extern GString *g_string_insert(GString *, gssize, const gchar *);
    extern gpointer g_trash_stack_pop(GTrashStack * *);
    extern void g_hook_list_marshal(GHookList *, gboolean, GHookMarshaller,
				    gpointer);
    extern size_t g_iconv(GIConv, gchar * *, gsize *, gchar * *, gsize *);
    extern void g_queue_remove(GQueue *, gconstpointer);
    extern const gchar *g_path_skip_root(const gchar *);
    extern gint g_queue_link_index(GQueue *, GList *);
    extern gpointer g_tuples_index(GTuples *, gint, gint);
    extern GIOChannelError g_io_channel_error_from_errno(gint);
    extern void g_main_context_wakeup(GMainContext *);
    extern gboolean g_direct_equal(gconstpointer, gconstpointer);
    extern GSource *g_source_new(GSourceFuncs *, guint);
    extern gboolean g_idle_remove_by_data(gpointer);
    extern void g_io_channel_set_buffer_size(GIOChannel *, gsize);
    extern guint g_io_add_watch_full(GIOChannel *, gint, GIOCondition,
				     GIOFunc, gpointer, GDestroyNotify);
    extern void g_dir_rewind(GDir *);
    extern GSourceFuncs g_child_watch_funcs;
    extern gint g_iconv_close(GIConv);
    extern gchar *g_ascii_strdown(const gchar *, gssize);
    extern gchar *g_key_file_get_locale_string(GKeyFile *, const gchar *,
					       const gchar *,
					       const gchar *, GError * *);
    extern GQueue *g_queue_copy(GQueue *);
    extern guint g_node_depth(GNode *);
    extern const gchar *g_strsignal(gint);
    extern GSList *g_slist_concat(GSList *, GSList *);
    extern gboolean g_source_remove_by_funcs_user_data(GSourceFuncs *,
						       gpointer);
    extern GSource *g_io_create_watch(GIOChannel *, GIOCondition);
    extern gpointer g_cache_insert(GCache *, gpointer);
    extern gpointer g_scanner_lookup_symbol(GScanner *, const gchar *);
    extern GIOStatus g_io_channel_seek_position(GIOChannel *, gint64,
						GSeekType, GError * *);
    extern gboolean g_thread_use_default_impl;
    extern guint g_io_add_watch(GIOChannel *, GIOCondition, GIOFunc,
				gpointer);
    extern GSource *g_main_context_find_source_by_user_data(GMainContext *,
							    gpointer);
    extern GIConv g_iconv_open(const gchar *, const gchar *);
    extern gchar *g_strdup_vprintf(const gchar *, va_list);
    extern void g_datalist_clear(GData * *);
    extern void g_static_rw_lock_reader_unlock(GStaticRWLock *);
    extern gsize g_strlcpy(gchar *, const gchar *, gsize);
    extern GRand *g_rand_new_with_seed(guint32);
    extern guint g_thread_pool_unprocessed(GThreadPool *);
    extern GQuark g_file_error_quark(void);
    extern gdouble g_ascii_strtod(const gchar *, gchar * *);
    extern GByteArray *g_byte_array_prepend(GByteArray *, const guint8 *,
					    guint);
    extern GQuark g_quark_from_static_string(const gchar *);
    extern void g_unicode_canonical_ordering(gunichar *, gsize);
    extern gboolean g_ptr_array_remove_fast(GPtrArray *, gpointer);
    extern gint g_list_index(GList *, gconstpointer);
    extern void g_tree_destroy(GTree *);
    extern GDate *g_date_new(void);
    extern void g_thread_init_with_errorcheck_mutexes(GThreadFunctions *);
    extern void g_thread_init(GThreadFunctions *);

    extern gpointer g_slice_alloc (gsize block_size) G_GNUC_MALLOC;
    extern gpointer g_slice_alloc0 (gsize block_size) G_GNUC_MALLOC;
    extern void g_slice_free1 (gsize block_size, gpointer mem_block);
#define g_slice_new(type) \
  ((type*) g_slice_alloc (sizeof (type)))
#define g_slice_new0(type) \
  ((type*) g_slice_alloc0 (sizeof (type)))
#define g_slice_free(type, mem)				do {	\
  if (1) g_slice_free1 (sizeof (type), (mem));		\
  else   (void) ((type*) 0 == (mem)); 				\
} while (0)
#ifdef __cplusplus
}
#endif
#endif
