serial_lcs: serial_lcs.cpp
	g++ -O3 -o $@ $<

parallel_omp_lcs: parallel_omp_lcs.cpp
	g++ -std=c++17 -O3 -fopenmp -o parallel_omp_lcs parallel_omp_lcs.cpp

serial_scs: serial_scs.cpp
	g++ -O3 -o $@ $<

clean:
	rm -f serial_lcs
	rm -f serial_scs
	rm -f parallel_omp_lcs
