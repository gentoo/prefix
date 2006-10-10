# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/kernel-mod.eclass,v 1.15 2006/02/28 03:05:35 vapier Exp $

# !!!!!!!!!!
#
# BEWARE: DO NOT USE. THIS ECLASS IS DEPRECATED AND BROKEN. DO NOT USE.
# Use linux-mod.eclass and/or linux-info.eclass instead. --brix
#
# !!!!!!!!!!

# This eclass provides help for compiling external kernel modules from
# source.
#
# This eclass differs from kmod.eclass because it doesn't require modules
# to be added to the kernel source tree first.

DESCRIPTION="Based on the $ECLASS eclass"

SRC_URI="${SRC_URI:-unknown - please fix me!!}"
KERNEL_DIR="${KERNEL_DIR:-/usr/src/linux}"

kernel-mod_getmakefilevar() {
	grep $1 $2 | head -n 1 | cut -d = -f 2- | awk '{ print $1 }'
}

kernel-mod_getversion() {
	# yes, this is horrible, but it is effective
	#
	# KV_DIR contains the real directory name of the directory containing
	# the Linux kernel that we are going to compile against

	if [ -h ${KERNEL_DIR} ] ; then
		einfo "${KERNEL_DIR} is a symbolic link"
		einfo "Determining the real directory of the Linux kernel source code"
		KV_DIR="`ls -ld --full-time ${KERNEL_DIR} | awk '{ print $11 }'`"
	elif [ -d ${KERNEL_DIR} ] ; then
		einfo "${KERNEL_DIR} is a real directory"
		KV_DIR="`ls -ld --full-time ${KERNEL_DIR} | awk '{ print $9 }'`"
	else
		eerror "Directory '${KERNEL_DIR}' cannot be found"
		die
	fi
	KV_DIR="`basename $KV_DIR`"

	# now, we need to break that down into versions

	KV_DIR_VERSION_FULL="`echo $KV_DIR | cut -f 2- -d -`"

	KV_DIR_MAJOR="`echo $KV_DIR_VERSION_FULL | cut -f 1 -d .`"
	KV_DIR_MINOR="`echo $KV_DIR_VERSION_FULL | cut -f 2 -d .`"
	KV_DIR_PATCH="`echo $KV_DIR_VERSION_FULL | cut -f 3 -d . | cut -f 3 -d -`"
	KV_DIR_TYPE="`echo $KV_DIR_VERSION_FULL | cut -f 2- -d -`"

	# sanity check - do the settings in the kernel's makefile match
	# the directory that the kernel src is stored in?

	KV_MK_FILE="${KERNEL_DIR}/Makefile"
	KV_MK_MAJOR="`kernel-mod_getmakefilevar VERSION $KV_MK_FILE`"
	KV_MK_MINOR="`kernel-mod_getmakefilevar PATCHLEVEL $KV_MK_FILE`"
	KV_MK_PATCH="`kernel-mod_getmakefilevar SUBLEVEL $KV_MK_FILE`"
	KV_MK_TYPE="`kernel-mod_getmakefilevar EXTRAVERSION $KV_MK_FILE`"

	KV_MK_VERSION_FULL="$KV_MK_MAJOR.$KV_MK_MINOR.$KV_MK_PATCH$KV_MK_TYPE"

	if [ "$KV_MK_VERSION_FULL" != "$KV_DIR_VERSION_FULL" ]; then
		ewarn
		ewarn "The kernel Makefile says that this is a $KV_MK_VERSION_FULL kernel"
		ewarn "but the source is in a directory for a $KV_DIR_VERSION_FULL kernel."
		ewarn
		ewarn "This goes against the recommended Gentoo naming convention."
		ewarn "Please rename your source directory to 'linux-${KV_MK_VERSION_FULL}'"
		ewarn
	fi

	# these variables can be used by ebuilds to determine whether they
	# will work with the targetted kernel or not
	#
	# do not rely on any of the variables above being available

	KV_VERSION_FULL="$KV_MK_VERSION_FULL"
	KV_MAJOR="$KV_MK_MAJOR"
	KV_MINOR="$KV_MK_MINOR"
	KV_PATCH="$KV_MK_PATCH"
	KV_TYPE="$KV_MK_TYPE"

	einfo "Building for Linux ${KV_VERSION_FULL} found in ${KERNEL_DIR}"
}

kernel-mod_configoption_present() {
	[ -e "${KERNEL_DIR}/.config" ] || die "kernel has not been configured yet"

	if egrep "^CONFIG_${1}=[ym]" ${ROOT}/usr/src/linux/.config >/dev/null
	then
		return 0
	else
		return -1
	fi
}

kernel-mod_configoption_module() {
	[ -e "${KERNEL_DIR}/.config" ] || die "kernel has not been configured yet"

	if egrep "^CONFIG_${1}=[m]" ${ROOT}/usr/src/linux/.config >/dev/null
	then
		return 0
	else
		return -1
	fi
}

kernel-mod_configoption_builtin() {
	[ -e "${KERNEL_DIR}/.config" ] || die "kernel has not been configured yet"

	if egrep "^CONFIG_${1}=[y]" ${ROOT}/usr/src/linux/.config >/dev/null
	then
		return 0
	else
		return -1
	fi
}

kernel-mod_modules_supported() {
	kernel-mod_configoption_builtin "MODULES"
}

kernel-mod_check_modules_supported() {
	if ! kernel-mod_modules_supported
	then
		eerror "Your current kernel does not support loading external modules."
		eerror "Please enable \"Loadable module support\" (CONFIG_MODULES) in your kernel config."
		die "kernel does not support loading modules"
	fi
}

kernel-mod_checkzlibinflate_configured() {
	einfo "Checking for status of CONFIG_ZLIB_INFLATE support in your kernel"

	. ${KERNEL_DIR}/.config || die "kernel has not been configured yet"
	[ "$CONFIG_ZLIB_INFLATE" != "y" ] && kernel-mod_badconfig_zlib
	[ "$CONFIG_ZLIB_DEFLATE" != "y" ] && kernel-mod_badconfig_zlib

	# bug #27882 - zlib routines are only linked into the kernel
	# if something compiled into the kernel calls them
	#
	# plus, for the cloop module, it appears that there's no way
	# to get cloop.o to include a static zlib if CONFIG_MODVERSIONS
	# is on

	# get the line numbers of the lines that default CONFIG_ZLIB_INFLATE
	# to 'y'

	local LINENO_START
	local LINENO_END
	local SYMBOLS
	local x

	LINENO_END="`grep -n 'CONFIG_ZLIB_INFLATE y' ${KERNEL_DIR}/lib/Config.in | cut -d : -f 1`"
	LINENO_START="`head -n $LINENO_END ${KERNEL_DIR}/lib/Config.in | grep -n 'if \[' | tail -n 1 | cut -d : -f 1`"
	(( LINENO_AMOUNT = $LINENO_END - $LINENO_START ))
	(( LINENO_END = $LINENO_END - 1 ))

	SYMBOLS="`head -n $LINENO_END ${KERNEL_DIR}/lib/Config.in | tail -n $LINENO_AMOUNT | sed -e 's/^.*\(CONFIG_[^\" ]*\).*/\1/g;'`"

	# okay, now we have a list of symbols
	# we need to check each one in turn, to see whether it is set or not

	for x in $SYMBOLS ; do
		if [ "${!x}" = "y" ]; then
			# we have a winner!
			einfo "${x} ensures zlib is linked into your kernel - excellent"
			return 0
		fi
	done

	# if we get to here, the kernel config needs changing
	#
	# I have made this an error, because otherwise this warning will
	# scroll off the top of the screen and be lost

	eerror
	eerror "This kernel module requires ZLIB library support."
	eerror "You have enabled zlib support in your kernel, but haven't enabled"
	eerror "enabled any option that will ensure that zlib is linked into your"
	eerror "kernel."
	eerror
	eerror "Please ensure that you enable at least one of these options:"
	eerror

	for x in $SYMBOLS ; do
		eerror "  * $x"
	done

	eerror
	eerror "Please remember to recompile and install your kernel, and reboot"
	eerror "into your new kernel before attempting to load this kernel module."

	die "Kernel doesn't include zlib support"
}

kernel-mod_src_compile() {
	emake KERNEL_DIR=${KERNEL_DIR} || die
}

kernel-mod_is_2_4_kernel() {
	kernel-mod_getversion

	if [ "${KV_MAJOR}" -eq 2 -a "${KV_MINOR}" -eq 4 ]
	then
		return 0
	else
		return 1
	fi
}

kernel-mod_is_2_5_kernel() {
	kernel-mod_getversion

	if [ "${KV_MAJOR}" -eq 2 -a "${KV_MINOR}" -eq 5 ]
	then
		return 0
	else
		return 1
	fi
}

kernel-mod_is_2_6_kernel() {
	kernel-mod_getversion

	if [ "${KV_MAJOR}" -eq 2 -a "${KV_MINOR}" -eq 6 ]
	then
		return 0
	else
		return 1
	fi
}

EXPORT_FUNCTIONS src_compile
