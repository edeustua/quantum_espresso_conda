#!/bin/bash

# Load appropriate modules
# I haven tested this configuration in HPC. You might
# need to change the versions.
module purge
module load gcc/8.3.0
module load openmpi/3.1.2
module load openblas/0.3.6

# Configure the package
# This lets the QE's build system know about the locations of
# the libraries, compilers and other required software so
# QE can be compiled and linked. The --prefix=$HOME/local
# indicates the installation path, such that make install
# installs the compiled binaries in that location
./configure --prefix="$HOME/local"

# Compile QE
# The -j 4 controls the number of processors used to compile
make all -j 4

make install
