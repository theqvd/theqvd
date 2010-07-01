#ifdef SHARED_OBJECT
#define FUNC_TYPE static
#else
#define FUNC_TYPE
#endif

FUNC_TYPE int baud_index_to_int(speed_t baud_index)
{
  switch(baud_index)
  {
    case B0:
      return 0;
    case B50:
      return 50;
    case B75:
      return 75;
    case B110:
      return 110;
    case B134:
      return 134;
    case B150:
      return 150;
    case B200:
      return 200;
    case B300:
      return 300;
    case B600:
      return 600;
    case B1200:
      return 1200;
    case B1800:
      return 1800;
    case B2400:
      return 2400;
    case B4800:
      return 4800;
    case B9600:
      return 9600;
    case B19200:
      return 19200;
    case B38400:
      return 38400;
#ifdef B57600
    case B57600:
      return 57600;
#endif
#ifdef B115200
    case B115200:
      return 115200;
#endif
#ifdef B230400
    case B230400:
      return 230400;
#endif
#ifdef B460800
    case B460800:
      return 460800;
#endif
  }
  return -1;
}

FUNC_TYPE speed_t int_to_baud_index(int speed)
{
  switch(speed)
  {
    case 0:
      return B0;
    case 50:
      return B50;
    case 75:
      return B75;
    case 110:
      return B110;
    case 134:
      return B134;
    case 150:
      return B150;
    case 200:
      return B200;
    case 300:
      return B300;
    case 600:
      return B600;
    case 1200:
      return B1200;
    case 1800:
      return B1800;
    case 2400:
      return B2400;
    case 4800:
      return B4800;
    case 9600:
      return B9600;
    case 19200:
      return B19200;
    case 38400:
      return B38400;
#ifdef B57600
    case 57600:
      return B57600;
#endif
#ifdef B115200
    case 115200:
      return B115200;
#endif
#ifdef B230400
    case 230400:
      return B230400;
#endif
#ifdef B460800
    case 460800:
      return B460800;
#endif
  }
  return B0;
}

