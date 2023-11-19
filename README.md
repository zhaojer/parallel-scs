# EECS 587 Final Project
## Idea
- Implement parallel algorithms for the Shortest Common Supersequence problem
- Try to do so in MPI, OpenMP, and CUDA

### Anti-diagonal Approach
- Key idea: calculate the memo diagonally b/c entries on the same diagonal are independent.
- Solution is working.
- However, it is slower than serial for small inputs.
- This might be due to
    - OMP spawning and joining threads involve extra overhead not present in serial
        - IN fact, when using smaller number of threads (for smaller inputs) resulted in faster performance.
    - accessing matrix (tabulation) diagonally instead of horizontal sequentially introduces overhead due to memory organization in C

### Row-wise Independent Approach
- Key idea: reformulate the SCS recursion formula such that they become row-wise independent, i.e., all entries on the same row can be calculated independently (for each entry, it is only dependent on the entry from previous row rather than the previous column)
- Naive solution currently working (i.e. find `k`, or the number times it takes for the current entry to find an entry to its left in the same row that does not depend on its left entry in the same row)

## TODO
- Implement parallel algorithm in OpenMP
    - Anti-diagonal approach
    - Row-wise independent approach
    - Other approaches
