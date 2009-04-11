# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/dvorak7min/dvorak7min-1.6.1.ebuild,v 1.14 2008/12/30 19:46:34 angelos Exp $

inherit toolchain-funcs

DESCRIPTION="simple ncurses-based typing tutor for learning the Dvorak keyboard layout"
HOMEPAGE="http://www.linalco.com/comunidad.html"
SRC_URI="http://www.linalco.com/ragnar/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

src_compile() {
	make clean
	emake CC="$(tc-getCC)" \
		PROF="${CFLAGS}" \
		|| die "emake failed"
}

src_install() {
	dobin dvorak7min || die "dobin failed"
	dodoc ChangeLog README
}
