// Global overflow
// Section 3.4

#include <stdio.h>
int global_array[10] = {0}; 

void trigger_global_oob(int index) {
    global_array[index] = 42; 
}

int main(int argc, char **argv) {
    int idx = argc + 9; 
    trigger_global_oob(idx); 
    return 0;
}