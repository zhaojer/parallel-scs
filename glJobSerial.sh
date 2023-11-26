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

./serial_scs input/input-2000.txt > output-serial-scs-2000.txt
./serial_scs input/input-4000.txt > output-serial-scs-4000.txt
./serial_scs input/input-6000.txt > output-serial-scs-6000.txt
./serial_scs input/input-8000.txt > output-serial-scs-8000.txt
./serial_scs input/input-10000.txt > output-serial-scs-10000.txt
./serial_scs input/input-20000.txt > output-serial-scs-20000.txt
./serial_scs input/input-40000.txt > output-serial-scs-40000.txt
./serial_scs input/input-60000.txt > output-serial-scs-60000.txt
