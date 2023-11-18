#include <algorithm>
#include <string>
// #include <cstring>
#include <chrono>

/*
class Solution {
    // LCS has 3 cases (for 2 strings, S1 and S2, as input)
    // Base Case: LCS(S1,S2) = 0, if either S1 or S2 has size 0
    // Case 1: LCS(S1,S2) = LCS(S1[i-1], S2[j-1]) + 1, if S1[i] == S2[j]
    // Case 2: LCS(S1,S2) = MAX{LCS(S1[i], S2[j-1]), LCS(S1[i-1], S2[j])}, if S1[i] != S2[j]
    int memo[1000+1][1000+1];

    int LCS_top_down(std::string s1, std::string s2) {
        // initialize memo to some impossible value
        // static int memo[1000+1][1000+1];
        // get length of s1 and s2
        const int n = s1.size();
        const int m = s2.size();
        // base case
        if (n == 0 || m == 0) {
            memo[n][m] = 0;
            // return 0;
        }
        // case 1
        else if (s1[n-1] == s2[m-1]) {
            memo[n][m] = (memo[n-1][m-1] != -1)
                        ? memo[n-1][m-1] + 1
                        : LCS_top_down(s1.substr(0, n-1), s2.substr(0, m-1)) + 1;
        }
        // case 2
        else {
            int lcs1 = (memo[n][m-1] != -1)
                        ? memo[n][m-1]
                        : LCS_top_down(s1, s2.substr(0, m-1));
            int lcs2 = (memo[n-1][m] != -1)
                        ? memo[n-1][m]
                        : LCS_top_down(s1.substr(0, n-1), s2);
            memo[n][m] = std::max(lcs1, lcs2);
        }
        return memo[n][m];
    }

    int LCS_bottom_up(std::string s1, std::string s2) {
        // get length of s1 and s2
        const int n = s1.size();
        const int m = s2.size();
        // construct tabulation (memoization)
        // +1 row/col for "ghost cells" for base case, which are initialized to 0
        // int tab[n+1][m+1] = {0};
        int tab[1000+1][1000+1] = {0};
        // bottom up iteration
        for (int i = 1; i < n + 1; ++i) {
            for (int j = 1; j < m + 1; ++j) {
                // Case 1
                if (s1[i-1] == s2[j-1]) { // -1 bc memo starts at 1, but string starts at 0
                    tab[i][j] = tab[i-1][j-1] + 1;
                }
                // Case 2
                else if (s1[i-1] != s2[j-1]) {
                    tab[i][j] = std::max(tab[i][j-1], tab[i-1][j]);
                }
            }
        }
        return tab[n][m];
    }
public:
    int longestCommonSubsequence(std::string text1, std::string text2) {
        return LCS_top_down(text1, text2);
    }

    Solution() {
        // initialize all entries in memo to -1
        memset(memo, -1, sizeof(memo));
    }
};
*/

// A bottom up DP implementation of LCS
// Returns length of LCS
int LCS(const std::string &s1, const std::string &s2, std::chrono::duration<double, std::milli> &time) {
    // get length of s1 and s2
    const int n = s1.size();
    const int m = s2.size();
    // construct tabulation (memoization)
    // +1 row/col for "ghost cells" for base case, which are initialized to 0
    int tab[n+1][m+1] = {0};
    // start timer
    std::chrono::time_point<std::chrono::system_clock> start, end;
    start = std::chrono::high_resolution_clock::now();
    // bottom up iteration
    for (int i = 1; i < n + 1; ++i) {
        for (int j = 1; j < m + 1; ++j) {
            // Case 1
            if (s1[i-1] == s2[j-1]) { // -1 bc memo starts at 1, but string starts at 0
                tab[i][j] = tab[i-1][j-1] + 1;
            }
            // Case 2
            else if (s1[i-1] != s2[j-1]) {
                tab[i][j] = std::max(tab[i][j-1], tab[i-1][j]);
            }
        }
    }
    // end timer
    end = std::chrono::high_resolution_clock::now();
    time = end - start;
    // output length
    return tab[n][m];
}

int main(int argc, char** argv) {
    // 2 input strings
    std::string X = "abadcabadcabadcabadcabadcabadc";
    std::string Y = "adcadcadc";
    // declare timer
    std::chrono::duration<double, std::milli> elapsed_ms;
    // get LCS
    int length = LCS(X, Y, elapsed_ms);
    // output
    printf("Execution Time (ms) %f\n", elapsed_ms.count());
    printf("Length of LCS is %d\n", length);
    return 0;
}
