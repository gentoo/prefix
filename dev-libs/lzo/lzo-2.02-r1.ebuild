# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/lzo/lzo-2.02-r1.ebuild,v 1.15 2006/11/09 03:09:34 iluxa Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="An extremely fast compression and decompression library"
HOMEPAGE="http://www.oberhumer.com/opensource/lzo/"
SRC_URI="http://www.oberhumer.com/opensource/lzo/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="examples"

DEPEND="x86? ( dev-lang/nasm )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-exec-stack.patch
}

src_compile() {
	econf --enable-shared || die
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog NEWS README THANKS doc/LZO*
	if use examples ; then
		docinto examples
		dodoc examples/*.c examples/Makefile
	fi
}
