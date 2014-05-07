#include <stdio.h>
#include "websocket.h"


int main(int argc, char *argv[], char *envp[]) {
  websockify(1, "127.0.0.1", 5800, "127.0.0.1", 5900);

  return 0;
}
