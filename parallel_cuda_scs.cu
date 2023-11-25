/* Author: zhaojer */
#include <string>
#include <fstream>

#define ALPHABET_SIZE 26
#define CONVERT_LETTER_TO_IDX(letter) (int(letter) - 97)
#define MIN(a, b) ((a) < (b) ? (a) : (b))

static const char ALPHABET[ALPHABET_SIZE] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};

// REQUIRES: nums only has 5 numbers
// MODIFIES: nums
// EFFECTS: sort nums up to 3 elements using a bubble sort; median is nums[2]
__device__ void bubleSort(double nums[])
{
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 5 - i - 1; j++) {
            if (nums[j] > nums[j + 1]) {
                double temp = nums[j];
                nums[j] = nums[j+1];
                nums[j+1] = temp;
            }
        }
    }
}

// REQUIRES: curA and nextA correspond to matrix A and have size N * N
//           curA contains values from previous iteration
// MODIFIES: nextA
// EFFECTS: perform (1 iteration of) stencil calculation
//          by reading from curA and writing to nextA
// __global__ void StencilCalculation(double* curA, double* nextA)
// {
//     /*
//     we are using 2-Dimensional grid and 2-Dimensional block for this kernel
//     this structure/setup is automatically partioning the 2D matrix A for us
//     think of each block as taking non-overlapping partition of A of size [blockDim.x][blockDim.y]
//     e.g. if block dims are 16 by 16, then each block is taking partition_of_A[16][16]
//         and all these blocks together span the entire A
//         see diagram I drew on paper
//     */

//     // declare shared memory for each block, speeds up memory access
//     __shared__ double localA[one_dim + 2][one_dim + 2];
//     // doing +2 on each dimension because of ghost cells

//     // calculate colIdx and rowIdx corresponding to this thread in GPU
//     // actual/global column index in 2D array A this thread corresponds to
//     int colIdx = blockIdx.y * blockDim.y + threadIdx.y;
//     // actual/global row index in 2D array A this thread corresponds to
//     int rowIdx = blockIdx.x * blockDim.x + threadIdx.x;
//     // this is the index this thread accesses in the flattened array A
//     int idx = rowIdx * N + colIdx;
//     // if this thread is out of bounds of N, then no need to go further
//     if (colIdx >= N || rowIdx >= N) {
//         // this happens bc N does not always evenly divide blockDim
//         return;
//     }
//     // find index of surrounding elements, needed for finding median
//     int downIdx = (rowIdx + 1) * N + colIdx;
//     int upIdx = (rowIdx - 1) * N + colIdx;
//     int rightIdx = rowIdx * N + (colIdx + 1);
//     int leftIdx = rowIdx * N + (colIdx - 1);
//     // local index is now 1-based indexing b/c of ghost cells up/down/left/right
//     int localRowIdx = threadIdx.x + 1;
//     int localColIdx = threadIdx.y + 1;
//     // read from global to shared to speedup later access
//     localA[localRowIdx][localColIdx] = curA[idx];
//     if (localRowIdx == 1 && rowIdx > 0) {
//         localA[localRowIdx - 1][localColIdx] = curA[upIdx];
//     }
//     if (localColIdx == 1 && colIdx > 0) {
//         localA[localRowIdx][localColIdx - 1] = curA[leftIdx];
//     }
//     if (localRowIdx == one_dim && rowIdx < N - 1) {
//         localA[localRowIdx + 1][localColIdx] = curA[downIdx];
//     }
//     if (localColIdx == one_dim && colIdx < N - 1) {
//         localA[localRowIdx][localColIdx + 1] = curA[rightIdx];
//     }
//     // need to make sure all threads have read to shared localA before continue
//     __syncthreads();

//     // need synchronization before moving on to next iteration; this is done in CPU
//     if ((rowIdx == 0) || (rowIdx == N - 1) || (colIdx == 0) || (colIdx == N - 1)) {
//         // A's border remains unchanged throughout the iterations
//         nextA[idx] = localA[localRowIdx][localColIdx];
//     }
//     else {
//         // get all values from shared memory
//         double nums[5] = {localA[localRowIdx][localColIdx],
//                             localA[localRowIdx + 1][localColIdx],
//                             localA[localRowIdx - 1][localColIdx], 
//                             localA[localRowIdx][localColIdx + 1],
//                             localA[localRowIdx][localColIdx - 1]};
//         // need to efficiently find the median out of 5 elements
//         // partial bubble sort is the fast (way faster than insertion)
//         bubleSort(nums);
//         double new_median = nums[2];
//         nextA[idx] = new_median;
//         // need to synchronize all threads here before writing to matrix A
//         // this is done using read/write buffer (indirection), see CPU code
//     }
// }


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
    // DEBUG
    // for (int i = 0; i < ALPHABET_SIZE; ++i) {
    //     printf("%c ", ALPHABET[i]);
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", A[i][j]);
    //     }
    //     printf("\n");
    // }
    // END DEBUG

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

    // clean up
    cudaFree(d_A);
    cudaFree(d_M);

    return 0;
}