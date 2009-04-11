# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/cccc/cccc-3.1.4.ebuild,v 1.2 2006/06/30 10:42:50 tchiwam Exp $

inherit eutils toolchain-funcs

DESCRIPTION="A code counter for C and C++"
HOMEPAGE="http://cccc.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin-ld.patch
	epatch "${FILESDIR}"/${P}-prefix.patch
}

src_compile() {
	make CCC=$(tc-getCXX) LD=$(tc-getCXX) pccts cccc || die
}

src_install() {
	dodoc readme.txt changes.txt
	cd install
	dodir /usr
	make -f install.mak INSTDIR="${ED}"/usr/bin || die
}
