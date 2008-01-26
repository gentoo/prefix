# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/shed/shed-1.13.ebuild,v 1.2 2007/08/09 10:00:25 hattya Exp $

EAPI="prefix"

IUSE=""

DESCRIPTION="Simple Hex EDitor"
HOMEPAGE="http://shed.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"

DEPEND=">=sys-libs/ncurses-5.3"

src_compile() {

	econf || die
	emake AM_CFLAGS="${CFLAGS}" || die

}

src_install() {

	emake DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog README TODO

}
