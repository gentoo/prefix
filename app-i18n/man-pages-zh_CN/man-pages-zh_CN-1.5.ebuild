# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-i18n/man-pages-zh_CN/man-pages-zh_CN-1.5.ebuild,v 1.2 2006/06/21 17:26:24 vapier Exp $

DESCRIPTION="A somewhat comprehensive collection of Chinese Linux man pages"
HOMEPAGE="http://cmpp.linuxforum.net/"
SRC_URI="http://download.sf.linuxforum.net/cmpp/${P}.tar.gz"

LICENSE="FDL-1.2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

RDEPEND="virtual/man"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -r `find . -type d -name CVS`
}

src_compile() {
	make u8 || die
}

src_install() {
	make install-u8 DESTDIR="${ED}"/usr/share || die
	dodoc README* DOCS/*
}
