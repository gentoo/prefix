# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/mg/mg-20090107.ebuild,v 1.3 2009/04/14 10:04:50 armin76 Exp $

inherit toolchain-funcs

DESCRIPTION="Micro GNU/emacs, a port from the BSDs"
HOMEPAGE="http://www.han.dds.nl/software/mg/"
SRC_URI="http://www.han.dds.nl/software/mg/${P}.tar.gz"

LICENSE="public-domain BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

src_compile() {
	# econf won't work, as this script does not accept any parameters
	./configure || die "configure failed"
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" || die
}

src_install()  {
	einstall || die
	dodoc README tutorial || die
}
