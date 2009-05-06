# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXt/libXt-1.0.5.ebuild,v 1.15 2009/05/05 07:18:13 ssuominen Exp $

# Must be before x-modular eclass is inherited
SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org Xt library"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libSM
	x11-proto/xproto
	x11-proto/kbproto"
DEPEND="${RDEPEND}"

PATCHES=("${FILESDIR}/libXt-1.0.5-cross.patch")

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

src_unpack() {
	PATCHES="${FILESDIR}"/${P}-winnt.patch

	x-modular_src_unpack
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	x-modular_src_compile
}
