#!/bin/sh
#
#  mkruntime.sh - prepare QEMU runtime from Mandriva Linux 2006.0
#
#  nspluginwrapper (C) 2005-2009 Gwenole Beauchesne
#

# Usage: mkruntime <MDV2006-RPMS>
#        unpacks RPMs to /usr/gnemul/qemu-i386/
#
# Notes:
# - Check acroread5, something is missing while loading a PDF
# - Enough for Flash Player & PluginSDK npsimple.so

error() {
	echo ${1+"$@"} > /dev/stderr
}

status() {
	echo ${1+"$@"} > /dev/stderr
}

run() {
	status " " ${1+"$@"}
	${1+"$@"}
}

RPMS=$1
[[ -d "$RPMS" ]] || { error "unspecified RPMs dir"; exit 1; }

ARCH=$2
[[ -n "$ARCH" ]] || ARCH="i386"

ROOT=$3
[[ -d "$ROOT" ]] || ROOT="/usr/gnemul/qemu-$ARCH"

QEMU="qemu-$ARCH"
[[ -x "`which $QEMU`" ]] || { error "inexistent QEMU for $ARCH in PATH"; exit 1; }
QEMU="$QEMU -L $ROOT"

files="$files glibc-[0-9]* ldconfig-[0-9]*"
files="$files zlib1-[0-9]* libbzip2_[0-9]-[0-9]*"
files="$files bash-[0-9]* libtermcap2-[0-9]* libslang1-[0-9]*"
files="$files libstdc++5-[0-9]*"
files="$files libxorg-x11-[0-9]*"
files="$files fontconfig-[0-9]* libfontconfig1-[0-9]* libfreetype6-[0-9]*"
files="$files libxml2-[0-9]* libexpat0-[0-9]* libxslt1-[0-9]*"
files="$files libjpeg62-[0-9]* libpng3-[0-9]*"
files="$files libaudiofile0-[0-9]* libesound0-[0-9]*"
files="$files libglib2.0_0-[0-9]* libgtk+2.0_0-[0-9]* libgtk+-x11-2.0_0-[0-9]*"
files="$files libgdk_pixbuf2.0_0-[0-9]*"
files="$files libatk1.0_0-[0-9]* libcairo2-[0-9]*"
files="$files pango-[0-9]* libpango1.0_0-[0-9]* libpango1.0_0-modules-[0-9]*"

mkdir -p $ROOT
pushd $ROOT >& /dev/null
for file in $(cd $RPMS && echo $files); do
	echo "Processing $file" > /dev/stderr
	rpm2cpio $RPMS/$file | cpio -id >& /dev/null
done
popd $ROOT >& /dev/null

find $ROOT -type d -name tls | xargs rm -rf

echo "Regenerating ld.so.cache"
echo "/usr/X11R6/lib" >> $ROOT/etc/ld.so.conf
run touch $ROOT/etc/ld.so.cache
run $QEMU $ROOT/sbin/ldconfig -C $ROOT/etc/ld.so.cache

echo "Regenerating fontconfig cache"
run $QEMU $ROOT/usr/bin/fc-cache -f

echo "Regenerating pango cache"
for file in $ROOT/usr/lib/pango/*/modules/*.so; do
	case $file in
		*/pango-basic*.so);;
		*) run rm -f $file;;
	esac
done
if [[ "$ARCH" = "i386" ]]; then
	run $QEMU $ROOT/usr/bin/pango-querymodules-32 > $ROOT/etc/pango/i386/pango.modules
else
	run $QEMU $ROOT/usr/bin/pango-querymodules > $ROOT/etc/pango/pango.modules
fi
