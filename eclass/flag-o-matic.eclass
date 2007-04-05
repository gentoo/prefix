# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/flag-o-matic.eclass,v 1.118 2007/03/24 07:07:18 vapier Exp $
#
# Maintainer: toolchain@gentoo.org

# need access to emktemp()
inherit eutils toolchain-funcs multilib

#
#### filter-flags <flags> ####
# Remove particular flags from C[XX]FLAGS
# Matches only complete flags
#
#### append-flags <flags> ####
# Add extra flags to your current C[XX]FLAGS
#
#### replace-flags <orig.flag> <new.flag> ###
# Replace a flag by another one
#
#### replace-cpu-flags <old.cpus> <new.cpu> ###
# Replace march/mcpu flags that specify <old.cpus>
# with flags that specify <new.cpu>
#
#### is-flag[q] <flag> ####
# Returns "true" if flag is set in C[XX]FLAGS
# Matches only complete a flag
# q version sets return code but doesn't echo
#
#### is-ldflag[q] <flag> ####
# Returns "true" if flag is set in LDFLAGS
# Matches only complete a flag
# q version sets return code but doesn't echo
#
#### strip-flags ####
# Strip C[XX]FLAGS of everything except known
# good options.
#
#### strip-unsupported-flags ####
# Strip C[XX]FLAGS of any flags not supported by
# installed version of gcc
#
#### get-flag <flag> ####
# Find and echo the value for a particular flag
#
#### replace-sparc64-flags ####
# Sets mcpu to v8 and uses the original value
# as mtune if none specified.
#
#### filter-mfpmath <math types> ####
# Remove specified math types from the fpmath specification
# If the user has -mfpmath=sse,386, running `filter-mfpmath sse`
# will leave the user with -mfpmath=386
#
#### append-ldflags ####
# Add extra flags to your current LDFLAGS
#
#### filter-ldflags <flags> ####
# Remove particular flags from LDFLAGS
# Matches only complete flags
#
#### bindnow-flags ####
# Returns the flags to enable "now" binding in the current selected linker.
#
################ DEPRECATED functions ################
# The following are still present to avoid breaking existing
# code more than necessary; however they are deprecated. Please
# use gcc-specs-* from toolchain-funcs.eclass instead, if you
# need to know which hardened techs are active in the compiler.
# See bug #100974
#
#### has_hardened ####
# Returns true if the compiler has 'Hardened' in its version string,
# (note; switched-spec vanilla compilers satisfy this condition) or
# the specs file name contains 'hardened'.
#
#### has_pie ####
# Returns true if the compiler by default or with current CFLAGS
# builds position-independent code.
#
#### has_pic ####
# Returns true if the compiler by default or with current CFLAGS
# builds position-independent code.
#
#### has_ssp_all ####
# Returns true if the compiler by default or with current CFLAGS
# generates stack smash protections for all functions
#
#### has_ssp ####
# Returns true if the compiler by default or with current CFLAGS
# generates stack smash protections for most vulnerable functions
#

# C[XX]FLAGS that we allow in strip-flags
# Note: shell globs and character lists are allowed
setup-allowed-flags() {
	if [[ -z ${ALLOWED_FLAGS} ]] ; then
		export ALLOWED_FLAGS="-pipe"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -O -O0 -O1 -O2 -mcpu -march -mtune"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -fstack-protector -fstack-protector-all"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -fbounds-checking -fno-bounds-checking"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -fno-PIE -fno-pie -fno-unit-at-a-time"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -g -g[0-9] -ggdb -ggdb[0-9] -gstabs -gstabs+"
		export ALLOWED_FLAGS="${ALLOWED_FLAGS} -fno-ident"
	fi
	# allow a bunch of flags that negate features / control ABI
	ALLOWED_FLAGS="${ALLOWED_FLAGS} -fno-stack-protector -fno-stack-protector-all"
	ALLOWED_FLAGS="${ALLOWED_FLAGS} -mregparm -mno-app-regs -mapp-regs \
		-mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-3dnow \
		-mips1 -mips2 -mips3 -mips4 -mips32 -mips64 -mips16 \
		-msoft-float -mno-soft-float -mhard-float -mno-hard-float -mfpu \
		-mieee -mieee-with-inexact -mschedule \
		-mtls-direct-seg-refs -mno-tls-direct-seg-refs \
		-mflat -mno-flat -mno-faster-structs -mfaster-structs \
		-m32 -m64 -mabi -mlittle-endian -mbig-endian -EL -EB -fPIC \
		-mlive-g0 -mcmodel -mstack-bias -mno-stack-bias \
		-msecure-plt -D*"

	# C[XX]FLAGS that we are think is ok, but needs testing
	# NOTE:  currently -Os have issues with gcc3 and K6* arch's
	export UNSTABLE_FLAGS="-Os -O3 -freorder-blocks"
	return 0
}

# inverted filters for hardened compiler.  This is trying to unpick
# the hardened compiler defaults.
_filter-hardened() {
	local f
	for f in "$@" ; do
		case "${f}" in
			# Ideally we should only concern ourselves with PIE flags,
			# not -fPIC or -fpic, but too many places filter -fPIC without
			# thinking about -fPIE.
			-fPIC|-fpic|-fPIE|-fpie|-Wl,pie|-pie)
				gcc-specs-pie || continue
				is-flagq -nopie || append-flags -nopie;;
			-fstack-protector)
				gcc-specs-ssp || continue
				is-flagq -fno-stack-protector || append-flags -fno-stack-protector;;
			-fstack-protector-all)
				gcc-specs-ssp-to-all || continue
				is-flagq -fno-stack-protector-all || append-flags -fno-stack-protector-all;;
		esac
	done
}

# Remove occurrences of strings from variable given in $1
# Strings removed are matched as globs, so for example
# '-O*' would remove -O1, -O2 etc.
_filter-var() {
	local f x VAR VAL
	declare -a new

	VAR=$1
	shift
	eval VAL=\${${VAR}}
	for f in ${VAL}; do
		for x in "$@"; do
			# Note this should work with globs like -O*
			[[ ${f} == ${x} ]] && continue 2
		done
		eval new\[\${\#new\[@]}]=\${f}
	done
	eval export ${VAR}=\${new\[*]}
}

filter-flags() {
	_filter-hardened "$@"
	_filter-var CFLAGS "$@"
	_filter-var CPPFLAGS "$@"
	_filter-var CXXFLAGS "$@"
	return 0
}

filter-lfs-flags() {
	[[ -n $@ ]] && die "filter-lfs-flags takes no arguments"
	filter-flags -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
}

append-cppflags() {
	[[ -z $* ]] && return 0
	export CPPFLAGS="${CPPFLAGS} $*"
	return 0
}

append-lfs-flags() {
	[[ -n $@ ]] && die "append-lfs-flags takes no arguments"
	append-cppflags -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE
}

append-flags() {
	[[ -z $* ]] && return 0
	export CFLAGS="${CFLAGS} $*"
	export CXXFLAGS="${CXXFLAGS} $*"
	return 0
}

replace-flags() {
	[[ $# != 2 ]] \
		&& echo && eerror "Usage: replace-flags <old flag> <new flag>" \
		&& die "replace-flags takes 2 arguments, not $#"

	local f fset
	declare -a new_CFLAGS new_CXXFLAGS

	for fset in CFLAGS CXXFLAGS; do
		# Looping over the flags instead of using a global
		# substitution ensures that we're working with flag atoms.
		# Otherwise globs like -O* have the potential to wipe out the
		# list of flags.
		for f in ${!fset}; do
			# Note this should work with globs like -O*
			[[ ${f} == ${1} ]] && f=${2}
			eval new_${fset}\[\${\#new_${fset}\[@]}]=\${f}
		done
		eval export ${fset}=\${new_${fset}\[*]}
	done

	return 0
}

replace-cpu-flags() {
	local newcpu="$#" ; newcpu="${!newcpu}"
	while [ $# -gt 1 ] ; do
		# quote to make sure that no globbing is done (particularly on
		# ${oldcpu}) prior to calling replace-flags
		replace-flags "-march=${1}" "-march=${newcpu}"
		replace-flags "-mcpu=${1}" "-mcpu=${newcpu}"
		replace-flags "-mtune=${1}" "-mtune=${newcpu}"
		shift
	done
	return 0
}

_is_flagq() {
	local x
	for x in ${!1} ; do
		[[ ${x} == $2 ]] && return 0
	done
	return 1
}

is-flagq() {
	[[ -n $2 ]] && die "Usage: is-flag <flag>"
	_is_flagq CFLAGS $1 || _is_flagq CXXFLAGS $1
}

is-flag() {
	is-flagq "$@" && echo true
}

is-ldflagq() {
	[[ -n $2 ]] && die "Usage: is-ldflag <flag>"
	_is_flagq LDFLAGS $1
}

is-ldflag() {
	is-ldflagq "$@" && echo true
}

filter-mfpmath() {
	local orig_mfpmath new_math prune_math

	# save the original -mfpmath flag
	orig_mfpmath=$(get-flag -mfpmath)
	# get the value of the current -mfpmath flag
	new_math=$(get-flag mfpmath)
	new_math=" ${new_math//,/ } "
	# figure out which math values are to be removed
	prune_math=""
	for prune_math in "$@" ; do
		new_math=${new_math/ ${prune_math} / }
	done
	new_math=$(echo ${new_math})
	new_math=${new_math// /,}

	if [[ -z ${new_math} ]] ; then
		# if we're removing all user specified math values are
		# slated for removal, then we just filter the flag
		filter-flags ${orig_mfpmath}
	else
		# if we only want to filter some of the user specified
		# math values, then we replace the current flag
		replace-flags ${orig_mfpmath} -mfpmath=${new_math}
	fi
	return 0
}

strip-flags() {
	local x y flag NEW_CFLAGS NEW_CXXFLAGS

	setup-allowed-flags

	local NEW_CFLAGS=""
	local NEW_CXXFLAGS=""

	# Allow unstable C[XX]FLAGS if we are using unstable profile ...
	if has ~$(tc-arch) ${ACCEPT_KEYWORDS} ; then
		ALLOWED_FLAGS="${ALLOWED_FLAGS} ${UNSTABLE_FLAGS}"
	fi

	set -f	# disable pathname expansion

	for x in ${CFLAGS}; do
		for y in ${ALLOWED_FLAGS}; do
			flag=${x%%=*}
			if [ "${flag%%${y}}" = "" ] ; then
				NEW_CFLAGS="${NEW_CFLAGS} ${x}"
				break
			fi
		done
	done

	for x in ${CXXFLAGS}; do
		for y in ${ALLOWED_FLAGS}; do
			flag=${x%%=*}
			if [ "${flag%%${y}}" = "" ] ; then
				NEW_CXXFLAGS="${NEW_CXXFLAGS} ${x}"
				break
			fi
		done
	done

	# In case we filtered out all optimization flags fallback to -O2
	if [ "${CFLAGS/-O}" != "${CFLAGS}" -a "${NEW_CFLAGS/-O}" = "${NEW_CFLAGS}" ]; then
		NEW_CFLAGS="${NEW_CFLAGS} -O2"
	fi
	if [ "${CXXFLAGS/-O}" != "${CXXFLAGS}" -a "${NEW_CXXFLAGS/-O}" = "${NEW_CXXFLAGS}" ]; then
		NEW_CXXFLAGS="${NEW_CXXFLAGS} -O2"
	fi

	set +f	# re-enable pathname expansion

	export CFLAGS="${NEW_CFLAGS}"
	export CXXFLAGS="${NEW_CXXFLAGS}"
	return 0
}

test-flag-PROG() {
	local comp=$1
	local flags="$2"

	[[ -z ${comp} || -z ${flags} ]] && \
		return 1

	local PROG=$(tc-get${comp})
	${PROG} ${flags} -S -o /dev/null -xc /dev/null \
		> /dev/null 2>&1
}

# Returns true if C compiler support given flag
test-flag-CC() { test-flag-PROG "CC" "$1"; }

# Returns true if C++ compiler support given flag
test-flag-CXX() { test-flag-PROG "CXX" "$1"; }

test-flags-PROG() {
	local comp=$1
	local flags
	local x

	shift

	[[ -z ${comp} ]] && return 1

	x=""
	for x in "$@" ; do
		test-flag-${comp} "${x}" && flags="${flags}${flags:+ }${x}"
	done

	echo "${flags}"

	# Just bail if we dont have any flags
	[[ -n ${flags} ]]
}

# Returns (echo's) the given flags supported by the C compiler
test-flags-CC() { test-flags-PROG "CC" "$@"; }

# Returns (echo's) the given flags supported by the C++ compiler
test-flags-CXX() { test-flags-PROG "CXX" "$@"; }

# Short-hand that should hopefully work for both C and C++ compiler, but
# its really only present due to the append-flags() abomination.
test-flags() { test-flags-CC "$@"; }

# Depriciated, use test-flags()
test_flag() {
	ewarn "test_flag: deprecated, please use test-flags()!" >&2

	test-flags-CC "$@"
}

test_version_info() {
	if [[ $($(tc-getCC) --version 2>&1) == *$1* ]]; then
		return 0
	else
		return 1
	fi
}

strip-unsupported-flags() {
	export CFLAGS=$(test-flags-CC ${CFLAGS})
	export CXXFLAGS=$(test-flags-CXX ${CXXFLAGS})
}

get-flag() {
	local f findflag="$1"

	# this code looks a little flaky but seems to work for
	# everything we want ...
	# for example, if CFLAGS="-march=i686":
	# `get-flag -march` == "-march=i686"
	# `get-flag march` == "i686"
	for f in ${CFLAGS} ${CXXFLAGS} ; do
		if [ "${f/${findflag}}" != "${f}" ] ; then
			printf "%s\n" "${f/-${findflag}=}"
			return 0
		fi
	done
	return 1
}

# DEPRECATED - use gcc-specs-relro or gcc-specs-now from toolchain-funcs
has_hardened() {
	ewarn "has_hardened: deprecated, please use gcc-specs-{relro,now}()!" >&2

	test_version_info Hardened && return 0
	# The specs file wont exist unless gcc has GCC_SPECS support
	[[ -f ${GCC_SPECS} && ${GCC_SPECS} != ${GCC_SPECS/hardened/} ]]
}

# DEPRECATED - use gcc-specs-pie from toolchain-funcs
# indicate whether PIC is set
has_pic() {
	ewarn "has_pic: deprecated, please use gcc-specs-pie()!" >&2

	[[ ${CFLAGS/-fPIC} != ${CFLAGS} || \
	   ${CFLAGS/-fpic} != ${CFLAGS} ]] || \
	gcc-specs-pie
}

# DEPRECATED - use gcc-specs-pie from toolchain-funcs
# indicate whether PIE is set
has_pie() {
	ewarn "has_pie: deprecated, please use gcc-specs-pie()!" >&2

	[[ ${CFLAGS/-fPIE} != ${CFLAGS} || \
	   ${CFLAGS/-fpie} != ${CFLAGS} ]] || \
	gcc-specs-pie
}

# DEPRECATED - use gcc-specs-ssp from toolchain-funcs
# indicate whether code for SSP is being generated for all functions
has_ssp_all() {
	ewarn "has_ssp_all: deprecated, please use gcc-specs-ssp()!" >&2

	# note; this matches only -fstack-protector-all
	[[ ${CFLAGS/-fstack-protector-all} != ${CFLAGS} || \
	   -n $(echo | $(tc-getCC) ${CFLAGS} -E -dM - | grep __SSP_ALL__) ]] || \
	gcc-specs-ssp-all
}

# DEPRECATED - use gcc-specs-ssp from toolchain-funcs
# indicate whether code for SSP is being generated
has_ssp() {
	ewarn "has_ssp: deprecated, please use gcc-specs-ssp()!" >&2

	# note; this matches both -fstack-protector and -fstack-protector-all
	[[ ${CFLAGS/-fstack-protector} != ${CFLAGS} || \
	   -n $(echo | $(tc-getCC) ${CFLAGS} -E -dM - | grep __SSP__) ]] || \
	gcc-specs-ssp
}

has_m64() {
	# this doesnt test if the flag is accepted, it tests if the flag
	# actually -WORKS-. non-multilib gcc will take both -m32 and -m64!
	# please dont replace this function with test_flag in some future
	# clean-up!

	local temp="$(emktemp)"
	echo "int main() { return(0); }" > "${temp}".c
	MY_CC=$(tc-getCC)
	${MY_CC/ .*/} -m64 -o "$(emktemp)" "${temp}".c > /dev/null 2>&1
	local ret=$?
	rm -f "${temp}".c
	[[ ${ret} != 1 ]] && return 0
	return 1
}

has_m32() {
	# this doesnt test if the flag is accepted, it tests if the flag
	# actually -WORKS-. non-multilib gcc will take both -m32 and -m64!
	# please dont replace this function with test_flag in some future
	# clean-up!

	[ "$(tc-arch)" = "amd64" ] && has_multilib_profile && return 0

	local temp=$(emktemp)
	echo "int main() { return(0); }" > "${temp}".c
	MY_CC=$(tc-getCC)
	${MY_CC/ .*/} -m32 -o "$(emktemp)" "${temp}".c > /dev/null 2>&1
	local ret=$?
	rm -f "${temp}".c
	[[ ${ret} != 1 ]] && return 0
	return 1
}

replace-sparc64-flags() {
	local SPARC64_CPUS="ultrasparc3 ultrasparc v9"

	if [ "${CFLAGS/mtune}" != "${CFLAGS}" ]; then
		for x in ${SPARC64_CPUS}; do
			CFLAGS="${CFLAGS/-mcpu=${x}/-mcpu=v8}"
		done
	else
		for x in ${SPARC64_CPUS}; do
			CFLAGS="${CFLAGS/-mcpu=${x}/-mcpu=v8 -mtune=${x}}"
		done
	fi

	if [ "${CXXFLAGS/mtune}" != "${CXXFLAGS}" ]; then
		for x in ${SPARC64_CPUS}; do
			CXXFLAGS="${CXXFLAGS/-mcpu=${x}/-mcpu=v8}"
		done
	else
		for x in ${SPARC64_CPUS}; do
			CXXFLAGS="${CXXFLAGS/-mcpu=${x}/-mcpu=v8 -mtune=${x}}"
		done
	fi

	export CFLAGS CXXFLAGS
}

append-ldflags() {
	[[ -z $* ]] && return 0
	export LDFLAGS="${LDFLAGS} $*"
	return 0
}

# Remove flags from LDFLAGS - it's up to the ebuild to filter
# CFLAGS and CXXFLAGS via filter-flags if they need to.
filter-ldflags() {
	_filter-var LDFLAGS "$@"
	return 0
}

# Turn C style ldflags (-Wl,-foo) into straight ldflags - the results
# are suitable for passing directly to 'ld'; note LDFLAGS is usually passed
# to gcc where it needs the '-Wl,'.
raw-ldflags() {
	local x input="$@"
	[[ -z ${input} ]] && input=${LDFLAGS}
	set --
	for x in ${input} ; do
		x=${x#-Wl,}
		set -- "$@" ${x//,/ }
	done
	echo "$@"
}

# Gets the flags needed for "NOW" binding
bindnow-flags() {
	case $($(tc-getLD) -v 2>&1 </dev/null) in
	*GNU* | *'with BFD'*) # GNU ld
		echo "-Wl,-z,now" ;;
	*Apple*) # Darwin ld
		echo "-bind_at_load" ;;
	*)
		# Some linkers just recognize -V instead of -v
		case $($(tc-getLD) -V 2>&1 </dev/null) in
			*Solaris*) # Solaris accept almost the same GNU options
				echo "-Wl,-z,now" ;;
		esac
		;;
	esac
}


# Some tests for when we screw with things and want to make
# sure we didn't break anything
#TESTS() {
#	CFLAGS="-a -b -c=1"
#	CXXFLAGS="-x -y -z=2"
#	LDFLAGS="-l -m -n=3"
#
#	die() { exit 1; }
#	(is-flag 1 2 3) && die
#	(is-ldflag 1 2 3) && die
#
#	is-flagq -l && die
#	is-ldflagq -a && die
#	is-flagq -a || die
#	is-flagq -x || die
#	is-ldflagq -n=* || die
#	is-ldflagq -n && die
#
#	strip-unsupported-flags
#	[[ ${CFLAGS} == "-c=1" ]] || die
#	[[ ${CXXFLAGS} == "-y -z=2" ]] || die
#
#	echo "All tests pass"
#}
#TESTS
