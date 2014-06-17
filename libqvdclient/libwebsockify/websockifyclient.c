#include <stdio.h>
#include <pthread.h>
#include "websocket.h"


void *runwebsockify(void *notused) {
  websockify(0, "127.0.0.1", 5800, "127.0.0.1", 5900);
  return NULL;
}

int main(int argc, char *argv[], char *envp[]) {
  pthread_t t;
  void *return_value;
  int v;
  if (pthread_create(&t, NULL, runwebsockify, NULL)) {
    perror("Error in pthread_create");
    exit(1);
  }
  printf("Press enter to finish loop\n");
  scanf("%*d");
  printf("Finishing loop\n");
  websockify_stop();
  if (pthread_join(t, &return_value)) {
    perror("Error in pthread_join");
    exit(1);
  }
  fprintf(stderr, "End in pthread_join %p", return_value);
  return 0;
}
