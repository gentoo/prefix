#!/bin/env bash

# This wrapper just adds the correct EPREFIX paths to the compiler
# and/or linker call.

compiler=$(basename $0)

case "${compiler}" in
*-ld) compiler=parity.gnu.ld@EXEEXT@ ;;
*) compiler=parity.gnu.gcc@EXEEXT@ ;;
esac

link_dirs=()
opts=()
mode=link
orig_args=("$@")

for opt in "$@"; do
 case "$opt" in
  -L)	link_dirs=("${link_dirs[@]}" "-L$1"); shift ;;
  -L*)	link_dirs=("${link_dirs[@]}" "${opt}") ;;
  *)
  	case "${opt}" in
	-v)			mode=version ;;
	-c|-E|-S)	mode=compile ;;
	esac
  	opts=("${opts[@]}" "${opt}")
	;;
 esac
done

if test -n "${EPREFIX}"; then
	pfx_link=("-L${EPREFIX}/lib" "-L${EPREFIX}/usr/lib" "-Wl,-rpath,${EPREFIX}/lib" "-Wl,-rpath,${EPREFIX}/usr/lib")
	pfx_comp=("-I${EPREFIX}/include" "-I${EPREFIX}/usr/include")
fi

case "$mode" in
link) 		exec "${compiler}" "${link_dirs[@]}" "${pfx_link[@]}" "${opts[@]}" ;;
compile)	exec "${compiler}" "${link_dirs[@]}" "${opts[@]}" "${pfx_comp[@]}" ;;
version)	exec "${compiler}" "${orig_args[@]}" ;;
*)			echo "cannot infer $0's mode from comamnd line arguments"; exit 1 ;;
esac
