# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mysql_fx.eclass,v 1.13 2006/05/05 19:49:43 chtekk Exp $

# Author: Francesco Riosa <vivo@gentoo.org>
# Maintainer: Francesco Riosa <vivo@gentoo.org>

inherit multilib

# Helper function, version (integer) may have sections separated by dots
# for readability
#
stripdots() {
	local dotver=${1:-"0"}
	while [[ "${dotver/./}" != "${dotver}" ]] ; do dotver="${dotver/./}" ; done
	echo "${dotver:-"0"}"
}

# bool mysql_check_version_range(char * range, int ver=MYSQL_VERSION_ID, int die_on_err=MYSQL_DIE_ON_RANGE_ERROR)
#
# Check if a version number falls inside a given range.
# The range includes the extremes and must be specified as
# "low_version to high_version" i.e. "4.00.00.00 to 5.01.99.99"
# Return true if inside the range
# 2005-11-19 <vivo@gentoo.org>
#
mysql_check_version_range() {
	local lbound="${1%% to *}" ; lbound=$(stripdots "${lbound}")
	local rbound="${1#* to }"  ; rbound=$(stripdots "${rbound}")
	local my_ver="${2:-"${MYSQL_VERSION_ID}"}"
	[[ ${lbound} -le ${my_ver} && ${my_ver} -le ${rbound} ]] && return 0
	return 1
}

# * char mysql_strip_double_slash()
#
# Strip double slashes from passed argument.
# 2005-11-19 <vivo@gentoo.org>
#
mysql_strip_double_slash() {
	local path="${1}"
	local newpath="${path/\/\///}"
	while [[ "${path}" != "${newpath}" ]] ; do
		path="${newpath}"
		newpath="${path/\/\///}"
	done
	echo "${newpath}"
}

# Is $2 (defaults to $MYSQL_VERSION_ID) at least version $1?
# (nice) idea from versionator.eclass
#
mysql_version_is_at_least() {
	local want_s=$(stripdots "$1") have_s=$(stripdots "${2:-${MYSQL_VERSION_ID}}")
	[[ -z "${want_s}" ]] && die "mysql_version_is_at_least missing value to check"
	[[ ${want_s} -le ${have_s} ]] && return 0 || return 1
}

# void mysql_lib_symlinks()
#
# To be called on the live filesystem, reassigning symlinks of each MySQL
# library to the best version available.
# 2005-12-30 <vivo@gentoo.org>
#
mysql_lib_symlinks() {
	local d dirlist maxdots soname sonameln other better
	pushd "${ROOT}/usr/$(get_libdir)" &> /dev/null

	# dirlist must contain the less significative directory left
	dirlist="mysql"

	# waste some time in removing and recreating symlinks
	for d in $dirlist ; do
		for soname in $(find "${d}" -name "*.so*" -and -not -type "l") ; do
			# maxdot is a limit versus infinite loop
			maxdots=0
			sonameln=${soname##*/}
			# loop in version of the library to link it, similar to how
			# libtool works
			while [[ ${sonameln:0-3} != '.so' ]] && [[ ${maxdots} -lt 6 ]] ; do
				rm -f "${sonameln}"
				ln -s "${soname}" "${sonameln}"
				(( ++maxdots ))
				sonameln="${sonameln%.*}"
			done
			rm -f "${sonameln}"
			ln -s "${soname}" "${sonameln}"
		done
	done

	popd &> /dev/null
}
