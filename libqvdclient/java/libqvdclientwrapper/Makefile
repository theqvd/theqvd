# Try to be agnostic to the make version and not go into GNU Make
# Skip a lot of auto rules that aply to gnu make
CC=gcc
LD=gcc
QVDCLIENTDIR=../../c
QVDCLIENTLIB=libqvdclientwrapper.so
SOURCE=com_theqvd_client_jni_QvdclientWrapper.c
OBJ=com_theqvd_client_jni_QvdclientWrapper.o
QVDCLIENTLIBS=-L$(QVDCLIENTDIR) -lqvdclient
CFLAGS=-fPIC -g -I/usr/lib/jvm/default-java/include -I/usr/lib/jvm/default-java/include/linux -I$(QVDCLIENTDIR)

# Agnostic to the make version
#.phony: ALL
all: $(QVDCLIENTLIB)

test: $(QVDCLIENTLIB)

$(QVDCLIENTLIB): $(OBJ)
	$(LD) -shared -o $(QVDCLIENTLIB) $(OBJ) $(QVDCLIENTLIBS)

clean:
	rm -f *~ *.o

distclean: clean
	rm -f $(QVDCLIENTLIB) core

javah:
	$(MAKE) -C ../jni -e
	javah -classpath ../jni/target/classes com.theqvd.client.jni.QvdclientWrapper

.EXPORT_ALL_VARIABLES:
