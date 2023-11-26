all: serial_scs parallel_omp_anti_diag_scs parallel_omp_scs parallel_cuda_scs

serial_scs: serial_scs.cpp
	g++ -O3 -o $@ $<

parallel_omp_anti_diag_scs: parallel_omp_anti_diag_scs.cpp
	g++ -std=c++17 -O3 -fopenmp -o $@ $<

parallel_omp_scs: parallel_omp_scs.cpp
	g++ -std=c++17 -O3 -fopenmp -o $@ $<

parallel_cuda_scs: parallel_cuda_scs.cu
	nvcc -o $@ $<

clean:
	rm -f serial_scs
	rm -f parallel_omp_anti_diag_scs
	rm -f parallel_omp_scs
	rm -f parallel_cuda_scs
