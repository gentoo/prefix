# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/dvorak7min/dvorak7min-1.6.1.ebuild,v 1.12 2005/03/12 23:53:41 luckyduck Exp $

EAPI="prefix"

DESCRIPTION="simple ncurses-based typing tutor for learning the Dvorak keyboard layout"
HOMEPAGE="http://www.linalco.com/comunidad.html"
SRC_URI="http://www.linalco.com/ragnar/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND=""

src_compile() {
	make clean
	emake || die "Make failed"
}

src_install() {
	dobin dvorak7min
	dodoc ChangeLog README
}
