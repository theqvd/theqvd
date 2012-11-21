CFLAGS=-Wall -std=gnu99 -D_GNU_SOURCE -fPIC -rdynamic -ldl -g
LDFLAGS=-fPIC 

all: qvd-serial-wrapper.so tester

clean:
	rm *.o *.so

tester: tester.o

qvd-serial-wrapper.so: qvd-serial-wrapper.o
	$(CC) $(LDFLAGS) -shared -rdynamic -o qvd-serial-wrapper.so qvd-serial-wrapper.o -lpthread -ldl

*.o : *.c
