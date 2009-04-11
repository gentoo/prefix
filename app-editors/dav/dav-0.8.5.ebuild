# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/dav/dav-0.8.5.ebuild,v 1.10 2008/12/30 18:35:33 angelos Exp $

inherit eutils toolchain-funcs

DESCRIPTION="A minimal console text editor"
HOMEPAGE="http://dav-text.sourceforge.net/"

# The maintainer does not keep sourceforge's mirrors up-to-date,
# so we point to the website's store of files.
SRC_URI="http://dav-text.sourceforge.net/files/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="sys-libs/ncurses"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-asneeded.patch
}

src_compile() {
	emake CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS} -lncurses" \
		CC="$(tc-getCC)" \
		|| die "emake failed"
}

src_install() {
	# no configure, is no prefix known
	emake DESTDIR="${D}${EPREFIX}" install || die
	dodoc README
}
