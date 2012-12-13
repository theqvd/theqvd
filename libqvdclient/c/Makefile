# Try to be agnostic to the make version and not go into GNU Make
# Skip a lot of auto rules that aply to gnu make
CC=gcc
LD=gcc
AR=ar
QVDCLIENTLIBA=libqvdclient.a
QVDCLIENTLIB=libqvdclient.so
SOURCE=qvdclientcore.c debug.c qvdbuffer.c qvdvm.c
OBJ=qvdclientcore.o debug.o qvdbuffer.o qvdvm.o
QVDCLIENT=qvdclient
QVDCLIENTOBJ=$(QVDCLIENT).o
QVDCLIENTLIBLIBS=-L. -lcurl -lcrypto -lssl -lldap -lidn -lrt -ljansson -lXcomp
QVDCLIENTLIBS=-L. -lqvdclient
CFLAGS=-fPIC -g 
STATICLIBS=
STDCLIB=

default: all

all: $(QVDCLIENTLIB) $(QVDCLIENTLIBA) $(QVDCLIENT) 

qvdclient: $(QVDCLIENTOBJ) $(QVDCLIENTLIB) $(QVDCLIENTLIBA)
	$(LD) $(LDFLAGS) -o $(QVDCLIENT) $(QVDCLIENTOBJ) $(QVDCLIENTLIBS)

qvdclient-static: $(QVDCLIENTOBJ) $(QVDCLIENTLIBA)
	$(LD) $(LDFLAGS) -o $(QVDCLIENT) $(QVDCLIENTOBJ) $(QVDCLIENTLIBS)

$(QVDCLIENTLIB): $(OBJ)
	$(LD) $(LDFLAGS) -shared -o $(QVDCLIENTLIB) $(OBJ) $(QVDCLIENTLIBLIBS)

$(QVDCLIENTLIBA): $(OBJ)
	$(AR) cru $(QVDCLIENTLIBA) $(OBJ)

clean:
	rm -f *~ *.o

distclean: clean
	rm -rf $(QVDCLIENT) core lib*

.EXPORT_ALL_VARIABLES:
