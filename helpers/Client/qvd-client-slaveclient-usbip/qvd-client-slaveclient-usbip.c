#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>

int main( int argc, char ** argv, char ** envp )
{
              if( setgid(getegid()) < 0 ) { perror( "setgid" ); exit(1); }
              if( setuid(geteuid()) < 0 ) { perror( "setuid" ); exit(1); }
              envp = 0; /* blocks IFS attack on non-bash shells */
              execve( "/usr/lib/qvd/bin/qvd-client-slaveclient-usbip-aux", argv, envp );
              return(1);
}
