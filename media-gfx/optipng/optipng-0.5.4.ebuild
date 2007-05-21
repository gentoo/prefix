# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/optipng/optipng-0.5.4.ebuild,v 1.4 2007/02/14 17:25:15 dang Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Find the optimal compression settings for your png files"
SRC_URI="mirror://sourceforge/optipng/${P}.tar.gz"
HOMEPAGE="http://optipng.sourceforge.net/"

LICENSE="as-is"

SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE=""

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}
	sed -i -e 's!-O2!${CFLAGS}!' ${S}/src/scripts/gcc.mak
}

src_compile() {
	emake -C ${S}/src -f ${S}/src/scripts/gcc.mak optipng \
		CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" || die
}

src_install() {
	dobin ${S}/src/optipng
	dodoc ${S}/doc/{CAVEAT.txt,HISTORY.txt,TODO.txt,USAGE.txt}
	dohtml ${S}/doc/{design.html,features.html,guide.html,thanks.html}
	doman ${S}/man/optipng.1
}
