# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/pax-utils.eclass,v 1.3 2006/11/24 15:11:55 kevquinn Exp $

# Author:
#	Kevin F. Quinn <kevquinn@gentoo.org>
#
# This eclass provides support for manipulating PaX markings on ELF
# binaries, wrapping the use of the chpax and paxctl utilities.

inherit eutils

##### pax-mark ####
# Mark a file for PaX, with the provided flags, and log it into
# a PaX database.  Returns non-zero if flag marking failed.
#
# If paxctl is installed, but not chpax, then the legacy
# EI flags (which are not strip-safe) will not be set.
# If neither are installed, falls back to scanelf (which
# is always present, but currently doesn't quite do all
# that paxctl can do).
_pax_list_files() {
	local m cmd
	m=$1 ; shift
	for f in $*; do
		${cmd} "  ${f}"
	done
}

pax-mark() {
	local f flags fail=0 failures=""
	flags=${1//-}
	shift
	if [[ -x /sbin/chpax ]]; then
		einfo "Legacy EI PaX marking -${flags}"
		_pax_list_files echo $*
		for f in $*; do
			/sbin/chpax -${flags} ${f} && continue
			fail=1
			failures="${failures} ${f}"
		done
	fi
	if [[ -x /sbin/paxctl ]]; then
		einfo "PT PaX marking -${flags}"
		_pax_list_files echo $*
		for f in $*; do
			/sbin/paxctl -q${flags} ${f} && continue
			/sbin/paxctl -qc${flags} ${f} && continue
			/sbin/paxctl -qC${flags} ${f} && continue
			fail=1
			failures="${failures} ${f}"
		done
	elif [[ -x /usr/bin/scanelf ]]; then
		einfo "Fallback PaX marking -${flags}"
		_pax_list_files echo $*
		/usr/bin/scanelf -Xxz ${flags} $*
	else
		failures="$*"
		fail=1
	fi
	if [[ ${fail} == 1 ]]; then
		ewarn "Failed to set PaX markings -${flags} for:"
		_pax_list_files ewarn ${failures}
		ewarn "Executables may be killed by PaX kernels."
	fi
	return ${fail}
}

##### host-is-pax
# Indicates whether the build machine has PaX or not; intended for use
# where the build process must be modified conditionally in order to satisfy PaX.
host-is-pax() {
	# We need procfs to work this out.  PaX is only available on Linux,
	# so result is always false on non-linux machines (e.g. Gentoo/*BSD)
	[[ -e /proc/self/status ]] || return 1
	grep ^PaX: /proc/self/status > /dev/null
	return $?
}
