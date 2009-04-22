# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/pngrewrite/pngrewrite-1.3.0.ebuild,v 1.1 2009/04/20 20:43:24 maekke Exp $

inherit toolchain-funcs

DESCRIPTION="A utility which reduces large palettes in PNG images"
HOMEPAGE="http://entropymine.com/jason/pngrewrite/"
SRC_URI="http://entropymine.com/jason/${PN}/${P}.zip"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="media-libs/libpng"
DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}

src_compile() {
	$(tc-getCC) ${LDFLAGS} ${CFLAGS} ${PN}.c -lpng -o ${PN} \
		|| die "compile failed."
}

src_install() {
	dobin ${PN} || die "dobin failed."
}
