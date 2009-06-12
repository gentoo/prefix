# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.2.1.ebuild,v 1.1 2009/06/07 21:47:14 remi Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="1"

inherit x-modular toolchain-funcs flag-o-matic

DESCRIPTION="X.Org X11 library"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="ipv6 +xcb"

RDEPEND=">=x11-libs/xtrans-1.2.3
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.15
	xcb? ( >=x11-libs/libxcb-1.2 )
	!xcb? (
		x11-libs/libXau
		x11-libs/libXdmcp
	)"
DEPEND="${RDEPEND}
	x11-proto/xf86bigfontproto
	x11-proto/bigreqsproto
	x11-proto/inputproto
	x11-proto/xextproto
	x11-proto/xcmiscproto
	>=x11-misc/util-macros-1.2.1"

pkg_setup() {
	CONFIGURE_OPTIONS="$(use_enable ipv6)
		$(use_with xcb)"
	# xorg really doesn't like xlocale disabled.
	# $(use_enable nls xlocale)
}

src_unpack() {
	PATCHES=(
		"${FILESDIR}"/${PN}-1.1.4-aix-pthread.patch
		"${FILESDIR}"/${PN}-1.1.5-winnt.patch
		"${FILESDIR}"/${PN}-1.1.5-winnt-private.patch
		"${FILESDIR}"/${PN}-1.1.5-solaris.patch
	)
	x-modular_src_unpack
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	x-modular_src_configure
	# [Cross-Compile Love] Disable {C,LD}FLAGS and redefine CC= for 'makekeys'
	( filter-flags -m* ; cd src/util && make CC=$(tc-getBUILD_CC) CFLAGS="${CFLAGS}" LDFLAGS="" clean all)
	x-modular_src_make
}
