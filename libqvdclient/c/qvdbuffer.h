#include <stdlib.h>
#ifndef QVDBUFFER_H
#define QVDBUFFER_H

typedef struct {
    char data[BUFFER_SIZE];
    int offset;
    int size;
} QvdBuffer;

void QvdBufferInit(QvdBuffer *self);
int QvdBufferCanRead(QvdBuffer *self);
int QvdBufferCanWrite(QvdBuffer *self);
void QvdBufferReset(QvdBuffer *self);
int QvdBufferAppend(QvdBuffer *self, const char *data, size_t count);
int QvdBufferRead(QvdBuffer *self, int fd);
int QvdBufferWrite(QvdBuffer *self, int fd);

#endif
