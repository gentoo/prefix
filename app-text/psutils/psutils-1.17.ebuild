# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/psutils/psutils-1.17.ebuild,v 1.29 2006/11/27 00:18:42 vapier Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="PostScript Utilities"
HOMEPAGE="http://www.tardis.ed.ac.uk/~ajcd/psutils"
SRC_URI="ftp://ftp.enst.fr/pub/unix/a2ps/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

RDEPEND="virtual/libc"
DEPEND="${RDEPEND}
	dev-lang/perl"

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	sed \
		-e "s:/usr/local:\$(DESTDIR)/usr:" \
		-e "s:-DUNIX -O:-DUNIX ${CFLAGS}:" \
		"${S}/Makefile.unix" > "${S}/Makefile"
}

src_compile() {
	emake CC="$(tc-getCC)" || die
}

src_install () {
	dodir /usr/{bin,share/man}
	make DESTDIR="${D}${EPREFIX}" install || die
	dodoc README
}
