#include <string.h>
#include "qvdclient.h"
#include "qvdbuffer.h"

void QvdBufferInit(QvdBuffer *self)
{
  memset(self->data, 0, BUFFER_SIZE);
  self->offset = 0;
  self->size = 0;
#ifdef TRACE
  qvd_printf("QvdBufferInit offset=0, size=0\n");
#endif
}

int QvdBufferCanRead(QvdBuffer *self)
{
#ifdef TRACE
  qvd_printf("QvdBufferCanRead offset=%d, size=%d: %d\n", self->offset, self->size, self->size < BUFFER_SIZE);
#endif
  return self->size < BUFFER_SIZE;
}

int QvdBufferCanWrite(QvdBuffer *self)
{
#ifdef TRACE
  qvd_printf("QvdBufferCanWrite offset=%d, size=%d: %d\n", self->offset, self->size, self->offset < self->size);
#endif
  return self->offset < self->size;
}

void QvdBufferReset(QvdBuffer *self)
{
#ifdef TRACE
  qvd_printf("QvdBufferReset offset=%d, size=%d\n", self->offset, self->size);
#endif
  self->offset = 0;
  self->size = 0;
#ifdef TRACE
  qvd_printf("QvdBufferReset offset=%d, size=%d\n", self->offset, self->size);
#endif
}

int QvdBufferAppend(QvdBuffer *self, const char *data, size_t count)
{
#ifdef TRACE
  qvd_printf("QvdBufferAppend offset=%d, size=%d\n", self->offset, self->size);
#endif
  size_t bytes_to_copy = MIN(count, BUFFER_SIZE - self->size);
  memcpy(self->data+self->size, data, bytes_to_copy);
  self->size += count;
#ifdef TRACE
  qvd_printf("QvdBufferReset offset=%d, size=%d\n", self->offset, self->size);
#endif
  return bytes_to_copy;
}

int QvdBufferRead(QvdBuffer *self, int fd)
{
  int ret;
  ret = read(fd, self->data+self->size, BUFFER_SIZE-self->size);
#ifdef TRACE
  qvd_printf("%d: read %d\n", fd, ret);
#endif
  if (ret >= 0)
    self->size += ret;
  return ret;
}

int QvdBufferWrite(QvdBuffer *self, int fd)
{
  int ret;
  ret = write(fd, self->data+self->offset, self->size-self->offset);
#ifdef TRACE
  qvd_printf("%d: wrote %d\n", fd, ret);
#endif
  if (ret >= 0) {
    self->offset += ret;
    /* Write head has reached read head */
    if (self->offset >= self->size)
      QvdBufferReset(self);
  }
  return ret;
}
