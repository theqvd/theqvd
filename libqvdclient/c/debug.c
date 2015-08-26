#include "qvdclient.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <limits.h>
#include <errno.h>
#include <string.h>
#ifdef ANDROID
#include <android/log.h>
#elif __APPLE__
#include <asl.h>
#endif
static int qvd_global_debug_level = -1;
static FILE *global_debug_file = NULL; /* By default it becomes stderr see unistd.h */

void qvd_printf(const char *format, ...);

int _qvd_init_debug() {
  const char *log_file = getenv(DEBUG_FILE_ENV_VAR_NAME);
  global_debug_file = stderr; /* setting it to stderr */
  if (log_file) {
    if ((global_debug_file = fopen(log_file, "a")) == NULL) {
      global_debug_file = stderr;
      qvd_printf("Using stderr for debugging. Unable to open file %s, because of error: %s", log_file, strerror(errno));
    }
  }

  const char *debug_str = getenv(DEBUG_FLAG_ENV_VAR_NAME);
  if (debug_str) {
        errno = 0;
        long v = strtol(debug_str, NULL, 10);
        if ((v != LONG_MIN && v != LONG_MAX) || errno != ERANGE)
          return v;
  }
  return 0;
}


inline int get_debug_level(void) {
  if (qvd_global_debug_level < 0) {
    qvd_global_debug_level = _qvd_init_debug();
  }
  return qvd_global_debug_level;
}

inline void set_debug_level(int level)
{
  _qvd_init_debug();
  qvd_global_debug_level = level;
}
void _qvd_vprintf(const char *format, va_list args)
{
  if (get_debug_level() <= 0
#ifdef ANDROID
      || get_debug_level() >= ANDROID_LOG_SILENT
#endif
      )
    return;

#ifdef ANDROID
  __android_log_vprint(get_debug_level(), "qvd", format, args);
#elif __APPLE__
  asl_vlog(NULL, NULL, ASL_LEVEL_DEBUG, format, args);
#else
  vfprintf(global_debug_file, format, args);
  fflush(global_debug_file);
#endif
}

void qvd_printf(const char *format, ...)
{
  va_list args;
  va_start(args, format);
  _qvd_vprintf(format, args);
  va_end(args);
}

void qvd_error(qvdclient *qvd, const char *format, ...)
{
  va_list args;
  va_start(args, format);
  _qvd_vprintf(format, args);
  va_end(args);

  va_start(args, format);
  vsnprintf(qvd->error_buffer, MAX_ERROR_BUFFER, format, args);
  va_end(args);
  qvd->error_buffer[MAX_ERROR_BUFFER-1] = '\0';
}

void qvd_progress(qvdclient *qvd, const char *message)
{
  if (qvd->progress_callback == NULL)
    qvd_printf("Progress callback not defined. Progress message: %s", message);
  else
    qvd->progress_callback(qvd, message);
}


void qvd_curl_dump(const char *text,
          unsigned char *ptr, size_t size,
          char nohex)
{
  size_t i;
  size_t c;

  unsigned int width=0x10;

  if(nohex)
    /* without the hex output, we can fit more on screen */
    width = 0x40;

  qvd_printf("%s, %10.10ld bytes (0x%8.8lx)\n",
          text, (long)size, (long)size);

  for(i=0; i<size; i+= width) {

    qvd_printf("%4.4lx: ", (long)i);

    if(!nohex) {
      /* hex not disabled, show it */
      for(c = 0; c < width; c++)
        if(i+c < size)
          qvd_printf("%02x ", ptr[i+c]);
        else
          qvd_printf("   ");
    }

    for(c = 0; (c < width) && (i+c < size); c++) {
      /* check for 0D0A; if found, skip past and start a new line of output */
      if (nohex && (i+c+1 < size) && ptr[i+c]==0x0D && ptr[i+c+1]==0x0A) {
        i+=(c+2-width);
        break;
      }

      qvd_printf("%c",
              (ptr[i+c]>=0x20) && (ptr[i+c]<0x80)?ptr[i+c]:'.');

      /* check again for 0D0A, to avoid an extra \n if it's at width */
      if (nohex && (i+c+2 < size) && ptr[i+c+1]==0x0D && ptr[i+c+2]==0x0A) {
        i+=(c+3-width);
        break;
      }
    }
    qvd_printf("\n"); /* newline */
  }
}


int qvd_curl_debug_callback(CURL *handle, curl_infotype type,
             unsigned char *data, size_t size,
             void *userp)
{
  const char *text;

  (void)userp;
  (void)handle; /* prevent compiler warning */

  switch (type) {
  case CURLINFO_TEXT:
    fprintf(stderr, "== Info: %s", data);
  default: /* in case a new one is introduced to shock us */
    return 0;

  case CURLINFO_HEADER_OUT:
    text = "=> Send header";
    break;
  case CURLINFO_DATA_OUT:
    text = "=> Send data";
    break;
  case CURLINFO_HEADER_IN:
    text = "<= Recv header";
    break;
  case CURLINFO_DATA_IN:
    text = "<= Recv data";
    break;
  }

#ifdef TRACE
  qvd_curl_dump(text, data, size, 1);
#else
  qvd_curl_dump(text, data, size, 0);
#endif
  return 0;
}
