//only measure overstepping
#include <stdlib.h>
int main() {
    int *a = (int*)malloc(10 * sizeof(int));
    a[10] = 42; 
    free(a);
    return 0;
}





//#include <stdlib.h>
//#include <stdio.h>
//volatile int sink;
//int main() {
//    char *buf = malloc(1);
//    buf[1] = 'B'; 
//    sink = buf[1]; 
//    printf("Sink: %d\n", sink);
//    free(buf);
//    return 0;
//}