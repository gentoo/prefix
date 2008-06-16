# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/duconv/duconv-1.1.ebuild,v 1.21 2008/06/15 20:12:14 loki_val Exp $

EAPI="prefix"

inherit toolchain-funcs base

DESCRIPTION="A small util that converts from dos<->unix"
SRC_URI="http://people.freenet.de/tfaehr/${PN}.tgz"
HOMEPAGE="http://people.freenet.de/tfaehr/linux.htm"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"

IUSE=""
DEPEND=""
RDEPEND=""

S=${WORKDIR}/home/torsten/gcc/${PN}

PATCHES=( "${FILESDIR}/${P}-gcc43.patch" )

src_compile() {
	$(tc-getCXX) ${CXXFLAGS} -Wall -D_GNU_SOURCE ${LDFLAGS} -c -o duconv.o duconv.cc
	$(tc-getCXX) ${CXXFLAGS} ${LDFLAGS} -o duconv duconv.o
}

src_install () {
	dobin duconv
	doman duconv.1
	dodoc Changes
}
