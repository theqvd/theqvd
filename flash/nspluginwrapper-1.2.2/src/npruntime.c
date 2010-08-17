/*
 *  npruntime.c - Scripting plugins support
 *
 *  nspluginwrapper (C) 2005-2009 Gwenole Beauchesne
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "sysdeps.h"

#include <assert.h>
#include <glib.h> /* <glib/ghash.h> */
#include "utils.h"
#include "npw-common.h"
#include "npw-malloc.h"

#define DEBUG 1
#include "debug.h"


// Defined in npw-{wrapper,viewer}.c
extern rpc_connection_t *g_rpc_connection attribute_hidden;

// Defined in npw-viewer.c
#if USE_PID_CHECK && NPW_IS_PLUGIN
extern bool pid_check(void);
#else
#define pid_check() true
#endif


/* ====================================================================== */
/* === NPClass Bridge                                                 === */
/* ====================================================================== */

static void g_NPClass_Invalidate(NPObject *npobj);
static bool g_NPClass_HasMethod(NPObject *npobj, NPIdentifier name);
static bool g_NPClass_Invoke(NPObject *npobj, NPIdentifier name, const NPVariant *args, uint32_t argCount, NPVariant *result);
static bool g_NPClass_InvokeDefault(NPObject *npobj, const NPVariant *args, uint32_t argCount, NPVariant *result);
static bool g_NPClass_HasProperty(NPObject *npobj, NPIdentifier name);
static bool g_NPClass_GetProperty(NPObject *npobj, NPIdentifier name, NPVariant *result);
static bool g_NPClass_SetProperty(NPObject *npobj, NPIdentifier name, const NPVariant *value);
static bool g_NPClass_RemoveProperty(NPObject *npobj, NPIdentifier name);

NPClass npclass_bridge = {
  NPW_NP_CLASS_STRUCT_VERSION,
  NULL,
  NULL,
  g_NPClass_Invalidate,
  g_NPClass_HasMethod,
  g_NPClass_Invoke,
  g_NPClass_InvokeDefault,
  g_NPClass_HasProperty,
  g_NPClass_GetProperty,
  g_NPClass_SetProperty,
  g_NPClass_RemoveProperty
};

static inline bool is_valid_npobject_class(NPObject *npobj)
{
  if (npobj == NULL || npobj->_class == NULL)
	return false;
  NPObjectInfo *npobj_info = npobject_info_lookup(npobj);
  if (npobj_info == NULL)
	return false;
  if (!npobj_info->is_valid)
	npw_printf("ERROR: NPObject %p is no longer valid!\n", npobj);
  return npobj_info->is_valid;
}

// NPClass::Invalidate
int npclass_handle_Invalidate(rpc_connection_t *connection)
{
  D(bug("npclass_handle_Invalidate\n"));

  NPObject *npobj;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NP_OBJECT, &npobj,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::Invalidate() get args", error);
	return error;
  }

  if (npobj && is_valid_npobject_class(npobj) && npobj->_class->invalidate) {
	D(bugiI("NPClass::Invalidate(npobj %p)\n", npobj));
	npobj->_class->invalidate(npobj);
	D(bugiD("NPClass::Invalidate done\n"));
  }

  return rpc_method_send_reply(connection, RPC_TYPE_INVALID);
}

static void npclass_invoke_Invalidate(NPObject *npobj)
{
  npw_return_if_fail(rpc_method_invoke_possible(g_rpc_connection));

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPCLASS_INVALIDATE,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::Invalidate() invoke", error);
	return;
  }

  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::Invalidate() wait for reply", error);
	return;
  }
}

void g_NPClass_Invalidate(NPObject *npobj)
{
  if (!is_valid_npobject_class(npobj))
	return;

  if (!pid_check()) {
	npw_printf("WARNING: NPClass::Invalidate called from the wrong process\n");
	return;
  }

  D(bugiI("NPClass::Invalidate(npobj %p)\n", npobj));
  npclass_invoke_Invalidate(npobj);
  D(bugiD("NPClass::Invalidate done\n"));
}

// NPClass::HasMethod
int npclass_handle_HasMethod(rpc_connection_t *connection)
{
  D(bug("npclass_handle_HasMethod\n"));

  NPObject *npobj;
  NPIdentifier name;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NP_OBJECT, &npobj,
								  RPC_TYPE_NP_IDENTIFIER, &name,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::HasMethod() get args", error);
	return error;
  }

  uint32_t ret = false;
  if (npobj && is_valid_npobject_class(npobj) && npobj->_class->hasMethod) {
	D(bugiI("NPClass::HasMethod(npobj %p, name id %p)\n", npobj, name));
	ret = npobj->_class->hasMethod(npobj, name);
	D(bugiD("NPClass::HasMethod return: %d\n", ret));
  }

  return rpc_method_send_reply(connection,
							   RPC_TYPE_UINT32, ret,
							   RPC_TYPE_INVALID);
}

static bool npclass_invoke_HasMethod(NPObject *npobj, NPIdentifier name)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPCLASS_HAS_METHOD,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, name,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::HasMethod() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_UINT32, &ret, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::HasMethod() wait for reply", error);
	return false;
  }

  return ret;
}

bool g_NPClass_HasMethod(NPObject *npobj, NPIdentifier name)
{
  if (!is_valid_npobject_class(npobj))
	return false;

  if (!pid_check()) {
	npw_printf("WARNING: NPClass::HasMethod called from the wrong process\n");
	return false;
  }

  D(bugiI("NPClass::HasMethod(npobj %p, name id %p)\n", npobj, name));
  bool ret = npclass_invoke_HasMethod(npobj, name);
  D(bugiD("NPClass::HasMethod return: %d\n", ret));
  return ret;
}

// NPClass::Invoke
int npclass_handle_Invoke(rpc_connection_t *connection)
{
  D(bug("npclass_handle_Invoke\n"));

  NPObject *npobj;
  NPIdentifier name;
  uint32_t argCount;
  NPVariant *args;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NP_OBJECT, &npobj,
								  RPC_TYPE_NP_IDENTIFIER, &name,
								  RPC_TYPE_ARRAY, RPC_TYPE_NP_VARIANT, &argCount, &args,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::Invoke() get args", error);
	return error;
  }

  uint32_t ret = false;
  NPVariant result;
  VOID_TO_NPVARIANT(result);
  if (npobj && is_valid_npobject_class(npobj) && npobj->_class->invoke) {
	D(bugiI("NPClass::Invoke(npobj %p, name id %p)\n", npobj, name));
	print_npvariant_args(args, argCount);
	ret = npobj->_class->invoke(npobj, name, args, argCount, &result);
	gchar *result_str = string_of_NPVariant(&result);
	D(bugiD("NPClass::Invoke return: %d (%s)\n", ret, result_str));
	g_free(result_str);
  }

  int rpc_ret = rpc_method_send_reply(connection,
									  RPC_TYPE_UINT32, ret,
									  RPC_TYPE_NP_VARIANT, &result,
									  RPC_TYPE_INVALID);

  if (args) {
	for (int i = 0; i < argCount; i++)
	  NPN_ReleaseVariantValue(&args[i]);
	free(args);
  }

  NPN_ReleaseVariantValue(&result);
  return rpc_ret;
}

static bool npclass_invoke_Invoke(NPObject *npobj, NPIdentifier name, const NPVariant *args, uint32_t argCount,
								  NPVariant *result)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPCLASS_INVOKE,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, name,
								RPC_TYPE_ARRAY, RPC_TYPE_NP_VARIANT, argCount, args,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::Invoke() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_NP_VARIANT, result,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::Invoke() wait for reply", error);
	return false;
  }

  return ret;
}

bool g_NPClass_Invoke(NPObject *npobj, NPIdentifier name, const NPVariant *args, uint32_t argCount,
					  NPVariant *result)
{
  if (result == NULL)
	return false;
  VOID_TO_NPVARIANT(*result);

  if (!is_valid_npobject_class(npobj))
	return false;

  if (!pid_check()) {
	npw_printf("WARNING: NPClass::Invoke called from the wrong process\n");
	return false;
  }

  D(bugiI("NPClass::Invoke(npobj %p, name id %p)\n", npobj, name));
  print_npvariant_args(args, argCount);
  bool ret = npclass_invoke_Invoke(npobj, name, args, argCount, result);
  gchar *result_str = string_of_NPVariant(result);
  D(bugiD("NPClass::Invoke return: %d (%s)\n", ret, result_str));
  g_free(result_str);
  return ret;
}

// NPClass::InvokeDefault
int npclass_handle_InvokeDefault(rpc_connection_t *connection)
{
  D(bug("npclass_handle_InvokeDefault\n"));

  NPObject *npobj;
  uint32_t argCount;
  NPVariant *args;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NP_OBJECT, &npobj,
								  RPC_TYPE_ARRAY, RPC_TYPE_NP_VARIANT, &argCount, &args,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::InvokeDefault() get args", error);
	return error;
  }

  uint32_t ret = false;
  NPVariant result;
  VOID_TO_NPVARIANT(result);
  if (npobj && is_valid_npobject_class(npobj) && npobj->_class->invokeDefault) {
	D(bugiI("NPClass::InvokeDefault(npobj %p)\n", npobj));
	print_npvariant_args(args, argCount);
	ret = npobj->_class->invokeDefault(npobj, args, argCount, &result);
	gchar *result_str = string_of_NPVariant(&result);
	D(bugiD("NPClass::InvokeDefault return: %d (%s)\n", ret, result_str));
	g_free(result_str);
  }

  int rpc_ret = rpc_method_send_reply(connection,
									  RPC_TYPE_UINT32, ret,
									  RPC_TYPE_NP_VARIANT, &result,
									  RPC_TYPE_INVALID);

  if (args) {
	for (int i = 0; i < argCount; i++)
	  NPN_ReleaseVariantValue(&args[i]);
	free(args);
  }

  NPN_ReleaseVariantValue(&result);
  return rpc_ret;
}

static bool npclass_invoke_InvokeDefault(NPObject *npobj, const NPVariant *args, uint32_t argCount,
										 NPVariant *result)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPCLASS_INVOKE_DEFAULT,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_ARRAY, RPC_TYPE_NP_VARIANT, argCount, args,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::InvokeDefault() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_NP_VARIANT, result,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::InvokeDefault() wait for reply", error);
	return false;
  }

  return ret;
}

bool g_NPClass_InvokeDefault(NPObject *npobj, const NPVariant *args, uint32_t argCount,
							 NPVariant *result)
{
  if (result == NULL)
	return false;
  VOID_TO_NPVARIANT(*result);

  if (!is_valid_npobject_class(npobj))
	return false;

  if (!pid_check()) {
	npw_printf("WARNING: NPClass::InvokeDefault called from the wrong process\n");
	return false;
  }

  D(bugiI("NPClass::InvokeDefault(npobj %p)\n", npobj));
  print_npvariant_args(args, argCount);
  bool ret = npclass_invoke_InvokeDefault(npobj, args, argCount, result);
  gchar *result_str = string_of_NPVariant(result);
  D(bugiD("NPClass::InvokeDefault return: %d (%s)\n", ret, result_str));
  g_free(result_str);
  return ret;
}

// NPClass::HasProperty
int npclass_handle_HasProperty(rpc_connection_t *connection)
{
  D(bug("npclass_handle_HasProperty\n"));

  NPObject *npobj;
  NPIdentifier name;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NP_OBJECT, &npobj,
								  RPC_TYPE_NP_IDENTIFIER, &name,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::HasProperty() get args", error);
	return error;
  }

  uint32_t ret = false;
  if (npobj && is_valid_npobject_class(npobj) && npobj->_class->hasProperty) {
	D(bugiI("NPClass::HasProperty(npobj %p, name id %p)\n", npobj, name));
	ret = npobj->_class->hasProperty(npobj, name);
	D(bugiD("NPClass::HasProperty return: %d\n", ret));
  }

  return rpc_method_send_reply(connection,
							   RPC_TYPE_UINT32, ret,
							   RPC_TYPE_INVALID);
}

static bool npclass_invoke_HasProperty(NPObject *npobj, NPIdentifier name)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPCLASS_HAS_PROPERTY,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, name,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::HasProperty() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_UINT32, &ret, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::HasProperty() wait for reply", error);
	return false;
  }

  return ret;
}

bool g_NPClass_HasProperty(NPObject *npobj, NPIdentifier name)
{
  if (!is_valid_npobject_class(npobj))
	return false;

  if (!pid_check()) {
	npw_printf("WARNING: NPClass::HasProperty called from the wrong process\n");
	return false;
  }

  D(bugiI("NPClass::HasProperty(npobj %p, name id %p)\n", npobj, name));
  bool ret = npclass_invoke_HasProperty(npobj, name);
  D(bugiD("NPClass::HasProperty return: %d\n", ret));
  return ret;
}
  
// NPClass::GetProperty
int npclass_handle_GetProperty(rpc_connection_t *connection)
{
  D(bug("npclass_handle_GetProperty\n"));

  NPObject *npobj;
  NPIdentifier name;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NP_OBJECT, &npobj,
								  RPC_TYPE_NP_IDENTIFIER, &name,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::GetProperty() get args", error);
	return error;
  }

  uint32_t ret = false;
  NPVariant result;
  VOID_TO_NPVARIANT(result);
  if (npobj && is_valid_npobject_class(npobj) && npobj->_class->getProperty) {
	D(bugiI("NPClass::GetProperty(npobj %p, name id %p)\n", npobj, name));
	ret = npobj->_class->getProperty(npobj, name, &result);
	gchar *result_str = string_of_NPVariant(&result);
	D(bugiD("NPClass::GetProperty return: %d (%s)\n", ret, result_str));
	g_free(result_str);
  }

  int rpc_ret = rpc_method_send_reply(connection,
									  RPC_TYPE_UINT32, ret,
									  RPC_TYPE_NP_VARIANT, &result,
									  RPC_TYPE_INVALID);

  NPN_ReleaseVariantValue(&result);
  return rpc_ret;
}

static bool npclass_invoke_GetProperty(NPObject *npobj, NPIdentifier name, NPVariant *result)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPCLASS_GET_PROPERTY,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, name,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::GetProperty() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_NP_VARIANT, result,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::GetProperty() wait for reply", error);
	return false;
  }

  return ret;
}

bool g_NPClass_GetProperty(NPObject *npobj, NPIdentifier name, NPVariant *result)
{
  if (result == NULL)
	return false;
  VOID_TO_NPVARIANT(*result);

  if (!is_valid_npobject_class(npobj))
	return false;

  if (!pid_check()) {
	npw_printf("WARNING: NPClass::GetProperty called from the wrong process\n");
	return false;
  }

  D(bugiI("NPClass::GetProperty(npobj %p, name id %p)\n", npobj, name));
  bool ret = npclass_invoke_GetProperty(npobj, name, result);
  gchar *result_str = string_of_NPVariant(result);
  D(bugiD("NPClass::GetProperty return: %d (%s)\n", ret, result_str));
  g_free(result_str);
  return ret;
}
  
// NPClass::SetProperty
int npclass_handle_SetProperty(rpc_connection_t *connection)
{
  D(bug("npclass_handle_SetProperty\n"));

  NPObject *npobj;
  NPIdentifier name;
  NPVariant value;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NP_OBJECT, &npobj,
								  RPC_TYPE_NP_IDENTIFIER, &name,
								  RPC_TYPE_NP_VARIANT, &value,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::SetProperty() get args", error);
	return error;
  }

  uint32_t ret = false;
  if (npobj && is_valid_npobject_class(npobj) && npobj->_class->setProperty) {
	D(bugiI("NPClass::SetProperty(npobj %p, name id %p)\n", npobj, name));
	ret = npobj->_class->setProperty(npobj, name, &value);
	D(bugiD("NPClass::SetProperty return: %d\n", ret));
  }

  int rpc_ret = rpc_method_send_reply(connection,
									  RPC_TYPE_UINT32, ret,
									  RPC_TYPE_INVALID);

  NPN_ReleaseVariantValue(&value);
  return rpc_ret;
}

static bool npclass_invoke_SetProperty(NPObject *npobj, NPIdentifier name, const NPVariant *value)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPCLASS_SET_PROPERTY,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, name,
								RPC_TYPE_NP_VARIANT, value,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::SetProperty() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection,
									RPC_TYPE_UINT32, &ret,
									RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::SetProperty() wait for reply", error);
	return false;
  }

  return ret;
}

bool g_NPClass_SetProperty(NPObject *npobj, NPIdentifier name, const NPVariant *value)
{
  if (value == NULL) {
	npw_printf("WARNING: NPClass::SetProperty() called with a NULL value\n");
	return false;
  }

  if (!is_valid_npobject_class(npobj))
	return false;

  if (!pid_check()) {
	npw_printf("WARNING: NPClass::SetProperty called from the wrong process\n");
	return false;
  }

  D(bugiI("NPClass::SetProperty(npobj %p, name id %p)\n", npobj, name));
  bool ret = npclass_invoke_SetProperty(npobj, name, value);
  D(bugiD("NPClass::SetProperty return: %d\n", ret));
  return ret;
}

// NPClass::RemoveProperty
int npclass_handle_RemoveProperty(rpc_connection_t *connection)
{
  D(bug("npclass_handle_RemoveProperty\n"));

  NPObject *npobj;
  NPIdentifier name;
  int error = rpc_method_get_args(connection,
								  RPC_TYPE_NP_OBJECT, &npobj,
								  RPC_TYPE_NP_IDENTIFIER, &name,
								  RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::RemoveProperty() get args", error);
	return error;
  }

  uint32_t ret = false;
  if (npobj && is_valid_npobject_class(npobj) && npobj->_class->removeProperty) {
	D(bugiI("NPClass::RemoveProperty(npobj %p, name id %p)\n", npobj, name));
	ret = npobj->_class->removeProperty(npobj, name);
	D(bugiD("NPClass::RemoveProperty return: %d\n", ret));
  }

  return rpc_method_send_reply(connection,
							   RPC_TYPE_UINT32, ret,
							   RPC_TYPE_INVALID);
}

static bool npclass_invoke_RemoveProperty(NPObject *npobj, NPIdentifier name)
{
  npw_return_val_if_fail(rpc_method_invoke_possible(g_rpc_connection), false);

  int error = rpc_method_invoke(g_rpc_connection,
								RPC_METHOD_NPCLASS_REMOVE_PROPERTY,
								RPC_TYPE_NP_OBJECT, npobj,
								RPC_TYPE_NP_IDENTIFIER, name,
								RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::RemoveProperty() invoke", error);
	return false;
  }

  uint32_t ret;
  error = rpc_method_wait_for_reply(g_rpc_connection, RPC_TYPE_UINT32, &ret, RPC_TYPE_INVALID);

  if (error != RPC_ERROR_NO_ERROR) {
	npw_perror("NPClass::RemoveProperty() wait for reply", error);
	return false;
  }

  return ret;
}

bool g_NPClass_RemoveProperty(NPObject *npobj, NPIdentifier name)
{
  if (!is_valid_npobject_class(npobj))
	return false;

  if (!pid_check()) {
	npw_printf("WARNING: NPClass::RemoveProperty called from the wrong process\n");
	return false;
  }
  
  D(bugiI("NPClass::RemoveProperty(npobj %p, name id %p)\n", npobj, name));
  bool ret = npclass_invoke_RemoveProperty(npobj, name);
  D(bugiD("NPClass::RemoveProperty return: %d\n", ret));
  return ret;
}


/* ====================================================================== */
/* === NPObjectInfo                                                   === */
/* ====================================================================== */

NPObjectInfo *npobject_info_new(NPObject *npobj)
{
  NPObjectInfo *npobj_info = NPW_MemNew0(NPObjectInfo, 1);
  if (npobj_info) {
	static uint32_t id;
	npobj_info->npobj = npobj;
	npobj_info->npobj_id = ++id;
	npobj_info->is_valid = true;
  }
  return npobj_info;
}

void npobject_info_destroy(NPObjectInfo *npobj_info)
{
  if (npobj_info) {
	npw_plugin_instance_unref(npobj_info->plugin);
	NPW_MemFree(npobj_info);
  }
}


/* ====================================================================== */
/* === NPObject                                                       === */
/* ====================================================================== */

static void npobject_hash_table_insert(NPObject *npobj, NPObjectInfo *npobj_info);
static bool npobject_hash_table_remove(NPObject *npobj);

static NPObject *_npobject_new(NPP instance, NPClass *class)
{
  NPObject *npobj;
  if (class && class->allocate)
	npobj = class->allocate(instance, class);
  else
	npobj = malloc(sizeof(*npobj));
  if (npobj) {
	npobj->_class = class ? class : &npclass_bridge;
	npobj->referenceCount = 1;
  }
  return npobj;
}

static void _npobject_destroy(NPObject *npobj)
{
  if (npobj) {
	if (npobj->_class && npobj->_class->deallocate)
	  npobj->_class->deallocate(npobj);
	else
	  free(npobj);
  }
}

NPObject *npobject_new(uint32_t npobj_id, NPP instance, NPClass *class)
{
  NPObject *npobj = _npobject_new(instance, class);
  if (npobj == NULL)
	return NULL;

  NPObjectInfo *npobj_info = npobject_info_new(npobj);
  if (npobj_info == NULL) {
	_npobject_destroy(npobj);
	return NULL;
  }
  npobj_info->npobj_id = npobj_id;
  npobj_info->plugin = npw_plugin_instance_ref(NPW_PLUGIN_INSTANCE(instance));
  npobject_associate(npobj, npobj_info);
  return npobj;
}

void npobject_destroy(NPObject *npobj)
{
  if (npobj)
	npobject_hash_table_remove(npobj);

  _npobject_destroy(npobj);
}

void npobject_associate(NPObject *npobj, NPObjectInfo *npobj_info)
{
  assert(npobj && npobj_info && npobj_info->npobj_id > 0);
  npobject_hash_table_insert(npobj, npobj_info);
}


/* ====================================================================== */
/* === NPObject Repository                                            === */
/* ====================================================================== */

// NOTE: those hashes must be maintained in a whole, not separately
static GHashTable *g_npobjects = NULL;			// (NPObject *)  -> (NPObjectInfo *)
static GHashTable *g_npobject_ids = NULL;		// (NPObject ID) -> (NPObject *)

bool npobject_bridge_new(void)
{
  if ((g_npobjects = g_hash_table_new_full(NULL, NULL, NULL, (GDestroyNotify)npobject_info_destroy)) == NULL)
	return false;
  if ((g_npobject_ids = g_hash_table_new(NULL, NULL)) == NULL)
	return false;
  return true;
}

void npobject_bridge_destroy(void)
{
  if (g_npobject_ids) {
	g_hash_table_destroy(g_npobject_ids);
	g_npobject_ids = NULL;
  }
  if (g_npobjects) {
	g_hash_table_destroy(g_npobjects);
	g_npobjects = NULL;
  }
}

void npobject_hash_table_insert(NPObject *npobj, NPObjectInfo *npobj_info)
{
  g_hash_table_insert(g_npobjects, npobj, npobj_info);
  g_hash_table_insert(g_npobject_ids, (void *)(uintptr_t)npobj_info->npobj_id, npobj);
}

bool npobject_hash_table_remove(NPObject *npobj)
{
  NPObjectInfo *npobj_info = npobject_info_lookup(npobj);
  assert(npobj_info != NULL);
  bool removed_all = true;
  if (!g_hash_table_remove(g_npobject_ids, (void *)(uintptr_t)npobj_info->npobj_id))
	removed_all = false;
  if (!g_hash_table_remove(g_npobjects, npobj))
	removed_all = false;
  return removed_all;
}

NPObjectInfo *npobject_info_lookup(NPObject *npobj)
{
  return g_hash_table_lookup(g_npobjects, npobj);
}

NPObject *npobject_lookup(uint32_t npobj_id)
{
  return g_hash_table_lookup(g_npobject_ids, (void *)(uintptr_t)npobj_id);
}

static void npruntime_deactivate_func(gpointer key, gpointer value, gpointer user_data)
{
  NPObjectInfo *npobj_info = (NPObjectInfo *)value;
  npobj_info->is_valid = false;
}

void npruntime_deactivate(void)
{
  g_hash_table_foreach(g_npobjects, npruntime_deactivate_func, NULL);
}


/* ====================================================================== */
/* === NPVariant helpers                                              === */
/* ====================================================================== */

void
npvariant_clear(NPVariant *variant)
{
  switch (variant->type) {
  case NPVariantType_Void:
  case NPVariantType_Null:
  case NPVariantType_Bool:
  case NPVariantType_Int32:
  case NPVariantType_Double:
	break;
  case NPVariantType_String:
	{
	  NPString *s = &NPVARIANT_TO_STRING(*variant);
	  if (s->utf8characters)
		NPN_MemFree((void *)s->utf8characters);
	  break;
	}
  case NPVariantType_Object:
	{
	  NPObject *npobj = NPVARIANT_TO_OBJECT(*variant);
	  if (npobj)
		NPN_ReleaseObject(npobj);
	  break;
	}
  }
  VOID_TO_NPVARIANT(*variant);
}

// Make sure to deallocate with g_free() since it comes from a GString
gchar *
string_of_NPVariant(const NPVariant *arg)
{
#if DEBUG
  if (arg == NULL)
	return NULL;
  GString *str = g_string_new(NULL);
  switch (arg->type)
	{
	case NPVariantType_Void:
	  g_string_append_printf(str, "void");
	  break;
	case NPVariantType_Null:
	  g_string_append_printf(str, "null");
	  break;
	case NPVariantType_Bool:
	  g_string_append(str, arg->value.boolValue ? "true" : "false");
	  break;
	case NPVariantType_Int32:
	  g_string_append_printf(str, "%d", arg->value.intValue);
	  break;
	case NPVariantType_Double:
	  g_string_append_printf(str, "%f", arg->value.doubleValue);
	  break;
	case NPVariantType_String:
	  g_string_append_c(str, '\'');
	  g_string_append_len(str,
						  arg->value.stringValue.utf8characters,
						  arg->value.stringValue.utf8length);
	  g_string_append_c(str, '\'');
	  break;
	case NPVariantType_Object:
	  g_string_append_printf(str, "<object %p>", arg->value.objectValue);
	  break;
	default:
	  g_string_append_printf(str, "<invalid type %d>", arg->type);
	  break;
	}
  return g_string_free(str, FALSE);
#endif
  return NULL;
}

void
print_npvariant_args(const NPVariant *args, uint32_t nargs)
{
#if DEBUG
  GString *str = g_string_new(NULL);
  for (int i = 0; i < nargs; i++) {
	if (i > 0)
	  g_string_append(str, ", ");
	gchar *argstr = string_of_NPVariant(&args[i]);
	g_string_append(str, argstr);
	g_free(argstr);
  }
  D(bug("%u args (%s)\n", nargs, str->str));
  g_string_free(str, TRUE);
#endif
}
