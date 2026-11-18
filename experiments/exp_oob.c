//only measure overstepping
#include <stdlib.h>
int main() {
    int *a = (int*)malloc(10 * sizeof(int));
    a[10] = 42; 
    free(a);
    return 0;
}





