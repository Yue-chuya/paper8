// gemm_thread.c: gemm.c pthreaded version

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <time.h>
#include <sys/resource.h>

#ifndef N
#define N 1000
#endif

static double A[N][N], B[N][N], C[N][N];

typedef struct {
    int i_start; 
    int i_end;
} slice_t;

static void *gemm_worker(void *arg)
{
    const slice_t *s = (const slice_t *)arg;
    for (int i = s->i_start; i < s->i_end; i++) {
        for (int j = 0; j < N; j++) {
            for (int k = 0; k < N; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    return NULL;
}

int main(int argc, char **argv)
{
    int nthreads = 1;
    if (argc > 1) {
        char *end = NULL;
        long v = strtol(argv[1], &end, 10);
        if (end == argv[1] || *end != '\0' || v < 1) {
            fprintf(stderr, "usage: %s [nthreads>=1]\n", argv[0]);
            return 2;
        }
        nthreads = (int)v;
    }
    if (nthreads > N) nthreads = N; 

    // same initialization as gemm.c
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            A[i][j] = (double)i / N;
            B[i][j] = (double)j / N;
            C[i][j] = 0.0;
        }
    }

    slice_t *slices = NULL;
    pthread_t *tids = NULL;
    if (nthreads > 1) {
        slices = malloc(sizeof(*slices) * (size_t)nthreads);
        tids   = malloc(sizeof(*tids)   * (size_t)nthreads);
        if (!slices || !tids) { perror("malloc"); return 1; }
    }
    {
        int base = N / nthreads, rem = N % nthreads, start = 0;
        for (int t = 0; t < nthreads; t++) {
            int len = base + (t < rem ? 1 : 0);
            if (slices) {
                slices[t].i_start = start;
                slices[t].i_end   = start + len;
            }
            start += len;
        }
    }

    struct timespec t0, t1;
    clock_gettime(CLOCK_MONOTONIC, &t0);

    if (nthreads == 1) {
        slice_t whole = { 0, N };
        gemm_worker(&whole);
    } else {
        for (int t = 0; t < nthreads; t++) {
            int rc = pthread_create(&tids[t], NULL, gemm_worker, &slices[t]);
            if (rc != 0) {
                fprintf(stderr, "pthread_create failed: %s\n", strerror(rc));
                return 1;
            }
        }
        for (int t = 0; t < nthreads; t++) {
            pthread_join(tids[t], NULL);
        }
    }

    clock_gettime(CLOCK_MONOTONIC, &t1);
    double secs = (double)(t1.tv_sec - t0.tv_sec)
                + (double)(t1.tv_nsec - t0.tv_nsec) / 1e9;

    printf("%f\n", secs); 

    if (getenv("GEMM_VERIFY")) {
        double sum = 0.0;
        for (int i = 0; i < N; i++)
            for (int j = 0; j < N; j++)
                sum += C[i][j];
        fprintf(stderr, "checksum=%.17g\n", sum);
    }

    if (getenv("GEMM_REPORT_MEM")) {
        struct rusage ru;
        getrusage(RUSAGE_SELF, &ru);
        fprintf(stderr, "maxrss_kb=%ld\n", ru.ru_maxrss);
    }

    free(slices);
    free(tids);
    return 0;
}