# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mysql_fx.eclass,v 1.15 2007/01/01 22:27:01 swegener Exp $

# Author: Francesco Riosa <vivo@gentoo.org>
# Maintainer: Francesco Riosa <vivo@gentoo.org>

ECLASS="mysql_fx"
INHERITED="$INHERITED $ECLASS"
inherit multilib

# Helper function, version (integer) may have sections separated by dots
# for readability
#
stripdots() {
	local dotver=${1:-"0"}
	local v=""
	local ret=0
	if [[ "${dotver/./}" != "${dotver}" ]] ; then
		# dotted version number
		for i in 1000000 10000 100 1 ; do
			v=${dotver%%\.*}
			# remove leading zeroes
			while [[ ${#v} -gt 1 ]] && [[ ${v:0:1} == "0" ]]; do v=${v#0}; done
			# increment integer version number
			ret=$(( ${v} * ${i} + ${ret} ))
			if [[ "${dotver}" == "${dotver/\.}" ]] ; then
				dotver=0
			else
				dotver=${dotver#*\.}
			fi
		done
		echo ${ret}
	else
		# already an integer
		v=${dotver}
		while [[ ${#v} -gt 1 ]] && [[ ${v:0:1} == "0" ]]; do v=${v#0}; done
		echo ${v}
	fi
}

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

# THERE IS A COPY OF THIS ONE IN ESELECT-MYSQL, keep the two synced
# crappy sorting file list per version
mysql_make_file_list() {
	local base="${1}-"
	local n=( )
	echo $( for i in $( ls -d ${1}-[[:digit:]]_[[:digit:]]{,[[:digit:]]}_[[:digit:]]{,[[:digit:]]} 2>/dev/null )
	do
		n=${i#${base}}
		n=( ${n//_/ } )
		# prepend the file name with its numeric version number to make
		# it sortable
		echo "$(( 100000 + ${n[0]} * 10000 + ${n[1]} * 100 + ${n[2]} ))$i"
	# sort and cut the numeric version we added in the previous line
	done | sort | cut -c 7- )
}

# THERE IS A COPY OF THIS ONE IN ESELECT-MYSQL, keep the two synced
mysql_choose_better_version() {
	local better=$(mysql_make_file_list ${1})
	echo ${better##* }
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
