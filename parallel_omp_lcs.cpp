#include <omp.h>
#include <algorithm>
#include <string>

int test_omp() {
    int count = 0;
#pragma omp parallel 
{
    #pragma omp single
    printf("Number of threads in use: %d\n", omp_get_num_threads());
    int local_count = 0;
	// printf("Number of threads: %d\n", omp_get_num_threads());
    #pragma omp for
    for (int i = 0; i < 10000; i++) {
        // no need to protect this count since each thread have its own local count
        // this local count shows how many times each thread executes the for loop
        ++local_count;
        // need to protect modifying shared variable
        #pragma omp atomic
        ++count;
    }
    printf("Thread %d local count: %d\n", omp_get_thread_num(), local_count);
}
printf("Total count: %d\n", count);
    return 0;
}

int main(int argc, char** argv) {
    // 2 input strings
    std::string X = "abadcabadcabadcabadcabadcabadc";
    std::string Y = "adcadcadc";

    test_omp();

    return 0;
}
