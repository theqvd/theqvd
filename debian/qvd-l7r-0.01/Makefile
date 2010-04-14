SHARE=$(DESTDIR)/usr/share/qvd-l7r

build:

clean:

install:
	mkdir -p $(SHARE)/config/certs
	cp config/config.ini $(SHARE)/config
	cp config/log4perl.conf $(SHARE)/config
	cp config/certs/server-cert.pem $(SHARE)/config/certs
	cp config/certs/server-key.pem $(SHARE)/config/certs

