# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/pax-utils.eclass,v 1.6 2007/04/24 18:27:11 kevquinn Exp $

# Author:
#	Kevin F. Quinn <kevquinn@gentoo.org>
#
# This eclass provides support for manipulating PaX markings on ELF
# binaries, wrapping the use of the chpaxi, paxctl and scanelf utilities.
# Currently it decides which to use depending on what is installed on the
# build host; this may change in the future to use a control variable
# (which would also mean modifying DEPEND to bring in sys-apps/paxctl etc).
#
#
# CONTROL
# -------
#
# To control what markings are set, assign PAX_MARKINGS in
# /etc/make.conf to contain the strings "EI" and/or "PT".
# If EI is present in PAX_MARKINGS (and the chpax utility
# is present), the legacy 'chpax' style markings will be
# set.  If PT is present in PAX_MARKINGS (and the paxctl
# utility is present), the 'paxctl' markings will be set.
# Default is to try to do both.  Set it to "NONE" to prevent
# any markings being made.
#
#
# PROVIDED FUNCTIONS
# ------------------
#
#### pax-mark <flags> {<ELF files>}
# Marks files <files> with provided PaX flags <flags>
#
# Please confirm any relaxation of restrictions with the
# Gentoo Hardened team; either ask on the gentoo-hardened
# mailing list, or CC/assign hardened@g.o on a bug.
#
# Flags are passed directly to the utilities unchanged.  Possible
# flags at the time of writing, taken from /sbin/paxctl, are:
#
#	p: disable PAGEEXEC		P: enable PAGEEXEC
#	e: disable EMUTRMAP		E: enable EMUTRMAP
#	m: disable MPROTECT		M: enable MPROTECT
#	r: disable RANDMMAP		R: enable RANDMMAP
#	s: disable SEGMEXEC		S: enable SEGMEXEC
#
# Default flags are 'PeMRS', which are the most restrictive
# settings.  Refer to http://pax.grsecurity.net/ for details
# on what these flags are all about.  There is an obsolete
# flag 'x'/'X' which has been removed from PaX.
#
# If chpax is not installed, the legacy EI flags (which are
# not strip-safe, and strictly speaking violate the ELF spec)
# will not be set.  If paxctl is not installed, it falls back
# to scanelf.  scanelf is always present, but currently doesn't
# quite do all that paxctl can do.
# Returns fail if one or more files could not be marked.
#
#
#### list-paxables {<files>}
# Prints to stdout all of <files> that are suitable to having PaX
# flags (i.e. filter to just ELF files).  Useful for passing wild-card
# lists of files to pax-mark, although in general it is preferable
# for ebuilds to list precisely which executables are to be marked.
# Use like:
#     pax-mark -m $(list-paxables ${S}/{,usr/}bin/*)
#
#
#### host-is-pax
# Returns true if the host has a PaX-enabled kernel, false otherwise.
# Intended for use where the build process must be modified conditionally
# in order to satisfy PaX.  Note; it is _not_ intended to indicate
# whether the final executables should satisfy PaX - executables should
# always be marked appropriately even if they're only going to be
# installed on a non-PaX system.

inherit eutils

# Default to both EI and PT markings.
PAX_MARKINGS=${PAX_MARKINGS:="EI PT"}

# pax-mark <flags> {<ELF files>}
pax-mark() {
	local f flags fail=0 failures="" zero_load_alignment
	# Ignore '-' characters - in particular so that it doesn't matter if
	# the caller prefixes with -
	flags=${1//-}
	shift
	# Try chpax, for (deprecated) EI legacy marking.
	if type -p chpax > /dev/null && hasq EI ${PAX_MARKINGS}; then
		einfo "Legacy EI PaX marking -${flags}"
		_pax_list_files elog "$@"
		for f in "$@"; do
			chpax -${flags} "${f}" && continue
			fail=1
			failures="${failures} ${f}"
		done
	fi
	# Try paxctl, then scanelf - paxctl takes precedence
	# over scanelf.
	if type -p paxctl > /dev/null && hasq PT ${PAX_MARKINGS}; then
		# Try paxctl, the upstream supported tool.
		einfo "PT PaX marking -${flags}"
		_pax_list_files elog "$@"
		for f in "$@"; do
			# First, try modifying the existing PAX_FLAGS header
			paxctl -q${flags} "${f}" && continue
			# Second, try stealing the (unused under PaX) PT_GNU_STACK header
			paxctl -qc${flags} "${f}" && continue
			# Third, try pulling the base down a page, to create space and
			# insert a PT_GNU_STACK header (works on ET_EXEC)
			paxctl -qC${flags} "${f}" && continue
			# Fourth - check if it loads to 0 (probably an ET_DYN) and if so,
			# try rebasing with prelink first to give paxctl some space to
			# grow downwards into.
			if type -p objdump > /dev/null && type -p prelink > /dev/null; then
				zero_load_alignment=$(objdump -p "${f}" | \
					grep -E '^[[:space:]]*LOAD[[:space:]]*off[[:space:]]*0x0+[[:space:]]' | \
					sed -e 's/.*align\(.*\)/\1/')
				if [[ ${zero_load_alignment} != "" ]]; then
					prelink -r $(( 2*(${zero_load_alignment}) )) &&
					paxctl -qC${flags} "${f}" && continue
				fi
			fi
			fail=1
			failures="${failures} ${f}"
		done
	elif type -p scanelf > /dev/null && [[ ${PAX_MARKINGS} != "none" ]]; then
		# Try scanelf, the Gentoo swiss-army knife ELF utility
		# Currently this sets EI and PT if it can, no option to
		# control what it does.
		einfo "Fallback PaX marking -${flags}"
		_pax_list_files elog "$@"
		scanelf -Xxz ${flags} "$@"
	elif [[ ${PAX_MARKINGS} != "none" ]]; then
		# Out of options!
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

# list-paxables {<files>}
list-paxables() {
	file "$@" 2> /dev/null | grep -E 'ELF.*(executable|shared object)' | sed -e 's/: .*$//'
}

# host-is-pax
# Note: if procfs is not on /proc, this returns False (e.g. Gentoo/FBSD).
host-is-pax() {
	grep -qs ^PaX: /proc/self/status
}


# INTERNAL FUNCTIONS
# ------------------
#
# These functions are for use internally by the eclass - do not use
# them elsewhere as they are not supported (i.e. they may be removed
# or their function may change arbitratily).

# Display a list of things, one per line, indented a bit, using the
# display command in $1.
_pax_list_files() {
	local f cmd
	cmd=$1
	shift
	for f in "$@"; do
		${cmd} "     ${f}"
	done
}

