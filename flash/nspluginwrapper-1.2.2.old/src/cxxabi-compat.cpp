/*
 *  cxxabi-compat.cpp - Compatibility glue for older libg++ symbols
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

/* Original code from Mozilla */

// On x86 linux, the current builds of some popular plugins (notably
// flashplayer and real) expect a few builtin symbols from libgcc
// which were available in some older versions of gcc.  However,
// they're _NOT_ available in newer versions of gcc (eg 3.1), so if we
// want those plugin to work with a gcc-3.1 built binary, we need to
// provide these symbols.  MOZ_ENABLE_OLD_ABI_COMPAT_WRAPPERS defaults
// to true on x86 linux, and false everywhere else.
//
// The fact that the new and free operators are mismatched mirrors the
// way the original functions in egcs 1.1.2 worked.

#include <stddef.h>
#include <stdlib.h>
#include <new>

#if defined(__linux__) && defined(__i386__)

extern "C" {

#	ifndef HAVE___BUILTIN_VEC_NEW
	void *__builtin_vec_new(size_t aSize, const std::nothrow_t &aNoThrow) throw()
	{
		return ::operator new(aSize, aNoThrow);
	}
#	endif

#	ifndef HAVE___BUILTIN_VEC_DELETE
	void __builtin_vec_delete(void *aPtr, const std::nothrow_t &) throw ()
	{
		free(aPtr);
	}
#	endif

#	ifndef HAVE___BUILTIN_NEW
	void *__builtin_new(int aSize)
	{
		return malloc(aSize);
	}
#	endif

#	ifndef HAVE___BUILTIN_DELETE
	void __builtin_delete(void *aPtr)
	{
		free(aPtr);
	}
#	endif

#	ifndef HAVE___PURE_VIRTUAL
	void __pure_virtual(void)
	{
		extern void __cxa_pure_virtual(void);
		__cxa_pure_virtual();
	}
#	endif

}

#endif
