#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
/* __USE_GNU is for strcasestr */
#define __USE_GNU
#include <string.h>
#include <sys/socket.h>
#include <sys/select.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <openssl/ssl.h>
#include <openssl/bio.h>
#include <openssl/evp.h>
#include <curl/curl.h>
#include <jansson.h>
#include <NX.h>
#include "qvdclient.h"
#include "qvdbuffer.h"
#include "qvdvm.h"

/* See http://www.openssl.org/docs/ssl/SSL_get_ex_new_index.html# */
#ifndef ANDROID
extern char **environ;
#endif

static int _qvd_ssl_index;

int _qvd_proxy_connect(qvdclient *qvd);
int _qvd_client_loop(qvdclient *qvd, int connFd, int proxyFd);
size_t _qvd_write_buffer_callback(void *contents, size_t size, size_t nmemb, void *buffer);
/* static void _qvd_dumpcert(X509 *x); */
/* void _qvd_print_certificate(X509 *cert); */
int _qvd_verify_cert_callback(int preverify_ok, X509_STORE_CTX *x509_ctx);
CURLcode _qvd_sslctxfun(CURL *curl, SSL_CTX *sslctx, void *parm);
int _qvd_set_base64_auth(qvdclient *qvd);
int _qvd_switch_protocols(qvdclient *qvd, int id);
void _qvd_print_environ();
int _qvd_set_certdir(qvdclient *qvd);
int _qvd_dir_exists(qvdclient *qvd, const char *path);
int _qvd_create_dir(qvdclient *qvd, const char *home, const char *subdir);
int _qvd_use_client_cert(qvdclient *qvd);
static char qvdversion[MAX_STRING_VERSION];

int qvd_get_version(void) {
  return QVDVERSION;
}

const char *qvd_get_version_text(void) {
  snprintf(qvdversion, MAX_STRING_VERSION, "QVD Version: %s\nCurl Version: %s\nOpenssl version: %s\nnxcomp version: %s\n", QVDABOUT, curl_version(), OPENSSL_VERSION_TEXT, NXVersion());
  return qvdversion;
}

const char *qvd_get_changelog(void) {
  return QVDCHANGELOG;
}

/* Init and free functions */
qvdclient *qvd_init(const char *hostname, const int port, const char *username, const char *password) {
  qvdclient *qvd;
  qvd_printf("Starting qvd_init. %s", qvd_get_version_text());
  if (strlen(username) + strlen(password) + 2 > MAX_USERPWD) {
    qvd_error(qvd, "Length of username and password + 2 is longer than %d\n", MAX_USERPWD);
    return NULL;
  }

  if (strlen(hostname) + 6 + strlen("https:///") + 2 > MAX_BASEURL) {
    qvd_error(qvd, "Length of hostname and port + scheme  + 2 is longer than %d\n", MAX_BASEURL);
    return NULL;
  }

  if (! (qvd = (qvdclient *) malloc(sizeof(qvdclient)))) {
    qvd_error(qvd, "Error allocating memory: %s", strerror(errno));
    return NULL;
  }

  if (snprintf(qvd->userpwd, MAX_USERPWD, "%s:%s", username, password) >= MAX_USERPWD) {
    qvd_error(qvd, "Error initializing userpwd (string too long)\n");
    free(qvd);
    return NULL;
  }
  if (_qvd_set_base64_auth(qvd)) {
    qvd_error(qvd, "Error initializing authdigest\n");
    free(qvd);
    return NULL;
    }

  if (snprintf(qvd->baseurl, MAX_BASEURL, "https://%s:%d", hostname, port) >= MAX_BASEURL) {
    qvd_error(qvd, "Error initializing baseurl(string too long)\n");
    free(qvd);
    return NULL;
  }

  if (snprintf(qvd->useragent, MAX_USERAGENT, "%s %s", DEFAULT_USERAGENT_PRODUCT, curl_version()) >= MAX_USERAGENT) {
    qvd_error(qvd, "Error initializing useragent (string too long)\n");
    free(qvd);
    return NULL;
  }

  qvd->curl = curl_easy_init();
  if (!qvd->curl) {
    qvd_error(qvd, "Error initializing curl\n");
    free(qvd);
    return NULL;
  }
  qvd_printf("Curl pointer is %p", qvd->curl);
  if (get_debug_level()) {
    curl_easy_setopt(qvd->curl, CURLOPT_VERBOSE, 1L);
    curl_easy_setopt(qvd->curl, CURLOPT_DEBUGFUNCTION, qvd_curl_debug_callback);
  }

  curl_easy_setopt(qvd->curl, CURLOPT_ERRORBUFFER, qvd->error_buffer);  /* curl_easy_setopt(qvd->curl, CURLOPT_SSL_VERIFYPEER, 1L); */
  /* curl_easy_setopt(qvd->curl, CURLOPT_SSL_VERIFYHOST, 2L); */
  curl_easy_setopt(qvd->curl, CURLOPT_CERTINFO, 1L);
  curl_easy_setopt(qvd->curl, CURLOPT_CAPATH, qvd->certpath);
  curl_easy_setopt(qvd->curl, CURLOPT_SSL_CTX_FUNCTION, _qvd_sslctxfun);
  curl_easy_setopt(qvd->curl, CURLOPT_SSL_CTX_DATA, (void *)qvd);
  /*  curl_easy_setopt(qvd->curl, CURLOPT_CAINFO, NULL);*/
  _qvd_ssl_index = SSL_CTX_get_ex_new_index(0, (void *)qvd, NULL, NULL, NULL);
  curl_easy_setopt(qvd->curl, CURLOPT_SSL_VERIFYPEER, 0L);
  curl_easy_setopt(qvd->curl, CURLOPT_SSL_VERIFYHOST, 0L);
  curl_easy_setopt(qvd->curl, CURLOPT_TCP_NODELAY, 1L);
  /*  curl_easy_setopt(qvd->curl, CURLOPT_FAILONERROR, 1L);*/
  curl_easy_setopt(qvd->curl, CURLOPT_HTTPAUTH, (long)CURLAUTH_BASIC);
  curl_easy_setopt(qvd->curl, CURLOPT_USERPWD, qvd->userpwd);
  curl_easy_setopt(qvd->curl, CURLOPT_WRITEFUNCTION, _qvd_write_buffer_callback);
  curl_easy_setopt(qvd->curl, CURLOPT_WRITEDATA, &(qvd->buffer));
  curl_easy_setopt(qvd->curl, CURLOPT_USERAGENT, qvd->useragent);
  /* If client certificate CURLOPT_SSLCERT , CURLOPT_SSLKEY, CURLOPT_SSLCERTTYPE "PEM" */
  /* Copy parameters */
  strncpy(qvd->hostname, hostname, MAX_BASEURL);
  qvd->hostname[MAX_BASEURL - 1] = '\0';
  qvd->port = port;
  strncpy(qvd->username, username, MAX_USERPWD);
  qvd->username[MAX_USERPWD - 1] = '\0';
  strncpy(qvd->password, password, MAX_USERPWD);
  qvd->password[MAX_USERPWD - 1] = '\0';
  strncpy(qvd->client_cert, "", MAX_PATH_STRING);
  strncpy(qvd->client_key, "", MAX_PATH_STRING);
  qvd->use_client_cert = 0;
  qvd->numvms = 0;
  qvd_set_link(qvd, DEFAULT_LINK);
  qvd_set_geometry(qvd, DEFAULT_GEOMETRY);
  qvd_set_os(qvd, DEFAULT_OS);
  qvd->keyboard = "pc%2F105";
  qvd->fullscreen = 0;
  qvd->print_enabled = 0;
  qvd->ssl_no_cert_check = 0;
  qvd->ssl_verify_callback = NULL;
  qvd->progress_callback = NULL;
  qvd->userdata = NULL;
  qvd->nx_options = NULL;
  qvd->payment_required=0;

  *(qvd->display) = '\0';
  *(qvd->home) = '\0';
  strcpy(qvd->error_buffer, "");
  QvdBufferInit(&(qvd->buffer));

  if (!(qvd->vmlist = malloc(sizeof(vmlist)))) {
    free(qvd);
    return NULL;
  }
  QvdVmListInit(qvd->vmlist);

  return qvd;
}

void qvd_free(qvdclient *qvd) {
  qvd_printf("Calling qvd_free with qvd=%p, and curl=%p\n", qvd, qvd->curl);
  curl_easy_cleanup(qvd->curl);
  QvdVmListFree(qvd->vmlist);
  /* nx_options should be null */
  free(qvd->nx_options);
  free(qvd);
}

vmlist *qvd_list_of_vm(qvdclient *qvd) {
  char url[MAX_BASEURL];
  int i;
  long http_code = 0;
  json_error_t error;
  char *command = "/qvd/list_of_vm";

  if (!_qvd_set_certdir(qvd)) {
    qvd_printf("Please set the cert dir");
    return NULL;
  }

  if (qvd->home && (*(qvd->home)) != '\0') {
    qvd_printf("Setting NX_HOME to %s\n", qvd->home);
    if (setenv("NX_HOME", qvd->home, 1)) {
      qvd_error(qvd, "Error setting NX_HOME to %s. errno: %d (%s)", qvd->home, errno, strerror(errno));
    }
  }

  if (snprintf(url, MAX_BASEURL, "%s%s", qvd->baseurl, command) >= MAX_BASEURL) {
    qvd_error(qvd, "Error initializing url in list_of_vm, length is longer than %d\n", MAX_BASEURL);
    return NULL;
  }

  _qvd_use_client_cert(qvd);
  curl_easy_setopt(qvd->curl, CURLOPT_URL, url);
  /*  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &jsonBuffer); */
  qvd->res = curl_easy_perform(qvd->curl);
  qvd_printf("After easy_perform: %ul\n", qvd->res);
  if (qvd->res)
    {
      qvd_printf("Error accessing url: <%s>, error code: %ul\n", url, qvd->res);
      qvd_error(qvd, "Error accessing list of VMs: %s\n", curl_easy_strerror(qvd->res));
      return NULL;
    }

  curl_easy_getinfo (qvd->curl, CURLINFO_RESPONSE_CODE, &http_code);
  if (http_code == 401)
    {
      qvd_error(qvd, "Error authenticating user\n");
      return NULL;
    }
  if (http_code == 402)
    {
      qvd->payment_required = 1;
      qvd_error(qvd, "Error no subscription available\n");
      /*      qvd->numvms = 0;
      QvdVmListInit(qvd->vmlist);
      return qvd->vmlist;
      */
      return NULL;
    }
  qvd_printf("No error and no auth error after curl_easy_perform\n");
  /*  QvdBufferInit(&(qvd->buffer)); */

  json_t *vmList = json_loads(qvd->buffer.data, 0, &error);
  int arrayLength = json_array_size(vmList);
  qvd->numvms = arrayLength;
  qvd_printf("VMs available: %d\n", qvd->numvms);

  QvdVmListFree(qvd->vmlist);
  if (!(qvd->vmlist = malloc(sizeof(vmlist)))) {
    qvd_error(qvd, "Error allocating memory for vmlist");
    return NULL;
  }
  QvdVmListInit(qvd->vmlist);

  for (i = 0; i < arrayLength; i++) {
    json_t *obj = json_array_get(vmList, i);
    int id, blocked;
    char *name, *state;
    json_unpack(obj, "{s:i,s:s,s:i,s:s}",
		"id", &id,
		"state", &state,
		"blocked", &blocked,
		"name", &name);
    qvd_printf("VM ID:%d NAME:%s STATE:%s BLOCKED:%d\n",
	       id, name, state, blocked);
    QvdVmListAppendVm(qvd, qvd->vmlist, QvdVmNew(id, name, state, blocked));
  }
  /*  QvdBufferReset(&(qvd->buffer));*/
  if (qvd->numvms <= 0) {
    qvd_error(qvd, "No virtual machines available for user %s\n", qvd->username);
  } else {
    qvd_progress(qvd, "Returning list of vms");
  }
  return qvd->vmlist;
}

int qvd_stop_vm(qvdclient *qvd, int vm) {
  char url[MAX_BASEURL];
  int i;
  long http_code = 0;
  json_error_t error;
  char *command = "/qvd/stop_vm";

  if (!_qvd_set_certdir(qvd)) {
    qvd_printf("Please set the cert dir");
    return 1;
  }

  if (snprintf(url, MAX_BASEURL, "%s%s", qvd->baseurl, command) >= MAX_BASEURL) {
    qvd_error(qvd, "Error initializing url in list_of_vm, length is longer than %d\n", MAX_BASEURL);
    return 2;
  }

  _qvd_use_client_cert(qvd);
  curl_easy_setopt(qvd->curl, CURLOPT_URL, url);
  /*  curl_easy_setopt(curl, CURLOPT_WRITEDATA, &jsonBuffer); */
  qvd->res = curl_easy_perform(qvd->curl);
  qvd_printf("After easy_perform: %ul\n", qvd->res);
  if (qvd->res)
    {
      qvd_printf("Error accessing url: <%s>, error code: %ul\n", url, qvd->res);
      qvd_error(qvd, "Error accessing list of VMs: %s\n", curl_easy_strerror(qvd->res));
      return 3;
    }

  curl_easy_getinfo (qvd->curl, CURLINFO_RESPONSE_CODE, &http_code);
  if (http_code == 401)
    {
      qvd_error(qvd, "Error authenticating user\n");
      return 4;
    }
  qvd_printf("No error and no auth error after curl_easy_perform\n");
  /*  QvdBufferInit(&(qvd->buffer)); */


   return 0;
}

int qvd_connect_to_vm(qvdclient *qvd, int id)
{
  int result, proxyFd, fd;
  long curlsock;

  qvd_printf("qvd_connect_to_vm(%p,%d)", qvd, id);
  if (qvd->display && (*(qvd->display)) != '\0') {
    qvd_printf("Setting DISPLAY to %s\n", qvd->display);
    if (setenv(DISPLAY_ENV, qvd->display, 1)) {
      qvd_error(qvd, "Error setting DISPLAY to %s. errno: %d (%s)", qvd->display, errno, strerror(errno));
    }
  }
  if (qvd->home && (*(qvd->home)) != '\0') {
    qvd_printf("Setting NX_HOME to %s\n", qvd->home);
    if (setenv("NX_HOME", qvd->home, 1)) {
      qvd_error(qvd, "Error setting NX_HOME to %s. errno: %d (%s)", qvd->home, errno, strerror(errno));
    }
  }
  if (!_qvd_set_certdir(qvd)) {
    qvd_printf("Please set the cert dir");
    return 5;
  }

  qvd->end_connection = 0;

  result = _qvd_switch_protocols(qvd, id);
  _qvd_print_environ();
  /* if non zero return with error */
  if (result)
    return result;

  curl_easy_getinfo(qvd->curl, CURLINFO_LASTSOCKET, &curlsock);
  fd = (int) curlsock;
  qvd_printf("QVD curl socket is %d", fd);
  if (fd == -1) {
      qvd_error(qvd, "Error getting recent socket from curl");
     return 7;
  }

  if ((proxyFd = _qvd_proxy_connect(qvd)) < 0)
    return 4;

  qvd_printf("Remote fd: %d Local fd: %d\n", fd, proxyFd);
  qvd_printf("Before _qvd_client_loop\n");
  result = _qvd_client_loop(qvd, fd, proxyFd);
  qvd_progress(qvd, "End of QVD connection");
  shutdown(proxyFd, 2); // is invoked in qvd_free
  qvd_printf("before NXTransDestroy\n");
  NXTransDestroy(NX_FD_ANY);
  qvd_printf("after NXTransDestroy\n");

  if (result)
    return 6;

  return 0;
}


/*
 * TODO set general way to set options
 */
void qvd_set_fullscreen(qvdclient *qvd) {
  qvd->fullscreen = 1;
}
void qvd_set_nofullscreen(qvdclient *qvd) {
  qvd->fullscreen = 0;
}
void qvd_set_debug() {
  set_debug_level(2);
}

void qvd_set_display(qvdclient *qvd, const char *display) {
  strncpy(qvd->display, display, MAXDISPLAYSTRING);
  qvd->display[MAXDISPLAYSTRING - 1] = '\0';
}

void qvd_set_home(qvdclient *qvd, const char *home) {
  strncpy(qvd->home, home, MAX_PATH_STRING);
  qvd->home[MAX_PATH_STRING - 1] = '\0';
}

char *qvd_get_last_error(qvdclient *qvd) {
  return qvd->error_buffer;
}

void qvd_set_useragent(qvdclient *qvd, const char *useragent) {
  strncpy(qvd->useragent, useragent, MAX_USERAGENT);
  qvd->useragent[MAX_USERAGENT - 1] = '\0';
  curl_easy_setopt(qvd->curl, CURLOPT_USERAGENT, qvd->useragent);
}
void qvd_set_os(qvdclient *qvd, const char *os) {
  strncpy(qvd->os, os, MAX_OS);
  qvd->os[MAX_OS - 1] = '\0';
}
void qvd_set_geometry(qvdclient *qvd, const char *geometry) {
  strncpy(qvd->geometry, geometry, MAX_GEOMETRY);
  qvd->os[MAX_GEOMETRY - 1] = '\0';
}
void qvd_set_link(qvdclient *qvd, const char *link) {
  strncpy(qvd->link, link, MAX_LINK);
  qvd->os[MAX_LINK - 1] = '\0';
}

void qvd_set_no_cert_check(qvdclient *qvd) {
  qvd->ssl_no_cert_check = 1;
}
void qvd_set_strict_cert_check(qvdclient *qvd) {
  qvd->ssl_no_cert_check = 0;
}


void qvd_set_unknown_cert_callback(qvdclient *qvd, int (*ssl_verify_callback)(qvdclient *qvd, const char *cert_pem_str, const char *cert_pem_data))
{
  qvd->ssl_verify_callback = ssl_verify_callback;
}

void qvd_set_progress_callback(qvdclient *qvd, int (*progress_callback)(qvdclient *, const char *message))
{
  qvd_printf("Setting progress callback\n");
  qvd->progress_callback = progress_callback;
}

void qvd_set_nx_options(qvdclient *qvd, const char *nx_options) {
  /*  MAX_NX_OPTS_BUFFER */
  /* Should be null in case it was never defined */
  free(qvd->nx_options);
  qvd->nx_options = malloc(strlen(nx_options) + 1);
  strcpy(qvd->nx_options, nx_options);
}

/*
 * Internal funcs for qvd_init
 */

int _qvd_set_certdir(qvdclient *qvd)
{
  char *home = getenv(HOME_ENV);
  char *appdata = getenv(APPDATA_ENV);

  int result;
  if (home == NULL && appdata == NULL && !qvd->home && (*(qvd->home)) == '\0' && !_qvd_dir_exists(qvd, qvd->home)
      && _qvd_dir_exists(qvd, home) && !_qvd_dir_exists(qvd, appdata))
    {
      qvd_error(qvd, "Error %s and %s environment var were not defined, cannot save to $HOME/.qvd/certs, you can try to set also qvd_set_home", HOME_ENV, APPDATA_ENV);
      return 0;
    }

  if (qvd->home && (*(qvd->home)) && _qvd_dir_exists(qvd, qvd->home))
    {
      home = qvd->home;
    } else if (home != NULL && _qvd_dir_exists(qvd, home))
    {
      qvd_set_home(qvd, home);
      qvd_printf("using %s environment var", HOME_ENV);
    } else if (appdata != NULL && _qvd_dir_exists(qvd, appdata))
    {
      qvd_set_home(qvd, appdata);
      home = appdata;
      qvd_printf("%s was not defined using %s environment var", HOME_ENV, APPDATA_ENV);
    }

  /* Define .qvd/certs in qvdclient.h */
  if (!_qvd_create_dir(qvd, home, CONF_DIR))
    return 0;

  if (!_qvd_create_dir(qvd, home, CERT_DIR))
    return 0;

  snprintf(qvd->certpath, MAX_PATH_STRING, "%s/%s", home, CERT_DIR);
  qvd->certpath[MAX_PATH_STRING - 1] = '\0';
  if (strlen(qvd->certpath) == MAX_PATH_STRING)
    {
      qvd_error(qvd, "Cert string too long (%d) recompile program. Path is %s", MAX_PATH_STRING, qvd->certpath);
      return 0;
    }
  qvd_printf("Setting cert path to %s\n", qvd->certpath);
  curl_easy_setopt(qvd->curl, CURLOPT_CAPATH, qvd->certpath);
  return 1;
}

int _qvd_set_base64_auth(qvdclient *qvd)
{
  CURLcode error;
  char *ptr = NULL, *content;
  size_t outlen;
  int result = 0;
  char *digest = NULL;
  BIO *bio, *b64;

  // Digest using the openssl BIO functionality
  b64 = BIO_new(BIO_f_base64());
  bio = BIO_new(BIO_s_mem());
  bio = BIO_push(b64, bio);
  BIO_set_flags(b64, BIO_FLAGS_BASE64_NO_NL);
  BIO_write(b64, qvd->userpwd, strlen(qvd->userpwd));
  BIO_flush(b64);

  outlen = BIO_get_mem_data(bio, &ptr);

  if ( outlen >= MAX_AUTHDIGEST-1 )
    {
      qvd_error(qvd, "The authdigest string for %s is longer than %d\n", qvd->userpwd, MAX_AUTHDIGEST);
      result = 1;
    }
  else
    {
      // The resulting digest isn't zero terminated
      memcpy(qvd->authdigest, ptr, outlen);
      qvd->authdigest[outlen] = '\0';

#ifdef TRACE
      qvd_printf("The conversion to base64 from <%s> is <%s>", qvd->userpwd, qvd->authdigest);
#endif
      result = 0;
    }

  BIO_free_all(bio);


  /* hack for base64 encode of "nito@deiro.com:O3xTMCQ3" */
  /*  snprintf(qvd->authdigest, MAX_AUTHDIGEST, "%s", "bml0b0BkZWlyby5jb206TzN4VE1DUTM=");*/
  return result;
}

/*
 * Internal funcs for qvd_connect_to_vm
 */
int _qvd_proxy_connect(qvdclient *qvd)
{
  int proxyPair[2];
  if (socketpair(PF_UNIX, SOCK_STREAM, 0, proxyPair) < 0)
    {
      qvd_error(qvd, "Error creating proxy socket <%s>\n", strerror(errno));
      return -1;
    }
  /*  if (NXTransCreate(proxyPair[0], NX_MODE_SERVER, "nx/nx,data=0,delta=0,cache=16384,pack=0:0") < 0)*/
  if (NXTransCreate(proxyPair[0], NX_MODE_SERVER, qvd->nx_options) < 0)
    {
      qvd_error(qvd, "Error creating proxy transport <%s>\n", strerror(errno));
      return -1;
    }
  return proxyPair[1];
}

/*
 * _qvd_client_loop
 *            --------------------
 *            |                  |
 * proxyFd ---| _qvd_client_loop |---connFd
 * (X display)|                  | (curl to remote host)
 *            --------------------
 *
 *       -----   proxyRead  ---->
 *      <-----   proxyWrite ----
 *
 * We read from proxyFd and store it in the proxyRead buffer and then write it into connFd (curl)
 * We read from connFd and store it in the proxyWrite buffer and then write it ingo proxyFd (NX)
 *
 */
int _qvd_client_loop(qvdclient *qvd, int connFd, int proxyFd)
{
  qvd_printf("_qvd_client_loop\n");
  size_t read = 0, written = 0;
  struct timeval timeout;
  fd_set rfds, wfds;
  int ret, res, err, maxfds, numunsupportedprotocolerrs = 0, result = 0, i;

  QvdBuffer proxyWrite, proxyRead;
  qvd_printf("_qvd_client_loop(%p, %d, %d)\n", qvd, connFd, proxyFd);
  QvdBufferInit(&proxyWrite);
  QvdBufferInit(&proxyRead);
  do
    {
      ret = 0;
      timeout.tv_sec = QVDLOOP_TIMEOUT_SEC;
      timeout.tv_usec = QVDLOOP_TIMEOUT_USEC;
      maxfds = 1+MAX(connFd, proxyFd);
      FD_ZERO(&rfds);
      FD_ZERO(&wfds);
      if (proxyFd > 0 && QvdBufferCanRead(&proxyRead))
	  FD_SET(proxyFd, &rfds);

      if (connFd > 0 && QvdBufferCanRead(&proxyWrite))
	FD_SET(connFd, &rfds);

      if (NXTransPrepare(&maxfds, &rfds, &wfds, &timeout))
	{
#ifdef TRACE
	  qvd_printf("_qvd_client_loop: executing select()\n");
#endif
	  NXTransSelect(&ret, &err, &maxfds, &rfds, &wfds, &timeout);
	  NXTransExecute(&ret, &err, &maxfds, &rfds, &wfds, &timeout);
	}
      if (ret == -1 && (errno == EINTR || errno == EAGAIN || errno == EWOULDBLOCK ))
	continue;

      if (ret < 0)
	{
	  qvd_error(qvd, "Error in _qvd_client_loop: select() %s\n", strerror(errno));
	  return 1;
	}
      if (qvd->end_connection)
	{
	  qvd_printf("Connection ended with qvd_end_connection().");
	  qvd_progress(qvd, "Connection ended with qvd_end_connection().");
	  return 0;
	}
#ifdef TRACE
      qvd_printf("isset proxyfd read: %d; connfd read: %d\n",
		   FD_ISSET(proxyFd, &rfds), FD_ISSET(connFd, &rfds));
#endif
      /* Read from curl socket and store in proxyWrite buffer */
      if (connFd > 0 && FD_ISSET(connFd, &rfds))
	{
	  read = 0; /* handle case of CURLE_UNSUPPORTED_PROTOCOL where read does not gets modified */
	  res = curl_easy_recv(qvd->curl, proxyWrite.data+proxyWrite.offset,
			       BUFFER_SIZE-proxyWrite.size, &read);

	  switch (res)
	    {
	    case CURLE_OK:
#ifdef TRACE
	      qvd_printf("curl: recv'd %ld\n", read);
#endif
	      proxyWrite.size += read;
	      if (read == 0)
		{
		  qvd_printf("Setting connFd to 0, End of stream\n");
		  connFd = -1;
		}
	      numunsupportedprotocolerrs = 0;
	      break;
	    case CURLE_AGAIN:
	      qvd_printf("Nothing read. receiving curl_easy_recv: %d CURLE_AGAIN, read %d\n", res, read);
	      break;
	    case CURLE_UNSUPPORTED_PROTOCOL:
	      numunsupportedprotocolerrs++;
	      qvd_printf("Unsupported protocol. receiving curl_easy_recv: %d CURLE_UNSUPPORTED_PROTOCOL (wait for next iteration), read %d, number of sequential errors=%d\n", res, read, numunsupportedprotocolerrs);
	      qvd_printf("Error buffer: %s", qvd->error_buffer);
#ifdef TRACE
	      qvd_printf("curle_unsupported_protocol string size");
	      for (i=0; i < read; i++)
		qvd_printf("%x %c ",proxyWrite.data[i], proxyWrite.data[i]);
	      qvd_printf("\n");
#endif
# define MAX_CURLE_UNSUPPORTED_PROTOCOL 1
	      if (numunsupportedprotocolerrs >= MAX_CURLE_UNSUPPORTED_PROTOCOL) {
		qvd_error(qvd, "Unsupported protocol received %d times. receiving curl_easy_recv: %d CURLE_UNSUPPORTED_PROTOCOL (wait for next iteration), read %d, number of sequential errors=%d\n", MAX_CURLE_UNSUPPORTED_PROTOCOL, res, read, numunsupportedprotocolerrs);
		/* An error we need to finish the connection */
		connFd = -1;
		/*		  proxyFd = -1;  */
		result = 0;
	      }
	      break;
	    default:
	      qvd_error(qvd, "Error receiving curl_easy_recv: %d\n", res);
	      connFd = -1;
	      /* proxyFd = -1; */
	      result = -1;
	    }
	}
      /* Read from NX and store in proxyRead buffer */
      if (proxyFd > 0 && FD_ISSET(proxyFd, &rfds))
	{
	  ret = QvdBufferRead(&proxyRead, proxyFd);
	  if (ret == 0)
	    {
	      qvd_printf("No more bytes to read from proxyFd ending\n");
	      proxyFd = -1;
	    }
	  if (ret < 0)
            {
	      if ( errno == EINTR || errno == EWOULDBLOCK || errno == EAGAIN )
              {
                qvd_printf("Read returned %s, retrying\n", strerror(errno));
              }
              else
              {
	        qvd_error(qvd, "Error proxyFd read error: %s\n", strerror(errno));
	        proxyFd = -1;
              }
	    }
	}
      if (proxyFd > 0 && QvdBufferCanWrite(&proxyWrite))
	{
	  ret = QvdBufferWrite(&proxyWrite, proxyFd);
	  if (ret < 0 && errno != EINTR && errno != EAGAIN && errno != EWOULDBLOCK) {
	    qvd_error(qvd, "Error writing to proxyFd: %d %s\n", errno, strerror(errno));
	    proxyFd = -1;
	  }
	}
      if (connFd > 0 && QvdBufferCanWrite(&proxyRead))
	{
	  /*QvdBufferWrite(&proxyRead, connFd);*/
	  res = curl_easy_send(qvd->curl, proxyRead.data+proxyRead.offset,
			       proxyRead.size-proxyRead.offset, &written);
	  switch (res)
	    {
	    case CURLE_OK:
	      proxyRead.offset += written;
#ifdef TRACE
	      qvd_printf("curl: send'd %ld\n", written);
#endif
	      if (proxyRead.offset >= proxyRead.size)
		QvdBufferReset(&proxyRead);
	      numunsupportedprotocolerrs = 0;
	      break;
	    case CURLE_AGAIN:
	      qvd_printf("Nothing written, wait for next iteration. curl_easy_send: %d CURLE_AGAIN, written %d\n", res, written);
	      break;
	    case CURLE_UNSUPPORTED_PROTOCOL:
	      numunsupportedprotocolerrs++;
	      qvd_printf("Unsupported protocol sent %d times. sending curl_easy_sendv: %d CURLE_UNSUPPORTED_PROTOCOL (wait for next iteration), written %d, number of sequential errors=%d\n", MAX_CURLE_UNSUPPORTED_PROTOCOL, res, written, numunsupportedprotocolerrs);
	      qvd_printf("Error buffer: %s", qvd->error_buffer);

#ifdef TRACE
	      qvd_printf("curle_unsupported_protocol string size");
	      for (i=0; i < written; i++)
		qvd_printf("%x %c ",proxyWrite.data[i], proxyWrite.data[i]);
	      qvd_printf("\n");
#endif
	      if (numunsupportedprotocolerrs >= MAX_CURLE_UNSUPPORTED_PROTOCOL) {
		qvd_error(qvd, "Unsupported protocol sent %d times. sending curl_easy_sendv: %d CURLE_UNSUPPORTED_PROTOCOL (wait for next iteration), written %d, number of sequential errors=%d\n", MAX_CURLE_UNSUPPORTED_PROTOCOL, res, written, numunsupportedprotocolerrs);
		/* An error we need to finish the connection */
		/* TODO only finish connFd */
		connFd = -1;
		/*		  proxyFd = -1; */
		result = 0;
	      }
	      break;
	    default:
	      qvd_error(qvd, "Error sending curl_easy_send: %d", res);
	      connFd = -1;
	    }
	}
    } while (connFd > 0 && proxyFd > 0);

  return result;
}

size_t _qvd_write_buffer_callback(void *contents, size_t size, size_t nmemb, void *buffer)
{
    size_t realsize = size*nmemb;
    size_t bytes_written = QvdBufferAppend((QvdBuffer*)buffer, contents, realsize);
    return bytes_written;
}


int _qvd_switch_protocols(qvdclient *qvd, int id)
{
  fd_set myset, zero;
  size_t bytes_sent, bytes_received, bytes_received_total;
  int socket, i, content_length, content_size_parsed;
  char url[MAX_BASEURL];
  char base64auth[MAX_PARAM];
  char *ptr, *content;

  _qvd_use_client_cert(qvd);
  curl_easy_setopt(qvd->curl, CURLOPT_URL, qvd->baseurl);
  curl_easy_setopt(qvd->curl, CURLOPT_CONNECT_ONLY, 1L);
  curl_easy_perform(qvd->curl);
  curl_easy_getinfo(qvd->curl, CURLINFO_LASTSOCKET, &socket);

  /*  if (snprintf(url, MAX_BASEURL, "GET /qvd/connect_to_vm?id=%d&qvd.client.os=%s&qvd.client.fullscreen=%d&qvd.client.geometry=%s&qvd.client.link=%s&qvd.client.keyboard=%s&qvd.client.printing.enabled=%d HTTP/1.1\nAuthorization: Basic %s\nConnection: Upgrade\nUpgrade: QVD/1.0\n\n", id, qvd->os, qvd->fullscreen, qvd->geometry, qvd->link, qvd->keyboard, qvd->print_enabled, qvd->authdigest) >= MAX_BASEURL) { */
  if (snprintf(url, MAX_BASEURL, "GET /qvd/connect_to_vm?id=%d&qvd.client.os=%s&qvd.client.geometry=%s&qvd.client.link=%s&qvd.client.keyboard=%s&qvd.client.fullscreen=%d HTTP/1.1\nAuthorization: Basic %s\nConnection: Upgrade\nUpgrade: QVD/1.0\n\n", id, qvd->os, qvd->geometry, qvd->link, qvd->keyboard, qvd->fullscreen, qvd->authdigest) >= MAX_BASEURL) {
    qvd_error(qvd, "Error initializing authdigest\n");
    return 1;
  }
  qvd_printf("Switch protocols the url is: <%s>\n", url);

  /*  char *url = "GET /qvd/connect_to_vm?id=1&qvd.client.os=linux&qvd.client.fullscreen=&qvd.client.geometry=800x600&qvd.client.link=local&qvd.client.keyboard=pc105%2Fus&qvd.client.printing.enabled=0 HTTP/1.1\nAuthorization: Basic bml0bzpuaXRv\nConnection: Upgrade\nUpgrade: QVD/1.0\n\n"; */
  if ((qvd->res = curl_easy_send(qvd->curl, url, strlen(url) , &bytes_sent )) != CURLE_OK ) {
    qvd_error(qvd, "An error ocurred in first curl_easy_send: %ul <%s>\n", qvd->res, curl_easy_strerror(qvd->res));
    return 1;
  }

  /* TODO perhaps put this in another func ??? */

  FD_ZERO(&myset);
  FD_ZERO(&zero);
  FD_SET(socket, &myset);
  qvd_printf("Before select on send socket is: %d\n", socket);
  for (i=0; i<MAX_HTTP_RESPONSES_FOR_UPGRADE; ++i) {
    /* TODO define timeouts perhaps in qvd_init */
    select(socket+1, &myset, &zero, &zero, NULL);
    if ((qvd->res = curl_easy_recv(qvd->curl, qvd->buffer.data, BUFFER_SIZE, &bytes_received)) != CURLE_OK ) {
      qvd_error(qvd, "An error ocurred in curl_easy_recv: %ul <%s>\n", qvd->res, curl_easy_strerror(qvd->res));
      return 2;
    }
    qvd->buffer.data[bytes_received] = 0;
    qvd_printf("%d input received was <%s>\n", i, qvd->buffer.data);
    /* TODO what happens if  for other strings
V/qvd     ( 7551): Before select on send socket is: 43
V/qvd     ( 7551): 0 input received was <HTTP/1.1 403 Forbidden
V/qvd     ( 7551): Content-Type: text/plain
V/qvd     ( 7551): Content-Length: 56
V/qvd     ( 7551):
V/qvd     ( 7551): >
V/qvd     ( 7551): 1 input received was <The requested virtual machine is offline for maintenance>

 */


    if (strstr(qvd->buffer.data, "HTTP/1.1 101")) {
      qvd_printf("Upgrade of protocol was done\n");
      break;
    }

#define PROGRESSINFO "\r\nX-QVD-VM-Info: "
    if (strstr(qvd->buffer.data, "HTTP/1.1 102")) {
      qvd_printf("Progress message");
      if ((ptr = strcasestr(qvd->buffer.data, PROGRESSINFO)) != NULL) {
#ifdef TRACE
	qvd_printf("ptr is %s and size is %d", ptr, strlen(PROGRESSINFO));
#endif
	ptr += strlen(PROGRESSINFO);
	qvd_progress(qvd, ptr);
      }
#ifdef TRACE
      else {
	qvd_printf("Pointer finding %s is null", PROGRESSINFO);
      }
#endif
    }

    /* TODO verify for 402 */
    if (strstr(qvd->buffer.data, "HTTP/1.1 2")
	|| strstr(qvd->buffer.data, "HTTP/1.1 3")
	|| strstr(qvd->buffer.data, "HTTP/1.1 4")
	|| strstr(qvd->buffer.data, "HTTP/1.1 5")) {
      bytes_received_total = 0;
#define CONTENT_LENGTH "\r\nContent-Length: "
      if ((ptr = strcasestr(qvd->buffer.data, CONTENT_LENGTH)) != NULL) {
	ptr += strlen(CONTENT_LENGTH);
#ifdef TRACE
	qvd_printf("Parsing content length from <%s> and starting in <%s>", qvd->buffer.data, ptr);
#endif
	content_length = -1;
	if (sscanf(ptr, "%d", &content_length) != 1) {
	  qvd_printf("Error parsing content-length setting to -1: %d", content_length);
	  content_length = -1;
	}
      }
      while (bytes_received < BUFFER_SIZE) {
	qvd_printf("Waiting for extra data after found 2xx, 3xx, 4xx or 5xx code <%s>", qvd->buffer.data);
	select(socket+1, &myset, &zero, &zero, NULL);

	ptr = qvd->buffer.data;
	ptr += bytes_received;
	/* TODO implement callback for info */
	if ((qvd->res = curl_easy_recv(qvd->curl, ptr, BUFFER_SIZE, &bytes_received_total)) != CURLE_OK ) {
	  ptr = strstr(qvd->buffer.data, "\r\n\r\n");
	  qvd_error(qvd, "Error received in qvd_curl_easy_recv: %d. <%s>", qvd->res, ptr);
	  return 7;
	}
	bytes_received += bytes_received_total;
#define DOUBLENEWLINE "\r\n\r\n"
	content = strstr(qvd->buffer.data, DOUBLENEWLINE);
	content_size_parsed = content != NULL ? strlen(content): -1;
#ifdef TRACE
	qvd_printf("The bytes received were: %d, and curle code was: %d, content: <%s>, size of content: %d", bytes_received_total, qvd->res, content, content_size_parsed);
#endif
	if (bytes_received == 0 || content_size_parsed >= content_length) {
	  content += strlen(DOUBLENEWLINE);
	  qvd_error(qvd, "Error: <%s>", content);
	  return 8;
	}

      }
    }

  }
  if (i >=10 ) {
    qvd_error(qvd, "Error not received response for protocol upgrade in %d tries http/1.1\n", i);
    return 3;
  }

  return 0;
}

void _qvd_print_environ()
{
  if (environ == NULL)
    qvd_printf("Environment variable not defined (NULL)");
  char **ptr;
  qvd_printf("Printing environment variables\n");
  for (ptr=environ; *ptr != NULL; ptr ++)
      qvd_printf("Environment var %s\n", *ptr);

}


/*
 * Internal funcs for qvd_init callbacks for qvd_list_of_vm
 * Really generic
 */


/* arrays for certificate chain and errors */
#define MAX_CERTS 20
X509 *certificate[MAX_CERTS];
long certificate_error[MAX_CERTS];

int _qvd_dir_exists(qvdclient *qvd, const char *path)
{
  struct stat fs_stat;
  int result;
  result = stat(path, &fs_stat);
  if (!S_ISDIR(fs_stat.st_mode))
    {
      qvd_error(qvd, "Error accessing dir %s the file is not a directory\n", path);
      return 0;
    }
  return 1;
}
int _qvd_create_dir(qvdclient *qvd, const char *home, const char *subdir)
{
  char path[MAX_PATH_STRING];
  struct stat fs_stat;
  int result;
  snprintf(path, MAX_PATH_STRING - 1, "%s/%s", home, subdir);
  path[MAX_PATH_STRING - 1] = '\0';
  result = stat(path, &fs_stat);
  if (result == -1)
    {
      if (errno != ENOENT)
	{
	  qvd_error(qvd, "Error accessing directory $HOME/%s (%s), with error: %s\n", subdir, path, strerror(errno));
	  return 0;
	}
      result = mkdir(path, 0755);
      if (result)
	{
	  qvd_error(qvd, "Error creating directory $HOME/%s (%s), with error: %s\n", subdir, path, strerror(errno));
	  return 0;
	}
      return 1;
    }
  if (!S_ISDIR(fs_stat.st_mode))
    {
      qvd_error(qvd, "Error accessing dir $HOME/%s (%s) the file is not a directory", subdir, path);
      return 0;
    }
  return 1;
}
int _qvd_save_certificate(qvdclient *qvd, X509 *cert, int depth, BUF_MEM *biomem)
{
  char path[MAX_PATH_STRING];

  int fd, result;
  snprintf(path, MAX_PATH_STRING - 1, "%s/%lx.%d", qvd->certpath, X509_subject_name_hash(cert), depth);
  path[MAX_PATH_STRING - 1] = '\0';
  if (strlen(path) == MAX_PATH_STRING)
    {
      qvd_error(qvd, "Cert string too long (%d) recompile program. Path is %s", MAX_PATH_STRING, path);
      return 0;
    }

  fd = open(path, O_CREAT|O_TRUNC|O_WRONLY, 0644);
  if (fd == -1)
    {
      qvd_error(qvd, "Error creating file %s: %s", path, strerror(errno));
      return 0;
    }

  result = write(fd, biomem->data, strlen(biomem->data));
  if (result == -1)
    {
      qvd_error(qvd, "Error writing file %s: %s", path, strerror(errno));
      return 0;
	}
  if (result != strlen(biomem->data))
    {
      qvd_error(qvd, "Error writing file not enough bytes written in %s: %d vs %d", path, result, strlen(biomem->data));
      return 0;
    }

  result = close(fd);
  if (result == -1)
    {
	  qvd_error(qvd, "Error closing file %s: %s", path, strerror(errno));
	  return 0;
    }
  qvd_printf("Successfully saved cert in %s\n", path);
  return 1;
}

int _qvd_verify_cert_callback(int preverify_ok, X509_STORE_CTX *x509_ctx)
{

  SSL    *ssl;
  SSL_CTX *sslctx;
  qvdclient *qvd ;

  ssl = X509_STORE_CTX_get_ex_data(x509_ctx, SSL_get_ex_data_X509_STORE_CTX_idx());
  sslctx = SSL_get_SSL_CTX(ssl);
  qvd = SSL_CTX_get_ex_data(sslctx, _qvd_ssl_index);

  X509 *cert = X509_STORE_CTX_get_current_cert(x509_ctx);
  int depth = X509_STORE_CTX_get_error_depth(x509_ctx);
  int err = X509_STORE_CTX_get_error(x509_ctx);

  /* save the certificate by incrementing the reference count and
   * keeping a pointer */
  if (depth < MAX_CERTS && !certificate[depth]) {
    certificate[depth] = cert;
    certificate_error[depth] = err;
    cert->references++;
  }

  /* See http://www.openssl.org/docs/ssl/SSL_CTX_set_verify.html# */
  if (preverify_ok)
    {
      qvd_printf("_qvd_verify_cert_callback: Certificate was validated\n");
      return preverify_ok;
    }
  if (qvd->ssl_verify_callback == NULL)
    {
      qvd_printf("_qvd_verify_cert_callback: No callback specified returning false (specify if you wissh callbacks for unknown certs with qvd_set_unknown_cert_callback)\n");
      return 0;
    }

  BIO *bio_out = BIO_new(BIO_s_mem());
  BUF_MEM *biomem;
  int result;
  PEM_write_bio_X509(bio_out, certificate[depth]);
  BIO_get_mem_ptr(bio_out, &biomem);
  char cert_info[1024];
  char issuer[256], subject[256];
  X509_NAME_oneline(X509_get_issuer_name(certificate[depth]), issuer, 256);
  X509_NAME_oneline(X509_get_subject_name(certificate[depth]), subject, 256);

  snprintf(cert_info, 1023, "Serial: %lu\n\nIssuer: %s\n\nValidity:\n\tNot before: %s\n\tNot after: %s\n\nSubject: %s\n",
	   ASN1_INTEGER_get(X509_get_serialNumber(certificate[depth])), issuer,
	   X509_get_notBefore(certificate[depth])->data, X509_get_notAfter(cert)->data, subject);
  cert_info[1023] = '\0';
  result = qvd->ssl_verify_callback(qvd, cert_info, biomem->data);
  if (result)
    {
      _qvd_save_certificate(qvd, certificate[depth], depth, biomem);
    }

  BIO_free(bio_out);
  return result;
}

CURLcode _qvd_sslctxfun(CURL *curl, SSL_CTX *sslctx, void *parm)
{

  qvdclient *qvd = (qvdclient *) parm;
  if (qvd->ssl_no_cert_check)
    {
      qvd_printf("No strict certificate checking. Accepting any server certificate\n");
      return CURLE_OK;
    }
  /* See SSL_set_ex_data and http://www.openssl.org/docs/ssl/SSL_get_ex_new_index.htm*/
  /* parm is qvdclient *qvd, the qvd object, set with  CURLOPT_SSL_CTX_DATA */
  SSL_CTX_set_ex_data(sslctx, _qvd_ssl_index, parm);

  SSL_CTX_set_verify(sslctx, SSL_VERIFY_PEER, _qvd_verify_cert_callback);

  return CURLE_OK;
}

/*
 * Returns 1 if client certificates are used and 0 otherwise
 */
int _qvd_use_client_cert(qvdclient *qvd)
{
  if (qvd->use_client_cert == 0)
    {
      qvd_printf("No client certificates used\n");
      return 0;
    }


  qvd_printf("Using client certificates cert: <%s>, key <%s>\n", qvd->client_cert, qvd->client_key);
  curl_easy_setopt(qvd->curl, CURLOPT_SSLCERT, qvd->client_cert);
  curl_easy_setopt(qvd->curl, CURLOPT_SSLKEY, qvd->client_key);
  /*  curl_easy_setopt(qvd->curl, CURLOPT_KEYPASSWD, "");*/
  return 1;
}



void qvd_set_cert_files(qvdclient *qvd, const char *client_cert, const char *client_key)
{
  if (client_cert == NULL || client_key == NULL)
    {
      qvd_printf("Disabling client certificate\n");
      qvd->use_client_cert = 0;
      return;
    }

  if (access(client_cert, R_OK) != 0)
    {
      qvd_error(qvd, "Cert file %s is not accessible: %s\n", client_cert, strerror(errno));
      qvd->use_client_cert = 0;
      return;
    }

  if (access(client_key, R_OK) != 0)
    {
      qvd_error(qvd, "Key file %s is not accessible: %s\n", client_key, strerror(errno));
      qvd->use_client_cert = 0;
      return;
    }

  strncpy(qvd->client_cert, client_cert, MAX_PATH_STRING);
  qvd->client_cert[MAX_PATH_STRING - 1] = '\0';

  strncpy(qvd->client_key, client_key, MAX_PATH_STRING);
  qvd->client_key[MAX_PATH_STRING - 1] = '\0';

  qvd->use_client_cert = 1;

  qvd_printf("Setting client_cert to <%s> and client_key to <%s> and enabling client certificate send", qvd->client_cert, qvd->client_key);

  return;
}

void qvd_end_connection(qvdclient *qvd)
{
  qvd->end_connection=1;
}

int qvd_payment_required(qvdclient *qvd)
{
  return qvd->payment_required;
}
