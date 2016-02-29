#CC=i686-w64-mingw32-gcc
CC=gcc
CFLAGS=-g

SOURCES=bufaux.c \
	buffer.c \
	fatal.c \
	log.c \
	misc.c \
	openbsd-compat/bsd-misc.c \
	openbsd-compat/fmt_scaled.c \
	openbsd-compat/strlcat.c \
	openbsd-compat/strlcpy.c \
	openbsd-compat/strmode.c \
	openbsd-compat/vis.c \
	sftp-common.c \
	sftp-server.c \
	sftp-server-main.c \
	xmalloc.c

sftp-server.exe: $(SOURCES:.c=.o)
	$(CC) --verbose -o $@ $+ -lmsvcrtd -lws2_32
	strip $@

clean:
	rm -f sftp-server.exe *.o openbsd-compat/*.o
