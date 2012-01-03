#!/bin/sh
#
#  nsplugin viewer wrapper script (C) 2005-2006 Gwenole Beauchesne
#
OS="`uname -s`"
ARCH="`uname -m`"
NPW_LIBDIR="%NPW_LIBDIR%"

if test -z "$TARGET_OS"; then
    echo "*** NSPlugin Viewer *** error, TARGET_OS not initialized"
    exit 1
fi

if test -z "$TARGET_ARCH"; then
    echo "*** NSPlugin Viewer *** error, TARGET_ARCH not initialized"
    exit 1
fi

NPW_VIEWER_DIR=$NPW_LIBDIR/$TARGET_ARCH/$TARGET_OS

# Set a new LD_LIBRARY_PATH that is TARGET specific
export LD_LIBRARY_PATH=$NPW_VIEWER_DIR

# Note that a clever DBT will work at the function level and XShm
# should be possible with a proper native replacement to emulated code
# XXX: BTW, anything other than "yes" is interpreted as "no"
NPW_USE_XSHM=${NPW_USE_XSHM:-yes}

# Enable use of valgrind?
# Define NPW_VALGRIND_OPTIONS if you want to pass additional options to valgrind
NPW_USE_VALGRIND=${NPW_USE_VALGRIND:-no}
can_use_valgrind="no"

case $ARCH in
i?86|i86pc)
    ARCH=i386
    ;;
amd64)
    ARCH=x86_64
    ;;
esac

if test "$ARCH" != "$TARGET_ARCH"; then
    case $TARGET_ARCH in
    i386)
	if test "$ARCH" = "x86_64"; then
	    case "$OS" in
	    Linux)
		LOADER=`which linux32`
		;;
	    FreeBSD | NetBSD)
		# XXX check that COMPAT_LINUX is enabled or fail otherwise
		LOADER="none"
	        ;;
	    esac
	elif test "$ARCH" = "ia64"; then
	    # XXX check that IA-32 EL or HW emulator is enabled or fail
	    # otherwise (use QEMU?)
	    LOADER="none"
	else
	    LOADER=`which qemu-i386`
	    # Don't allow Xshm with qemu
	    NPW_USE_XSHM="no"
	fi
	;;
    ppc)
	if test "$ARCH" = "ppc64"; then
	    case "$OS" in
	    Linux)
		LOADER=`which linux32`
	        ;;
	    esac
	else
	    LOADER=`which qemu-ppc`
	    # Don't allow Xshm with qemu
	    NPW_USE_XSHM="no"
	fi
	;;
    esac
    if test "$LOADER" = "none"; then
	unset LOADER
    elif test -z "$LOADER" -o ! -x "$LOADER"; then
	echo "*** NSPlugin Viewer *** preloader not found"
	exit 1
    fi
fi

# Disallow Xshm (implying XVideo too)
if test "$NPW_USE_XSHM" != "yes"; then
    if test -x "$NPW_VIEWER_DIR/libnoxshm.so"; then
	if test -n "$LD_PRELOAD"; then
	    LD_PRELOAD="$LD_PRELOAD:$NPW_VIEWER_DIR/libnoxshm.so"
	else
	    LD_PRELOAD="$NPW_VIEWER_DIR/libnoxshm.so"
	fi
	export LD_PRELOAD
    fi
fi

# Expand PATH for RealPlayer package on NetBSD (realplay)
if test "$OS" = "NetBSD"; then
    REALPLAYER_HOME="/usr/pkg/lib/RealPlayer"
    if test -x "$REALPLAYER_HOME/realplay"; then
	export PATH=$PATH:$REALPLAYER_HOME
    fi
fi

# Use sound wrappers wherever possible (Flash 9 plugin)
case " $@ " in
*" --test "*|*" -t "*)
    # do nothing, don't even allow valgrind'ing here
    ;;
*)
    # XXX: detect QEMU target soundwrapper differently
    case "$LOADER" in
    *linux32)
	if test "$OS" = "Linux"; then
	    soundwrapper=`which soundwrapper 2>/dev/null`
	    if test -x "$soundwrapper"; then
		LOADER="$LOADER $soundwrapper"
	    elif ps aux | grep artsd | grep -vq grep; then
		soundwrapper=`which artsdsp 2>/dev/null`
		if test -x "$soundwrapper"; then
		    LOADER="$LOADER $soundwrapper"
		fi
	    fi
	fi
	can_use_valgrind="yes"
	;;
    "")
	can_use_valgrind="yes"
	;;
    esac
    ;;
esac

if test "$NPW_USE_VALGRIND:$can_use_valgrind" = "yes:yes"; then
    valgrind=`which valgrind 2>/dev/null`
    if test -x "$valgrind"; then
	LOADER="$LOADER $valgrind --log-fd=1 $NPW_VALGRIND_OPTIONS"
	export G_SLICE=always-malloc
	export NPW_INIT_TIMEOUT=30
    fi
fi

exec $LOADER $NPW_VIEWER_DIR/npviewer.bin ${1+"$@"}
