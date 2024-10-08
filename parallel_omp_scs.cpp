#include <omp.h>
#include <algorithm>
#include <string>
#include <cassert>
#include <fstream>

// #define NUM_THREADS_USED 16
#define ALPHABET_SIZE 26
#define CONVERT_LETTER_TO_IDX(letter) (int(letter) - 97)
#define MIN(a, b) ((a) < (b) ? (a) : (b))

static const char ALPHABET[ALPHABET_SIZE] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
// static int NUM_THREADS_USED = 16;
// new plan: specify environment variable using OMP_NUM_THREADS in command line or shell script

/* Original Recurrence Relation for finding SCS
Shortest Common Supersequence of 2 strings X, Y can be expressed using a recurrence relation.
Base case: If X or Y has length 0, then the SCS is simply the other string.
Let a, b denote the last symbol in X and Y respectively,
Case 1: If the last symbol in X and Y are the same, i.e. a == b,
        then SCS(X, Y) = SCS(X-a, Y-b) + a, i.e. it is the SCS of both strings without
        their last symbol, concatenated with this last symbol once.
Case 2: If the last symbol in X and Y are NOT the same, i.e. a != b,
        then SCS(X, Y) = MIN{ SCS(X-a,Y) + a, SCS(X,Y-b) + b }, i.e. find the SCS between
        one string remaining the same but excluding the last symbol of the other string,
        concatenated with the symbol that was excluded.
This approach is allowed because the problem satisfies the optimal substructure property of DP.
*/


/* Reformulated Recurrence Relation for finding SCS
Originally, Case 2 requires each entry to look at the entry to its left on the same row.
So each entry [i][j], is dependent on [i-1][j], [i-1][j-1], and [i][j-1];
this makes the relation having data dependency both row-wise and column-wise.
However, we make the claim that the tabulation can actually be row-wise independent, i.e.
the ith row data can be calculated just based on the (i − 1)th row data!

To do this, we need to reformulate Case 2, specifically, somehow to not use tab[i][j-1].
We make an observation that tab[i][j-1] can only be one of the following:
1. tab[i][j-1] = i                                  if j-1 = 0
2. tab[i][j-1] = tab[i-1][j-2] + 1                  if X[i] = Y[j-1]
3. tab[i][j-1] = min{tab[i-1][j-1], tab[i][j-2]}    otherwise
Note that case 3 requires tab[i][j-2] which is on the same row again, but we can simply
do recursion using this formula until we get to either case 1 or 2!

In other words, we can think of this as we just keep going left 1 char or col at a time, until
we eventually no longer need to use the entry on the same row by either
1. Reach the leftmost column, or
2. Reach a character in string Y (i.e. at location j - k) that is the same as the current
   character in string X (i.e. at location i).

Thus, we can substitute tab[i][j-1] in Case 2 or the original recurrence relation as the following:
- tab[i][j-1] = i + k - 1               if j-k = 0
- tab[i][j-1] = tab[i-1][j-k-1] + k     if X[i] = Y[j-k]
where k is the minimum number of chars we look left until either one of the two cases in the
previous paragraph becomes true.

The scs_rowwise_independent function implements this approach.

Note that in the actual implementation, we are actually comparing X[i-1] and Y[i-1-k]
bc the strings are 0-based indexing whereas the tabulation is 1-based indexing because
of "the ghost cells" padding to account for the base case of scs.
*/

int scs_rowwise_independent(const std::string &s1, const std::string &s2) {
    // get length of both strings
    int n = s1.size();
    int m = s2.size();
    // create tabulation (memoization)
    int tab[n+1][m+1];
    // use bottom up iteration to find the optimal length of SCS
    for (int i = 0; i < n + 1; ++i) {
        for (int j = 0; j < m + 1; ++j) {
            // both base cases and case 1 do not need to access anything from current row
            if (i == 0) {
                tab[i][j] = j;
            }
            else if (j == 0) {
                tab[i][j] = i;
            }
            else if (s1[i-1] == s2[j-1]) {
                tab[i][j] = 1 + tab[i-1][j-1];
            }
            // only case two needs to access from current row
            // use new formula
            else if (s1[i-1] != s2[j-1]) {
                printf("Row: %d, Col: %d; ", i, j);
                // first find k
                int k = 1;
                int tab_i_j_1;
                while (true) {
                    if (j - k == 0) {
                        tab_i_j_1 = i + k - 1;
                        // printf("Reached edge of column");
                        break;
                    }
                    else if (s1[i-1] == s2[j-1-k]) {
                        tab_i_j_1 = tab[i-1][j-k-1] + k;
                        // printf("Found matching symbol");
                        break;
                    }
                    else {
                        ++k;
                    }
                }
                printf(" j - k = %d ", j - k);
                printf("found k = %d, tab[i][j-1] = %d\n", k, tab_i_j_1);
                tab[i][j] = 1 + std::min(tab_i_j_1, tab[i-1][j]);
            }
        }
    }
    // DEBUG
    for (int i = 0; i <= n; ++i) {
        for (int j = 0; j <= m; ++j) {
            printf("%d ", tab[i][j]);
        }
        printf("\n");
    }
    // END DEBUG
    // output length
    return tab[n][m];
}

/*
The above row-wise implementation does remove the data dependency in the same row.
However, the process of looking for k can be slow, especially when string Y is large.
We can preprocess another matrix/tabulation for computing/storing j - k,
let's call this matrix P.

Let C be a finite alphabet for the input strings, C[1,...,l]
Let 1 <= i <= l, 0 <= j <= m
Define matrix/tabulation P[l+1][m+1] (i.e. row=each char in alphabet, col=each char in string Y),
1. P[i][j] = 0              if j = 0
2. P[i][j] = j - 1          if Y[j-1] = C[i]
3. P[i][j] = P[i][j-1]      otherwise

As a result, P[i][j] indicates the closest index (to index j) in string Y such that
1. this index either equals to 0 (we have reached the edge column, i.e. no matching
   chars between anything before index j in string Y and C[i]), or
2. the char at this index in string Y equals to C[i] (we found a matching char)
These two conditions parallel the two stopping conditions in the recurrence relation for
tab[i][j-1] in the previous block of comment.
In other words, P[i][j] equals to j - k.

Note that filling out the matrix P is column-wise independent, which can also be parallelized.
But bc cache is stored contiguous as rows in C, it is better to flip the row and column of P
when actually implementing this approach.

Lastly, we can replace the j - k in the recurrence relation for tab[i][j-1] in the previous
block of comment with the following:
- tab[i][j-1] = i + j - 1                                if P[c][j] = 0
- tab[i][j-1] = tab[i-1][P[c][j]-1] + (j-P[c][j]-1])     if X[i] = Y[P[c][j]]
*/

// REQUIRES: alphabet has only 26 letters, specifically [a-z] lower case
// MODIFIES: none
// EFFECTS: returns 0-based indexing for the letter, e.g., a=0, b=1, ...
int convert_letter_to_idx(const char letter) {
    // TODO: make this compiler macro
    // sanity check
    assert(0 <= int(letter) - 97 && int(letter) - 97 <= 25);
    return int(letter) - 97;
}

int scs_rowwise_independent_w_two_memos(const std::string &s1, const std::string &s2) {
    // get length of both strings
    int n = s1.size();
    int m = s2.size();
    // create tabulation (memoization)
    int P[ALPHABET_SIZE][m+1];
    int tab[n+1][m+1];
    // Step 1: fill out j-k values (see block of comments above for more info)
    for (int i = 0; i < ALPHABET_SIZE; ++i) {
        // first column is always 0 bc it represents the empty string s2
        P[i][0] = 0;
        for (int j = 1; j <= m; ++j) {
            if (s2[j-1] == ALPHABET[i])
                // note: no -1 here bc we do -1 later when indexing into s2
                P[i][j] = j;
            else
                P[i][j] = P[i][j-1];
        }
    }
    // DEBUG
    // for (int i = 0; i < ALPHABET_SIZE; ++i) {
    //     printf("%c ", ALPHABET[i]);
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", P[i][j]);
    //     }
    //     printf("\n");
    // }
    // END DEBUG

    // Step 2: use bottom up iteration to find the optimal length of SCS
    for (int i = 0; i < n + 1; ++i) {
        for (int j = 0; j < m + 1; ++j) {
            // both base cases and case 1 do not need to access anything from current row
            if (i == 0) {
                tab[i][j] = j;
            }
            else if (j == 0) {
                tab[i][j] = i;
            }
            else if (s1[i-1] == s2[j-1]) {
                tab[i][j] = 1 + tab[i-1][j-1];
            }
            // only case two needs to access from current row
            // use new formula
            else {
                // printf("Row: %d, Col: %d; ", i, j);
                // first find k
                int j_minus_k = P[convert_letter_to_idx(s1[i-1])][j];
                // printf(" j - k = %d ", j_minus_k);
                int k = j - j_minus_k;
                int tab_i_j_minus_1;
                // tab[i][j-1] = i + j - 1                                if P[c][j] = 0
                // tab[i][j-1] = tab[i-1][P[c][j]-1] + (j-P[c][j]-1])     if X[i] = Y[P[c][j]]
                if (j_minus_k == 0) {
                    tab_i_j_minus_1 = i + k - 1;
                    // printf("Reached edge of column");
                }
                else if (s1[i-1] == s2[j_minus_k-1]) {
                    tab_i_j_minus_1 = tab[i-1][j_minus_k-1] + k;
                    // printf("Found matching symbol");
                }
                // printf("found k = %d, tab[i][j-1] = %d\n", k, tab_i_j_minus_1);
                tab[i][j] = 1 + std::min(tab_i_j_minus_1, tab[i-1][j]);
            }
        }
    }
    // DEBUG
    for (int i = 0; i <= n; ++i) {
        for (int j = 0; j <= m; ++j) {
            printf("%d ", tab[i][j]);
        }
        printf("\n");
    }
    // END DEBUG
    // output length
    return tab[n][m];
}

/*
The algorithm below presents further optimized code with less conditional branches.
*/

int scs_rowwise_independent_optimal(const std::string &s1, const std::string &s2) {
    // get length of both strings
    int n = s1.size();
    int m = s2.size();
    // create tabulation (memoization)
    int P[ALPHABET_SIZE][m+1];
    int tab[n+1][m+1];
    double start, end;
    // record start time
    start = omp_get_wtime();
    // Step 1: fill out j-k values (see block of comments above for more info)
    // TODO: can parallelize the outer loop
    //      spawn 26 threads (one for each letter), each thread do the inner loop
#pragma omp parallel for num_threads(ALPHABET_SIZE)
    for (int i = 0; i < ALPHABET_SIZE; ++i) {
        // first column is always 0 bc it represents the empty string s2
        P[i][0] = 0;
        for (int j = 1; j <= m; ++j) {
            // printf("Thread Idx: %d, Row: %d Col: %d\n", omp_get_thread_num(), i, j);
            if (s2[j-1] == ALPHABET[i])
                // note: no -1 here bc we do -1 later when indexing into s2
                P[i][j] = j;
            else
                P[i][j] = P[i][j-1];
        }
    }

    // Step 2: use bottom up iteration to find the optimal length of SCS
    int i = 1;
    // using omp parallel outside to minimize threads generation for each inner loop
// #pragma omp parallel num_threads(NUM_THREADS_USED)
#pragma omp parallel
{
    // printf("sanity check, number of threads: %d\n", omp_get_num_threads());
    // calculate base case (row 0) first
    // TODO: parallelize here or this can be considered as part of the initialization of tab
#pragma omp for schedule(static)
    for (int j = 0; j <= m; ++j) {
        tab[0][j] = j;
    }
    // then iteratively calculate remaining rows
    while (i <= n) {
        // base case (col 0)
        tab[i][0] = i;
        // TODO: can parallelize the inner loop
#pragma omp for schedule(static)
        for (int j = 1; j <= m; ++j) {
            // printf("Thread Idx: %d, Row: %d Col: %d\n", omp_get_thread_num(), i, j);
            // first find k
            int j_minus_k = P[CONVERT_LETTER_TO_IDX(s1[i-1])][j];
            int k = j - j_minus_k;
            int tab_i_j_minus_1;
            if (j_minus_k == 0)
                // reached edge of column
                tab_i_j_minus_1 = i + k - 1;
            else
                // found matching symbol
                tab_i_j_minus_1 = tab[i-1][j_minus_k-1] + k;
            // compute current value in tab
            tab[i][j] = 1 + MIN(tab_i_j_minus_1, tab[i-1][j]);
        }
#pragma omp single
        ++i;
    }
}
    // END DEBUG
    // record end time
    end = omp_get_wtime();
    // DEBUG
    // for (int i = 0; i <= n; ++i) {
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", tab[i][j]);
    //     }
    //     printf("\n");
    // }
    printf("Execution Time (ms) %f\n", (end - start) * 1000.0);
    // output length
    return tab[n][m];
}

int scs_rowwise_independent_no_branch(const std::string &s1, const std::string &s2) {
    // get length of both strings
    const int n = s1.size();
    const int m = s2.size();
    // create memoization
    int A[ALPHABET_SIZE][m+1];
    int tab[n+1][m+1];
    double start, end;
    // record start time
    start = omp_get_wtime();
    // Step 1: fill out j-k values in first memo (see paper)
    // spawn 26 threads (one for each letter), each thread do the inner loop
#pragma omp parallel for num_threads(ALPHABET_SIZE)
    for (int i = 0; i < ALPHABET_SIZE; ++i) {
        // opt: first column is always 0 bc it represents the empty string s2
        A[i][0] = 0;
        for (int j = 1; j <= m; ++j)
            // opt: only 1 comparison
            A[i][j] = (s2[j-1] == ALPHABET[i]) ? j : A[i][j-1];
    }

    // Step 2: use bottom up iteration to find the optimal length of SCS
    int i = 1;
    // opt: using omp parallel outside to minimize threads generation for each inner loop
// #pragma omp parallel num_threads(NUM_THREADS_USED)
#pragma omp parallel
{
    // opt: calculate base case (row 0) first
#pragma omp for schedule(static)
    for (int j = 0; j <= m; ++j) {
        tab[0][j] = j;
    }
    // then iteratively calculate remaining rows
    while (i <= n) {
        // base case (col 0)
        tab[i][0] = i;
#pragma omp for schedule(static)
        for (int j = 1; j <= m; ++j) {
            // first find k
            int j_minus_k = A[CONVERT_LETTER_TO_IDX(s1[i-1])][j];

            // rely solely on boolean logic
            bool found_matching = j_minus_k > 0;
            bool i_minus_1_leq_j_minus_1 = found_matching * (tab[i-1][j] <= tab[i-1][j_minus_k-1] + (j - j_minus_k))
                                            + !found_matching * (tab[i-1][j] <= i + j - 1);
            // observation: the difference between [i-1][j] and [i][j-1] is at most 1
            // we can simply use tab[i-1][j] to compute tab[i][j]
            // if tab[i-1][j] <= tab_i_j_minus_1, then simply add 1 as normal
            // otherwise, we know that tab[i-1][j] = tab_i_j_minus_1 + 1,
            // so we simply do not need to add 1 to it
            tab[i][j] = tab[i-1][j] + i_minus_1_leq_j_minus_1;
        }
#pragma omp single
        ++i;
    }
}
    // END DEBUG
    // record end time
    end = omp_get_wtime();
    // DEBUG
    // for (int i = 0; i <= n; ++i) {
    //     for (int j = 0; j <= m; ++j) {
    //         printf("%d ", tab[i][j]);
    //     }
    //     printf("\n");
    // }
    printf("Execution Time (ms) %f\n", (end - start) * 1000.0);
    // output length
    return tab[n][m];
}

int main(int argc, char** argv) {
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
    // printf("Size of X is %d, first char in X is %c\n", X.size(), X[0]);
    // printf("Size of Y is %d, first char in Y is %c\n", Y.size(), Y[0]);
    fin.close();

    // explicitly enable dynamic teams
    // omp_set_dynamic(true);

    // int scs_length_og = scs_rowwise_independent(X, Y);
    // int scs_length = scs_rowwise_independent_w_two_memos(X, Y);
    int scs_length = scs_rowwise_independent_optimal(X, Y);
    // int scs_length = scs_rowwise_independent_no_branch(X, Y);
    printf("Length of SCS is %d\n", scs_length);

    return 0;
}
