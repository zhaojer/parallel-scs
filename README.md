# Parallel Shortest Common Supersequence

Two *novel, efficient* parallel dynamic programming algorithms (1. Anti-diagonal Algorithm and 2. Row-wise Independent Algorithm) for the shortest common supersequence problem implemented using OpenMP and CUDA.

The SCS problem is difficult to parallelize and has not been done before because the current serial solution utilizes a Dynamic Programming algorithm with both row-wise and column-wise data dependencies, making parallelization impossible using a traditional iterative approach.

After a reinterpretation and a substantial analysis of the problem and the serial algorithm, I was able to design and implement 2 parallel algorithms in OMP and CUDA. My parallel programs had fast runtimes and reasonable effiency/speedup, with the Row-wise Independent Algorithm on the GPU being the best solution overall.

## Files/Directory Description

| Name    | Description |
| -------- | ------- |
| `input/`  | Files containing various sized inputs for the algorithms |
| `output/` | Output produced by the algorithms, ran on Great Lakes supercomputer |
| `generate_string.cpp`    | Generate inputs of desired size for the algorithms |
| `*.sh` | Scripts to submit/run the algorithms on Great Lakes supercomputer |
| `parallel_cuda_scs.cu` | Two algorithms implemented using CUDA |
| `parallel_omp*.cpp` | Two algorithms implemented using OpenMP |
| `serial_scs.cpp` | Serial algorithm |

## Running

The programs are configured to run on the Great Lakes supercomputer at University of Michigan. To do so, simply compile the files by running `make` and then execute the corresponding `.sh` script file to submit/run the program.

Running the programs locally is also possible, but may need some additiona set up. Running the OpenMP implementations (`.cpp` files) require the OpenMP library installed. Running the CUDA implementations require an NVIDIA GPU, NVIDIA Driver, and CUDA Toolkit installed.

## Implementation Details

See [report](report.pdf).

## Issues
- Cannot figure out how to get enough memory to test out anything above 80000 * 80000 input size on greatlakes (for gpu).
    - i.e. `cudaMalloc` no longer return `cudaSuccess`
    - Thus, only test everything up to & including 60000 * 60000
