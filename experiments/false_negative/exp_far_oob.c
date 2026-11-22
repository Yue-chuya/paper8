#include <stdlib.h>
#include <stdio.h>

volatile int sink;
int main() {
    char *a = (char*)malloc(64);
    a[64 + 40] = 'X';
    sink = a[64 + 40];
    free(a);
    return 0;
}
