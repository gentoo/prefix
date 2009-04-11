# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/pngcrush/pngcrush-1.6.14.ebuild,v 1.1 2009/03/14 11:27:22 maekke Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Portable Network Graphics (PNG) optimizing utility"
HOMEPAGE="http://pmt.sourceforge.net/pngcrush"
SRC_URI="mirror://sourceforge/pmt/${P}-nolib.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=">=media-libs/libpng-1.2.31"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${P}-nolib"

src_unpack() {
	unpack ${A}
	cp "${FILESDIR}"/Makefile "${S}" || die
}

src_compile() {
	tc-export CC
	emake || die "emake failed."
}

src_install() {
	dobin ${PN} || die "dobin failed."
	dodoc *.txt
}
