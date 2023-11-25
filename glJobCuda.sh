#!/bin/bash
#SBATCH --job-name=term_project
#SBATCH --mail-type=BEGIN,END
#SBATCH --nodes=1
#SBATCH --gres=gpu:1
#SBATCH --time=00:05:00
#SBATCH --account=eecs587f23_class
#SBATCH --partition=gpu




#make sure to load the cuda module before running
#module load cuda
#make sure to compile your program using nvcc
#nvcc -o example1 example1.cu
./parallel_cuda_scs input/input-2000.txt > output-parallel-cuda-scs-2000.txt
./parallel_cuda_scs input/input-4000.txt > output-parallel-cuda-scs-4000.txt
./parallel_cuda_scs input/input-6000.txt > output-parallel-cuda-scs-6000.txt
./parallel_cuda_scs input/input-8000.txt > output-parallel-cuda-scs-8000.txt
./parallel_cuda_scs input/input-10000.txt > output-parallel-cuda-scs-10000.txt
./parallel_cuda_scs input/input-20000.txt > output-parallel-cuda-scs-20000.txt
./parallel_cuda_scs input/input-40000.txt > output-parallel-cuda-scs-40000.txt
./parallel_cuda_scs input/input-60000.txt > output-parallel-cuda-scs-60000.txt
./parallel_cuda_scs input/input-80000.txt > output-parallel-cuda-scs-80000.txt
./parallel_cuda_scs input/input-100000.txt > output-parallel-cuda-scs-100000.txt
