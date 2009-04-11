# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/highlight/highlight-2.4.8.ebuild,v 1.9 2008/05/04 20:41:59 drac Exp $

DESCRIPTION="converts source code to formatted text ((X)HTML, RTF, (La)TeX,
XSL-FO, XML) with syntax highlight"
HOMEPAGE="http://www.andre-simon.de/"
SRC_URI="http://www.andre-simon.de/zip/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_compile() {
	make -f makefile DESTDIR="${EPREFIX}" || die
}

src_install() {
	DESTDIR=${ED} bin_dir=${ED}/usr/bin make -f makefile -e install || die
}
