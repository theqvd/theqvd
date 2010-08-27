TARGETS=xwin-wrapper
LDLIBS:=$(shell pkg-config --libs gtk+-2.0)
CFLAGS:=-g $(shell pkg-config --cflags gtk+-2.0)

all: $(TARGETS)

clean:
	rm -f *~ *.o

distclean: clean
	rm -f $(TARGETS)
