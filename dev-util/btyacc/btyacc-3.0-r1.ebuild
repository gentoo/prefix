# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/btyacc/btyacc-3.0-r1.ebuild,v 1.1 2009/09/04 13:34:14 jer Exp $

EAPI="2"

inherit eutils toolchain-funcs

MY_P=${P/./-}
IUSE=""
DESCRIPTION="Backtracking YACC - modified from Berkeley YACC"
HOMEPAGE="http://www.siber.com/btyacc"
SRC_URI="http://www.siber.com/btyacc/${MY_P}.tar.gz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"

S="${WORKDIR}"

src_prepare() {
	cp -av Makefile{,.orig}
	epatch "${FILESDIR}/${P}-includes.patch"
	epatch "${FILESDIR}/${P}-makefile.patch"
}

src_compile() {
	tc-export CC
	emake || die
}

src_install() {
	dobin btyacc
	dodoc README README.BYACC
	newman manpage btyacc.1
}
