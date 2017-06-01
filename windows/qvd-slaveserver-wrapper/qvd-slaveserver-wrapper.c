#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <poll.h>
#include <errno.h>
#include <sys/wait.h>

#define BUFSIZE (1024*16)

/* C = child, P = parent, I = in (we write here), O = out (we read from here) */
#define FDPO 0
#define FDPI 1
#define FDCI 3
#define FDCO 4
#define FDUNUSED 5
int
main(int argc, char *argv[]) {

    /* ensure file descriptors 0, 1 and 2 are open */
    for (int fd = 0; fd < 3; fd++) {
        if (fcntl(fd, F_GETFD) < 0) {
            int newfd = open("/dev/null", (fd ? O_WRONLY : O_RDONLY));
            if (newfd < 0) {
                perror("open failed");
                exit(254);
            }
            if (newfd != fd) {
                if (dup2(newfd, fd) < 0) {
                    perror("dup2 failed");
                    exit(254);
                }
                close(newfd);
            }
        }
    }

    int cin[2];
    int cout[2];
    if (pipe(cin) < 0 || pipe(cout) < 0) {
        perror("pipe failed");
        exit(254);
    }

    struct sigaction intsave, quitsave;
    sigaction(SIGINT, NULL, &intsave);
    sigaction(SIGQUIT, NULL, &quitsave);

    int pid = fork();
    if (pid == 0) {
        sigaction(SIGINT, &intsave, NULL);
        sigaction(SIGQUIT, &quitsave, NULL);

        if (dup2(cin[0], 0) < 0 || dup2(cout[1], 1) < 0) {
            perror("dup2 failed");
            exit(254);
        }
        if (close(cin[0]) < 0 || close(cin[1]) < 0 ||
            close(cout[0]) < 0 || close(cout[1]) < 0) {
            perror("close failed");
        }

        for (int fd = 0; fd < 2; fd++)
            fcntl(fd, F_SETFD, fcntl(fd, F_GETFD) & ~FD_CLOEXEC);

        char *cargv[5];
        cargv[0] = getenv("QVD_SLAVE_CMD");
        cargv[1] = getenv("QVD_SLAVE_ARG1");
        cargv[2] = getenv("QVD_SLAVE_ARG2");
        cargv[3] = getenv("QVD_SLAVE_ARG3");
        cargv[4] = NULL;

        if (cargv[0] == NULL) {
            errno = EINVAL;
            perror("QVD_SLAVE_CMD not set");
            exit(254);
        }

        execvp(cargv[0], cargv);
        perror("execvp failed");
        exit(254);
     }

    if (pid < 0) {
        perror("fork failed");
        exit(254);
    }

    dup2(cin[1], FDCI);
    dup2(cout[0], FDCO);

    /* for (int fd = FDUNUSED; fd < 256; fd++) close(fd); */

    char p2c[BUFSIZE];
    char c2p[BUFSIZE];

    int p2c_p = 0, p2c_c = 0;
    int c2p_p = 0, c2p_c = 0;

    struct pollfd pfd[FDUNUSED];

    for (int fd = 0; fd < FDUNUSED; fd++) {
        pfd[fd].fd = fd;
        pfd[fd].events = 0;
        pfd[fd].revents = 0;
    }

    pfd[FDPO].events = POLLIN;
    pfd[FDCO].events = POLLIN;

    while (pfd[FDCI].fd >= 0 || pfd[FDPI].fd >= 0) {
        int n = poll(pfd, FDUNUSED, 1000);
        if (n < 0) {
            if (n == EINTR) continue;
            perror("poll failed");
            exit(254);
        }

        if (pfd[FDPI].events) {
            if (pfd[FDPI].revents & POLLOUT) {
                int n = write(FDPI, c2p + c2p_p, (c2p_c - c2p_p));
                if (n < 0) {
                    if (n != EAGAIN && n != EINTR) {
                        perror("write failed");
                        exit(254);
                    }
                }
                else if (n > 0) {
                    c2p_p += n;
                    if (c2p_p == c2p_c) {
                        pfd[FDPI].events = 0;
                        if (pfd[FDCO].fd < 0) {
                            close(FDPI);
                            pfd[FDPI].fd = -1;
                        }
                        else {
                            c2p_p = c2p_c = 0;
                            pfd[FDCO].events = POLLIN;
                        }
                    }
                    else if (c2p_p > (BUFSIZE / 2)) {
                        memcpy(c2p, c2p + c2p_p, c2p_c - c2p_p);
                        c2p_c -= c2p_p;
                        c2p_p = 0;
                        if (pfd[FDCO].fd >= 0)
                            pfd[FDCO].events = POLLIN;
                    }
                }
            }
            else if (pfd[FDPI].revents & POLLHUP) {
                close(FDPI);
                pfd[FDPI].fd = -1;
                pfd[FDPI].events = 0;
                if (pfd[FDCO].fd >= 0) {
                    close(FDCO);
                    pfd[FDCO].fd = -1;
                    pfd[FDCO].events = 0;
                }
            }
        }
        if (pfd[FDCI].events) {
            if (pfd[FDCI].revents & POLLOUT) {
                int n = write(FDCI, p2c + p2c_c, (p2c_p - p2c_c));
                if (n < 0){
                    if (n != EAGAIN && n != EINTR) {
                        perror("write failed");
                        exit(254);
                    }
                }
                else if (n > 0) {
                    p2c_c += n;
                    if (p2c_c == p2c_p) {
                        pfd[FDCI].events = 0;
                        if (pfd[FDPO].fd < 0) {
                            close(FDCI);
                            pfd[FDCI].fd = -1;
                        }
                        else {
                            p2c_c = p2c_p = 0;
                            pfd[FDPO].events = POLLIN;
                        }
                    }
                    else if (p2c_c > (BUFSIZE / 2)) {
                        memcpy(p2c, p2c + p2c_c, p2c_p - p2c_c);
                        p2c_p -= p2c_c;
                        p2c_c = 0;
                        if (pfd[FDPO].fd >= 0)
                            pfd[FDPO].events = POLLIN;
                    }
                }
            }
            else if (pfd[FDCI].revents & POLLHUP) {
                close(FDCI);
                pfd[FDCI].fd = -1;
                pfd[FDCI].events = 0;
                if (pfd[FDPO].fd >= 0) {
                    close(FDPO);
                    pfd[FDPO].fd = -1;
                    pfd[FDPO].events = 0;
                }
            }
        }
        if (pfd[FDPO].events) {
            if (pfd[FDPO].revents & POLLIN) {
                int n = read(FDPO, p2c + p2c_p, BUFSIZE - p2c_p);
                if (n < 0) {
                     if (n != EAGAIN && n != EINTR) {
                        perror("write failed");
                        exit(254);
                    }
                }
                else {
                    p2c_p += n;
                    if (p2c_p) {
                        pfd[FDCI].events = POLLOUT;
                        if (p2c_p ==  BUFSIZE)
                            pfd[FDPO].events = 0;
                    }
                }
            }
            else if (pfd[FDPO].revents & POLLHUP) {
                close(FDPO);
                pfd[FDPO].fd = -1;
                pfd[FDPO].events = 0;
                if (p2c_p == p2c_c) {
                    close(FDCI);
                    pfd[FDCI].fd = -1;
                    pfd[FDCI].events = 0;
                }
            }
        }
        if (pfd[FDCO].events) {
            if (pfd[FDCO].revents & POLLIN) {
                int n = read(FDCO, c2p + c2p_c, BUFSIZE - c2p_c);
                if (n < 0) {
                     if (n != EAGAIN && n != EINTR) {
                        perror("write failed");
                        exit(254);
                    }
                }
                else {
                    c2p_c += n;
                    if (c2p_c) {
                        pfd[FDPI].events = POLLOUT;
                        if (c2p_c ==  BUFSIZE)
                            pfd[FDCO].events = 0;
                    }
                }
            }
            else if (pfd[FDCO].revents & POLLHUP) {
                close(FDCO);
                pfd[FDCO].fd = -1;
                pfd[FDCO].events = 0;
                if (c2p_c == c2p_p) {
                    close(FDPI);
                    pfd[FDPI].fd = -1;
                    pfd[FDPI].events = 0;
                }
            }
        }
    }

    int wstatus;
    while(1) {
        int rc = waitpid(pid, &wstatus, 0);
        if (rc < 0) {
            perror("waitpid failed");
            exit(254);
        }
        if (rc > 0) {
            if (WIFEXITED(wstatus))
                exit(WEXITSTATUS(wstatus));
            if (WIFSIGNALED(wstatus)) {
                sigaction(SIGINT, &intsave, NULL);
                sigaction(SIGQUIT, &quitsave, NULL);
                raise(WTERMSIG(wstatus));
            }
            exit(254);
        }
        poll(pfd, 0, 100);
    }
}
