# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/aalib/aalib-1.4_rc5.ebuild,v 1.18 2007/02/17 17:21:56 grobian Exp $

EAPI="prefix"

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest

inherit eutils libtool toolchain-funcs autotools

MY_P="${P/_/}"
S="${WORKDIR}/${PN}-1.4.0"

DESCRIPTION="A ASCII-Graphics Library"
HOMEPAGE="http://aa-project.sourceforge.net/aalib/"
SRC_URI="mirror://sourceforge/aa-project/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="X slang gpm"

RDEPEND="X? ( || ( x11-libs/libX11 virtual/x11 ) )"

DEPEND="${RDEPEND}
	>=sys-libs/ncurses-5.1
	X? ( || ( x11-proto/xproto virtual/x11 ) )
	gpm? ( sys-libs/gpm )
	slang? ( >=sys-libs/slang-1.4.2 )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.4_rc4-gentoo.patch
	epatch "${FILESDIR}"/${PN}-1.4_rc4-m4.patch

	sed -i -e 's:#include <malloc.h>:#include <stdlib.h>:g' ${S}/src/*.c
	eautoreconf
}

src_compile() {
	econf \
		$(use_with slang slang-driver) \
		$(use_with X x11-driver) \
		|| die
	if [[ ${CHOST} == *-darwin* ]] && use X; then
		sed -i -e 's:aafire_LDFLAGS =:aafire_LDFLAGS = -undefined define_a_way:' \
		${S}/src/Makefile || die "Failed to edit Makefile for X compatibility"
	fi
	emake CC="$(tc-getCC)" || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc ANNOUNCE AUTHORS ChangeLog NEWS README*
}
