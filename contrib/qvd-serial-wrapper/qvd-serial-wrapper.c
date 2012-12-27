


#include <sys/ioctl.h>
#include <linux/serial.h>

#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <stdarg.h>
#include <stdbool.h>
#include <limits.h>
#include <dlfcn.h>
#include <string.h>
#include <pthread.h>
#include <string.h>
#include <stdlib.h>





struct port_entry {
	char *name;
	struct port_entry *next;
};


pthread_mutex_t g_lock = PTHREAD_MUTEX_INITIALIZER;

char *g_serial_port = "/dev/ttyS";
int (*g_ioctl_original)(int, unsigned long int, ...) = NULL;
struct port_entry *g_ports = NULL;


static bool check_intercept(int fd);
static void initialize();
static void add_port(char *port);
 
int ioctl(int fd, unsigned long int request, ...) {
	
	
	va_list args;
	va_start(args, request);
	bool handled = false;
	int ret;
	
	initialize();
	
	switch(request) {
		case TIOCMGET:
			if ( check_intercept(fd) ) {
				fprintf(stderr, "qvdserial: overriding TIOCMGET to fd %i\n", fd);
				int *cm = va_arg(args, int *);
				*cm = TIOCM_CTS | TIOCM_RTS | TIOCM_DTR;
				
				handled = true;
				ret = 0;
			}
			break;
		case TIOCMSET:
			if ( check_intercept(fd) ) {
				fprintf(stderr, "qvdserial: overriding TIOCMSET to fd %i\n", fd);
				handled = true;
				ret = 0;
			}
			break;
		case TIOCGICOUNT:
			if ( check_intercept(fd) ) {
				fprintf(stderr, "qvdserial: overriding TIOCGICOUNT to fd %i\n", fd);
				struct serial_icounter_struct *cnt = va_arg(args, struct serial_icounter_struct *);
				
				cnt->cts         = 0;
				cnt->dsr         = 0;
				cnt->rng         = 0;
				cnt->dcd         = 0;
				cnt->rx          = 0;
				cnt->tx          = 0;
				cnt->frame       = 0;
				cnt->overrun     = 0;
				cnt->parity      = 0;
				cnt->brk         = 0;
				cnt->buf_overrun = 0;
				
				handled = true;
				ret = 0;
			}
			break;
		case TIOCSERGETLSR:
			if ( check_intercept(fd) ) {
				fprintf(stderr, "qvdserial: overriding TIOCSERGETLSR to fd %i\n", fd);
				unsigned int *flag = va_arg(args, unsigned int*);
				*flag = TIOCSER_TEMT; /* Transmitter empty */
				handled = true;
				ret = 0;
			}
			break;
	}
	
	

	
	if (!handled) {
		void *ptr = va_arg(args, void*);
		ret = g_ioctl_original(fd, request, ptr);
		
		fprintf(stderr, "qvdserial: original_ioctl(%i, %ld, %p) returned %i\n", fd, request, ptr, ret);
	} else {
		void *ptr = va_arg(args, void*);
		g_ioctl_original(-fd, request, ptr);
	}

	va_end(args);
	return ret;
	
}


static bool check_intercept(int fd) {
	char link_path[PATH_MAX];
	char real_path[PATH_MAX];
	
	snprintf(link_path, sizeof(link_path), "/proc/self/fd/%i", fd);
	
	if ( readlink(link_path, real_path, sizeof(real_path)) >= 0 ) {
		struct port_entry *port = g_ports;
		
		while( port != NULL ) {
			if (!strncmp(real_path, port->name, strlen(port->name))) {
				return true;
			}
			
			port = port->next;
		}
	} else {
		fprintf(stderr, "qvdserial: Can't read link %s to fd %i: %s\n", link_path, fd, strerror(errno));
	}
	
	
	return false;
}

static void initialize() {
	pthread_mutex_lock(&g_lock);
	
	/* Cache original function to reduce performance impact */
	if ( g_ioctl_original == NULL ) {
		fprintf(stderr, "qvdserial: init\n");
		g_ioctl_original = (int (*)(int, unsigned long int, ...)) dlsym(RTLD_NEXT, "ioctl");
	}
	
	if ( g_ports == NULL ) {
		char *ports = getenv("QVD_WRAP_PORTS");
		if ( ports ) {
			char *port = strtok(ports, ":");
			while(port) {
				add_port(port);
				port = strtok(NULL, ":");
			}
		} else {
			fprintf(stderr, "qvdserial: no ports defined, using default\n");
			add_port("/dev/ttyS0");
		}
	}
	
	pthread_mutex_unlock(&g_lock);
}

static void add_port(char *port) {
	struct port_entry *ent = malloc(sizeof(*ent));
	
	ent->name = strdup(port);
	ent->next = NULL;
	
	
	if ( g_ports == NULL ) {
		g_ports = ent;
	} else {
		struct port_entry *last = g_ports;
		
		while(last->next != NULL) {
			last = last->next;
		}
		
		last->next = ent;
	}
	
	fprintf(stderr, "qvdserial: added port %s\n", port);
}