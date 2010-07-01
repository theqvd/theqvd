#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <dlfcn.h>
#include <sys/time.h>
#include <unistd.h>
#include <sys/types.h>
#include <utime.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/un.h>
#include "../inc/control.h"
#include "../inc/misc.h"
#include "../inc/telnet.h"
#define SHARED_OBJECT
#include "../inc/port_speed.h"
#include <signal.h>
#include <syslog.h>

#define MAX_PORTS 32

static void *libc = NULL;
static int (*real_tcsetattr) (int fd, int optional_actions,
			      const struct termios * termios_p) = NULL;
static int (*real_tcsendbreak) (int fd, int duration);
static char *cyclades_devices[MAX_PORTS];
static int num_devices;
static int socket_fd = -1;
static int socket_ind = -1;

void
libcsc_init()
{
    FILE *fp = NULL;
    char *cyclades_env = NULL;

    libc = dlopen(LIBC, RTLD_LAZY | RTLD_GLOBAL);
    if (!libc) {
	printf("Can't map " LIBC "\n");
	exit(1);
    }
    real_tcsetattr =
	(int (*)(int, int, const struct termios *)) dlsym(libc, "tcsetattr");
    real_tcsendbreak = (int (*)(int, int)) dlsym(libc, "tcsendbreak");

    num_devices = 0;
    cyclades_env = getenv("CYCLADES_DEVICES");
    if (cyclades_env) {
	char *next;
	while (num_devices < MAX_PORTS && cyclades_env && *cyclades_env) {
	    next = strchr(cyclades_env, ':');
	    if (next) {
		*next = '\0';
		next++;
	    }
	    cyclades_devices[num_devices] = strdup(cyclades_env);
	    num_devices++;
	    cyclades_env = next;
	}
    }
    else
	fp = fopen("/etc/cyclades-devices", "r");

    if (fp) {
	char str[1024];
	while (num_devices < MAX_PORTS && fgets(str, sizeof(str), fp)) {
	    if (str[0] == '/') {
		strtok(str, ":\r\n");
		cyclades_devices[num_devices] = strdup(str);
		num_devices++;
	    }
	}
	fclose(fp);
    }
}

void
libcsc_fini()
{
    dlclose(libc);
    libc = NULL;
}

static void
close_socket()
{
    close(socket_fd);
    socket_fd = -1;
    socket_ind = -1;
}

static int
open_socket(int ind)
{
    struct sockaddr_un addr;

    if (socket_ind == ind)
	return 0;
    if (socket_fd >= 0)
	close(socket_fd);
    socket_fd = socket(PF_UNIX, SOCK_STREAM, 0);
    if (socket_fd == -1)
	return -1;
    addr.sun_family = AF_UNIX;
    snprintf(addr.sun_path, sizeof(addr.sun_path), "%s.control",
	     cyclades_devices[ind]);
    addr.sun_path[sizeof(addr.sun_path) - 1] = '\0';
    socket_ind = ind;
    if (connect(socket_fd, (const struct sockaddr *) &addr, sizeof(addr))) {
	close(socket_fd);
	socket_fd = -1;
	socket_ind = -1;
	return -1;
    }
    return 0;
}

static int
get_device_ind(int fd)
{
    struct stat device_stat, fd_stat;
    int i;

    if (fstat(fd, &fd_stat))
	return -1;
    for (i = 0; i < num_devices; i++) {
	if (!stat(cyclades_devices[i], &device_stat)) {
	    if (device_stat.st_dev == fd_stat.st_dev
		&& device_stat.st_ino == fd_stat.st_ino)
		return i;
	}
    }
    return -1;
}

static int
send_data(int port_ind, e_operation oper, int val, int extra_timeout)
{
    fd_set readfds, exceptfds;
    struct timeval timeout;
    s_control s;
    struct sigaction act, oldact;
    int rc;
    int no_ign_pipe = 0;

    if (open_socket(port_ind) == -1)
	return -1;
    act.sa_handler = SIG_IGN;
    if (sigaction(SIGPIPE, &act, &oldact)) {
	syslog(LOG_WARNING, "libcyclades-ser-cli: Can't ignore SIGPIPE.");
	no_ign_pipe = 1;
    }

    s.oper = oper;
    s.val = val;
    s.size = sizeof(s_control);
    if (send(socket_fd, &s, sizeof(s_control), 0) != sizeof(s_control)) {
	if (!no_ign_pipe) {
	    if (sigaction(SIGPIPE, &oldact, NULL))
		syslog(LOG_ERR,
		       "libcyclades-ser-cli: Can't reset SIGPIPE handler.");
	}
	close_socket();
	return -1;
    }
    FD_ZERO(&readfds);
    FD_SET(socket_fd, &readfds);
    FD_ZERO(&exceptfds);
    FD_SET(socket_fd, &exceptfds);
    timeout.tv_sec = extra_timeout + 2;
    timeout.tv_usec = 0;
    if (select(socket_fd + 1, &readfds, NULL, &exceptfds, &timeout) != 1
	|| FD_ISSET(socket_fd, &exceptfds)) {
	if (!no_ign_pipe) {
	    if (sigaction(SIGPIPE, &oldact, NULL))
		syslog(LOG_ERR,
		       "libcyclades-ser-cli: Can't reset SIGPIPE handler.");
	}
	close_socket();
	return -1;
    }
    rc = recv(socket_fd, &s, sizeof(s), MSG_WAITALL);
    if (!no_ign_pipe) {
	if (sigaction(SIGPIPE, &oldact, NULL))
	    syslog(LOG_ERR,
		   "libcyclades-ser-cli: Can't reset SIGPIPE handler.");
    }
    if (rc != sizeof(s) || s.val != val || s.oper != oper
	|| s.size != sizeof(s)) {
	close_socket();
	return -1;
    }
    return 0;
}

static void
do_xon_xoff(int ind, int *a_success, int *a_fail, struct termios *term,
	    const struct termios *termios_p)
{
/* first do XON/XOFF for outbound/both */
    if ((term->c_iflag & IXON) != (termios_p->c_iflag & IXON)) {
	int xon = COM_OFLOW_NONE;
	if (termios_p->c_iflag & IXON)
	    xon = COM_OFLOW_SOFT;
	if (!send_data(ind, eSET_CONTROL, xon, 0)) {
	    /* if we set outbound XON/XOFF we set inbound as well and we need to
	     * turn it off next */
	    term->c_iflag &= !(IXON | IXOFF);
#ifdef CRTSCTS
	    term->c_cflag &= !CRTSCTS;
#endif
	    if (termios_p->c_iflag & IXON)
		term->c_iflag |= (IXON | IXOFF);
	    *a_success++;
	}
	else
	    *a_fail++;
    }
    if ((term->c_iflag & IXOFF) != (termios_p->c_iflag & IXOFF)) {
	int xon = COM_IFLOW_NONE;
	if (termios_p->c_iflag & IXOFF)
	    xon = COM_IFLOW_SOFT;
	if (!send_data(ind, eSET_CONTROL, xon, 0)) {
	    term->c_iflag &= !IXOFF;
#ifdef CRTSCTS
	    term->c_cflag &= !CRTSCTS;
#endif
	    term->c_iflag |= termios_p->c_iflag & IXON;
	    *a_success++;
	}
	else
	    *a_fail++;
    }
}

int
tcsetattr(int fd, int optional_actions, const struct termios *termios_p)
{
    int ind = get_device_ind(fd);
    struct termios term;
    int a_fail = 0, a_success = 0;
    speed_t i_sp, o_sp, term_sp;

    if (ind == -1)
	return real_tcsetattr(fd, optional_actions, termios_p);
    if (tcgetattr(fd, &term))
	return -1;
    if (!memcmp(&term, termios_p, sizeof(struct termios)))
	return 0;

    if ((term.c_cflag & HUPCL) != (termios_p->c_cflag & HUPCL)) {
	term.c_cflag &= !HUPCL;
	term.c_cflag |= termios_p->c_cflag & HUPCL;
	a_success++;
    }
    /* Some really ugly code because termios supports split baud rates while
     * RFC 2217 does not.  */
    i_sp = cfgetispeed(termios_p);
    o_sp = cfgetospeed(termios_p);
    term_sp = cfgetispeed(&term);
    if (i_sp != term_sp || o_sp != term_sp) {
	if (i_sp != o_sp) {
	    if (i_sp != term_sp)
		term_sp = i_sp;
	    else
		term_sp = o_sp;
	}
	else {
	    term_sp = i_sp;
	}
	if (!send_data(ind, eSET_SPEED, baud_index_to_int(term_sp), 0)) {
	    cfsetispeed(&term, term_sp);
	    cfsetospeed(&term, term_sp);
	    a_success++;
	}
	else
	    a_fail++;
    }
    if ((term.c_cflag & CSIZE) != (termios_p->c_cflag & CSIZE)) {
	int csize;

	switch (termios_p->c_cflag & CSIZE) {
	case CS5:
	    csize = 5;
	    break;
	case CS6:
	    csize = 6;
	    break;
	case CS7:
	    csize = 7;
	    break;
	case CS8:
	    csize = 8;
	    break;
	default:
	    csize = 0;
	}
	if (csize == 0) {
	    a_fail++;
	}
	else {
	    if (!send_data(ind, eSET_CSIZE, csize, 0)) {
		a_success++;
		term.c_cflag = (term.c_cflag & (!CSIZE)) | csize;
	    }
	    else
		a_fail++;
	}
    }
    if ((term.c_iflag & INPCK) != (termios_p->c_iflag & INPCK)
	|| (term.c_cflag & (PARENB | PARODD)) !=
	(termios_p->c_cflag & (PARENB | PARODD))) {
	int parity;
	if (termios_p->c_cflag & PARENB) {
	    if (termios_p->c_cflag & PARODD)
		parity = 2;	/* parity Odd */
	    else
		parity = 3;	/* parity Even */
	}
	else
	    parity = 1;		/* parity None */

	if (!send_data(ind, eSET_PARITY, parity, 0)) {
	    term.c_cflag &= !(PARENB | PARODD);
	    term.c_cflag |= termios_p->c_cflag & (PARENB | PARODD);
	    a_success++;
	}
	else
	    a_fail++;
    }
    if ((term.c_cflag & CSTOPB) != (termios_p->c_cflag & CSTOPB)) {
	int stop = 1;
	if (termios_p->c_cflag & CSTOPB)
	    stop = 2;
	if (!send_data(ind, eSET_STOPSIZE, stop, 0)) {
	    term.c_cflag &= !CSTOPB;
	    term.c_cflag |= termios_p->c_cflag & CSTOPB;
	    a_success++;
	}
	else
	    a_fail++;
    }
    do_xon_xoff(ind, &a_success, &a_fail, &term, termios_p);
#ifdef CRTSCTS
/* CRTSCTS is not in POSIX */
    if ((term.c_cflag & CRTSCTS) != (termios_p->c_cflag & CRTSCTS)) {
	int rtscts = COM_OFLOW_NONE;
	if (termios_p->c_cflag & CRTSCTS)
	    rtscts = COM_OFLOW_HARD;
	if (!send_data(ind, eSET_CONTROL, rtscts, 0)) {
	    term.c_cflag &= !CRTSCTS;
	    term.c_cflag |= termios_p->c_cflag & CRTSCTS;
	    a_success++;
	    if (rtscts == COM_OFLOW_NONE) {
		/* if we turn off RTSCTS then it also turns off xon/xof and we need
		 * to turn it back on.  RFC2217 sucks in this regard */
		term.c_iflag &= !(IXON | IXOFF);
		do_xon_xoff(ind, &a_success, &a_fail, &term, termios_p);
	    }
	}
	else
	    a_fail++;
    }
#endif
    if (memcmp(&term.c_cc, &termios_p->c_cc, sizeof(term.c_cc))) {
	memcpy(&term.c_cc, &termios_p->c_cc, sizeof(term.c_cc));
	a_success++;
    }
    if (a_success)
	real_tcsetattr(fd, optional_actions, &term);
    if (a_success || !a_fail)
	return 0;
    return -1;
}

int
tcsendbreak(int fd, int duration)
{
    int ind = get_device_ind(fd);
    if (ind == -1)
	return real_tcsendbreak(fd, duration);
    return send_data(ind, eSEND_BREAK, duration, duration % 4 + 1);
}
