# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXaw/libXaw-1.0.4.ebuild,v 1.8 2008/01/13 09:23:19 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit eutils autotools x-modular

DESCRIPTION="X.Org Xaw library"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="xprint"

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libXpm
	x11-proto/xproto
	xprint? ( x11-libs/libXp )"
DEPEND="${RDEPEND}
	sys-apps/ed"

CONFIGURE_OPTIONS="$(use_enable xprint xaw8)"

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

src_unpack() {
	x-modular_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.0.3-darwin.patch
	eautoreconf
}
