# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/shed/shed-1.13.ebuild,v 1.4 2008/02/08 19:32:02 coldwind Exp $

inherit eutils

IUSE=""

DESCRIPTION="Simple Hex EDitor"
HOMEPAGE="http://shed.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"

DEPEND=">=sys-libs/ncurses-5.3"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	econf || die
	emake AM_CFLAGS="${CFLAGS}" || die

}

src_install() {

	emake DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog README TODO

}
