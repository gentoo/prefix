# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/html2text/html2text-1.3.2.ebuild,v 1.19 2008/03/27 20:59:41 jer Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="A HTML to text converter"
HOMEPAGE="http://www.mbayer.de/html2text/index.shtml"
SRC_URI="http://userpage.fu-berlin.de/~mbayer/tools/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="virtual/libc"

src_unpack() {
	unpack ${A}
	cd ${S}
	if [ `gcc-major-version` -ge 4 -o \
		`gcc-major-version` -ge 3 -a `gcc-minor-version` -ge 3 ];
	then
		epatch 1.3.2_to_1.3.2a.diff
	fi
	epatch ${FILESDIR}/${P}-compiler.patch
}

src_compile() {
	econf || die
	emake CXX="$(tc-getCXX)" || die
}

src_install() {
	dobin html2text
	doman html2text.1.gz
	doman html2textrc.5.gz
	dodoc CHANGES CREDITS KNOWN_BUGS README TODO
}
