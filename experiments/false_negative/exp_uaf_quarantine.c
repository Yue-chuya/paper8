// Use-after-free with quarantine
// Section 3.5

#include <stdio.h>
#include <stdlib.h>

volatile char sink;
int main(void) {
    const size_t small_sz = 1U << 20;   
    const size_t drain_sz = 1U << 22; 

    char *a = (char*)malloc(small_sz);
    if (!a){
        return 1;
    }

    a[0] = 'A';
    free(a);
    for(int i=0; i < 8; i++){
        char *tmp = (char*)malloc(drain_sz);
         if(tmp){
            free(tmp);
        }
    }

    sink = a[0];
    printf("Survived: quarantine drained use-after-free (false negative)\n");
    return 0;
}
