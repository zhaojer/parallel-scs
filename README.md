# EECS 587 Final Project
## Idea
- Implement parallel algorithms for the Shortest Common Supersequence problem
- Try to do so in MPI, OpenMP, and CUDA
### Anti-diagonal Approach
- Solution is working.
- However, it is slower than serial for small inputs.
- This might be due to
    - OMP spawning and joining threads involve extra overhead not present in serial
        - IN fact, when using smaller number of threads (for smaller inputs) resulted in faster performance.
    - accessing matrix (tabulation) diagonally instead of horizontal sequentially introduces overhead due to memory organization in C

## TODO
- Implement parallel algorithm in OpenMP
    - Anti-diagonal approach
    - Other approaches
