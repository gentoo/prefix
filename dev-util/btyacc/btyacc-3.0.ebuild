# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/btyacc/btyacc-3.0.ebuild,v 1.7 2005/04/24 12:44:30 hansmi Exp $

EAPI="prefix"

MY_P=${P/./-}
IUSE=""
DESCRIPTION="Backtracking YACC - modified from Berkeley YACC"
HOMEPAGE="http://www.siber.com/btyacc"
SRC_URI="http://www.siber.com/btyacc/${MY_P}.tar.gz"

LICENSE="freedist"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos ~x86-macos"
DEPEND="virtual/libc"
S=${WORKDIR}

src_compile() {
	emake CFLAGS="${CFLAGS}" LDFLAGS= || die
}

src_install() {
	dobin btyacc
	dodoc README README.BYACC
	newman manpage btyacc.1
}
