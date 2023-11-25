/* Author: zhaojer */
#include <string>
#include <fstream>

#define ALPHABET_SIZE 26
#define CONVERT_LETTER_TO_IDX(letter) (int(letter) - 97)
#define MIN(a, b) ((a) < (b) ? (a) : (b))

const char ALPHABET[ALPHABET_SIZE] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
__device__ const char d_ALPHABET[ALPHABET_SIZE] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};


__global__ void compute_j_minus_k(int* A, const char* s2, const int m)
{
    // sanity check
    // printf("Block Id: %d, Thread Id: %d\n", blockIdx.x, threadIdx.x);
    // printf("String Y: %s, m = %d\n", s2, m);
    // for (int i = 0; i < ALPHABET_SIZE; ++i) {
    //     printf("%c ", d_ALPHABET[i]);
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", A[i*ALPHABET_SIZE + j]);
    //     }
    //     printf("\n");
    // }

    // calculate index which current thread needs to access
    // threadIdx.x simply corresponds to the row index i
    // note: no need to use blockIdx bc assumption: size of alphabet <= 1024
    int startIdx = threadIdx.x * (m+1);
    // each thread loops an entire "row" in A
    int endIdx = startIdx + m;
    // both indices are inclusive
    // printf("Block Id: %d, Thread Id: %d, Start Index: %d, End Indx: %d\n", blockIdx.x, threadIdx.x, startIdx, endIdx);
    int j = 1;
    for (int idx = startIdx + 1; idx <= endIdx; ++idx) {
        if (s2[j-1] == d_ALPHABET[threadIdx.x])
            A[idx] = j;
        else
            A[idx] = A[idx-1];
        ++j;
    }
}

__global__ void compute_scs_0th_row(int* M, const int m)
{
    // sanity check
    // printf("Block Id: %d, Thread Id: %d\n", blockIdx.x, threadIdx.x);
    // printf("String X: %s, String Y: %s, n = %d, m = %d\n", s1, s2, n, m);
    // for (int i = 0; i < ALPHABET_SIZE; ++i) {
    //     printf("%c ", d_ALPHABET[i]);
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", A[i*ALPHABET_SIZE + j]);
    //     }
    //     printf("\n");
    // }
    // compute the 0th row, base case
    int j_idx = threadIdx.x + blockIdx.x * blockDim.x;
    if (j_idx > m)
        return;
    // printf("Block Id: %d, Thread Id: %d, Idx: %d\n", blockIdx.x, threadIdx.x, j_idx);
    M[j_idx] = j_idx;
}

__global__ void compute_scs(int* M, const int* A, const char* s1, const char* s2, const int i_idx, const int m)
{
    // sanity check
    // printf("Block Id: %d, Thread Id: %d\n", blockIdx.x, threadIdx.x);
    // printf("String X: %s, String Y: %s, n = %d, m = %d\n", s1, s2, n, m);
    // for (int i = 0; i < ALPHABET_SIZE; ++i) {
    //     printf("%c ", d_ALPHABET[i]);
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", A[i*ALPHABET_SIZE + j]);
    //     }
    //     printf("\n");
    // }
    // find corresponding column index
    const int j_idx = threadIdx.x + blockIdx.x * blockDim.x;
    // check for boundaries
    if (j_idx > m)
        return;
    // find index into M when M is flattened
    const int idx_i_j = i_idx * (m+1) + j_idx;
    // printf("Block Id: %d, Thread Id: %d, Idx: %d\n", blockIdx.x, threadIdx.x, idx_i_j);
    // base case
    if (j_idx == 0) {
        M[idx_i_j] = i_idx;
    }
    else {
        const int idx_i_minus_1_j = (i_idx-1) * (m+1) + j_idx;
        const int j_minus_k = A[CONVERT_LETTER_TO_IDX(s1[i_idx-1]) * (m+1) + j_idx];
        const int k = j_idx - j_minus_k;
        int M_i_j_minus_1;
        if (j_minus_k == 0)
            M_i_j_minus_1 = i_idx + k - 1;
        else
            M_i_j_minus_1 = M[(i_idx-1) * (m+1) + (j_minus_k-1)] + k;
        // compute current value
        M[idx_i_j] = 1 + MIN(M_i_j_minus_1, M[idx_i_minus_1_j]);
    }
}

//host function, __host__ qualifier assumed by default
int main()
{
    // 2 input strings
    std::string X = "ozpxennwaelglzwocdybdmpmmcyconwcmlbsaoqcvciidewfiuiljaavcazqnvvbjyvjpmokqwstboa";
    std::string Y = "iyklqkkdhnvwnrjbxkuyltiaqbllgsipqvaihmlozhnmyypxkjwwegyujjhqepfumhfuvqiuzvixtxxgivcobakllrbriimvrrpmjzgjxqisnfy";
    // size of strings
    const int n = X.size();
    const int m = Y.size();
    // define memo
    int A[ALPHABET_SIZE][m+1]; // j - k
    int M[n+1][m+1];           // SCS length
    // guarantee all entries have been set to 0
    memset(A, 0, sizeof(A));
    memset(M, 0, sizeof(M));

    // allocate memory for device variables
    char *d_X, *d_Y;
    int *d_A;
    int *d_M;
    // check if the cuda functions fail using status codes provided by nvcc compiler
    if (cudaMalloc(&d_X, sizeof(char) * (n+1)) != cudaSuccess) {
        printf("CUDA Error: Could not allocate d_X for string X\n");
        return 1;
    }
    if (cudaMalloc(&d_Y, sizeof(char) * (m+1)) != cudaSuccess) {
        printf("CUDA Error: Could not allocate d_Y for string Y\n");
        return 1;
    }
    if (cudaMalloc(&d_A, sizeof(int) * (m+1) * ALPHABET_SIZE) != cudaSuccess) {
        printf("CUDA Error: Could not allocate d_A for memo A\n");
        return 1;
    }
    if (cudaMalloc(&d_M, sizeof(int) * (m+1) * (n+1)) != cudaSuccess) {
        printf("CUDA Error: Could not allocate d_M for memo M\n");
        return 1;
    }

    // copy memory to device
    if (cudaMemcpy(d_X, X.c_str(), sizeof(char) * (n+1), cudaMemcpyHostToDevice) != cudaSuccess) {
        printf("CUDA Error: Could not copy X into d_X\n");
        return 1;
    }
    if (cudaMemcpy(d_Y, Y.c_str(), sizeof(char) * (m+1), cudaMemcpyHostToDevice) != cudaSuccess) {
        printf("CUDA Error: Could not copy Y into d_Y\n");
        return 1;
    }
    if (cudaMemcpy(d_A, A, sizeof(int) * (m+1) * ALPHABET_SIZE, cudaMemcpyHostToDevice) != cudaSuccess) {
        printf("CUDA Error: Could not copy A into d_A\n");
        return 1;
    }
    if (cudaMemcpy(d_M, M, sizeof(int) * (m+1) * (n+1), cudaMemcpyHostToDevice) != cudaSuccess) {
        printf("CUDA Error: Could not copy M into d_M\n");
        return 1;
    }

    // declare & create cuda events
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    // declare block and grid dimensions
    // only use 1 dimension bc of row-wise and col-wise independence
    // for computing j-k or memmo A, assume ALPHABET_SIZE <= 1024
    dim3 blockDimA(ALPHABET_SIZE, 1, 1);
    dim3 gridDimA(1, 1, 1);
    // for computing SCS or memo M
    int num_threads = MIN(1024, m+1);
    dim3 blockDimM(num_threads, 1, 1);
    int num_blocks = std::ceil((m+1) / (double)1024);
    dim3 gridDimM(num_blocks, 1, 1);
    printf("Sanity Check, Number of Threads %d, Number of Blocks: %d\n", num_threads, num_blocks);

    // record time for start
    cudaEventRecord(start);

    // Step 1: compute j - k, i.e. memo A
    compute_j_minus_k<<<gridDimA,blockDimA>>>(d_A, d_Y, m);
    // Step 2: compute SCS length, i.e. memo M
    compute_scs_0th_row<<<gridDimM,blockDimM>>>(d_M, m);
    for (int i = 1; i <= n; ++i) {
        compute_scs<<<gridDimM,blockDimM>>>(d_M, d_A, d_X, d_Y, i, m);
    }

    // record time for stop
    cudaEventRecord(stop);
    // blocks CPU execution until the specified event is recorded
    cudaEventSynchronize(stop);

    /* ---------------- 6. Copy stuff back from GPU to CPU ---------------- */
    if (cudaMemcpy(A, d_A, sizeof(int) * (m+1) * ALPHABET_SIZE, cudaMemcpyDeviceToHost) != cudaSuccess) {
        printf("CUDA Error: Could not copy d_A from device back to A in host\n");
    }
    if (cudaMemcpy(M, d_M, sizeof(int) * (m+1) * (n+1), cudaMemcpyDeviceToHost) != cudaSuccess) {
        printf("CUDA Error: Could not copy d_M from device back to M in host\n");
    }
    // DEBUG
    // for (int i = 0; i < ALPHABET_SIZE; ++i) {
    //     printf("%c ", ALPHABET[i]);
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", A[i][j]);
    //     }
    //     printf("\n");
    // }
    for (int i = 0; i <= n; ++i) {
        for (int j = 0; j <= m; ++j) {
            printf("%d ", M[i][j]);
        }
        printf("\n");
    }
    // END DEBUG

    // if (cudaMemcpy(&sum, write_buf, sizeof(double), cudaMemcpyDeviceToHost) != cudaSuccess) {
    //     std::cout << "CUDA Error: Could not copy final sum (d_A[0]) back to host" << std::endl;
    //     return 1;
    // }
    // if (cudaMemcpy(&A_n3_n3, d_A_n3_n3, sizeof(double), cudaMemcpyDeviceToHost) != cudaSuccess) {
    //     std::cout << "CUDA Error: Could not copy final d_A[N/3][N/3] back to host" << std::endl;
    //     return 1;
    // }
    // if (cudaMemcpy(&A_19_37, d_A_19_37, sizeof(double), cudaMemcpyDeviceToHost) != cudaSuccess) {
    //     std::cout << "CUDA Error: Could not copy final d_A[19][37] back to host" << std::endl;
    //     return 1;
    // }
    /* --------------- 7. Print elapsed time & verification --------------- */
    float elapsed_time;
    cudaEventElapsedTime(&elapsed_time, start, stop);
    printf("Elapsed Time (ms) = %f\n", elapsed_time);

    // clean up
    cudaFree(d_X);
    cudaFree(d_Y);
    cudaFree(d_A);
    cudaFree(d_M);

    return 0;
}