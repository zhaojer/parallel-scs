#!/bin/bash
# (See https://arc-ts.umich.edu/greatlakes/user-guide/ for command details)

# Set up batch job settings
#SBATCH --job-name=term_project
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=36
#SBATCH --exclusive
#SBATCH --time=00:05:00
#SBATCH --account=eecs587f23_class
#SBATCH --partition=standard

export OMP_NUM_THREADS=16
./parallel_omp_anti_diag_scs input/input-2000.txt > output-parallel-omp-anti-diag-scs-2000-$OMP_NUM_THREADS.txt
./parallel_omp_anti_diag_scs input/input-4000.txt > output-parallel-omp-anti-diag-scs-4000-$OMP_NUM_THREADS.txt
./parallel_omp_anti_diag_scs input/input-6000.txt > output-parallel-omp-anti-diag-scs-6000-$OMP_NUM_THREADS.txt
./parallel_omp_anti_diag_scs input/input-8000.txt > output-parallel-omp-anti-diag-scs-8000-$OMP_NUM_THREADS.txt
./parallel_omp_anti_diag_scs input/input-10000.txt > output-parallel-omp-anti-diag-scs-10000-$OMP_NUM_THREADS.txt
./parallel_omp_anti_diag_scs input/input-20000.txt > output-parallel-omp-anti-diag-scs-20000-$OMP_NUM_THREADS.txt
./parallel_omp_anti_diag_scs input/input-40000.txt > output-parallel-omp-anti-diag-scs-40000-$OMP_NUM_THREADS.txt
