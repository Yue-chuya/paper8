//Heap overflow
//Section 3.3

#include <stdlib.h>
int main() {
    int *a = (int*)malloc(10 * sizeof(int));
    a[10] = 42; 
    free(a);
    return 0;
}





