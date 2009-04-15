# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/bogosort/bogosort-0.4.2.ebuild,v 1.8 2009/04/13 02:26:45 darkside Exp $

inherit libtool eutils toolchain-funcs

DESCRIPTION="A file sorting program which uses the bogosort algorithm"
HOMEPAGE="http://www.lysator.liu.se/~qha/bogosort/"
SRC_URI="ftp://ulrik.haugen.se/pub/unix/bogosort/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}

	cd ${S}
	epatch ${FILESDIR}/xmalloc.patch
}

src_compile() {
	tc-export CC
	econf
	emake || die
}

src_install() {
	make DESTDIR="${D}" install
	dodoc README NEWS ChangeLog AUTHORS
}
