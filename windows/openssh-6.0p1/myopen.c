#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <stdio.h>
#include <fcntl.h>

int myopen(const char *name, int flags) {
    int fd;

    DWORD dwDesiredAccess = 0;
    DWORD dwCreationDisposition = 0;
    switch (flags & (_O_RDONLY | _O_WRONLY | _O_RDWR)) {
        case _O_RDONLY: dwDesiredAccess = GENERIC_READ; break;
        case _O_WRONLY: dwDesiredAccess = GENERIC_WRITE; break;
        case _O_RDWR: dwDesiredAccess = GENERIC_READ | GENERIC_WRITE; break;
    }

    if (flags & _O_APPEND) dwDesiredAccess |= FILE_APPEND_DATA;

    /*
     * decode open/create method flags
     */
    switch ( flags & (_O_CREAT | _O_EXCL | _O_TRUNC) ) {
        case 0:
        case _O_EXCL:                   // ignore EXCL w/o CREAT
            dwCreationDisposition = OPEN_EXISTING;
            break;

        case _O_CREAT:
            dwCreationDisposition = OPEN_ALWAYS;
            break;

        case _O_CREAT | _O_EXCL:
        case _O_CREAT | _O_TRUNC | _O_EXCL:
            dwCreationDisposition = CREATE_NEW;
            break;

        case _O_TRUNC:
        case _O_TRUNC | _O_EXCL:        // ignore EXCL w/o CREAT
            dwCreationDisposition = TRUNCATE_EXISTING;
            break;

        case _O_CREAT | _O_TRUNC:
            dwCreationDisposition = CREATE_ALWAYS;
            break;
    }

    printf("Flags: 0x%x O_RDONLY %x _O_RDONLY %x\n", flags, O_RDONLY, _O_RDONLY);
    printf("Access flags: 0x%lx\n", dwDesiredAccess);
    printf("Creation flags: 0x%lx\n", dwCreationDisposition);

    HANDLE hFile = CreateFile(name, dwDesiredAccess, 
            FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, 
            NULL, dwCreationDisposition,
            FILE_ATTRIBUTE_NORMAL, NULL); 

    if (hFile == INVALID_HANDLE_VALUE) {
        printf("CreateFile: error 0x%x\n", GetLastError());
        fd = -1;
    } else {
        fd = _open_osfhandle((intptr_t) hFile, flags /*| _O_BINARY*/);
    }
}

void fun1(const char *fname) {
    int fd = open(fname, O_RDONLY);
    printf("Got fd %d\n", fd);

    char buffer[1024] = {0};
    ssize_t readAmount = 0;
    readAmount = read(fd, buffer, sizeof(buffer)-1);
    if (readAmount != -1) {
        printf("I read %d bytes. They are:\n%s\n", readAmount, buffer);
    } else {
        printf("Read error, code: 0x%x\n", GetLastError());
    }

    close(fd);
}

void fun2(const char *fname) {
    int fd = myopen(fname, O_RDONLY);
    printf("Got fd %d\n", fd);

    char buffer[1024] = {0};
    ssize_t readAmount = 0;
    readAmount = read(fd, buffer, sizeof(buffer)-1);
    if (readAmount != -1) {
        printf("I read %d bytes. They are:\n%s\n", readAmount, buffer);
    } else {
        printf("Read error, code: 0x%x\n", GetLastError());
    }

    close(fd);
}

int main(int argc, char *argv[]) {
    fun1(argv[1]); /* with open */
    puts("--------------------------------------------------------------------------------\n");
    fun2(argv[1]); /* with myopen */
}
