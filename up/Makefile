#!/usr/bin/make -f


prefix = /usr/lib/qvd
install: 
	mkdir -p $(DESTDIR)$(prefix)/up
	cp README.rd config.json index.html remember.html $(DESTDIR)$(prefix)/up
	cp -r images $(DESTDIR)$(prefix)/up/
	cp -r lib $(DESTDIR)$(prefix)/up/
	cp -r style $(DESTDIR)$(prefix)/up
	cp -r templates $(DESTDIR)$(prefix)/up

.PHONY: all install
