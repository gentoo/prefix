#!/bin/env bash

# This wrapper just adds the correct EPREFIX paths to the compiler
# and/or linker call.

compiler=$0

case "${compiler}" in
*-ld) compiler=parity.gnu.ld@EXEEXT@ ;;
*) compiler=parity.gnu.gcc@EXEEXT@ ;;
esac

# parity is not very picky about getting options not required for
# the current pass, so give them always.
link_add="-L${EPREFIX}/lib -L${EPREFIX}/usr/lib -rpath ${EPREFIX}/lib -rpath ${EPREFIX}/usr/lib"
comp_add="-I${EPREFIX}/include -I${EPREFIX}/usr/include"

# options added at end of command line intentionally, to keep up
# correct search orders for user given paths, and allow overriding
# single files from other directories.
exec $compiler "$@" $comp_add $link_add
