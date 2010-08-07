# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.4.21.ebuild,v 1.1 2010/06/16 12:21:59 chithanh Exp $

inherit x-modular

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="http://dri.freedesktop.org/${PN}/${P}.tar.bz2"
fi

KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="kernel_linux"
RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs"
DEPEND="${RDEPEND}"

pkg_setup() {
	# libdrm_intel fails to build on some arches if dev-libs/libatomic_ops is
	# installed, bugs 297630, bug 316421 and bug 316541, and is presently only
	# useful on amd64 and x86.
	CONFIGURE_OPTIONS="--enable-udev
			--enable-nouveau-experimental-api
			--enable-vmwgfx-experimental-api
			$(use_enable kernel_linux libkms)
			$(! use amd64 && ! use x86 && ! use x86-fbsd && echo "--disable-intel")"
}

PATCHES=(
	"${FILESDIR}"/${PN}-2.4.16-solaris.patch
	"${FILESDIR}"/${PN}-2.4.15-solaris.patch
)

# FIXME, we should try to see how we can fit the --enable-udev configure flag

pkg_postinst() {
	x-modular_pkg_postinst

	ewarn "libdrm's ABI may have changed without change in library name"
	ewarn "Please rebuild media-libs/mesa, x11-base/xorg-server and"
	ewarn "your video drivers in x11-drivers/*."
}
