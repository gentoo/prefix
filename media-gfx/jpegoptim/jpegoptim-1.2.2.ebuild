# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/jpegoptim/jpegoptim-1.2.2.ebuild,v 1.11 2008/10/25 12:46:23 maekke Exp $

inherit toolchain-funcs

DESCRIPTION="JPEG file optimiser"
HOMEPAGE="http://www.kokkonen.net/tjko/projects.html"
SRC_URI="http://www.kokkonen.net/tjko/src/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

IUSE=""
DEPEND="media-libs/jpeg"

src_compile() {
	econf || die "./configure failed"
	emake CC="$(tc-getCC)" || die
}

src_install() {
	make INSTALL_ROOT="${D}" install || die
	dodoc COPYRIGHT README
}
