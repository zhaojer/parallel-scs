#include <algorithm>
#include <string>
#include <cstring>
#include <iostream>


class Solution {
    /*
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

    std::string SCS_bottom_up(std::string s1, std::string s2) {
        // get length of both strings
        int n = s1.size();
        int m = s2.size();
        // create tabulation (memoization)
        int tab[n+1][m+1];
        // Step 1: use bottom up iteration to find the optimal length of SCS
        for (int i = 0; i < n + 1; ++i) {
            for (int j = 0; j < m + 1; ++j) {
                // base case
                if (i == 0) {
                    tab[i][j] = j;
                }
                // base case
                else if (j == 0) {
                    tab[i][j] = i;
                }
                // case 1
                else if (s1[i-1] == s2[j-1]) {
                    tab[i][j] = 1 + tab[i-1][j-1];
                }
                // case 2
                else if (s1[i-1] != s2[j-1]) {
                    tab[i][j] = 1 + std::min(tab[i][j-1], tab[i-1][j]);
                }
            }
        }
        // DEBUG
        // for (int i = 0; i <= n; ++i) {
        //     for (int j = 0; j <= m; ++j) {
        //         std::cout << tab[i][j] << " ";
        //     }
        //     std::cout << std::endl;
        // }
        // END DEBUG
        // Step 2: construct shortest common supersequence
        // indicates which index to write to in the scs
        int idx_to_write = tab[n][m] - 1;
        std::string scs(tab[n][m], ' ');
        // use n and m as iterators to index into tabulation, and s1 and s2
        while (n > 0 && m > 0) {
            // case 1
            if (s1[n-1] == s2[m-1]) {
                // include this symbol exactly once, move diagnoally
                scs[idx_to_write] = s1[n-1];
                --idx_to_write;
                --n;
                --m;
            }
            // case 2
            else {
                // determine symbol in which string would result in shorter supersequence
                if (tab[n][m-1] < tab[n-1][m]) {
                    scs[idx_to_write] = s2[m-1];
                    --idx_to_write;
                    --m;
                }
                else {
                    scs[idx_to_write] = s1[n-1];
                    --idx_to_write;
                    --n;
                }
            }
        }
        // one string has reached the end
        // do the same if/else as before, but now only needs to append one string's symbols
        if (n == 0) {
            while (m > 0) {
                scs[idx_to_write] = s2[m-1];
                --idx_to_write;
                --m;
            }
        }
        else if (m == 0) {
            while (n > 0) {
                scs[idx_to_write] = s1[n-1];
                --idx_to_write;
                --n;
            }
        }
        return scs;
    }
public:
    std::string shortestCommonSupersequence(std::string str1, std::string str2) {
        return SCS_bottom_up(str1, str2);
    }
};


int main(int argc, char** argv) {
    Solution s;
    return 0;
}
