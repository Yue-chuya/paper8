#include <stdlib.h>
#include <stdio.h>

int main(){
    void *p1 = malloc(0);
    free(p1);

    int *p2 = malloc(sizeof(int));
    free(p2);
    free(p2);

    char *buf = malloc(1);
    buf[1] = 1;
    free(buf);
    return 0;
}
