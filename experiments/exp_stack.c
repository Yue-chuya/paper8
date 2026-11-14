#include <stdio.h>

volatile int sink;
int main() {
    int stack_array[10];
    volatile int idx = 10; 
    stack_array[idx] = 42; 
    sink = stack_array[idx];
    return 0;
}