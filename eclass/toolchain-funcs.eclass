# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/toolchain-funcs.eclass,v 1.100 2010/05/23 02:00:17 vapier Exp $

# @ECLASS: toolchain-funcs.eclass
# @MAINTAINER:
# Toolchain Ninjas <toolchain@gentoo.org>
# @BLURB: functions to query common info about the toolchain
# @DESCRIPTION:
# The toolchain-funcs aims to provide a complete suite of functions
# for gleaning useful information about the toolchain and to simplify
# ugly things like cross-compiling and multilib.  All of this is done
# in such a way that you can rely on the function always returning
# something sane.

___ECLASS_RECUR_TOOLCHAIN_FUNCS="yes"
[[ -z ${___ECLASS_RECUR_MULTILIB} ]] && inherit multilib
inherit prefix

DESCRIPTION="Based on the ${ECLASS} eclass"

tc-getPROG() {
	local var=$1
	local prog=$2

	if [[ -n ${!var} ]] ; then
		echo "${!var}"
		return 0
	fi

	local search=
	[[ -n $3 ]] && search=$(type -p "$3-${prog}")
	[[ -z ${search} && -n ${CHOST} ]] && search=$(type -p "${CHOST}-${prog}")
	[[ -n ${search} ]] && prog=${search##*/}

	export ${var}=${prog}
	echo "${!var}"
}

# @FUNCTION: tc-getAR
# @USAGE: [toolchain prefix]
# @RETURN: name of the archiver
tc-getAR() { tc-getPROG AR ar "$@"; }
# @FUNCTION: tc-getAS
# @USAGE: [toolchain prefix]
# @RETURN: name of the assembler
tc-getAS() { tc-getPROG AS as "$@"; }
# @FUNCTION: tc-getCC
# @USAGE: [toolchain prefix]
# @RETURN: name of the C compiler
tc-getCC() { tc-getPROG CC gcc "$@"; }
# @FUNCTION: tc-getCPP
# @USAGE: [toolchain prefix]
# @RETURN: name of the C preprocessor
tc-getCPP() { tc-getPROG CPP cpp "$@"; }
# @FUNCTION: tc-getCXX
# @USAGE: [toolchain prefix]
# @RETURN: name of the C++ compiler
tc-getCXX() { tc-getPROG CXX g++ "$@"; }
# @FUNCTION: tc-getLD
# @USAGE: [toolchain prefix]
# @RETURN: name of the linker
tc-getLD() { tc-getPROG LD ld "$@"; }
# @FUNCTION: tc-getSTRIP
# @USAGE: [toolchain prefix]
# @RETURN: name of the strip program
tc-getSTRIP() { tc-getPROG STRIP strip "$@"; }
# @FUNCTION: tc-getNM
# @USAGE: [toolchain prefix]
# @RETURN: name of the symbol/object thingy
tc-getNM() { tc-getPROG NM nm "$@"; }
# @FUNCTION: tc-getRANLIB
# @USAGE: [toolchain prefix]
# @RETURN: name of the archiver indexer
tc-getRANLIB() { tc-getPROG RANLIB ranlib "$@"; }
# @FUNCTION: tc-getOBJCOPY
# @USAGE: [toolchain prefix]
# @RETURN: name of the object copier
tc-getOBJCOPY() { tc-getPROG OBJCOPY objcopy "$@"; }
# @FUNCTION: tc-getF77
# @USAGE: [toolchain prefix]
# @RETURN: name of the Fortran 77 compiler
tc-getF77() { tc-getPROG F77 f77 "$@"; }
# @FUNCTION: tc-getFC
# @USAGE: [toolchain prefix]
# @RETURN: name of the Fortran 90 compiler
tc-getFC() { tc-getPROG FC gfortran "$@"; }
# @FUNCTION: tc-getGCJ
# @USAGE: [toolchain prefix]
# @RETURN: name of the java compiler
tc-getGCJ() { tc-getPROG GCJ gcj "$@"; }
# @FUNCTION: tc-getPKG_CONFIG
# @USAGE: [toolchain prefix]
# @RETURN: name of the pkg-config tool
tc-getPKG_CONFIG() { tc-getPROG PKG_CONFIG pkg-config "$@"; }
# @FUNCTION: tc-getRC
# @USAGE: [toolchain prefix]
# @RETURN: name of the Windows resource compiler
tc-getRC() { tc-getPROG RC windres "$@"; }
# @FUNCTION: tc-getDLLWRAP
# @USAGE: [toolchain prefix]
# @RETURN: name of the Windows dllwrap utility
tc-getDLLWRAP() { tc-getPROG DLLWRAP dllwrap "$@"; }

# @FUNCTION: tc-getBUILD_CC
# @USAGE: [toolchain prefix]
# @RETURN: name of the C compiler for building binaries to run on the build machine
tc-getBUILD_CC() {
	local v
	for v in CC_FOR_BUILD BUILD_CC HOSTCC ; do
		if [[ -n ${!v} ]] ; then
			export BUILD_CC=${!v}
			echo "${!v}"
			return 0
		fi
	done

	local search=
	if [[ -n ${CBUILD} ]] ; then
		search=$(type -p ${CBUILD}-gcc)
		search=${search##*/}
	fi
	search=${search:-gcc}

	export BUILD_CC=${search}
	echo "${search}"
}

# @FUNCTION: tc-export
# @USAGE: <list of toolchain variables>
# @DESCRIPTION:
# Quick way to export a bunch of compiler vars at once.
tc-export() {
	local var
	for var in "$@" ; do
		[[ $(type -t tc-get${var}) != "function" ]] && die "tc-export: invalid export variable '${var}'"
		eval tc-get${var} > /dev/null
	done
}

# @FUNCTION: tc-is-cross-compiler
# @RETURN: Shell true if we are using a cross-compiler, shell false otherwise
tc-is-cross-compiler() {
	return $([[ ${CBUILD:-${CHOST}} != ${CHOST} ]])
}

# @FUNCTION: tc-is-softfloat
# @DESCRIPTION:
# See if this toolchain is a softfloat based one.
# @CODE
# The possible return values:
#  - only: the target is always softfloat (never had fpu)
#  - yes:  the target should support softfloat
#  - no:   the target doesn't support softfloat
# @CODE
# This allows us to react differently where packages accept
# softfloat flags in the case where support is optional, but
# rejects softfloat flags where the target always lacks an fpu.
tc-is-softfloat() {
	case ${CTARGET} in
		bfin*|h8300*)
			echo "only" ;;
		*)
			[[ ${CTARGET//_/-} == *-softfloat-* ]] \
				&& echo "yes" \
				|| echo "no"
			;;
	esac
}

# @FUNCTION: tc-is-hardfloat
# @DESCRIPTION:
# See if this toolchain is a hardfloat based one.
# @CODE
# The possible return values:
#  - yes:  the target should support hardfloat
#  - no:   the target doesn't support hardfloat
tc-is-hardfloat() {
	[[ ${CTARGET//_/-} == *-hardfloat-* ]] \
		&& echo "yes" \
		|| echo "no"
}

# @FUNCTION: tc-is-static-only
# @DESCRIPTION:
# Return shell true if the target does not support shared libs, shell false
# otherwise.
tc-is-static-only() {
	local host=${CTARGET:-${CHOST}}

	# *MiNT doesn't have shared libraries, only platform so far
	return $([[ ${host} == *-mint* ]])
}

# @FUNCTION: tc-has-openmp
# @USAGE: [toolchain prefix]
# @DESCRIPTION:
# See if the toolchain supports OpenMP.
tc-has-openmp() {
	local base="${T}/test-tc-openmp"
	cat <<-EOF > "${base}.c"
	#include <omp.h>
	int main() {
		int nthreads, tid, ret = 0;
		#pragma omp parallel private(nthreads, tid)
		{
		tid = omp_get_thread_num();
		nthreads = omp_get_num_threads(); ret += tid + nthreads;
		}
		return ret;
	}
	EOF
	$(tc-getCC "$@") -fopenmp "${base}.c" -o "${base}" >&/dev/null
	local ret=$?
	rm -f "${base}"*
	return ${ret}
}

# @FUNCTION: tc-has-tls
# @USAGE: [-s|-c|-l] [toolchain prefix]
# @DESCRIPTION:
# See if the toolchain supports thread local storage (TLS).  Use -s to test the
# compiler, -c to also test the assembler, and -l to also test the C library
# (the default).
tc-has-tls() {
	local base="${T}/test-tc-tls"
	cat <<-EOF > "${base}.c"
	int foo(int *i) {
		static __thread int j = 0;
		return *i ? j : *i;
	}
	EOF
	local flags
	case $1 in
		-s) flags="-S";;
		-c) flags="-c";;
		-l) ;;
		-*) die "Usage: tc-has-tls [-c|-l] [toolchain prefix]";;
	esac
	: ${flags:=-fPIC -shared -Wl,-z,defs}
	[[ $1 == -* ]] && shift
	$(tc-getCC "$@") ${flags} "${base}.c" -o "${base}" >&/dev/null
	local ret=$?
	rm -f "${base}"*
	return ${ret}
}


# Parse information from CBUILD/CHOST/CTARGET rather than
# use external variables from the profile.
tc-ninja_magic_to_arch() {
ninj() { [[ ${type} == "kern" ]] && echo $1 || echo $2 ; }

	local type=$1
	local host=$2
	[[ -z ${host} ]] && host=${CTARGET:-${CHOST}}

	case ${host} in
		powerpc-apple-darwin*)    echo ppc-macos;;
		powerpc64-apple-darwin*)  echo ppc64-macos;;
		i?86-apple-darwin*)       echo x86-macos;;
		x86_64-apple-darwin*)     echo x64-macos;;
		sparc-sun-solaris*)       echo sparc-solaris;;
		sparcv9-sun-solaris*)     echo sparc64-solaris;;
		i?86-pc-solaris*)         echo x86-solaris;;
		x86_64-pc-solaris*)       echo x64-solaris;;
		powerpc-ibm-aix*)         echo ppc-aix;;
		mips-sgi-irix*)           echo mips-irix;;
		ia64w-hp-hpux*)           echo ia64w-hpux;;
		ia64-hp-hpux*)            echo ia64-hpux;;
		hppa*64*-hp-hpux*)        echo hppa64-hpux;;
		hppa*-hp-hpux*)           echo hppa-hpux;;
		i?86-pc-freebsd*)         echo x86-freebsd;;
		x86_64-pc-freebsd*)       echo x64-freebsd;;
		powerpc-unknown-openbsd*) echo ppc-openbsd;;
		i?86-pc-openbsd*)         echo x86-openbsd;;
		x86_64-pc-openbsd*)       echo x64-openbsd;;
		i?86-pc-netbsd*)          echo x86-netbsd;;
		i?86-pc-interix*)         echo x86-interix;;
		i?86-pc-winnt*)           echo x86-winnt;;

		alpha*)		echo alpha;;
		arm*)		echo arm;;
		avr*)		ninj avr32 avr;;
		bfin*)		ninj blackfin bfin;;
		cris*)		echo cris;;
		hppa*)		ninj parisc hppa;;
		i?86*)
			# Starting with linux-2.6.24, the 'x86_64' and 'i386'
			# trees have been unified into 'x86'.
			# FreeBSD still uses i386
			if [[ ${type} == "kern" ]] && [[ $(KV_to_int ${KV}) -lt $(KV_to_int 2.6.24) || ${host} == *freebsd* ]] ; then
				echo i386
			else
				echo x86
			fi
			;;
		ia64*)		echo ia64;;
		m68*)		echo m68k;;
		mips*)		echo mips;;
		nios2*)		echo nios2;;
		nios*)		echo nios;;
		powerpc*)
					# Starting with linux-2.6.15, the 'ppc' and 'ppc64' trees
					# have been unified into simply 'powerpc', but until 2.6.16,
					# ppc32 is still using ARCH="ppc" as default
					if [[ $(KV_to_int ${KV}) -ge $(KV_to_int 2.6.16) ]] && [[ ${type} == "kern" ]] ; then
						echo powerpc
					elif [[ $(KV_to_int ${KV}) -eq $(KV_to_int 2.6.15) ]] && [[ ${type} == "kern" ]] ; then
						if [[ ${host} == powerpc64* ]] || [[ ${PROFILE_ARCH} == "ppc64" ]] ; then
							echo powerpc
						else
							echo ppc
						fi
					elif [[ ${host} == powerpc64* ]] ; then
						echo ppc64
					elif [[ ${PROFILE_ARCH} == "ppc64" ]] ; then
						ninj ppc64 ppc
					else
						echo ppc
					fi
					;;
		s390*)		echo s390;;
		sh64*)		ninj sh64 sh;;
		sh*)		echo sh;;
		sparc64*)	ninj sparc64 sparc;;
		sparc*)		[[ ${PROFILE_ARCH} == "sparc64" ]] \
						&& ninj sparc64 sparc \
						|| echo sparc
					;;
		vax*)		echo vax;;
		x86_64*)
			# Starting with linux-2.6.24, the 'x86_64' and 'i386'
			# trees have been unified into 'x86'.
			if [[ ${type} == "kern" ]] && [[ $(KV_to_int ${KV}) -ge $(KV_to_int 2.6.24) ]] ; then
				echo x86
			else
				ninj x86_64 amd64
			fi
			;;

		# since our usage of tc-arch is largely concerned with
		# normalizing inputs for testing ${CTARGET}, let's filter
		# other cross targets (mingw and such) into the unknown.
		*)			echo unknown;;
	esac
}
# @FUNCTION: tc-arch-kernel
# @USAGE: [toolchain prefix]
# @RETURN: name of the kernel arch according to the compiler target
tc-arch-kernel() {
	tc-ninja_magic_to_arch kern "$@"
}
# @FUNCTION: tc-arch
# @USAGE: [toolchain prefix]
# @RETURN: name of the portage arch according to the compiler target
tc-arch() {
	tc-ninja_magic_to_arch portage "$@"
}

tc-endian() {
	local host=$1
	[[ -z ${host} ]] && host=${CTARGET:-${CHOST}}
	host=${host%%-*}

	case ${host} in
		alpha*)		echo big;;
		arm*b*)		echo big;;
		arm*)		echo little;;
		cris*)		echo little;;
		hppa*)		echo big;;
		i?86*)		echo little;;
		ia64*)		echo little;;
		m68*)		echo big;;
		mips*l*)	echo little;;
		mips*)		echo big;;
		powerpc*)	echo big;;
		s390*)		echo big;;
		sh*b*)		echo big;;
		sh*)		echo little;;
		sparc*)		echo big;;
		x86_64*)	echo little;;
		*)			echo wtf;;
	esac
}

# @FUNCTION: gcc-fullversion
# @RETURN: compiler version (major.minor.micro: [3.4.6])
gcc-fullversion() {
	$(tc-getCC "$@") -dumpversion
}
# @FUNCTION: gcc-version
# @RETURN: compiler version (major.minor: [3.4].6)
gcc-version() {
	gcc-fullversion "$@" | cut -f1,2 -d.
}
# @FUNCTION: gcc-major-version
# @RETURN: major compiler version (major: [3].4.6)
gcc-major-version() {
	gcc-version "$@" | cut -f1 -d.
}
# @FUNCTION: gcc-minor-version
# @RETURN: minor compiler version (minor: 3.[4].6)
gcc-minor-version() {
	gcc-version "$@" | cut -f2 -d.
}
# @FUNCTION: gcc-micro-version
# @RETURN: micro compiler version (micro: 3.4.[6])
gcc-micro-version() {
	gcc-fullversion "$@" | cut -f3 -d. | cut -f1 -d-
}

# Returns the installation directory - internal toolchain
# function for use by _gcc-specs-exists (for flag-o-matic).
_gcc-install-dir() {
	echo "$(LC_ALL=C $(tc-getCC) -print-search-dirs 2> /dev/null |\
		awk '$1=="install:" {print $2}')"
}
# Returns true if the indicated specs file exists - internal toolchain
# function for use by flag-o-matic.
_gcc-specs-exists() {
	[[ -f $(_gcc-install-dir)/$1 ]]
}

# Returns requested gcc specs directive unprocessed - for used by
# gcc-specs-directive()
# Note; later specs normally overwrite earlier ones; however if a later
# spec starts with '+' then it appends.
# gcc -dumpspecs is parsed first, followed by files listed by "gcc -v"
# as "Reading <file>", in order.  Strictly speaking, if there's a
# $(gcc_install_dir)/specs, the built-in specs aren't read, however by
# the same token anything from 'gcc -dumpspecs' is overridden by
# the contents of $(gcc_install_dir)/specs so the result is the
# same either way.
_gcc-specs-directive_raw() {
	local cc=$(tc-getCC)
	local specfiles=$(LC_ALL=C ${cc} -v 2>&1 | awk '$1=="Reading" {print $NF}')
	${cc} -dumpspecs 2> /dev/null | cat - ${specfiles} | awk -v directive=$1 \
'BEGIN	{ pspec=""; spec=""; outside=1 }
$1=="*"directive":"  { pspec=spec; spec=""; outside=0; next }
	outside || NF==0 || ( substr($1,1,1)=="*" && substr($1,length($1),1)==":" ) { outside=1; next }
	spec=="" && substr($0,1,1)=="+" { spec=pspec " " substr($0,2); next }
	{ spec=spec $0 }
END	{ print spec }'
	return 0
}

# Return the requested gcc specs directive, with all included
# specs expanded.
# Note, it does not check for inclusion loops, which cause it
# to never finish - but such loops are invalid for gcc and we're
# assuming gcc is operational.
gcc-specs-directive() {
	local directive subdname subdirective
	directive="$(_gcc-specs-directive_raw $1)"
	while [[ ${directive} == *%\(*\)* ]]; do
		subdname=${directive/*%\(}
		subdname=${subdname/\)*}
		subdirective="$(_gcc-specs-directive_raw ${subdname})"
		directive="${directive//\%(${subdname})/${subdirective}}"
	done
	echo "${directive}"
	return 0
}

# Returns true if gcc sets relro
gcc-specs-relro() {
	local directive
	directive=$(gcc-specs-directive link_command)
	return $([[ "${directive/\{!norelro:}" != "${directive}" ]])
}
# Returns true if gcc sets now
gcc-specs-now() {
	local directive
	directive=$(gcc-specs-directive link_command)
	return $([[ "${directive/\{!nonow:}" != "${directive}" ]])
}
# Returns true if gcc builds PIEs
gcc-specs-pie() {
	local directive
	directive=$(gcc-specs-directive cc1)
	return $([[ "${directive/\{!nopie:}" != "${directive}" ]])
}
# Returns true if gcc builds with the stack protector
gcc-specs-ssp() {
	local directive
	directive=$(gcc-specs-directive cc1)
	return $([[ "${directive/\{!fno-stack-protector:}" != "${directive}" ]])
}
# Returns true if gcc upgrades fstack-protector to fstack-protector-all
gcc-specs-ssp-to-all() {
	local directive
	directive=$(gcc-specs-directive cc1)
	return $([[ "${directive/\{!fno-stack-protector-all:}" != "${directive}" ]])
}
# Returns true if gcc builds with fno-strict-overflow
gcc-specs-nostrict() {
	local directive
	directive=$(gcc-specs-directive cc1)
	return $([[ "${directive/\{!fstrict-overflow:}" != "${directive}" ]])
}


# @FUNCTION: gen_usr_ldscript
# @USAGE: [-a] <list of libs to create linker scripts for>
# @DESCRIPTION:
# This function generate linker scripts in /usr/lib for dynamic
# libs in /lib.  This is to fix linking problems when you have
# the .so in /lib, and the .a in /usr/lib.  What happens is that
# in some cases when linking dynamic, the .a in /usr/lib is used
# instead of the .so in /lib due to gcc/libtool tweaking ld's
# library search path.  This causes many builds to fail.
# See bug #4411 for more info.
#
# Note that you should in general use the unversioned name of
# the library (libfoo.so), as ldconfig should usually update it
# correctly to point to the latest version of the library present.
gen_usr_ldscript() {
	local lib libdir=$(get_libdir) output_format="" auto=false suffix=$(get_libname)
	[[ -z ${ED+set} ]] && local ED=${D%/}${EPREFIX}/

	tc-is-static-only && return

	# Just make sure it exists
	dodir /usr/${libdir}

	if [[ $1 == "-a" ]] ; then
		auto=true
		shift
		dodir /${libdir}
	fi

	# OUTPUT_FORMAT gives hints to the linker as to what binary format
	# is referenced ... makes multilib saner
	output_format=$($(tc-getCC) ${CFLAGS} ${LDFLAGS} -Wl,--verbose 2>&1 | sed -n 's/^OUTPUT_FORMAT("\([^"]*\)",.*/\1/p')
	[[ -n ${output_format} ]] && output_format="OUTPUT_FORMAT ( ${output_format} )"

	for lib in "$@" ; do
		local tlib
		if ${auto} ; then
			lib="lib${lib}${suffix}"
		else
			# Ensure /lib/${lib} exists to avoid dangling scripts/symlinks.
			# This especially is for AIX where $(get_libname) can return ".a",
			# so /lib/${lib} might be moved to /usr/lib/${lib} (by accident).
			[[ -r ${ED}/${libdir}/${lib} ]] || continue
			#TODO: better die here?
		fi

		case ${CTARGET:-${CHOST}} in
		*-darwin*)
			if ${auto} ; then
				tlib=$(scanmacho -qF'%S#F' "${ED}"/usr/${libdir}/${lib})
			else
				tlib=$(scanmacho -qF'%S#F' "${ED}"/${libdir}/${lib})
			fi
			if [[ -z ${tlib} ]] ; then
				ewarn "gen_usr_ldscript: unable to read install_name from ${lib}"
				tlib=${lib}
			fi
			tlib=${tlib##*/}

			if ${auto} ; then
				mv "${ED}"/usr/${libdir}/${lib%${suffix}}.*${suffix#.} "${ED}"/${libdir}/ || die
				# some install_names are funky: they encode a version
				if [[ ${tlib} != ${lib%${suffix}}.*${suffix#.} ]] ; then
					mv "${ED}"/usr/${libdir}/${tlib%${suffix}}.*${suffix#.} "${ED}"/${libdir}/ || die
				fi
				[[ ${tlib} != ${lib} ]] && rm -f "${ED}"/${libdir}/${lib}
			fi

			# Mach-O files have an id, which is like a soname, it tells how
			# another object linking against this lib should reference it.
			# Since we moved the lib from usr/lib into lib this reference is
			# wrong.  Hence, we update it here.  We don't configure with
			# libdir=/lib because that messes up libtool files.
			# Make sure we don't lose the specific version, so just modify the
			# existing install_name
			if [[ ! -w "${ED}/${libdir}/${tlib}" ]] ; then
				chmod u+w "${ED}${libdir}/${tlib}" # needed to write to it
				local nowrite=yes
			fi
			install_name_tool \
				-id "${EPREFIX}"/${libdir}/${tlib} \
				"${ED}"/${libdir}/${tlib} || die "install_name_tool failed"
			[[ -n ${nowrite} ]] && chmod u-w "${ED}${libdir}/${tlib}"
			# Now as we don't use GNU binutils and our linker doesn't
			# understand linker scripts, just create a symlink.
			pushd "${ED}/usr/${libdir}" > /dev/null
			ln -snf "../../${libdir}/${tlib}" "${lib}"
			popd > /dev/null
			;;
		*-aix*|*-irix*|*64*-hpux*|*-interix*|*-winnt*)
			if ${auto} ; then
				mv "${ED}"/usr/${libdir}/${lib}* "${ED}"/${libdir}/ || die
				# no way to retrieve soname on these platforms (?)
				tlib=$(readlink "${ED}"/${libdir}/${lib})
				tlib=${tlib##*/}
				if [[ -z ${tlib} ]] ; then
					# ok, apparently was not a symlink, don't remove it and
					# just link to it
					tlib=${lib}
				else
					rm -f "${ED}"/${libdir}/${lib}
				fi
			else
				tlib=${lib}
			fi

			# we don't have GNU binutils on these platforms, so we symlink
			# instead, which seems to work fine.  Keep it relative, otherwise
			# we break some QA checks in Portage
			# on interix, the linker scripts would work fine in _most_
			# situations. if a library links to such a linker script the
			# absolute path to the correct library is inserted into the binary,
			# which is wrong, since anybody linking _without_ libtool will miss
			# some dependencies, since the stupid linker cannot find libraries
			# hardcoded with absolute paths (as opposed to the loader, which
			# seems to be able to do this).
			# this has been seen while building shared-mime-info which needs
			# libxml2, but links without libtool (and does not add libz to the
			# command line by itself).
			pushd "${ED}/usr/${libdir}" > /dev/null
			ln -snf "../../${libdir}/${tlib}" "${lib}"
			popd > /dev/null
			;;
		hppa*-hpux*) # PA-RISC 32bit (SOM) only, others (ELF) match *64*-hpux* above.
			if ${auto} ; then
				tlib=$(chatr "${ED}"/usr/${libdir}/${lib} | sed -n '/internal name:/{n;s/^ *//;p;q}')
				[[ -z ${tlib} ]] && tlib=${lib}
				tlib=${tlib##*/} # 'internal name' can have a path component
				mv "${ED}"/usr/${libdir}/${lib}* "${ED}"/${libdir}/ || die
				# some SONAMEs are funky: they encode a version before the .so
				if [[ ${tlib} != ${lib}* ]] ; then
					mv "${ED}"/usr/${libdir}/${tlib}* "${ED}"/${libdir}/ || die
				fi
				[[ ${tlib} != ${lib} ]] &&
				rm -f "${ED}"/${libdir}/${lib}
			else
				tlib=$(chatr "${ED}"/${libdir}/${lib} | sed -n '/internal name:/{n;s/^ *//;p;q}')
				[[ -z ${tlib} ]] && tlib=${lib}
				tlib=${tlib##*/} # 'internal name' can have a path component
			fi
			pushd "${ED}"/usr/${libdir} >/dev/null
			ln -snf "../../${libdir}/${tlib}" "${lib}"
			# need the internal name in usr/lib too, to be available at runtime
			# when linked with /path/to/lib.sl (hardcode_direct_absolute=yes)
			[[ ${tlib} != ${lib} ]] &&
			ln -snf "../../${libdir}/${tlib}" "${tlib}"
			popd >/dev/null
			;;
		*)
			if ${auto} ; then
				tlib=$(scanelf -qF'%S#F' "${ED}"/usr/${libdir}/${lib})
				if [[ -z ${tlib} ]] ; then
					ewarn "gen_usr_ldscript: unable to read SONAME from ${lib}"
					tlib=${lib}
				fi
				mv "${ED}"/usr/${libdir}/${lib}* "${ED}"/${libdir}/ || die
				# some SONAMEs are funky: they encode a version before the .so
				if [[ ${tlib} != ${lib}* ]] ; then
					mv "${ED}"/usr/${libdir}/${tlib}* "${ED}"/${libdir}/ || die
				fi
				[[ ${tlib} != ${lib} ]] && rm -f "${ED}"/${libdir}/${lib}
			else
				tlib=${lib}
			fi
			cat > "${ED}/usr/${libdir}/${lib}" <<-END_LDSCRIPT
			/* GNU ld script
			   Since Gentoo has critical dynamic libraries in /lib, and the static versions
			   in /usr/lib, we need to have a "fake" dynamic lib in /usr/lib, otherwise we
			   run into linking problems.  This "fake" dynamic lib is a linker script that
			   redirects the linker to the real lib.  And yes, this works in the cross-
			   compiling scenario as the sysroot-ed linker will prepend the real path.

			   See bug http://bugs.gentoo.org/4411 for more info.
			 */
			${output_format}
			GROUP ( ${EPREFIX}/${libdir}/${tlib} )
			END_LDSCRIPT
			;;
		esac
		fperms a+x "/usr/${libdir}/${lib}" || die "could not change perms on ${lib}"
	done
}
