# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.1.3-r1.ebuild,v 1.1 2008/02/28 19:39:20 cardoe Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org X11 library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ipv6 xcb"
RDEPEND=">=x11-libs/xtrans-1.0.1
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.6
	xcb? ( >=x11-libs/libxcb-1.0 )"
DEPEND="${RDEPEND}
	x11-proto/xf86bigfontproto
	x11-proto/bigreqsproto
	x11-proto/inputproto
	x11-proto/xextproto
	x11-proto/xcmiscproto
	>=x11-misc/util-macros-0.99.0_p20051007"

CONFIGURE_OPTIONS="$(use_enable ipv6)
	$(use_with xcb)"
PATCHES="${FILESDIR}/libX11-1.1.3-xcb-locking.patch"

# xorg really doesn't like xlocale disabled.
# $(use_enable nls xlocale)

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	x-modular_src_compile
}
