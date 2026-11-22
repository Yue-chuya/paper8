// Unaligned
// Section 3.5

#include <stdio.h>
#include <stdlib.h>
volatile int sink;
int main(void) {
    int *a = (int*)malloc(sizeof(int)*2);
    if (!a) {
        return 1;
    }

    int *u = (int*) ((char*)a + 6);
    *u = 0x1234;
    sink = *u;

    printf("Survived: partial-granule unaligned out-of-bounds (false negative)\n");
    free(a);
    return 0;
}
