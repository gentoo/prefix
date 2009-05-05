# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXaw/libXaw-1.0.5.ebuild,v 1.9 2009/05/04 17:04:42 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit eutils x-modular autotools flag-o-matic

DESCRIPTION="X.Org Xaw library"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXt
	x11-libs/libXmu
	x11-libs/libXpm
	x11-proto/xproto"
DEPEND="${RDEPEND}"

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}

src_unpack() {
	PATCHES=(
		"${FILESDIR}"/${PN}-1.0.5-darwin.patch
	)

	if [[ ${CHOST} == *-winnt* ]]; then
		PATCHES[${#PATCHES[*]}]="${FILESDIR}"/${P}-winnt-cpp.patch
		PATCHES[${#PATCHES[*]}]="${FILESDIR}"/${P}-winnt-no-libtool-hack.patch
		PATCHES[${#PATCHES[*]}]="${FILESDIR}"/${P}-winnt-externalref.patch
	fi

	x-modular_src_unpack
	eautoreconf # eautoreconf gets ran by the eclass only if SNAPSHOT="yes", so
				# we need it for prefix.
}

src_compile() {
	[[ ${CHOST} == *-winnt* ]] && append-flags -xc++

	x-modular_src_compile
}
