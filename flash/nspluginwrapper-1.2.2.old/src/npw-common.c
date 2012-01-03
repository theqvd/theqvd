/*
 *  npw-common.c - Common code for both the wrapper and the plugin
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
#include "npw-common.h"
#include "npw-malloc.h"

#define DEBUG 0
#include "debug.h"


/* ====================================================================== */
/* === Plugin instances                                              === */
/* ====================================================================== */

void *
npw_plugin_instance_new(NPW_PluginInstanceClass *klass)
{
  NPW_PluginInstance *plugin;
  if (klass && klass->allocate)
    plugin = klass->allocate ();
  else
    plugin = NPW_MemNew0 (NPW_PluginInstance, 1);
  if (plugin)
    {
      plugin->klass = klass;
      plugin->refcount = 1;
      plugin->is_valid = true;
    }
  return plugin;
}

void *
npw_plugin_instance_ref(void *ptr)
{
  NPW_PluginInstance *plugin = (NPW_PluginInstance *)ptr;
  if (plugin)
    plugin->refcount++;
  return plugin;
}

void
npw_plugin_instance_unref(void *ptr)
{
  NPW_PluginInstance *plugin = (NPW_PluginInstance *)ptr;
  if (plugin == NULL)
    return;
  if (--plugin->refcount > 0)
    return;
  NPW_PluginInstanceClass *klass = plugin->klass;
  if (klass && klass->finalize)
    klass->finalize (plugin);
  if (klass && klass->deallocate)
    klass->deallocate (plugin);
  else
    NPW_MemFree (plugin);
}

void
npw_plugin_instance_invalidate(void *ptr)
{
  NPW_PluginInstance *plugin = (NPW_PluginInstance *)ptr;
  if (plugin == NULL)
    return;
  NPW_PluginInstanceClass *klass = plugin->klass;
  if (klass && klass->invalidate)
    klass->invalidate(ptr);
  plugin->is_valid = false;
}

/* ====================================================================== */
/* === NPAPI interface                                                === */
/* ====================================================================== */

static NPNetscapeFuncs g_mozilla_funcs;
static NPPluginFuncs   g_plugin_funcs;

void
NPW_InitializeFuncs (NPNetscapeFuncs *mozilla_funcs,
		     NPPluginFuncs   *plugin_funcs)
{
  memcpy (&g_mozilla_funcs, mozilla_funcs,
	  MIN (sizeof (g_mozilla_funcs), mozilla_funcs->size));
  memcpy (&g_plugin_funcs, plugin_funcs,
	  MIN (sizeof (g_plugin_funcs), plugin_funcs->size));
}

void *
NPN_MemAlloc (uint32_t size)
{
  return CallNPN_MemAllocProc (g_mozilla_funcs.memalloc, size);
}

void
NPN_MemFree (void *ptr)
{
  CallNPN_MemFreeProc (g_mozilla_funcs.memfree, ptr);
}

uint32_t
NPN_MemFlush (uint32_t size)
{
  return CallNPN_MemFlushProc (g_mozilla_funcs.memflush, size);
}

NPObject *
NPN_RetainObject (NPObject *npobj)
{
  return CallNPN_RetainObjectProc (g_mozilla_funcs.retainobject, npobj);
}

void
NPN_ReleaseObject (NPObject *npobj)
{
  CallNPN_ReleaseObjectProc (g_mozilla_funcs.releaseobject, npobj);
}

void
NPN_ReleaseVariantValue (NPVariant *var)
{
  CallNPN_ReleaseVariantValueProc (g_mozilla_funcs.releasevariantvalue, var);
}

/* ====================================================================== */
/* === Identifiers                                                    === */
/* ====================================================================== */

NPW_Identifier
NPW_CreateIntIdentifier (int32_t value)
{
  NPW_Identifier id = NPW_MemAlloc0 (sizeof (*id));
  if (id)
    {
      id->type    = NPW_IdentifierType_Integer;
      id->value.i = value;
    }
  return id;
}

NPW_Identifier
NPW_CreateStringIdentifier (const char *str)
{
  char           *str_copy;
  NPW_Identifier id;
  str_copy = strdup (str);
  if ((id = NPW_CreateStringIdentifierSink (str_copy)) == NULL)
    free (str_copy);
  return id;
}

NPW_Identifier
NPW_CreateStringIdentifierSink (char *str)
{
  NPW_Identifier id = NPW_MemAlloc0 (sizeof (*id));
  if (id)
    {
      id->type    = NPW_IdentifierType_String;
      id->value.s = str;
    }
  return id;
}

void
NPW_DestroyIdentifier (NPW_Identifier id)
{
  if (id == NULL)
    return;
  if (NPW_IsStringIdentifier (id) && id->value.s)
    free (id->value.s);
  NPW_MemFree (id);
}
