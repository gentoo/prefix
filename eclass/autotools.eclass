# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/autotools.eclass,v 1.65 2007/03/04 21:03:59 vapier Exp $
#
# Maintainer: base-system@gentoo.org
#
# This eclass is for handling autotooled software packages that
# needs to regenerate their build scripts.
#
# NB:  If you add anything, please comment it!

inherit eutils libtool

[[ -z ${WANT_AUTOCONF} ]] && WANT_AUTOCONF="latest"
[[ -z ${WANT_AUTOMAKE} ]] && WANT_AUTOMAKE="latest"

_automake_atom="sys-devel/automake"
_autoconf_atom="sys-devel/autoconf"
if [[ -n ${WANT_AUTOMAKE} ]]; then
	case ${WANT_AUTOMAKE} in
		# workaround while we have different versions of automake in arch and ~arch
		none) _automake_atom="" ;; # some packages don't require automake at all
		latest) _automake_atom="=sys-devel/automake-1.10*" ;;
		*) _automake_atom="=sys-devel/automake-${WANT_AUTOMAKE}*" ;;
	esac
	[[ ${WANT_AUTOMAKE} == "latest" ]] && WANT_AUTOMAKE="1.10"
	export WANT_AUTOMAKE
fi

if [[ -n ${WANT_AUTOCONF} ]] ; then
	case ${WANT_AUTOCONF} in
		2.1) _autoconf_atom="=sys-devel/autoconf-${WANT_AUTOCONF}*" ;;
		latest | 2.5) _autoconf_atom=">=sys-devel/autoconf-2.59" ;;
	esac
	[[ ${WANT_AUTOCONF} == "latest" ]] && WANT_AUTOCONF="2.5"
	export WANT_AUTOCONF
fi
DEPEND="${_automake_atom}
	${_autoconf_atom}
	sys-devel/libtool"
RDEPEND=""
unset _automake_atom _autoconf_atom

# Variables:
#
#	AT_M4DIR		  - Additional director(y|ies) aclocal should search
#	AM_OPTS			  - Additional options to pass to automake during
#						eautoreconf call.
#	AT_NOELIBTOOLIZE  - Don't run elibtoolize command if set to 'yes',
#						useful when elibtoolize needs to be ran with
#						particular options

# Functions:
#
#	eautoreconf()  - Should do a full autoreconf - normally what most people
#					 will be interested in.	 Also should handle additional
#					 directories specified by AC_CONFIG_SUBDIRS.
#	eaclocal()	   - Runs aclocal.	Respects AT_M4DIR for additional directories
#					 to search for macro's.
#	_elibtoolize() - Runs libtoolize.  Note the '_' prefix .. to not collide
#					 with elibtoolize() from libtool.eclass
#	eautoconf	   - Runs autoconf.
#	eautoheader	   - Runs autoheader.
#	eautomake	   - Runs automake
#

# XXX: M4DIR should be depreciated
AT_M4DIR=${AT_M4DIR:-${M4DIR}}
AT_GNUCONF_UPDATE="no"


# This function mimes the behavior of autoreconf, but uses the different
# eauto* functions to run the tools. It doesn't accept parameters, but
# the directory with include files can be specified with AT_M4DIR variable.
eautoreconf() {
	local pwd=$(pwd) x auxdir

	if [[ -z ${AT_NO_RECURSIVE} ]]; then
		# Take care of subdirs
		for x in $(autotools_get_subdirs); do
			if [[ -d ${x} ]] ; then
				cd "${x}"
				AT_NOELIBTOOLIZE="yes" eautoreconf
				cd "${pwd}"
			fi
		done
	fi

	auxdir=$(autotools_get_auxdir)

	einfo "Running eautoreconf in '$(pwd)' ..."
	[[ -n ${auxdir} ]] && mkdir -p ${auxdir}
	eaclocal
	_elibtoolize --copy --force
	eautoconf
	eautoheader
	FROM_EAUTORECONF="yes" eautomake ${AM_OPTS}

	[[ ${AT_NOELIBTOOLIZE} == "yes" ]] && return 0

	# Call it here to prevent failures due to elibtoolize called _before_
	# eautoreconf.
	elibtoolize

	return 0
}

# These functions runs the autotools using autotools_run_tool with the
# specified parametes. The name of the tool run is the same of the function
# without e prefix.
# They also force installing the support files for safety.
eaclocal() {
	local aclocal_opts

	if [[ -n ${AT_M4DIR} ]] ; then
		for x in ${AT_M4DIR} ; do
			case "${x}" in
			"-I")
				# We handle it below
				;;
			*)
				[[ ! -d ${x} ]] && ewarn "eaclocal: '${x}' does not exist"
				aclocal_opts="${aclocal_opts} -I ${x}"
				;;
			esac
		done
	fi

	[[ ! -f aclocal.m4 || -n $(grep -e 'generated.*by aclocal' aclocal.m4) ]] && \
		autotools_run_tool aclocal "$@" ${aclocal_opts}
}

_elibtoolize() {
	local opts
	local lttest

	# Check if we should run libtoolize (AM_PROG_LIBTOOL is an older macro,
	# check for both it and the current AC_PROG_LIBTOOL)
	lttest="$(autotools_check_macro "AC_PROG_LIBTOOL")$(autotools_check_macro "AM_PROG_LIBTOOL")"
	[[ -n $lttest ]] || return 0

	[[ -f Makefile.am ]] && opts="--automake"

	[[ "${USERLAND}" == "Darwin" ]] && LIBTOOLIZE="glibtoolize"
	autotools_run_tool ${LIBTOOLIZE:-libtoolize} "$@" ${opts}

	# Need to rerun aclocal
	eaclocal
}

eautoheader() {
	# Check if we should run autoheader
	[[ -n $(autotools_check_macro "AC_CONFIG_HEADERS") ]] || return 0
	NO_FAIL=1 autotools_run_tool autoheader "$@"
}

eautoconf() {
	if [[ ! -f configure.ac && ! -f configure.in ]] ; then
		echo
		eerror "No configure.{ac,in} present in '$(pwd | sed -e 's:.*/::')'!"
		echo
		die "No configure.{ac,in} present!"
	fi

	autotools_run_tool autoconf "$@"
}

eautomake() {
	local extra_opts

	[[ -f Makefile.am ]] || return 0

	if [[ -z ${FROM_EAUTORECONF} && -f Makefile.in ]]; then
		local used_automake
		local installed_automake

		installed_automake=$(automake --version | head -n 1 | \
			sed -e 's:.*(GNU automake) ::')
		used_automake=$(head -n 1 < Makefile.in | \
			sed -e 's:.*by automake \(.*\) from .*:\1:')

		if [[ ${installed_automake} != ${used_automake} ]]; then
			einfo "Automake used for the package (${used_automake}) differs from"
			einfo "the installed version (${installed_automake})."
			eautoreconf
			return 0
		fi
	fi

	[[ -f INSTALL && -f AUTHORS && -f ChangeLog && -f NEWS ]] \
		|| extra_opts="${extra_opts} --foreign"

	# --force-missing seems not to be recognized by some flavours of automake
	autotools_run_tool automake --add-missing --copy ${extra_opts} "$@"
}

# Internal function to run an autotools' tool
autotools_run_tool() {
	local STDERR_TARGET="${T}/$$.out"
	local ris

	echo "***** $1 *****" > ${STDERR_TARGET%/*}/$1-${STDERR_TARGET##*/}
	echo >> ${STDERR_TARGET%/*}/$1-${STDERR_TARGET##*/}

	ebegin "Running $@"
	$@ >> ${STDERR_TARGET%/*}/$1-${STDERR_TARGET##*/} 2>&1
	ris=$?
	eend ${ris}

	if [[ ${ris} != 0 && ${NO_FAIL} != 1 ]]; then
		echo
		eerror "Failed Running $1 !"
		eerror
		eerror "Include in your bugreport the contents of:"
		eerror
		eerror "  ${STDERR_TARGET%/*}/$1-${STDERR_TARGET##*/}"
		echo
		die "Failed Running $1 !"
	fi
}

# Internal function to check for support
autotools_check_macro() {
	[[ -f configure.ac || -f configure.in ]] && \
		WANT_AUTOCONF="2.5" autoconf --trace=$1 2>/dev/null
	return 0
}

# Internal function to get additional subdirs to configure
autotools_get_subdirs() {
	local subdirs_scan_out

	subdirs_scan_out=$(autotools_check_macro "AC_CONFIG_SUBDIRS")
	[[ -n ${subdirs_scan_out} ]] || return 0

	echo "${subdirs_scan_out}" | gawk \
	'($0 !~ /^[[:space:]]*(#|dnl)/) {
		if (match($0, /AC_CONFIG_SUBDIRS:(.*)$/, res))
			print res[1]
	}' | uniq

	return 0
}

autotools_get_auxdir() {
	local auxdir_scan_out

	auxdir_scan_out=$(autotools_check_macro "AC_CONFIG_AUX_DIR")
	[[ -n ${auxdir_scan_out} ]] || return 0

	echo ${auxdir_scan_out} | gawk \
	'($0 !~ /^[[:space:]]*(#|dnl)/) {
		if (match($0, /AC_CONFIG_AUX_DIR:(.*)$/, res))
			print res[1]
	}' | uniq

	return 0
}
