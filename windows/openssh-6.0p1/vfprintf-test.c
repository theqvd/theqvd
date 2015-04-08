#include <stdarg.h>
#include <stdio.h>
#include <fcntl.h>
#include <share.h>

int logfd;
void openlog(const char *ident, int option, int facility) {
    logfd = sopen("log.txt", O_WRONLY, SH_DENYNO);
}

void syslog(int priority, const char *format, ...) {
    va_list argp;
    va_start(argp, format);
    FILE *fp = fdopen(logfd, "w");
    vfprintf(fp, format, argp);
    va_end(argp);
}

void closelog() {
    close(logfd);
}


int main(void) {
    openlog("", 0, 0);
    syslog(1, "%s\n", "Hello World!");
    closelog();
}
