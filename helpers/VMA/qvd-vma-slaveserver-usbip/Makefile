CC=gcc
DESTDIR=/
PREFIX=/usr/lib/qvd
export DEBEMAIL=qvd@qindel.com
export DEBFULLNAME=QVD Team

datadir := $(shell /bin/pwd)
rpmbuild = $(HOME)/rpmbuild

versioned_dir=qvd-vma-slaveserver-usbip-$(QVD_VERSION)
tarfile_name=$(versioned_dir).tar.gz
deb_tarfile_name=qvd-vma-slaveserver-usbip_$(QVD_VERSION).orig.tar.gz
tarfile=../$(tarfile_name)
deb_tarfile=../$(deb_tarfile_name)

qvd-vma-slaveserver-usbip: qvd-vma-slaveserver-usbip.c
	$(CC) -o $@ $<

.PHONY: install
install: qvd-vma-slaveserver-usbip
	mkdir -p $(DESTDIR)/$(PREFIX)/bin
	install -m 04755 qvd-vma-slaveserver-usbip $(DESTDIR)/$(PREFIX)/bin/qvd-vma-slaveserver-usbip

.PHONY: help
help:
	@echo Targets:
	@echo "    deb: Debian package"
	@echo "    rpm: RPM package"
	@echo "    tar: tar file"


.PHONY: deb

deb: check-env qvd-vma-slaveserver-usbip $(deb_tarfile)
	dch --newversion "$(QVD_VERSION)-$(QVD_RELEASE)" "Release $(QVD_VERSION)-$(QVD_RELEASE)"
	debuild -us -uc

.PHONY: tar

tar: $(tarfile)


$(tarfile): check-env
	cd .. && if [ -d "$(versioned_dir)" ] ; then rm -rf "$(versioned_dir)" ; fi
	cd .. && cp -Rdpv qvd-vma-slaveserver-usbip "$(versioned_dir)" && tar -cvzf $(tarfile_name) $(versioned_dir) && rm -rf "$(versioned_dir)"
	@echo Tar file generated in: $(tarfile)

$(deb_tarfile): $(tarfile)
	mv $(tarfile) $(deb_tarfile)

.PHONY: rpm

rpm: check-env tar
	mkdir -p rpm-package $(rpmbuild)/BUILD $(rpmbuild)/BUILDROOT $(rpmbuild)/RPMS $(rpmbuild)/SOURCES $(rpmbuild)/SRPMS
	cp $(tarfile) $(rpmbuild)/SOURCES/
	rpmbuild -D '_topdir $(rpmbuild)' -D 'sourcedir $(datadir)' -D 'qvd_version $(QVD_VERSION)' -D 'qvd_release $(QVD_RELEASE)' -bb SPECS/qvd-vma-slaveserver-usbip.spec
	cp $(rpmbuild)/RPMS/x86_64/qvd-vma-slaveserver-usbip*.rpm rpm-package/

.PHONY: packages

packages: deb rpm

.PHONY: clean

clean:
	rm -f qvd-vma-slaveserver-usbip
	rm -Rf build
	rm -Rf debian-package
	rm -Rf rpm-package

.PHONY: check-env

check-env:
ifndef QVD_VERSION
	$(error Environment variable QVD_VERSION is undefined: cannot make packages)
endif
ifndef QVD_RELEASE
	$(error Environment variable QVD_RELEASE is undefined: cannot make packages)
endif
