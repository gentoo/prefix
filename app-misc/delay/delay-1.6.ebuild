# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/delay/delay-1.6.ebuild,v 1.16 2008/03/26 18:47:31 armin76 Exp $

EAPI="prefix"

DESCRIPTION="sleeplike program that counts down the number of seconds specified"
HOMEPAGE="http://onegeek.org/~tom/software/delay/"
SRC_URI="http://onegeek.org/~tom/software/delay/dl/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="virtual/libc"

src_compile() {
	sed -i -e "s/#include <stdio.h>/&\n#include <stdlib.h>/" delay.c
	./configure \
		--host=${CHOST} \
		--prefix="${EPREFIX}"/usr \
		--infodir="${EPREFIX}"/usr/share/info \
		--mandir="${EPREFIX}"/usr/share/man || die "./configure failed"
	emake || die
}

src_install() {
	make DESTDIR=${D} install || die
	dodoc ChangeLog README INSTALL
}
