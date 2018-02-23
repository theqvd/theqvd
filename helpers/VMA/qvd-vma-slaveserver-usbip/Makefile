CC=gcc
datadir := $(shell /bin/pwd)
rpmbuild = $(datadir)/rpmbuild

qvd-vma-slaveserver-usbip: qvd-vma-slaveserver-usbip.c
	$(CC) -o $@ $<

.PHONY: deb

deb: qvd-vma-slaveserver-usbip
	mkdir -p build/usr/lib/qvd/bin/
	cp -R DEBIAN build/
	mkdir debian-package/
	cp qvd-vma-slaveserver-usbip build/usr/lib/qvd/bin/
	chown -R root:root build
	dpkg-deb --build build debian-package

.PHONY: rpm

rpm: qvd-vma-slaveserver-usbip
	mkdir -p rpm-package $(rpmbuild)/BUILD $(rpmbuild)/BUILDROOT $(rpmbuild)/RPMS $(rpmbuild)/SOURCES $(rpmbuild)/SRPMS
	rpmbuild -D '_topdir $(rpmbuild)' -D 'sourcedir $(datadir)' -D 'qvd_version 4.1.0' -D 'release 0.1' -bb SPECS/qvd-vma-slaveserver-usbip.spec
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
