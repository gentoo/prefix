# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xcb-util/xcb-util-0.3.3.ebuild,v 1.1 2009/02/07 03:47:42 matsuu Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X C-language Bindings sample implementations"
HOMEPAGE="http://xcb.freedesktop.org/"
SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"

LICENSE="X11"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="test"

RDEPEND=">=x11-libs/libxcb-1"
DEPEND="${RDEPEND}
	>=dev-util/gperf-3.0.1
	dev-util/pkgconfig
	x11-proto/xproto
	test? ( >=dev-libs/check-0.9.4 )"

pkg_postinst() {
	x-modular_pkg_postinst

	echo
	ewarn "Library names have changed since earlier versions of xcb-util;"
	ewarn "you must rebuild packages that have linked against <xcb-util-0.3.0."
	einfo "Using 'revdep-rebuild' from app-portage/gentoolkit is highly"
	einfo "recommended."
	epause 5
}
