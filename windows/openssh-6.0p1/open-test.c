#include <windows.h>
#include <io.h>

#define WIN32_LEAN_AND_MEAN

int main(int argc, char *argv[]) {

    char *name = argv[1];
    char buf[4*1024];
    int flags = O_RDONLY;

    DWORD dwDesiredAccess = 0;
    DWORD dwCreationDisposition = 0;
    if (flags & _O_RDONLY) dwDesiredAccess |= GENERIC_READ;
    if (flags & _O_WRONLY) dwDesiredAccess |= GENERIC_WRITE;
    if (flags & _O_RDWR)   dwDesiredAccess |= GENERIC_READ | GENERIC_WRITE;
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


    HANDLE hFile = CreateFile(name, dwDesiredAccess, 
            FILE_SHARE_DELETE, NULL, dwCreationDisposition,
            FILE_ATTRIBUTE_NORMAL, NULL); 

    if (hFile == -1) {
        logit("CreateFile: error 0x%x", GetLastError());
        fd = -1;
    } else {
        fd = _open_osfhandle(hFile, flags | _O_BINARY);
    }

    int ch = read(fd, buf, sizeof(buf));
    buf[ch] = 0;

    printf("%s\n", buf);
    
    close(fd);
}
