/*
 *  npw-malloc.h - Memory allocation
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

#ifndef NPW_MALLOC_H
#define NPW_MALLOC_H

void *
NPW_MemAlloc (uint32_t size);

void *
NPW_MemAlloc0 (uint32_t size);

void *
NPW_MemAllocCopy (uint32_t size, const void *ptr);

void
NPW_MemFree (void *ptr);

#define NPW_MemNew(type, n) \
  ((type *) NPW_MemAlloc ((n) * sizeof (type)))

#define NPW_MemNew0(type, n) \
  ((type *) NPW_MemAlloc0 ((n) * sizeof (type)))

#define NPW_MemClone(type, ptr) \
  ((type *) NPW_MemAllocCopy (sizeof (type), ptr))

#endif /* NPW_MALLOC_H */
