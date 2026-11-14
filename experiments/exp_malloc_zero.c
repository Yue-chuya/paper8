//only measure malloc(0)
#include <stdlib.h>
int main() {
    char *p = (char*)malloc(1);
    p[0] = 'A';
    p[1] = 'B'; 
    free(p);
    return 0;
}



// #include <stdlib.h>
// int main() {
//    void *p = malloc(0);
//    free(p);
//    return 0;
//}