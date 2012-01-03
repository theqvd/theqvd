#!/bin/bash
#
#  getdeps.sh - get dependent libs of a program
#
#  nspluginwrapper (C) 2005-2009 Gwenole Beauchesne
#

# FIXME: needs pango config files, extra X11 libraries, etc. Thus it's
# better to rewrite the script so that to install from the actual RPMs...

function fatal_error() {
    echo "Error:" ${1+"$@"} >/dev/stderr
    exit 1
}

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <PROGRAM>"
    exit 1
fi

FILE=$1
[[ -f "$FILE" ]] || fatal_error "specified program $file does not exist"

nLIBS=0
declare -a LIBS

nDEPS=0
declare -a DEPS

function path_find() {
    local var=$1
    local path=$2
    eval "echo \" \${$var[*]} \"" | grep -q $path
}

function path_add() {
    local var=$1
    local path=$2
    path_find $var $path || {
	eval "$var[n$var]=$path ; n$var=\$((n$var+1))"
	[[ -L $path ]] && {
	    link=`readlink $path`
	    case $link in
		/*|../*)
		    fatal_error "links to files in other paths are not supported"
		    ;;
		*)
		    link="`dirname $path`/$link"
	    esac
	    eval "$var[n$var]=$link ; n$var=\$((n$var+1))"
	}
    }
}

function get_deps() {
    local file=$1
    path_find LIBS $file || {
	path_add LIBS $file
	local paths=`ldd $file | sed -n '/^[^l]*\(lib[^ ]*\) => \(\/[^ ]*\).*/s//\2/p'`
	for fullpath in $paths; do
	    local path=`echo $fullpath | sed -e 's/\(\/lib[0-9]*\)\/\(tls\|i686\|mmx\|sse[23]*\)/\1/'`
	    path_add DEPS $path
	    get_deps $path
	done
    }
}

ldso=`ldd $FILE | sed -n '/^[^\/]*\(\/[^ ]*ld-[^ ]*\) .*/s//\1/p'`
path_add DEPS $ldso

get_deps $FILE
echo ${DEPS[*]}
exit 0
