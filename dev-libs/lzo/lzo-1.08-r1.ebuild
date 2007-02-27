# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/lzo/lzo-1.08-r1.ebuild,v 1.24 2007/01/16 20:19:31 grobian Exp $

EAPI="prefix"

inherit eutils libtool autotools

DESCRIPTION="An extremely fast compression and decompression library"
HOMEPAGE="http://www.oberhumer.com/opensource/lzo/"
SRC_URI="http://www.oberhumer.com/opensource/lzo/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND="x86? ( dev-lang/nasm )"
RDEPEND=""

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${P}-exec-stack.patch
	cd ${S}
	epatch ${FILESDIR}/${PV}-gcc3.patch
	sed -i -e s,-O2,,g ${S}/aclocal.m4
	eautoconf

	elibtoolize
}

src_compile() {
	econf --enable-shared || die
	emake || die
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc AUTHORS BUGS ChangeLog INSTALL NEWS README THANKS doc/LZO*
	docinto examples
	dodoc examples/*.c examples/Makefile
}
