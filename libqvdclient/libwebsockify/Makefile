TARGETS=libwebsockify.a websockifyclient
CFLAGS += -fPIC
LD=cc

all: $(TARGETS)

libwebsockify.a: websockify.o websocket.o
	$(AR) cr $@ $^ 

websockifyclient: websockifyclient.o libwebsockify.a
#	$(LD) $(LDFLAGS) -o $@ $^ -lresolv
	$(LD) $(LDFLAGS) -o $@ $^ -lresolv -lssl -lcrypto 

websocket.o: websocket.c websocket.h
websockify.o: websockify.c websocket.h

install: 

clean:
	rm -f $(TARGETS) *.o *~

