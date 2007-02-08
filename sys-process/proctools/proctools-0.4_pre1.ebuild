# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

MY_P=${P/_}
S=${WORKDIR}/${MY_P}

inherit flag-o-matic eutils

DESCRIPTION="Standard informational utilities and process-handling tools"
HOMEPAGE="http://proctools.sourceforge.net/"
#SRC_URI="http://proctools.sourceforge.net/${MY_P}.tar.gz"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PN}-gmake.patch
}

src_compile() {
	make -f Makefile.gnu
}

src_install() {
	exeinto /usr/bin
	doexe pgrep/pgrep pkill/pkill pfind/pfind
	
	doman pgrep/pgrep.1 pkill/pkill.1 pfind/pfind.1	
}
