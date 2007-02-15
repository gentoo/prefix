# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/toolchain-funcs.eclass,v 1.65 2007/02/12 05:01:09 vapier Exp $
#
# Author: Toolchain Ninjas <toolchain@gentoo.org>
#
# This eclass contains (or should) functions to get common info
# about the toolchain (libc/compiler/binutils/etc...)

inherit multilib

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

# Returns the name of the archiver
tc-getAR() { tc-getPROG AR ar "$@"; }
# Returns the name of the assembler
tc-getAS() { tc-getPROG AS as "$@"; }
# Returns the name of the C compiler
tc-getCC() { tc-getPROG CC gcc "$@"; }
# Returns the name of the C preprocessor
tc-getCPP() { tc-getPROG CPP cpp "$@"; }
# Returns the name of the C++ compiler
tc-getCXX() { tc-getPROG CXX g++ "$@"; }
# Returns the name of the linker
tc-getLD() { tc-getPROG LD ld "$@"; }
# Returns the name of the strip prog
tc-getSTRIP() { tc-getPROG STRIP strip "$@"; }
# Returns the name of the symbol/object thingy
tc-getNM() { tc-getPROG NM nm "$@"; }
# Returns the name of the archiver indexer
tc-getRANLIB() { tc-getPROG RANLIB ranlib "$@"; }
# Returns the name of the fortran 77 compiler
tc-getF77() { tc-getPROG F77 f77 "$@"; }
# Returns the name of the fortran 90 compiler
tc-getF90() { tc-getPROG F90 gfortran "$@"; }
# Returns the name of the fortran compiler
tc-getFORTRAN() { tc-getPROG FORTRAN gfortran "$@"; }
# Returns the name of the java compiler
tc-getGCJ() { tc-getPROG GCJ gcj "$@"; }

# Returns the name of the C compiler for build
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

# Quick way to export a bunch of vars at once
tc-export() {
	local var
	for var in "$@" ; do
		eval tc-get${var} > /dev/null
	done
}

# A simple way to see if we're using a cross-compiler ...
tc-is-cross-compiler() {
	return $([[ ${CBUILD:-${CHOST}} != ${CHOST} ]])
}

# See if this toolchain is a softfloat based one.
# The possible return values:
#  - only: the target is always softfloat (never had fpu)
#  - yes:  the target should support softfloat
#  - no:   the target should support hardfloat
# This allows us to react differently where packages accept
# softfloat flags in the case where support is optional, but
# rejects softfloat flags where the target always lacks an fpu.
tc-is-softfloat() {
	case ${CTARGET} in
		h8300*)
			echo "only" ;;
		*)
			[[ ${CTARGET//_/-} == *-softfloat-* ]] \
				&& echo "yes" \
				|| echo "no"
			;;
	esac
}

# Parse information from CBUILD/CHOST/CTARGET rather than
# use external variables from the profile.
tc-ninja_magic_to_arch() {
ninj() { [[ ${type} == "kern" ]] && echo $1 || echo $2 ; }

	local type=$1
	local host=$2
	[[ -z ${host} ]] && host=${CTARGET:-${CHOST}}

	case ${host} in
		alpha*)		echo alpha;;
		arm*)		echo arm;;
		bfin*)		ninj blackfin bfin;;
		cris*)		echo cris;;
		hppa*)		ninj parisc hppa;;
		i?86*)		ninj i386 x86;;
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
		x86_64*)	ninj x86_64 amd64;;
		*)			echo ${ARCH};;
	esac
}
tc-arch-kernel() {
	tc-ninja_magic_to_arch kern $@
}
tc-arch() {
	tc-ninja_magic_to_arch portage $@
}

# Returns the version as by `$CC -dumpversion`
gcc-fullversion() {
	$(tc-getCC "$@") -dumpversion
}
# Returns the version, but only the <major>.<minor>
gcc-version() {
	gcc-fullversion "$@" | cut -f1,2 -d.
}
# Returns the Major version
gcc-major-version() {
	gcc-version "$@" | cut -f1 -d.
}
# Returns the Minor version
gcc-minor-version() {
	gcc-version "$@" | cut -f2 -d.
}
# Returns the Micro version
gcc-micro-version() {
	gcc-fullversion "$@" | cut -f3 -d. | cut -f1 -d-
}

# Returns requested gcc specs directive
# Note; later specs normally overwrite earlier ones; however if a later
# spec starts with '+' then it appends.
# gcc -dumpspecs is parsed first, followed by files listed by "gcc -v"
# as "Reading <file>", in order.
gcc-specs-directive() {
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

# Returns true if gcc sets relro
gcc-specs-relro() {
	local directive
	directive=$(gcc-specs-directive link_command)
	return $([[ ${directive/\{!norelro:} != ${directive} ]])
}
# Returns true if gcc sets now
gcc-specs-now() {
	local directive
	directive=$(gcc-specs-directive link_command)
	return $([[ ${directive/\{!nonow:} != ${directive} ]])
}
# Returns true if gcc builds PIEs
gcc-specs-pie() {
	local directive
	directive=$(gcc-specs-directive cc1)
	return $([[ ${directive/\{!nopie:} != ${directive} ]])
}
# Returns true if gcc builds with the stack protector
gcc-specs-ssp() {
	local directive
	directive=$(gcc-specs-directive cc1)
	return $([[ ${directive/\{!fno-stack-protector:} != ${directive} ]])
}
# Returns true if gcc upgrades fstack-protector to fstack-protector-all
gcc-specs-ssp-to-all() {
	local directive
	directive=$(gcc-specs-directive cc1)
	return $([[ ${directive/\{!fno-stack-protector-all:} != ${directive} ]])
}


# This function generate linker scripts in /usr/lib for dynamic
# libs in /lib.  This is to fix linking problems when you have
# the .so in /lib, and the .a in /usr/lib.  What happens is that
# in some cases when linking dynamic, the .a in /usr/lib is used
# instead of the .so in /lib due to gcc/libtool tweaking ld's
# library search path.  This cause many builds to fail.
# See bug #4411 for more info.
#
# To use, simply call:
#
#   gen_usr_ldscript libfoo.so
#
# Note that you should in general use the unversioned name of
# the library, as ldconfig should usually update it correctly
# to point to the latest version of the library present.
_tc_gen_usr_ldscript() {
	local lib libdir=$(get_libdir) output_format=""
	# Just make sure it exists
	dodir /usr/${libdir}

	# OUTPUT_FORMAT gives hints to the linker as to what binary format
	# is referenced ... makes multilib saner
	output_format=$($(tc-getCC) ${CFLAGS} ${LDFLAGS} -Wl,--verbose 2>&1 | sed -n 's/^OUTPUT_FORMAT("\([^"]*\)",.*/\1/p')
	[[ -n ${output_format} ]] && output_format="OUTPUT_FORMAT ( ${output_format} )"

	for lib in "$@" ; do
		if [[ ${USERLAND} == "Darwin" ]] ; then
			ewarn "Not creating fake dynamic library for $lib on Darwin;"
			ewarn "making a symlink instead."
			dosym "/${libdir}/${lib}" "/usr/${libdir}/${lib}"
		else
			cat > "${ED}/usr/${libdir}/${lib}" <<-END_LDSCRIPT
			/* GNU ld script
			   Since Gentoo has critical dynamic libraries
			   in /lib, and the static versions in /usr/lib,
			   we need to have a "fake" dynamic lib in /usr/lib,
			   otherwise we run into linking problems.

			   See bug http://bugs.gentoo.org/4411 for more info.
			 */
			${output_format}
			GROUP ( ${EPREFIX}/${libdir}/${lib} )
			END_LDSCRIPT
		fi
		fperms a+x "/usr/${libdir}/${lib}" || die "could not change perms on ${lib}"
	done
}
gen_usr_ldscript() { _tc_gen_usr_ldscript "$@" ; }
