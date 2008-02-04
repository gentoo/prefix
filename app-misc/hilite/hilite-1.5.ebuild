# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/hilite/hilite-1.5.ebuild,v 1.13 2008/02/03 15:27:23 grobian Exp $

EAPI="prefix"

inherit toolchain-funcs

HOMEPAGE="http://sourceforge.net/projects/hilite"
SRC_URI="mirror://gentoo/${P}.c"
DESCRIPTION="A utility which highlights stderr text in red"

SLOT="0"

LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~mips-linux ~x86-linux ~ppc-macos"
S=${WORKDIR}

IUSE=""
DEPEND=""

src_unpack() {
	cp ${DISTDIR}/${A} ${WORKDIR}/
}

src_compile() {
	$(tc-getCC ) ${CFLAGS} -o ${PN} ${P}.c \
		|| die "compile failed"
}

src_install() {
	dobin ${WORKDIR}/hilite
}
