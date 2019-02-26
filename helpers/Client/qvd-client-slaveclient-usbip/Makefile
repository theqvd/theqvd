CC=gcc
DESTDIR=/
PREFIX=/usr/lib/qvd
export DEBEMAIL=qvd@qindel.com
export DEBFULLNAME=QVD Team

datadir := $(shell /bin/pwd)
rpmbuild = $(HOME)/rpmbuild

versioned_dir=qvd-client-slaveclient-usbip-$(QVD_VERSION)
tarfile_name=$(versioned_dir).tar.gz
deb_tarfile_name=qvd-client-slaveclient-usbip_$(QVD_RELEASE)-$(DISTRIBUTION)-$(ORIG_BUILD_NUMBER).orig.tar.gz
tarfile=../$(tarfile_name)
deb_tarfile=../$(deb_tarfile_name)

qvd-client-slaveclient-usbip: qvd-client-slaveclient-usbip.c
	$(CC) -o $@ $<

.PHONY: install
install: qvd-client-slaveclient-usbip
	mkdir -p $(DESTDIR)/$(PREFIX)/bin
	install -m 04755 qvd-client-slaveclient-usbip $(DESTDIR)/$(PREFIX)/bin/qvd-client-slaveclient-usbip

.PHONY: help
help:
	@echo Targets:
	@echo "    deb: Debian package"
	@echo "    rpm: RPM package"
	@echo "    tar: tar file"


.PHONY: deb

deb: check-env qvd-client-slaveclient-usbip $(deb_tarfile)
	dch --newversion "$(QVD_RELEASE)-$(DISTRIBUTION)-$(ORIG_BUILD_NUMBER)-$(ORIG_COMMIT)" "Release $(QVD_RELEASE)-$(DISTRIBUTION)-$(ORIG_BUILD_NUMBER)-$(ORIG_COMMIT)" --distribution "$(DISTRIBUTION)"
	debuild -us -uc
	mkdir -p debian-package
	cp ../*deb debian-package/

.PHONY: tar

tar: $(tarfile)


$(tarfile): check-env
	cd .. && if [ -d "$(versioned_dir)" ] ; then rm -rf "$(versioned_dir)" ; fi
	cd .. && cp -Rdpv qvd-client-slaveclient-usbip "$(versioned_dir)" && tar -cvzf $(tarfile_name) $(versioned_dir) && rm -rf "$(versioned_dir)"
	@echo Tar file generated in: $(tarfile)

$(deb_tarfile): $(tarfile)
	mv $(tarfile) $(deb_tarfile)

.PHONY: rpm

rpm: check-env tar
	mkdir -p rpm-package $(rpmbuild)/BUILD $(rpmbuild)/BUILDROOT $(rpmbuild)/RPMS $(rpmbuild)/SOURCES $(rpmbuild)/SRPMS
	cp $(tarfile) $(rpmbuild)/SOURCES/
	rpmbuild -D '_topdir $(rpmbuild)' -D 'sourcedir $(datadir)' -D 'qvd_version $(QVD_VERSION)' -D 'qvd_release $(ORIG_BUILD_NUMBER)_$(ORIG_COMMIT)' -bb SPECS/qvd-client-slaveclient-usbip.spec
	cp $(rpmbuild)/RPMS/x86_64/qvd-client-slaveclient-usbip*.rpm rpm-package/

.PHONY: packages

packages: deb rpm

.PHONY: clean

clean:
	rm -f qvd-client-slaveclient-usbip
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
