#!/bin/bash

# Load appropriate modules
# I haven tested this configuration in HPC. You might
# need to change the versions.
module purge
module load gcc/8.3.0
module load openmpi/3.1.2
module load openblas/0.3.6

INPUT_FILE=diamond.scf.in
OUTPUT_FILE=diamond.scf.log

mpirun -np 4 pw.x -ni 1 -nk 2 -nd 1 -nb 1 -nt 1 < $INPUT_FILE > $OUTPUT_FILE
