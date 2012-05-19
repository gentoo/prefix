# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/aalib/aalib-1.4_rc5-r4.ebuild,v 1.2 2012/05/09 13:18:37 aballier Exp $

EAPI=4

inherit autotools eutils

MY_P="${P/_/}"
S="${WORKDIR}/${PN}-1.4.0"

DESCRIPTION="A ASCII-Graphics Library"
HOMEPAGE="http://aa-project.sourceforge.net/aalib/"
SRC_URI="mirror://sourceforge/aa-project/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="X slang gpm static-libs"

RDEPEND="X? ( x11-libs/libX11 )
	slang? ( >=sys-libs/slang-1.4.2 )"
DEPEND="${RDEPEND}
	>=sys-libs/ncurses-5.1
	X? ( x11-proto/xproto )
	gpm? ( sys-libs/gpm )"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.4_rc4-gentoo.patch
	epatch "${FILESDIR}"/${PN}-1.4_rc4-m4.patch
	epatch "${FILESDIR}"/${PN}-1.4_rc5-fix-protos.patch #224267
	epatch "${FILESDIR}"/${PN}-1.4_rc5-fix-aarender.patch #214142

	sed -i -e 's:#include <malloc.h>:#include <stdlib.h>:g' "${S}"/src/*.c

	# Fix bug #165617.
	use gpm || sed -i \
		's/gpm_mousedriver_test=yes/gpm_mousedriver_test=no/' "${S}/configure.in"

	eautoreconf
}

src_configure() {
	econf \
		$(use_with slang slang-driver) \
		$(use_with !slang ncurses "${EPREFIX}"/usr) \
		$(use_with X x11-driver) \
		$(use_enable static-libs static)
	if [[ ${CHOST} == *-darwin* ]] && use X; then
		sed -i -e 's:aafire_LDFLAGS =:aafire_LDFLAGS = -undefined define_a_way:' \
		${S}/src/Makefile || die "Failed to edit Makefile for X compatibility"
	fi
}

src_install() {
	default
	dodoc ANNOUNCE AUTHORS ChangeLog NEWS README*
	use static-libs || find "${ED}" -name '*.la' -delete
}
