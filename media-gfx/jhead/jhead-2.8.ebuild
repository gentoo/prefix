# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/jhead/jhead-2.8.ebuild,v 1.8 2008/04/09 17:49:03 nixnut Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Exif Jpeg camera setting parser and thumbnail remover"
HOMEPAGE="http://www.sentex.net/~mwandel/jhead/"
SRC_URI="http://www.sentex.net/~mwandel/jhead/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="media-libs/jpeg"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	sed -i -e "s:-O3 -Wall:${CFLAGS}:" "${S}"/makefile || die "sed failed."
}

src_compile() {
	tc-export CC
	emake || die "emake failed."
}

src_install() {
	dobin jhead || die "dobin failed."
	dodoc {readme,changes}.txt
	dohtml usage.html
	doman jhead.1.gz
}
