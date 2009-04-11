# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/blassic/blassic-0.10.0.ebuild,v 1.12 2009/01/13 17:10:29 mr_bones_ Exp $

inherit eutils

DESCRIPTION="classic Basic interpreter"
HOMEPAGE="http://blassic.org"
SRC_URI="http://blassic.org/bin/${P}.tgz"

LICENSE="GPL-2"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
SLOT="0"
IUSE="svga X"

RDEPEND="sys-libs/ncurses
	X? ( x11-libs/libICE x11-libs/libX11 x11-libs/libSM )
	svga? ( media-libs/svgalib )"
DEPEND="${RDEPEND}
	X? ( x11-proto/xproto )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-gcc43.patch
}

src_compile() {
	econf \
		--disable-dependency-tracking \
		$(use_with X x) \
		$(use_enable svga svgalib) \
		|| die
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README THANKS TODO
}
