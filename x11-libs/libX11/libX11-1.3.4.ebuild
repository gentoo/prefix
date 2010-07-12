# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.3.4.ebuild,v 1.1 2010/06/08 16:46:06 scarabeus Exp $

EAPI=3
inherit xorg-2 toolchain-funcs flag-o-matic

DESCRIPTION="X.Org X11 library"

KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="doc ipv6 test +xcb"

RDEPEND=">=x11-libs/xtrans-1.2.3
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.13
	xcb? ( >=x11-libs/libxcb-1.1.92 )
	!xcb? (
		x11-libs/libXau
		x11-libs/libXdmcp
	)"
DEPEND="${RDEPEND}
	doc? (
		app-text/ghostscript-gpl
		sys-apps/groff
	)
	test? ( dev-lang/perl )
	x11-proto/xf86bigfontproto
	!xcb? (
		x11-proto/bigreqsproto
		x11-proto/xcmiscproto
	)
	x11-proto/inputproto
	x11-proto/xextproto"

PATCHES=(
	"${FILESDIR}"/${PN}-1.1.4-aix-pthread.patch
	"${FILESDIR}"/${PN}-1.1.5-winnt-private.patch
	"${FILESDIR}"/${PN}-1.1.5-solaris.patch
)

pkg_setup() {
	xorg-2_pkg_setup
	CONFIGURE_OPTIONS="$(use_enable doc specs) $(use_enable ipv6)
		$(use_with xcb)
		$([[ ${CHOST} == *-darwin* ]] && echo "--with-launchd")"
	# xorg really doesn't like xlocale disabled.
	# $(use_enable nls xlocale)
}

src_configure() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	xorg-2_src_configure
}

src_compile() {
	# [Cross-Compile Love] Disable {C,LD}FLAGS and redefine CC= for 'makekeys'
	( filter-flags -m* ; cd src/util && make CC=$(tc-getBUILD_CC) CFLAGS="${CFLAGS}" LDFLAGS="" clean all)
	xorg-2_src_compile
}
