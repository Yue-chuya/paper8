#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N 1000

double A[N][N], B[N][N], C[N][N];

int main() {
    int i, j, k;
    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            A[i][j] = (double) i / N;
            B[i][j] = (double) j / N;
            C[i][j] = 0.0;
        }
    }

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (i = 0; i < N; i++) {
        for (j = 0; j < N; j++) {
            for (k = 0; k < N; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double time_spent = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    
    printf("%f\n", time_spent);

    return 0;
}