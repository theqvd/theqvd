
typedef enum
{
  eSET_SPEED = 0,
  eSEND_BREAK,
  eSET_CSIZE,
  eSET_PARITY,
  eSET_STOPSIZE,
  eSET_CONTROL
} e_operation;

typedef struct
{
  int size;
  e_operation oper;
  int val;
} s_control;
