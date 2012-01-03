#!/bin/bash
#
#  repackage.sh - repackage script for nspluginwrapper-ARCH
#
#  nspluginwrapper (C) 2005-2009 Gwenole Beauchesne
#

TMPDIR=${TMPDIR:-/tmp}
RPM_TOP_DIR=${RPM_TOP_DIR=$(rpm --eval "%{_topdir}")}

function fatal_error() {
    echo "Error:" ${1+"$@"} >/dev/stderr
    exit 1
}

if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <PACKAGE> [<ARCH>]"
    exit 1
fi

file=$1
rpm -qp "$file" >& /dev/null || fatal_error "package $file does not exist"

ARCH=$2
[[ -n "$ARCH" ]] || ARCH=$(rpm -qp --qf "%{arch}" $file | sed -e "s/^i.86$/i386/")

NAME=$(rpm -qp --qf "%{name}" $file)
PKGNAME=$(rpm -qpR $file | sed -n "/^\($NAME-[^ ]*\) .*/s//\1/p")
PKGARCH=$(rpm -qpR $file | sed -n "/^$NAME-\([^ ]*\) .*/s//\1/p")
[[ "$PKGNAME" = "$NAME-$ARCH" ]] || fatal_error "package $file is not nspluginwrapper for $PKGARCH"
VERSION=$(rpm -qp --qf "%{version}" $file)
RELEASE=$(rpm -qp --qf "%{release}" $file)
PACKAGE=$PKGNAME-$VERSION
TARBALL=$PACKAGE.tar.bz2
echo "Processing $NAME-$VERSION-$RELEASE"

# define platforms where we want binary deps generated
case $ARCH in
i?86)	AUTOREQ_ARCHES="%%ix86 x86_64 ia64";;
ppc)	AUTOREQ_ARCHES="ppc ppc64";;
sparc)	AUTOREQ_ARCHES="sparc sparcv9 sparc64";;
*)	AUTOREQ_ARCHES="$ARCH";;
esac

dstdir=$TMPDIR/$PACKAGE
rm -rf $dstdir
mkdir -p $dstdir

srcdir=$TMPDIR/package.d.$$
mkdir -p $srcdir
pushd $srcdir >& /dev/null
rpm2cpio $file | cpio -id >& /dev/null
tar cf - $(find . -name "npviewer.bin" -type f) | tar xf - -C $dstdir/
popd >& /dev/null
rm -rf $srcdir

cd $dstdir/..
rm -f $RPM_TOP_DIR/SOURCES/$TARBALL
tar jcf $RPM_TOP_DIR/SOURCES/$TARBALL $PACKAGE
filelist=$(cd $PACKAGE && find . "(" -type f -o -type l ")" | sed -n "/^\.\(.*\)/s//\1/p")
rm -rf $dstdir

specfile=$RPM_TOP_DIR/SPECS/$PKGNAME.spec
TZ=GMT LC_ALL=C rpm -qp --qf "\
###\n\
###\n\
### THIS PACKAGE IS AUTOMATICALLY GENERATED, DO NOT EDIT\n\
###\n\
###\n\
Summary: %{SUMMARY}\n\
Name: $PKGNAME\n\
Version: %{VERSION}\n\
Release: %{RELEASE}\n\
Source: $TARBALL\n\
License: %{LICENSE}\n\
Group: %{GROUP}\n\
%%ifnarch $AUTOREQ_ARCHES\n\
AutoReq: off\n\
%%endif\n\
BuildRoot: %%_tmppath/%%name-%%version-%%release-buildroot\n\
%|URL?{URL: %{URL}\n}|\
\n\
%%description\n\
%{DESCRIPTION}\n\
\nThis package provides the npviewer program for $ARCH.\n\
\n\
%%prep\n\
%%setup -q\n\
\n\
%%build\n\
\n\
%%install\n\
rm -rf \$RPM_BUILD_ROOT\n\
mkdir -p \$RPM_BUILD_ROOT\n\
tar cf - . | tar xf - -C \$RPM_BUILD_ROOT/\n\
\n\
%%clean\n\
rm -rf \$RPM_BUILD_ROOT\n\
\n\
\n\
%%files\n\
%%defattr(-,root,root)\n\
$filelist\
\n\
\n\
%%changelog\n\
[* %{CHANGELOGTIME:day} %{CHANGELOGNAME}\n\n%{CHANGELOGTEXT}\n\n]\
" $file > $specfile

rpm -ba --clean --nodeps --rmspec --rmsource $specfile >& /dev/null
exit 0
