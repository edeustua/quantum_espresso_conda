# Quantum-Espresso in central HPC System


## Compile using the provided HPC environments (not tested)
HPC systems usually provide an interface to configure your environment (c.f.
environment variables
[journaldev](https://www.journaldev.com/30868/linux-environment-variables#:~:text=7%20Conclusion-,Introduction,new%20shell%20session%20is%20created.)
and [arch wiki](https://wiki.archlinux.org/index.php/environment_variables)).
In Caltech's HPC, this system is called
[modules](https://modules.readthedocs.io/en/latest/module.html) and allows you
to load the various programs and libraries installed in HPC already. Some of
them are applications, like quantum-espresso (which is available), others are
building tools, like OpenMPI, OpenBLAS, gcc, etc. To list all available modules in HPC use
```
$ module avail
```
If you want to be able to scroll you can use
```
$ module avail 2>&1 | less
```

To compile Quantum Espresso (QE), you just have to download the source and then
load the right modules: a compiler, an MPI library, and a BLAS/Lapack library.
The file `qe_compile.sh` can be used as a reference and can be run in QE's
source directory, for example:
```bash
$ tar zxvf qe-6.6-ReleasePack.tgz
$ cd qe-6.6
$ bash qe_compile.sh
```
Once the compilation is
complete, the same modules need to be loaded to execute the binary as in
`qe_run.sh`. An example SLURM batch script is provided in `qe_example.sb`.

## Compile using anaconda (tested with QE v6.5)
First you need to get anaconda (miniconda is usually preferred, see
[this](https://www.hpc.caltech.edu/documentation/software-and-modules))
```bash
$ wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
$ sh ./Miniconda3-latest-Linux-x86_64.sh
```
Next, activate the base environment and install `conda-build`
```bash
$ conda activate
$ conda install -c conda-forge conda-build
```
Once that is done, copy `qe-conda-recipe` to QE's source folder and build
the conda package
```bash
$ tar zxvf qe-6.5-ReleasePack.tgz
$ cd qe-6.5
$ cp -r ../qe-conda-recipe .
$ cd qe-conda-recipe
$ conda build -c conda-forge .
```
If everything goes well, you should have a local QE conda package. Now
create a new conda environment environment, for example
```bash
$ conda create -n qe -c conda-forge python=3.8
$ conda activate qe
```
and install the compiled local package
```bash
$ conda install -c conda-forge --use-local quantum-espresso
```
If everything worked well, you should have all QE binaries available in your
path.


## Loading the installed Quantum-Espresso binaries
In order to use HPC's Quantum Espresso installation, just load it directly using
```bash
$ module load openblas/0.3.6 lapack/3.8.0 quantum-espresso/6.6
```
This command will load the required libaries, OpenBLAS and Lapack, and the
executables of quantum-espresso. After everything is loaded, you should be able to access
`pw.x`, `pp.x`, etc. on your terminal.

One thing to note is that this version does not appear to have been compiled
with MPI. This means that you wont be able to take advantage of multiple-node
(distributed memory) parllelization. You will only be able to use one node per
calculation using OpenBLAS' multiple threads (shared memory parallelization).
