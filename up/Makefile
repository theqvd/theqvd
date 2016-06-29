#!/usr/bin/make -f


prefix = /usr/lib/qvd
install: 
	mkdir -p $(DESTDIR)$(prefix)/wat
	cp README.rd config.json index.html remember.html $(DESTDIR)$(prefix)/wat
	cp -r images $(DESTDIR)$(prefix)/wat/
	cp -r lib $(DESTDIR)$(prefix)/wat/
	cp -r style $(DESTDIR)$(prefix)/wat
	cp -r templates $(DESTDIR)$(prefix)/wat

.PHONY: all install
