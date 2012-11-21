#include <stdio.h>
#include <sys/ioctl.h>
#include <linux/serial.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>



int main(int argc, char **argv) {
	if ( argc < 2 ) {
		fprintf(stderr, "Argument required\n");
		exit(1);
	}
	
	printf("Opening %s...\n", argv[1]);
	
	int fd = open(argv[1], O_RDWR);
	if ( fd < 0 ) {
		perror("Open failed");
		exit(2);
	}
	
	int flags = 0;
	unsigned int lsr;
	struct serial_icounter_struct cnt;
	
	
	if (ioctl(fd, TIOCMGET, &flags) == -1) {
		perror("TIOCMGET failed");
	} else {
		printf("Port flags = %i\n", flags);
		printf("Line Enable         (LE)  : %i\n", flags & TIOCM_LE  ? 1 : 0 );
		printf("Data Terminal Ready (DTR) : %i\n", flags & TIOCM_DTR ? 1 : 0  );
		printf("Request To Send     (RTS) : %i\n", flags & TIOCM_RTS ? 1 : 0 );
		printf("Secondary Transmit  (ST)  : %i\n", flags & TIOCM_ST  ? 1 : 0 );
		printf("Secondary Receive   (SR)  : %i\n", flags & TIOCM_SR  ? 1 : 0 );
		printf("Clear To Send       (CTS) : %i\n", flags & TIOCM_CTS ? 1 : 0 );
		printf("Carrier Detect      (CAR) : %i\n", flags & TIOCM_CAR ? 1 : 0 );
		printf("Ring Indicator      (RNG) : %i\n", flags & TIOCM_RNG ? 1 : 0 );
		printf("Data Set Ready      (DSR) : %i\n", flags & TIOCM_DSR ? 1 : 0 );

		
	}
	
	
	if (ioctl(fd, TIOCGICOUNT, &cnt) == -1) {
		perror("TIOCGICOUNT failed");
	} else {
		printf("==== Counts ====\n");
		printf("CTS            : %i\n", cnt.cts);
		printf("DSR            : %i\n", cnt.dsr);
		printf("RNG            : %i\n", cnt.rng);
		printf("DCD            : %i\n", cnt.dcd);
		printf("RX             : %i\n", cnt.rx);
		printf("TX             : %i\n", cnt.tx);
		printf("Frames         : %i\n", cnt.frame);
		printf("Overruns       : %i\n", cnt.overrun);
		printf("Parity         : %i\n", cnt.parity);
		printf("Brk            : %i\n", cnt.brk);
		printf("Buffer overruns: %i\n", cnt.buf_overrun);
	}
	
	if (ioctl(fd, TIOCSERGETLSR, &lsr) == -1) {
		perror("TIOCSERGETLSR failed");
	} else {
		printf("Port LSR   = %i\n", lsr);
	}
	
	/*
	char *send = "ATDT\n";
	char buf[1];
	int bytes = 0;
	
	printf("Trying to send %li bytes...\n", strlen(send));
	bytes = write(fd, send, strlen(send));
	printf("Wrote %i bytes\n", bytes);
	
	printf("Trying to read %li bytes...\n", sizeof(buf));
	bytes = read(fd, buf, sizeof(buf));
	printf("Read %i bytes. Value: %i", bytes, buf[0]);
	*/
	
	close(fd);
}

