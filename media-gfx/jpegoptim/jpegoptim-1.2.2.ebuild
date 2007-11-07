# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/jpegoptim/jpegoptim-1.2.2.ebuild,v 1.8 2007/02/08 16:15:44 blubb Exp $

EAPI="prefix"

DESCRIPTION="JPEG file optimiser"
HOMEPAGE="http://www.cc.jyu.fi/~tjko/projects.html"
SRC_URI="http://www.cc.jyu.fi/~tjko/src/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"

IUSE=""
DEPEND="media-libs/jpeg"

src_compile() {
	./configure \
		--host=${CHOST} \
		--prefix="${EPREFIX}"/usr \
		--infodir="${EPREFIX}"/usr/share/info \
		--mandir="${EPREFIX}"/usr/share/man || die "./configure failed"

	emake || die
}

src_install() {
	make INSTALL_ROOT="${D}" install || die
	dodoc COPYRIGHT README
}
