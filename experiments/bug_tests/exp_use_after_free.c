//use-after-free
// Section 3.3

#include <stdio.h>
#include <stdlib.h>
int main(void) {
    int *p = malloc(sizeof(int));
    *p = 100;
    free(p);
    int val = *p;
    printf("value = %d\n", val);
    return 0;
}
