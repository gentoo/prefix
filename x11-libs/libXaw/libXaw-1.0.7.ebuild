# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXaw/libXaw-1.0.7.ebuild,v 1.10 2010/01/19 20:03:57 armin76 Exp $

EAPI="2"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org Xaw library"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="doc"

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libXpm
	x11-proto/xproto"
DEPEND="${RDEPEND}
	doc? ( sys-apps/groff )
	"

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

pkg_setup() {
	if [[ ${CHOST} == *-winnt* ]]; then
		PATCHES=( ${PATCHES[@]}
			"${FILESDIR}"/${PN}-1.0.5-winnt-cpp.patch
			"${FILESDIR}"/${PN}-1.0.5-winnt-no-libtool-hack.patch
			"${FILESDIR}"/${PN}-1.0.5-winnt-externalref.patch
		)
	fi
}

src_configure() {
	CONFIGURE_OPTIONS="$(use_enable doc docs)"
	x-modular_src_configure
}

src_compile() {
	[[ ${CHOST} == *-winnt* ]] && append-flags -xc++

	x-modular_src_compile
}
