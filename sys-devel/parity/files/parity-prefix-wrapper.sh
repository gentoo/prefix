#!/bin/env bash

# This wrapper just adds the correct EPREFIX paths to the compiler
# and/or linker call.

compiler=$0

case "${compiler}" in
*-ld) compiler=parity.gnu.ld@EXEEXT@ ;;
*) compiler=parity.gnu.gcc@EXEEXT@ ;;
esac

opts=
link_dirs=

while test $# -gt 0; do
	opt=$1

	shift

	case "${opt}" in
	-L)
		dir=$1
		shift

		link_dirs="${link_dirs} -L${dir}"
		;;
	-L*)
		dir=${opt#-L}
		link_dirs="${link_dirs} -L${dir}"
		;;
	*) ;;
	esac

	opts="${opts} ${opt}"
done

# parity is not very picky about getting options not required for
# the current pass, so give them always.
link_add="-L${EPREFIX}/lib -L${EPREFIX}/usr/lib -rpath ${EPREFIX}/lib -rpath ${EPREFIX}/usr/lib"
comp_add="-I${EPREFIX}/include -I${EPREFIX}/usr/include"

# options added at end of command line intentionally, to keep up
# correct search orders for user given paths, and allow overriding
# single files from other directories. Cannot be done with link
# relevant dirs, since library lookup is done in the correct order.
exec $compiler $link_dirs $link_add $opts $comp_add
