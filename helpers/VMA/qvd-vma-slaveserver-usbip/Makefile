CC=gcc

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

.PHONY: clean

clean:
	rm -f qvd-vma-slaveserver-usbip
	rm -Rf build
	rm -Rf debian-package
