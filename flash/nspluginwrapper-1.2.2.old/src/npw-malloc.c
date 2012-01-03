/*
 *  npw-malloc.c - Memory allocation
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

#define DEBUG 1
#include "debug.h"

typedef void *(*NPW_MemAllocProcPtr)  (uint32_t);
typedef void *(*NPW_MemAlloc0ProcPtr) (uint32_t);
typedef void  (*NPW_MemFreeProcPtr)   (void *);

typedef struct _NPW_MallocHooks NPW_MallocHooks;
struct _NPW_MallocHooks
{
  NPW_MemAllocProcPtr  memalloc;
  NPW_MemAlloc0ProcPtr memalloc0;
  NPW_MemFreeProcPtr   memfree;
};

/* ====================================================================== */
/* === Standard C library                                             === */
/* ====================================================================== */

#ifndef USE_MALLOC_LIBC
#define USE_MALLOC_LIBC 0
#endif

#if USE_MALLOC_LIBC
#include <stdlib.h>

static void *
NPW_Libc_MemAlloc (uint32_t size)
{
  return malloc (size);
}

static void *
NPW_Libc_MemAlloc0 (uint32_t size)
{
  return calloc (1, size);
}

static void
NPW_Libc_MemFree (void *ptr)
{
  free (ptr);
}

static const NPW_MallocHooks g_libc_hooks = {
  NPW_Libc_MemAlloc,
  NPW_Libc_MemAlloc0,
  NPW_Libc_MemFree
};
#endif

/* ====================================================================== */
/* === Glib support                                                   === */
/* ====================================================================== */

#ifndef USE_MALLOC_GLIB
#define USE_MALLOC_GLIB 0
#endif

#if USE_MALLOC_GLIB
#include <glib.h>

#define NPW_GLIB_MALLOC_MAGIC 0x476c6962 /* 'Glib' */

typedef struct _NPW_Glib_MemBlock NPW_Glib_MemBlock;
struct _NPW_Glib_MemBlock
{
  uint32_t magic;
  uint32_t real_size;
  char     data[];
};

static void *
NPW_Glib_MemAlloc (uint32_t size)
{
  uint32_t real_size;
  NPW_Glib_MemBlock *mem;

  real_size = sizeof (*mem) + size;
  if ((mem = g_slice_alloc (real_size)) == NULL)
    return NULL;
  mem->magic     = NPW_GLIB_MALLOC_MAGIC;
  mem->real_size = real_size;
  return &mem->data[0];
}

static void *
NPW_Glib_MemAlloc0 (uint32_t size)
{
  uint32_t real_size;
  NPW_Glib_MemBlock *mem;

  real_size = sizeof (*mem) + size;
  if ((mem = g_slice_alloc0 (real_size)) == NULL)
    return NULL;
  mem->magic     = NPW_GLIB_MALLOC_MAGIC;
  mem->real_size = real_size;
  return &mem->data[0];
}

static void
NPW_Glib_MemFree (void *ptr)
{
  if (ptr == NULL)
    return;
  NPW_Glib_MemBlock *mem = (NPW_Glib_MemBlock *)((char *)ptr - sizeof (*mem));
  if (mem->magic == NPW_GLIB_MALLOC_MAGIC)
    g_slice_free1 (mem->real_size, mem);
  else
    {
      D(bug("WARNING: block %p was not allocated with NPN_MemAlloc(), reverting to libc free()\n", ptr));
      free (ptr);
    }
}

static const NPW_MallocHooks g_glib_hooks = {
  NPW_Glib_MemAlloc,
  NPW_Glib_MemAlloc0,
  NPW_Glib_MemFree
};
#endif

/* ====================================================================== */
/* === Public interface                                               === */
/* ====================================================================== */

#define N_MALLOC_LIBS (USE_MALLOC_LIBC + USE_MALLOC_GLIB)

#ifndef CONCAT
#define CONCAT_(a,b) a##b
#define CONCAT(a,b)  CONCAT_(a,b)
#endif

#define get_default_malloc_hooks() \
  (&CONCAT(CONCAT(g_,DEFAULT_MALLOC_LIB),_hooks))

#if N_MALLOC_LIBS > 1
static const NPW_MallocHooks *
do_get_malloc_hooks (void)
{
  const char *malloc_lib;
  if ((malloc_lib =  getenv ("NPW_MALLOC_LIB")) != NULL)
    {
#if USE_MALLOC_LIBC
      if (strcmp (malloc_lib, "libc") == 0)
	return &g_libc_hooks;
#endif
#if USE_MALLOC_GLIB
      if (strcmp (malloc_lib, "glib") == 0)
	return &g_glib_hooks;
#endif
    }
  return get_default_malloc_hooks ();
}

static inline const NPW_MallocHooks *
get_malloc_hooks (void)
{
  static const NPW_MallocHooks *malloc_hooks = NULL;
  if (malloc_hooks == NULL)
    malloc_hooks = do_get_malloc_hooks ();
  return malloc_hooks;
}
#else
#define get_malloc_hooks() get_default_malloc_hooks()
#endif

void *
NPW_MemAlloc (uint32_t size)
{
  return get_malloc_hooks ()->memalloc (size);
}

void *
NPW_MemAlloc0 (uint32_t size)
{
  return get_malloc_hooks ()->memalloc0 (size);
}

void *
NPW_MemAllocCopy (uint32_t size, const void *src)
{
  void *ptr = NPW_MemAlloc (size);
  if (ptr)
    memcpy (ptr, src, size);
  return ptr;
}

void
NPW_MemFree (void *ptr)
{
  get_malloc_hooks ()->memfree (ptr);
}
