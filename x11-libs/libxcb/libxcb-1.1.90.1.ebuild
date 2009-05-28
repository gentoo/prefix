# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxcb/libxcb-1.1.90.1.ebuild,v 1.2 2009/05/04 17:06:59 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X C-language Bindings library"
HOMEPAGE="http://xcb.freedesktop.org/"
SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"
LICENSE="X11"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="doc selinux"
RDEPEND="x11-libs/libXau
	x11-libs/libXdmcp
	dev-libs/libpthread-stubs"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	dev-libs/libxslt
	>=x11-proto/xcb-proto-1.2"

pkg_setup() {
	CONFIGURE_OPTIONS="$(use_enable doc build-docs)
		$(use_enable selinux xselinux)
		--enable-xinput"
}

pkg_postinst() {
	x-modular_pkg_postinst

	elog "libxcb-1.1 added the LIBXCB_ALLOW_SLOPPY_LOCK variable to allow"
	elog "broken applications to keep running instead of being aborted."
	elog "Set this variable if you need to use broken packages such as Java"
	elog "(for example, add LIBXCB_ALLOW_SLOPPY_LOCK=1 to ${EPREFIX}/etc/env.d/00local"
	elog "and run env-update)."
}
