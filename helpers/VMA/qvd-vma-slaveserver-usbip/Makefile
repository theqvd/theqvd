CC=gcc
datadir := $(shell /bin/pwd)
rpmbuild = $(datadir)/rpmbuild

qvd-vma-slaveserver-usbip: qvd-vma-slaveserver-usbip.c
	$(CC) -o $@ $<

.PHONY: deb

deb: check-env qvd-vma-slaveserver-usbip
	mkdir -p build/usr/lib/qvd/bin/
	mkdir -p debian-package/
	cp -R DEBIAN build/
	echo "Version: $(QVD_VERSION)-$(QVD_RELEASE)" >> build/DEBIAN/control
	cp qvd-vma-slaveserver-usbip build/usr/lib/qvd/bin/
	fakeroot -- bash -c 'chown -R root:root build && dpkg-deb --build build debian-package'

.PHONY: rpm

rpm: check-env qvd-vma-slaveserver-usbip
	mkdir -p rpm-package $(rpmbuild)/BUILD $(rpmbuild)/BUILDROOT $(rpmbuild)/RPMS $(rpmbuild)/SOURCES $(rpmbuild)/SRPMS
	rpmbuild -D '_topdir $(rpmbuild)' -D 'sourcedir $(datadir)' -D 'qvd_version $(QVD_VERSION)' -D 'release $(QVD_RELEASE)' -bb SPECS/qvd-vma-slaveserver-usbip.spec
	cp $(rpmbuild)/RPMS/x86_64/qvd-vma-slaveserver-usbip*.rpm rpm-package/

.PHONY: packages

packages: deb rpm

.PHONY: clean

clean:
	rm -f qvd-vma-slaveserver-usbip
	rm -Rf build
	rm -Rf debian-package
	rm -Rf rpm-package
	rm -Rf $(rpmbuild)

.PHONY: check-env

check-env:
ifndef QVD_VERSION
	$(error Environment variable QVD_VERSION is undefined: cannot make packages)
endif
ifndef QVD_RELEASE
	$(error Environment variable QVD_RELEASE is undefined: cannot make packages)
endif
