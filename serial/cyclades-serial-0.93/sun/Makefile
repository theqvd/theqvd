
all: pkg

INSTROOT=`pwd`/tmp
PKGNAME=cyclades-ser-cli

pkg:
	rm -rf ../tmp
	( cd .. ; ./configure --prefix=${INSTROOT} --mandir=`pwd`/sun/tmp/usr/share/man )
	( cd .. ; make )
	( cd .. ; make prefix=${INSTROOT} install )
	pkgmk -o -r ../tmp
	pkgtrans -s spool ${PKGNAME}.pkg ${PKGNAME}
	echo "/var/spool/pkg/${PKGNAME}.pkg complete!"
