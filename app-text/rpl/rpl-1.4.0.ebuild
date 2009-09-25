# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/rpl/rpl-1.4.0.ebuild,v 1.23 2009/09/23 16:38:36 patrick Exp $

inherit eutils toolchain-funcs

DESCRIPTION="rpl is a UN*X text replacement utility. It will replace strings with new strings in multiple text files. It can work recursively"
HOMEPAGE="http://www.laffeycomputer.com/rpl.html"
SRC_URI="http://downloads.laffeycomputer.com/current_builds/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-gcc4.patch
}

src_compile() {
	tc-export CC
	econf
	emake || die
}

src_install () {
	dobin src/rpl
	doman man/rpl.1
	dodoc AUTHORS COPYING ChangeLog NEWS README
}
