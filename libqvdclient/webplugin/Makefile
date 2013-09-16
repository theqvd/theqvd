FIREBREATHDIR=$(PWD)/pkg/firebreath
BUILDDIR=build
SRCDIR=src
TESTDIR=test

all: build
	cd $(BUILDDIR); make

build:
	[ -d $(BUILDDIR)/bin ] || $(FIREBREATHDIR)/prepmake.sh $(SRCDIR) $(BUILDDIR)

test: all
	$(TESTDIR)/test.sh $(TESTDIR)/test.html

clean:
	cd $(BUILDDIR); make clean

distclean:
	cd $(BUILDDIR); make distclean

.PHONY: build