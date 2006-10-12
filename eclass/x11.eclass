# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/x11.eclass,v 1.9 2006/10/11 02:29:29 dberkholz Exp $
#
# Author: Seemant Kulleen <seemant@gentoo.org>
#
# The x11.eclass is designed to ease the checking functions that are
# performed in xorg-x11, xfree and x11-drm ebuilds.  In the new scheme, a
# variable called VIDEO_CARDS will be used to indicate which cards a user
# wishes to build support for.  Note, that this variable is only unlocked if
# the USE variable "expertxfree" is switched on, at least for xfree.

inherit linux-info

vcards() {
	has "$1" ${VIDEO_CARDS} && return 0
	return 1
}

filter-patch() {
	mv ${PATCH_DIR}/"*${1}*" ${PATCH_DIR}/excluded
}

patch_exclude() {
	# Exclude patches matching a pattern if they exist
	for PATCH_GROUP in ${@}
	do
		# Repress errors for non-matching patterns, they're ugly
		for PATCH in $(ls ${PATCHDIR}/${PATCH_GROUP}* 2> /dev/null)
		do
			if [ -a "${PATCH}" ]
			then
				ebegin "  `basename ${PATCH}`"
					mv -f ${PATCH} ${EXCLUDED}
				eend 0
			fi
		done
	done
}


# This is to ease kernel checks for patching and other things. (spyderous)
# Kernel checker is_kernel $1 $2 where $1 is KV_major and $2 is KV_minor.
# is_kernel "2" "4" should map to a 2.4 kernel, etc.
#
# This function is DEPRECATED and should not be used anywhere in ebuilds!
# Use kernel_is() from linux-info.eclas instead!

check_version_h() {
	check_kernel_built
}

get_KV_info() {
	check_version_h
	get_version
	
	# Not used anywhere, leaving here just in case...
	export KV_full="${KV_FULL}"
	export KV_major="${KV_MAJOR}"
	export KV_minor="${KV_MINOR}"
	export KV_micro="${KV_PATCH}"
}

is_kernel() {
	get_KV_info

	ewarn "QA Notice: Please upgrade your ebuild to use kernel_is()"
	ewarn "QA Notice: from linux-info eclass instead."

	if [[ $(type -t kernel_is) == "function" ]] ; then
		kernel_is "$@"
		return $?
	fi
}

# For stripping binaries, but not drivers or modules.
# examples:
# /lib/modules for kernel modules:
# $1=\/lib\/modules
# /usr/X11R6/lib/modules for xfree modules:
# $1=\/usr\/X11R6\/lib\/modules
strip_bins() {
	einfo "Stripping binaries ..."
	# This bit I got from Redhat ... strip binaries and drivers ..
	# NOTE:  We do NOT want to strip the drivers, modules or DRI modules!
	for x in $(find ${D}/ -type f -perm +0111 -exec file {} \; | \
		grep -v ' shared object,' | \
		sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped/\1/p')
	do
	if [ -f ${x} ]
		then
			# Dont do the modules ...
			# need the 'eval echo \' to resolve 2-level variables
			if [ "`eval echo \${x/${1}}`" = "${x}" ]
			then
				echo "`echo ${x} | sed -e "s|${D}||"`"
				strip ${x} || :
			fi
		fi
	done
}

arch() {
	if archq ${1}; then
		echo "${1}"
		return 0
	fi
	return 1
}

archq() {
	local u="${1}"
	local neg=0
	if [ "${u:0:1}" == "!" ]; then
		u="${u:1}"
		neg=1
	fi
	local x
	for x in ${ARCH}; do
		if [ "${x}" == "${u}" ]; then
			if [ ${neg} -eq 1 ]; then
				return 1
			else
				return 0
			fi
		fi
	done
	if [ ${neg} -eq 1 ]; then
		return 0
	else
		return 1
	fi
}

# Function to ease the host.def editing and save lines in the ebuild
use_build() {
	if [ -z "$1" ]; then
		echo "!!! use_build() called without a parameter." >&2
		echo "!!! use_build <USEFLAG> [<flagname> [value]]" >&2
		return
	fi

	local UWORD="$2"
	if [ -z "${UWORD}" ]; then
		UWORD="$1"
		echo $UWORD
	fi

	if useq $1; then
		echo "#define ${UWORD} YES" >> ${HOSTCONF}
		return 0
	else
		echo "#define ${UWORD} NO" >> ${HOSTCONF}
		return 1
	fi
}

