# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/mysql_fx.eclass,v 1.17 2007/01/04 20:38:16 vivo Exp $
# kate: encoding utf-8; eol unix;
# kate: indent-width 4; mixedindent off; remove-trailing-space on; space-indent off;
# kate: word-wrap-column 80; word-wrap off;

# Author: Francesco Riosa (Retired) <vivo@gentoo.org>
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
	[[ ${lbound} -le ${my_ver} ]] && [[ ${my_ver} -le ${rbound} ]] && return 0
	return 1
}

# true if found at least one appliable range
# 2005-11-19 <vivo at gentoo.org>
_mysql_test_patch_ver_pn() {
	local filesdir="${WORKDIR}/mysql-extras"
	local allelements=", version, package name"

	[[ -d "${filesdir}" ]] || die "sourcedir must be a directory"
	local flags=$1 pname=$2
	if [[ $(( $flags & $(( 1 + 4 + 16 )) )) -eq 21 ]] ; then
		einfo "using \"${pname}\""
		mv "${filesdir}/${pname}" "${EPATCH_SOURCE}" || die "cannot move ${pname}"
		return 0
	fi

	[[ $(( $flags & $(( 2 + 4 )) )) -gt 0 ]] \
	&& allelements="${allelements//", version"}"
	
	[[ $(( $flags & $(( 8 + 16 )) )) -gt 0 ]] \
	&& allelements="${allelements//", package name"}"
	
	[[ -n "${allelements}" ]] && [[ "${flags}" -gt 0 ]] \
	&& ewarn "QA notice ${allelements} missing in ${pname} patch"

	return 1
}

# void mysql_mv_patches(char * index_file, char * filesdir, int my_ver)
#
# parse a "index_file" looking for patches to apply to current
# version.
# If the patch apply then print it's description
# 2005-11-19 <vivo at gentoo.org>
mysql_mv_patches() {
	local index_file="${1:-"${WORKDIR}/mysql-extras/000_index.txt"}"
	local my_ver="${2:-"${MYSQL_VERSION_ID}"}"
	local my_test_fx=${3:-"_mysql_test_patch_ver_pn"}
	local dsc ndsc=0 i
	dsc=( )

	# values for flags are (2^x):
	#  1 - one patch found
	#  2 - at  least one version range is wrong
	#  4 - at  least one version range is _good_
	#  8 - at  least one ${PN} did not match
	#  16 - at  least one ${PN} has been matched
	local flags=0 pname=''
	while read row; do
		case "${row}" in
			@patch\ *)
				[[ -n "${pname}" ]] \
				&& ${my_test_fx} $flags "${pname}" \
				&& for (( i=0 ; $i < $ndsc ; i++ )) ; do einfo ">    ${dsc[$i]}" ; done
				flags=1 ; ndsc=0 ; dsc=( )
				pname=${row#"@patch "}
				;;
			@ver\ *)
				if mysql_check_version_range "${row#"@ver "}" "${my_ver}" ; then
					flags=$(( $flags | 4 ))
				else
					flags=$(( $flags | 2 ))
				fi
				;;
			@pn\ *)
				if [[ ${row#"@pn "} == "${PN}" ]] ; then
					flags=$(( $flags | 16 ))
				else
					flags=$(( $flags | 8 ))
				fi
				;;
			# @use\ *) ;;
			@@\ *)
				dsc[$ndsc]="${row#"@@ "}"
				(( ++ndsc ))
				;;
		esac
	done < "${index_file}"
	${my_test_fx} $flags "${pname}" \
		&& for (( i=0 ; $i < $ndsc ; i++ )) ; do einfo ">    ${dsc[$i]}" ; done
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
# To be called on the live filesystem, reassign symlinks to each mysql
# library to the best version available
# 2005-12-30 <vivo at gentoo.org>
# THERE IS A COPY OF THIS ONE IN ESELECT-MYSQL, keep the two synced
mysql_lib_symlinks() {
	local d dirlist maxdots soname sonameln reldir
	reldir=${1}
	pushd "${EROOT}${reldir}/usr/$(get_libdir)" &> /dev/null
		# dirlist must contain the less significative directory left
		dirlist="mysql $( mysql_make_file_list mysql )"

		# waste some time in removing and recreating symlinks
		for d in $dirlist ; do
			for soname in $( find "${d}" -name "*.so*" -and -not -type "l" 2>/dev/null )
			do
				# maxdot is a limit versus infinite loop
				maxdots=0
				sonameln=${soname##*/}
				# loop in version of the library to link it, similar to the
				# libtool work
				while [[ ${sonameln:0-3} != '.so' ]] && [[ ${maxdots} -lt 6 ]]
				do
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

mysql_clients_link_to_best_version() {
	local other better
	# "include"s and "mysql_config", needed to compile other sw
	for other in "/usr/$(get_libdir)/mysql" "/usr/include/mysql" "/usr/bin/mysql_config" ; do
		pushd "${EROOT}${other%/*}" &> /dev/null
		better=$( mysql_choose_better_version "${other##*/}" )
		if ! [[ -d "${other##*/}" ]] ; then
			[[ -L "${other##*/}" ]] && rm -f "${other##*/}"
			! [[ -f "${other##*/}" ]] && ln -sf "${better}" "${other##*/}"
		else
			[[ -L "${other##*/}" ]] && rm -f "${other##*/}"
			! [[ -d "${other##*/}" ]] && ln -s "${better}" "${other##*/}"
		fi
		popd &> /dev/null
	done
}