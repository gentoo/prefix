# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/hnb/hnb-1.9.18-r1.ebuild,v 1.2 2009/10/23 12:45:50 jer Exp $

EAPI="2"

inherit eutils toolchain-funcs

DESCRIPTION="A program to organize many kinds of data in one place."
SRC_URI="http://hnb.sourceforge.net/.files/${P}.tar.gz"
HOMEPAGE="http://hnb.sourceforge.net/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}/${P}-flags.patch" "${FILESDIR}/${P}-include.patch"
}

src_compile() {
	tc-export CC
	default_src_compile
}

src_install() {
	dodoc README doc/hnbrc
	doman doc/hnb.1
	dobin src/hnb
}
