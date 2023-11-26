#include <omp.h>
#include <string>
#include <fstream>

// #define NUM_THREADS_USED 16
#define MIN(a, b) ((a) < (b) ? (a) : (b))

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

// Anti diagonal implementation of SCS
int scs_anti_diagonal(const std::string &x, const std::string &y) {
    // get length of strings x and y
    const int x_len = x.size();
    const int y_len = y.size();
    // construct tabulation (memoization)
    // +1 row/col for "ghost cells" for base case, which are initialized to 0
    int tab[x_len + 1][y_len + 1] = {0};
    // timer
    double start, end;
    // record start time
    start = omp_get_wtime();
    // fill out the matrix using anti-diagonal approach
    // first, only increment iterator j, corresponding to the column of tab
    for (int i = 0, j = 0; i <= x_len && j <= y_len; ++j) {
        // get the length of the anti-diagonal
        int diagonal_len = std::min(j, x_len - i);
        // parallel for loop for each anti-diagonal element
// #pragma omp parallel for num_threads(NUM_THREADS_USED)
#pragma omp parallel for
        // #pragma omp parallel for
        for (int k = 0; k <= diagonal_len; ++k) {
            // index of the diagonal elements
            // a corresponds to row, increases by 1 each time
            // b corresponds to col, decreases by 1 each time
            int a = i + k, b = j - k;
            // base case
            if (a == 0)
                tab[a][b] = b;
            else if (b == 0)
                tab[a][b] = a;
            // case 1
            else if (x[a - 1] == y[b - 1])
                tab[a][b] = 1 + tab[a - 1][b - 1];
            // case 2
            else
                tab[a][b] = 1 + MIN(tab[a][b - 1], tab[a - 1][b]);
        }
        // after j reached end of column, half (upper left) of tab has been filed
        // then, increment i to fill the remaining half of tab
        if (j >= y_len) {								
            j = y_len-1;
            ++i;
        }
    }
    // record end time
    end = omp_get_wtime();
    printf("Execution Time (ms) %f\n", (end - start) * 1000.0);

    // DEBUG
    // for (int i = 0; i <= x_len; ++i) {
    //     for (int j = 0; j <= y_len; ++j) {
    //         printf("%d ", tab[i][j]);
    //     }
    //     printf("\n");
    // }
    // END DEBUG

    // output length
	return tab[x_len][y_len];
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

    int scs_length = scs_anti_diagonal(X, Y);
    printf("Length of SCS is %d\n", scs_length);

    return 0;
}
