# include <termios.h>

main(argc, argv)
     int argc;
     char **argv;
{
    int interval = atoi(argv[1]);

    int i;

    for (i = 1; i; i++) {
	if (tcsendbreak(1, interval) == -1) {
	    perror("tcsendbreak");
	}
	if (!(i % 10))
	    printf("Delay %d, pass %d\n", interval, i);
    }
}
