#include <omp.h>
#include <algorithm>
#include <string>

int test_omp() {
    int count = 0;
#pragma omp parallel 
{
    #pragma omp single
    printf("Number of threads in use: %d\n", omp_get_num_threads());
    int local_count = 0;
	// printf("Number of threads: %d\n", omp_get_num_threads());
    #pragma omp for
    for (int i = 0; i < 10000; i++) {
        // no need to protect this count since each thread have its own local count
        // this local count shows how many times each thread executes the for loop
        ++local_count;
        // need to protect modifying shared variable
        #pragma omp atomic
        ++count;
    }
    printf("Thread %d local count: %d\n", omp_get_thread_num(), local_count);
}
printf("Total count: %d\n", count);
    return 0;
}

// Anti diagonal implementation of LCS
int lcs_anti_diagonal(const std::string &x, const std::string &y) {
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
		// #pragma omp parallel for num_threads(4)
		#pragma omp parallel for
		for (int k = 0; k <= diagonal_len; ++k)
		{
            // index of the diagonal elements
            // a corresponds to row, increases by 1 each time
            // b corresponds to col, decreases by 1 each time
			int a = i + k, b = j - k;
            // base case
			if (a == 0 || b == 0)
				tab[a][b] = 0;
            // case 1
			else if (x[a - 1] == y[b - 1])
				tab[a][b] = tab[a - 1][b - 1] + 1;
            // case 2
			else
				tab[a][b] = std::max(tab[a - 1][b], tab[a][b - 1]);
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
    // 2 input strings
    std::string X = "fqgigtdvxtzrqpbsludswuqegzplqvlxlufupirmdrfvigntcsoyoedueuhwpvtcryygiqvnhaiphxklpykedpajlihafaewadcitxvcyfthcdsteczjtauekbgrblndqrljpinppgyrlqmpvmaoouvaxbryoedevopmycdnibgusvlphofxiaxgeoguukzraoebthqdjzzduludbzajcxrinachkbamsepnogqzfqezdycezepbdhjqhoztpzhjgxwwdpxkfblkzpqytfcwonovbpqtqyeyxducsrmzuzjtobujgyhvnxspmlkclodirxmjraklzvhpwdyfdfaqcuhqhrusgxczxoloovbprkepncuqjwhnrqdaiatqzxpwmamcyourayioddgmzpcsgftohoehlvdzyseyiypiwxwbcfocuqwcxpqhfworutsslwqtwhcvgawjhmnccjecbxlgvzzpusjgqzbnifkpigyptntxwabz";
    std::string Y = "zjhmfhigrwixadchsfsklutefmxpvvaxejlmstsjrdirikzartncngisuhkqckphvatotnzkqieyudbmyoqluzfogrgldvszvlnqaobrwhrtmshkixveycthubsxzkyuxllzaoqyvkthcatlaorasmhoobonnmjmawmckcahowqtwjgyzxzukgiyiwnvlwiltunfypnplfikroiqljmvqvtatgxgfhrydgdeystlybvrpghapwyhtrjmahvhqmfuvkatdtgdweulkdnbzllsfuhhdcouqvqlfqgilnlhrhudlhgkvrfcomlrobngwfsbxamipzpghllsvseqljuzxhtniiugqojnovygxpmebaywueofokhlrcbbkvhcjqqzoqflfuriwreqvuxleezxgaytvhvganhodpbjlurhlyxgsuszbtwjtxcqeywelfuruvafptmct";

    // explicitly enable dynamic teams
    omp_set_dynamic(true);

    int lcs_length = lcs_anti_diagonal(X, Y);
    printf("Length of LCS is %d\n", lcs_length);

    return 0;
}
