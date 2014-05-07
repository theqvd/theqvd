TARGETS=libwebsockify.a
CFLAGS += -fPIC

all: $(TARGETS)

libwebsockify.a: websockify.o websocket.o
	$(AR) cr $@ $^ 

websocket.o: websocket.c websocket.h
websockify.o: websockify.c websocket.h

install:

clean:
	rm -f $(TARGETS) *.o *~

