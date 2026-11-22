#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define ITERATIONS 5000000 

volatile int sink;

int main() {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 0; i < ITERATIONS; i++) {
        int *p = (int*)malloc(16); 
        if (p) { 
            *p = i; 
            sink = *p;
            free(p); 
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double time_spent = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    printf("%.9f\n", time_spent); 
    return 0;
}