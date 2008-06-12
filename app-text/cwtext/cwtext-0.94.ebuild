# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/cwtext/cwtext-0.94.ebuild,v 1.13 2008/04/07 20:18:14 armin76 Exp $

EAPI="prefix"

inherit toolchain-funcs

DESCRIPTION="Text to Morse Code converter"
HOMEPAGE="http://cwtext.sourceforge.net"
SRC_URI="mirror://sourceforge/cwtext/${P}.tar.gz"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"
LICENSE="GPL-2"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	# change install directory to ${S}
	sed -i -e "/^PREFIX/ s:=.*:=\"${S}\":" makefile || \
		die "sed makefile failed"

	tc-export CC
}

src_compile() {
	emake install || die
}

src_install() {
	dobin cwtext cwpcm cwmm

	dodoc Changes README TODO
}
