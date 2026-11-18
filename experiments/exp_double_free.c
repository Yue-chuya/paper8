// only measure double free
#include <stdlib.h>
int main(int argc, char **argv) {
    int *p = (int*)malloc(sizeof(int));
    free(p);
    if (argc > 0) {
        free(p);
    }
    return 0;
}





