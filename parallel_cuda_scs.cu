/* Author: zhaojer */
#include <string>
#include <fstream>

#define ALPHABET_SIZE 26
#define CONVERT_LETTER_TO_IDX(letter) (int(letter) - 97)
#define MIN(a, b) ((a) < (b) ? (a) : (b))

// const char ALPHABET[ALPHABET_SIZE] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
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

__global__ void compute_scs(int* M, const int* A, const char* s1, const char* s2, const long long i_idx, const long long m)
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
    const long long j_idx = threadIdx.x + (long long)blockIdx.x * blockDim.x;
    // check for boundaries
    if (j_idx > m)
        return;
    // find index into M when M is flattened
    const long long idx_i_j = i_idx * (m+1) + j_idx;
    // printf("Block Id: %d, Thread Id: %d, Idx: %d\n", blockIdx.x, threadIdx.x, idx_i_j);
    // base case
    if (j_idx == 0) {
        M[idx_i_j] = i_idx;
    }
    else {
        const long long idx_i_minus_1_j = (i_idx-1) * (m+1) + j_idx;
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
int main(int argc, char** argv)
{
    // get input file name from commandline if one is provided
    std::string input_file;
    if (argc == 1) {
        // default input file name
        input_file = "input/input-2000.txt";
    }
    else if (argc == 2) {
        input_file = argv[1];
    }
    else {
        printf("Error: Invalid number of arguments provided\n");
        printf("Usage: ./<program> <input file>\n");
        return 1;
    }
    printf("Input: %s\n", input_file.c_str());
    // 2 input strings
    std::string X = "ozpxennwaelglzwocdybdmpmmcyconwcmlbsaoqcvciidewfiuiljaavcazqnvvbjyvjpmokqwstboa";
    std::string Y = "iyklqkkdhnvwnrjbxkuyltiaqbllgsipqvaihmlozhnmyypxkjwwegyujjhqepfumhfuvqiuzvixtxxgivcobakllrbriimvrrpmjzgjxqisnfy";
    // read input string from file
    std::ifstream fin;
    fin.open(input_file);
    // throw error if the file opening fails
    if (!fin.is_open()) {
        printf("Error opening file: %s\n", input_file.c_str());
        return 1;
    }
    std::getline(fin, X);
    std::getline(fin, Y);
    fin.close();

    // size of strings
    const long long n = X.size();
    const long long m = Y.size();

    // allocate memory for device variables
    char *d_X, *d_Y;
    // memo directly defined on device memory
    int *d_A; // j - k
    int *d_M; // SCS length
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
    if (cudaMemset(d_A, 0, sizeof(int) * (m+1) * ALPHABET_SIZE) != cudaSuccess) {
        printf("CUDA Error: Could not set memory of d_A to 0\n");
        return 1;
    }
    if (cudaMemset(d_M, 0, sizeof(int) * (m+1) * (n+1)) != cudaSuccess) {
        printf("CUDA Error: Could not set memory of d_M to 0\n");
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
    // printf("Sanity Check, Number of Threads %d, Number of Blocks: %d\n", num_threads, num_blocks);

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

    /* ---------------- Copy stuff back from GPU to CPU ---------------- */
    // DEBUG
    // if (cudaMemcpy(A, d_A, sizeof(int) * (m+1) * ALPHABET_SIZE, cudaMemcpyDeviceToHost) != cudaSuccess) {
    //     printf("CUDA Error: Could not copy d_A from device back to A in host\n");
    // }
    // if (cudaMemcpy(M, d_M, sizeof(int) * (m+1) * (n+1), cudaMemcpyDeviceToHost) != cudaSuccess) {
    //     printf("CUDA Error: Could not copy d_M from device back to M in host\n");
    // }
    // for (int i = 0; i < ALPHABET_SIZE; ++i) {
    //     printf("%c ", ALPHABET[i]);
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", A[i][j]);
    //     }
    //     printf("\n");
    // }
    // for (int i = 0; i <= n; ++i) {
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", M[i][j]);
    //     }
    //     printf("\n");
    // }
    // END DEBUG
    int scs_length;
    if (cudaMemcpy(&scs_length, &d_M[n * (m+1) + m], sizeof(int), cudaMemcpyDeviceToHost) != cudaSuccess) {
        printf("CUDA Error: Could not copy final SCS length from device back to host\n");
    }
    /* --------------- Print elapsed time & verification --------------- */
    float elapsed_time;
    cudaEventElapsedTime(&elapsed_time, start, stop);
    printf("Execution Time (ms) %f\n", elapsed_time);
    printf("Length of SCS is %d\n", scs_length);

    // clean up
    cudaFree(d_X);
    cudaFree(d_Y);
    cudaFree(d_A);
    cudaFree(d_M);

    return 0;
}