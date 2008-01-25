# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/duconv/duconv-1.1.ebuild,v 1.19 2006/12/18 21:24:45 eroyf Exp $

EAPI="prefix"

DESCRIPTION="A small util that converts from dos<->unix"
SRC_URI="http://people.freenet.de/tfaehr/${PN}.tgz"
HOMEPAGE="http://people.freenet.de/tfaehr/linux.htm"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~mips-linux ~x86-linux ~ppc-macos"
SLOT="0"

IUSE=""
DEPEND=">=sys-apps/sed-4"
RDEPEND=""

src_unpack() {
	unpack ${A}
	mv ${WORKDIR}/home/torsten/gcc/duconv ${S}
	cd ${S}
	sed -i -e 's,-m486,,' Makefile || die "Makefile fix failed"
	rm -R ${WORKDIR}/home
}

src_compile() {
	make all || die
}

src_install () {
	exeinto /usr/bin
	doexe ${PN}
	doman duconv.1
}
