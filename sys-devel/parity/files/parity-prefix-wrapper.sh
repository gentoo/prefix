#!/bin/env bash

# This wrapper just adds the correct EPREFIX paths to the compiler
# and/or linker call.

compiler=$0
exeext=@EXEEXT@

case "${compiler}" in
*-ld) compiler=parity.gnu.ld$exeext ;;
*) compiler=parity.gnu.gcc$exeext ;;
esac

# parity is not very picky about getting options not required for
# the current pass, so give them always.
link_add="-L${EPREFIX}/lib -L${EPREFIX}/usr/lib -rpath ${EPREFIX}/lib -rpath ${EPREFIX}/usr/lib"
comp_add="-I${EPREFIX}/include -I${EPREFIX}/usr/include"

exec $compiler $com_add $link_add "$@"
