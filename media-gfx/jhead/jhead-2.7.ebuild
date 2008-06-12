# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/jhead/jhead-2.7.ebuild,v 1.10 2008/01/27 16:03:45 angelos Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Exif Jpeg camera setting parser and thumbnail remover"
HOMEPAGE="http://www.sentex.net/~mwandel/jhead/"
SRC_URI="http://www.sentex.net/~mwandel/jhead/${P}.tar.gz"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="virtual/libc"
RDEPEND="virtual/libc
	media-libs/jpeg"

src_unpack() {
	unpack ${A}; cd "${S}"
	sed -i "s:-O3 -Wall:${CFLAGS}:" makefile || die "sed failed"
}

src_compile() {
	export CC="$(tc-getCC)"
	emake || die
}

src_install() {
	dobin jhead || die
	dodoc {readme,changes}.txt
	dohtml usage.html
	doman jhead.1.gz
}
