# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/kmod.eclass,v 1.19 2006/02/28 03:05:59 vapier Exp $

# !!!!!!!!!!
#
# BEWARE: DO NOT USE. THIS ECLASS IS DEPRECATED AND BROKEN. DO NOT USE.
# Use linux-mod.eclass and/or linux-info.eclass instead. --brix
#
# !!!!!!!!!!

# This eclass provides help for compiling external kernel modules from
# source.
#
# BEWARE: This eclass is superceding the old kmod.eclass. It does *not*
# implement the same functionality as the old kmod.eclass!

# DOCUMENTATION: Most documentation for this can be found at:
# http://www.gentoo.org/doc/en/2.6-koutput.xml
#
# More documentation comments will follow in the header of this soon!

# Variables you can use to change behavior
#
# KMOD_SOURCES - space seperated list of source to unpack in
#					   src_unpack() if you don't want ${A} unpacked.
#
# KMOD_KOUTPUT_PATCH - Patch to apply in src_unpack() if a seperate output
#							directory is detected.
#

inherit eutils

S=${WORKDIR}/${P}
DESCRIPTION="Based on the $ECLASS eclass"

SRC_URI="${SRC_URI:-unknown - please fix me!!}"
KERNEL_DIR="${KERNEL_DIR:-${ROOT}/usr/src/linux}"

EXPORT_FUNCTIONS src_unpack src_compile pkg_postinst

kmod_get_make_var ()
{
	grep "^${1}" ${2} | head -n 1 | grep -v ":=" | cut -d = -f 2- \
		| awk '{ print $1 }'
}

# getconfigvar() - Prints the value of a certain config varaible from the
#				current kernel's config file. Will return "n" for an unset
#				option

kmod_get_config_var()
{
	local configopt="CONFIG_${1}"
	local configresult

	if [ -z ${KV_OUTPUT} ]; then
		get_kernel_info
	fi

	configresult="`grep ^$configopt ${KV_OUTPUT}/.config | cut -d= -f 2-`"
	if [ -z "${configresult}" ]; then
		echo "n"
	else
		echo ${configresult} | awk '{ print $1 }'
	fi
}

# get_kernel_info is used to get our build environment. It initializes several
# variables that can be used in ebuilds
#
# KV_MAJOR, KV_MINOR, KV_PATCH - the kernel major, minor, and pathlevel #'s
# KV_TYPE - the type, as found from EXTRAVERSION.
#
# KV_VERSION_FULL - full string for the kernel version
#
# KV_OUTPUT - the output direcotry if used with a 2.6 kernel
#
# KV_OBJ - extension for kernel objects, "o" for 2.4 kernels and "ko" for 2.6
#
get_kernel_info()
{
	# yes, this is horrible, but it is effective
	#
	# KV_DIR contains the real directory name of the directory containing
	# the Linux kernel that we are going to compile against

	if [ -h ${KERNEL_DIR} ] ; then
		einfo "`echo ${KERNEL_DIR} | tr -s /` is a symbolic link"
		einfo "Determining the real directory of the Linux kernel source code"
		KV_DIR="`readlink ${KERNEL_DIR}`"
	elif [ -d ${KERNEL_DIR} ] ; then
		einfo "`echo ${KERNEL_DIR} | tr -s /` is a real directory"
		KV_DIR="`ls -d ${KERNEL_DIR}`"
		# KV_DIR="`ls -ld --full-time ${KERNEL_DIR} | awk '{ print $9 }'`"
	else
		eerror "Directory '${KERNEL_DIR}' cannot be found"
		die
	fi
	KV_DIR="`basename ${KV_DIR}`"

	# now, we need to break that down into versions

	KV_DIR_VERSION_FULL="`echo $KV_DIR | cut -f 2- -d -`"

	KV_DIR_MAJOR="`echo ${KV_DIR_VERSION_FULL} | cut -f 1 -d .`"
	KV_DIR_MINOR="`echo ${KV_DIR_VERSION_FULL} | cut -f 2 -d .`"
	KV_DIR_PATCH="`echo ${KV_DIR_VERSION_FULL} | cut -f 3 -d . | cut -f 1 -d -`"
	KV_DIR_TYPE="`echo ${KV_DIR_VERSION_FULL} | cut -f 2- -d -`"

	# sanity check - do the settings in the kernel's makefile match
	# the directory that the kernel src is stored in?

	KV_MK_FILE="${KERNEL_DIR}/Makefile"
	KV_MK_MAJOR="`kmod_get_make_var VERSION ${KV_MK_FILE}`"
	KV_MK_MINOR="`kmod_get_make_var PATCHLEVEL ${KV_MK_FILE}`"
	KV_MK_PATCH="`kmod_get_make_var SUBLEVEL ${KV_MK_FILE}`"
	KV_MK_TYPE="`kmod_get_make_var EXTRAVERSION ${KV_MK_FILE}`"

	KV_MK_VERSION_FULL="${KV_MK_MAJOR}.${KV_MK_MINOR}.${KV_MK_PATCH}${KV_MK_TYPE}"

	KV_MK_OUTPUT="`kmod_get_make_var KBUILD_OUTPUT ${KV_MK_FILE}`"

	# May need to deal with a dynamically set KBUILD_OUTPUT variable
	if [ "${KV_MK_OUTPUT/VERSION/}" != "${KV_MK_OUTPUT}" ]; then
		KV_MK_OUTPUT="${KV_MK_OUTPUT/\$(VERSION)/${KV_MK_MAJOR}}"
		KV_MK_OUTPUT="${KV_MK_OUTPUT/\$(PATCHLEVEL)/${KV_MK_MINOR}}"
		KV_MK_OUTPUT="${KV_MK_OUTPUT/\$(SUBLEVEL)/${KV_MK_PATCH}}"
		KV_MK_OUTPUT="${KV_MK_OUTPUT/\$(EXTRAVERSION)/${KV_MK_TYPE}}"
	fi

	if [ "$KV_MK_VERSION_FULL" != "${KV_DIR_VERSION_FULL}" ]; then
		ewarn
		ewarn "The kernel Makefile says that this is a ${KV_MK_VERSION_FULL} kernel"
		ewarn "but the source is in a directory for a ${KV_DIR_VERSION_FULL} kernel."
		ewarn
		ewarn "This goes against the recommended Gentoo naming convention."
		ewarn "Please rename your source directory to 'linux-${KV_MK_VERSION_FULL}'"
		ewarn
	fi

	# these variables can be used by ebuilds to determine whether they
	# will work with the targetted kernel or not
	#
	# do not rely on any of the variables above being available

	KV_VERSION_FULL="${KV_MK_VERSION_FULL}"
	KV_MAJOR="${KV_MK_MAJOR}"
	KV_MINOR="${KV_MK_MINOR}"
	KV_PATCH="${KV_MK_PATCH}"
	KV_TYPE="${KV_MK_TYPE}"

	# if we found an output location, use that. otherwise use KERNEL_DIR.
	if [ ! -z "${KV_MK_OUTPUT}" ]
	then
		KV_OUTPUT="${ROOT}/${KV_MK_OUTPUT}"
	else
		KV_OUTPUT="${KERNEL_DIR}"
	fi

	# KV_OBJ can be used when manually installing kernel modules
	if [ "${KV_MINOR}" -gt "4" ]
	then
		KV_OBJ="ko"
	else
		KV_OBJ="o"
	fi

	einfo "Building for Linux ${KV_VERSION_FULL} found in `echo ${KERNEL_DIR} | tr -s /`"

	if is_kernel 2 5 || is_kernel 2 6
	then
		einfo "which outputs to `echo ${KV_OUTPUT} | tr -s /`"

		# Warn them if they aren't using a different output directory
		if [ "${KV_OUTPUT}" = "${ROOT}/usr/src/linux" ]; then
			ewarn "By not using the kernel's ability to output to an alternative"
			ewarn "directory, some external module builds may fail."
			ewarn "See <insert link to user doc here>"
		fi
	fi
}

# kmod_make_linux_writeable() is used to allow portage to write to
# /usr/src/linux. This is a BIG no-no, but the "easiest" way for
# 2.6 module compilation. Since it's so horrible, we force users to accept
# doing it via a variable controlled by /etc/env.d/20kernel and kernel-config

kmod_make_linux_writable()
{
	# LINUX_PORTAGE_WRITABLE is set in /etc/env.d/20kernel to "yes"
	# if someone really wants to do that
	[ -x ${ROOT}/usr/bin/config-kernel ] && LINUX_PORTAGE_WRITABLE="$(${ROOT}/usr/bin/config-kernel --is-writable)"

	if [ "${LINUX_PORTAGE_WRITABLE}" != "yes" ]
	then
		if [ "${FEATURES/sandbox/}" != "${FEATURES}" ]
		then
			eerror "Due to the 2.6 kernel build system, external module compilation"
			eerror "with a normal setup requires write access to ${KERNEL_DIR}"
			eerror "There are several ways to fix/prevent this."
			eerror "Users can willingly let portage make this writable by doing"
			eerror "# config-kernel --allow-writable yes"
			eerror "However, this is considered a security risk!"
			eerror ""
			eerror "The prefered method is to enable Gentoo's new 'koutput' method"
			eerror "for kernel modules. See the doc"
			eerror "http://www.gentoo.org/doc/en/2.6-koutput-user.xml"
			eerror "To enable this, you'll need to run"
			eerror "# config-kernel --output-dir /var/tmp/kernel-output"
			eerror "and then install a new kernel"
			die "Incompatible kernel setup"
		else
			ewarn "Detected sandbox disabled for kernel module ebuild"
		fi
	fi

	eerror "Making ${ROOT}/usr/src/linux-${KV} writable by portage!!!"
	addwrite ${ROOT}/usr/src/linux-${KV}
}


# kmod_do_buildpatches performs the needed koutput patches as needed
kmod_do_buildpatches()
{
	if [ -z ${KV_OUTPUT} ]; then
		get_kernel_info
	fi

	cd ${S}
	if is_koutput && [ -n "${KMOD_KOUTPUT_PATCH}" ]; then
		EPATCH_SINGLE_MESSAGE="Patching to enable koutput compatibility" \
			epatch ${KMOD_KOUTPUT_PATCH}
	fi
}

kmod_src_unpack () {
	check_KV
	kmod_universal_unpack
}

kmod_universal_unpack()
{
	get_kernel_info

	# KMOD_SOURCES is used if you don't want to unpack just ${A}
	# It can be set to "none" if you need to unpack things by hand
	# (like the nvidia-kernel ebuild). If set to "none", you'll have
	# to do any patching by hand as ${S} won't be around yet!
	# You can just call kmod_do_buildpatches after unpacking ${S}
	# if need be.
	if [ -z "${KMOD_SOURCES}" ]
	then
		unpack ${A}
	elif [ "${KMOD_SOURCES}" != "none" ]
	then
		unpack ${KMOD_SOURCES}
	fi

	if is_kernel 2 5 || is_kernel 2 6
	then
		# If we have sources we've unpacked, patch as needed
		if [ "${KMOD_SOURCES}" != "none" ]; then
			kmod_do_buildpatches
		fi
	fi
}

kmod_src_compile () {
	if is_kernel 2 5 || is_kernel 2 6
	then
		# If we're on 2.5/2.6 and not koutputing, we need to make
		# /usr/src/linux writable to succeed
		if ! is_koutput
		then
			kmod_make_linux_writable
		fi

		unset ARCH
	fi
	emake KERNEL_DIR=${KERNEL_DIR} || die
}

kmod_pkg_postinst() {
	einfo "Checking kernel module dependancies"
	test -r "${ROOT}/${KV_OUTPUT}/System.map" && \
		depmod -ae -F "${ROOT}/${KV_OUTPUT}/System.map" -b "${ROOT}" -r ${KV}
}

# is_kernel() takes two arguments. They should be the major and minor number
# of the kernel you'd like to check for. e.g.
#
# if is_kernel 2 6; then foo; fi
#
is_kernel() {
	if [ -z "${KV_MAJOR}" ]
	then
		get_kernel_info
	fi

	if [ "${KV_MAJOR}" -eq "${1}" -a "${KV_MINOR}" -eq "${2}" ]
	then
		return 0
	else
		return 1
	fi
}

# is_koutput() should be used to determing if we are using the koutput
# method of compilation for 2.6 kernels

is_koutput() {
	if [ -z ${KV_OUTPUT} ]
	then
		get_kernel_info
	fi

	if [ "${KV_OUTPUT}" != "${ROOT}/usr/src/linux" ]; then
		return 0
	else
		return 1
	fi
}

