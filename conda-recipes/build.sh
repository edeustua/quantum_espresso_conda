# Exit if errors occur
set -e

# Fix issue with gfortran naming
ln -s $BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran $BUILD_PREFIX/bin/x86_64-conda-linux-gnu-gfortran

# Setting up environmental variables
# These are required to make sure QE loads what is in
# miniconda and not something in the system
export FC=$CONDA_PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran
export FCFLAGS=" -m64 -I$CONDA_PREFIX/include -fopenmp"
export CPPFLAGS=" -I$CONDA_PREFIX/include -I$CONDA_PREFIX/include/fftw $CPPFLAGS"

export LDFLAGS=" -fopenmp -L$CONDA_PREFIX/lib $LDFLAGS"
export LD="$CONDA_PREFIX/bin/mpif90"
export LIBDIRS="$CONDA_PREFIX/lib"


# Enter source directory
cd $SRC_DIR

# Configure with MKL
./configure \
    BLAS_LIBS="-L$CONDA_PREFIX/lib -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl" \
    LAPACK_LIBS="-L$CONDA_PREFIX/lib -Wl,--no-as-needed -lmkl_gf_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl" \
    --prefix=$PREFIX

# Fix some issues in the resulting make.inc file
escaped_prefix=$(echo $BUILD_PREFIX | sed 's/\//\\\//g')
sed -i "/^MPIF90 \+=/c\MPIF90         = $CONDA_PREFIX/bin/mpif90" $SRC_DIR/make.inc
sed -i "/^F90 \+=/c\F90         = $CONDA_PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran" $SRC_DIR/make.inc
sed -i "/^F77 \+=/c\F77         = $CONDA_PREFIX/bin/x86_64-conda_cos6-linux-gnu-gfortran" $SRC_DIR/make.inc
sed -i -e "/^IFLAGS/s/$/ -I$escaped_prefix\/include\/fftw/" $SRC_DIR/make.inc
sed -i 's/D__FFTW3/D__DFTI/' $SRC_DIR/make.inc
sed -i 's/-lfftw3//' $SRC_DIR/make.inc


# Make all modules and install in conda build system
make all -j4
make install
