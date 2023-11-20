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
- Memo solution also working: Now using one memo for j - k, and one memo for the length of scs; computing the former is column-wise independent, while the latter is row-wise independent.
- Next Step:
    - Keep reading the paper to further speedup the code (e.g., less conditional branches)
        - Could not really do it their way using bit operations (too complicated 😢)
        - However, we still tried our best to minimize the branches!
    - Flip memo for j - k to be row-wise independent as well (bc cache in C is contiguous per row)
        - Discovered that no need to do this because we can just simply parallelize different loop!
    - Switched some function calls to compiler macros
    - Implement parallel version in Omp
- Future:
    - Implement parallel version in CUDA

### Assumptions
- There are a finite number of letters in the alphabet which the input strings are generated from
    - Specifically, they are the 26 lower case letters of the English alphabet

## TODO
- Implement parallel algorithm in OpenMP
    - Anti-diagonal approach
    - Row-wise independent approach
    - Other approaches
