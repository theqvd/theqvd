#ifndef QVDBUFFER_H
#define QVDBUFFER_H

typedef struct {
    char data[BUFFER_SIZE];
    int offset;
    int size;
} QvdBuffer;


#endif
