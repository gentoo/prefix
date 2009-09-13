# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.4.13.ebuild,v 1.1 2009/09/09 10:47:58 scarabeus Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit autotools x-modular

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="http://dri.freedesktop.org/${PN}/${P}.tar.bz2"
fi

KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"

IUSE=""
RDEPEND="dev-libs/libpthread-stubs"
DEPEND="${RDEPEND}"
RESTRICT="test" # see bug #236845

CONFIGURE_OPTIONS="--enable-udev --enable-nouveau-experimental-api --enable-radeon-experimental-api"

PATCHES=(
	"${FILESDIR}"/${PN}-2.4.5-solaris.patch
)

# FIXME, we should try to see how we can fit the --enable-udev configure flag

pkg_postinst() {
	x-modular_pkg_postinst

	ewarn "libdrm's ABI may have changed without change in library name"
	ewarn "Please rebuild media-libs/mesa, x11-base/xorg-server and"
	ewarn "your video drivers in x11-drivers/*."
}
