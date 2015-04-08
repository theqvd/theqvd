#include <stdlib.h>

int main(void) {
	_set_errno(2);
	puts("oops!\n");
}