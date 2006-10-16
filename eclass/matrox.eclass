# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/matrox.eclass,v 1.15 2006/10/14 20:27:21 swegener Exp $
#
# Author: Donnie Berkholz <spyderous@gentoo.org>
#
# This eclass is designed to reduce code duplication in the mtxdrivers* ebuilds.
# The only addition to mtxdrivers-pro is OpenGL stuff.

inherit eutils


EXPORT_FUNCTIONS pkg_setup src_compile

HOMEPAGE="http://www.matrox.com/mga/products/parhelia/home.cfm"

LICENSE="Matrox"
SLOT="${KV}"
RESTRICT="fetch nostrip"

RDEPEND="virtual/linux-sources"

matrox_pkg_setup() {
	# Require correct /usr/src/linux
	check_KV

	# Set up X11 implementation
	X11_IMPLEM_P="$(best_version virtual/x11)"
	X11_IMPLEM="${X11_IMPLEM_P%-[0-9]*}"
	X11_IMPLEM="${X11_IMPLEM##*\/}"
	einfo "X11 implementation is ${X11_IMPLEM}."

	# Force XFree86 4.3.0, 4.2.1 or 4.2.0 to be installed unless FORCE_VERSION
	# is set. Need FORCE_VERSION for 4.3.99/4.4.0 compatibility until Matrox
	# comes up with drivers (spyderous)
	if has_version "x11-base/xfree"
	then
		local INSTALLED_X="`best_version x11-base/xfree`"
		GENTOO_X_VERSION_REVISION="${INSTALLED_X/x11-base\/xfree-}"
		GENTOO_X_VERSION="${GENTOO_X_VERSION_REVISION%-*}"
		if [ "${GENTOO_X_VERSION}" != "4.3.0" ]
		then
			if [ "${GENTOO_X_VERSION}" != "4.2.1" ]
			then
				if [ "${GENTOO_X_VERSION}" != "4.2.0" ]
				then
					if [ -n "${FORCE_VERSION}" ]
					then
						GENTOO_X_VERSION="${FORCE_VERSION}"
					else
						die "These drivers require XFree86 4.3.0, 4.2.1 or 4.2.0. Do FORCE_VERSION=version-you-want emerge ${PN} (4.3.0, 4.2.1 or 4.2.0) to force installation."
					fi
				fi
			fi
		fi
	# xorg-x11 compatibility
	elif has_version "x11-base/xorg-x11"
	then
		if [ "${FORCE_VERSION}" != "4.3.0" ]
		then
			die "Set FORCE_VERSION=4.3.0 to emerge this. Use at your own risk."
		fi
		GENTOO_X_VERSION="${FORCE_VERSION}"
	fi
}

matrox_src_compile() {
	# 2.6 builds use the ARCH variable
	set_arch_to_kernel
	export PARHELIUX="${PWD}/src"
	cd ${S}/src/kernel/parhelia
	ln -sf ../../../kernel/mtx_parhelia.o .
	cd ..
	# Can't use emake here
	make clean
	make || die "make failed"
	set_arch_to_portage
}

matrox_base_src_install() {
	# Kernel Module
	dodir /$(get_libdir)/modules/${KV}/kernel/drivers/video; insinto /$(get_libdir)/modules/${KV}/kernel/drivers/video
	doins src/kernel/mtx.o

	# X Driver (2D)
	dodir /usr/X11R6/$(get_libdir)/modules/drivers; insinto /usr/X11R6/$(get_libdir)/modules/drivers
	doins xfree86/${GENTOO_X_VERSION}/mtx_drv.o
}

matrox_base_pkg_postinst() {
	if [ "${ROOT}" = "/" ]
	then
		/sbin/modules-update
	fi

	if [ ! -d /dev/video ]
	then
		if [ -f /dev/video ]
		then
			einfo "NOTE: To be able to use busmastering, you MUST have /dev/video as"
			einfo "a directory, which means you must remove anything there first"
			einfo "(rm -f /dev/video), and mkdir /dev/video"
		else
			mkdir /dev/video
		fi
	fi
}
