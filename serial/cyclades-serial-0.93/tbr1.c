# include <termios.h>


main(argc, argv)
     int argc;
     char **argv;
{
    int interval = atoi(argv[1]);

    char buf[128];

    int i, j;

    for (i = 1; i; i++) {
	for (j = 0; j < 20; j++) {
	    sprintf(buf, "%4d: AAAAAAAAAAAAAAAAAAAAAAAAAAA\n", j);
	    write(1, buf, strlen(buf));
	}
	if (tcsendbreak(1, interval) == -1) {
	    perror("tcsendbreak");
	}
	if (!(i % 5))
	    printf("Delay %d, pass %d\n", interval, i);
    }
}
