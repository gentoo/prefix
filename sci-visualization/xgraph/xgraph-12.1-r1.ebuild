# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/xgraph/xgraph-12.1-r1.ebuild,v 1.5 2008/02/06 21:43:31 grobian Exp $

inherit eutils

DESCRIPTION="X11 Plotting Utility"
HOMEPAGE="http://www.isi.edu/nsnam/xgraph/"
SRC_URI="http://www.isi.edu/nsnam/dist/${P}.tar.gz"
LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND="x11-libs/libSM
		x11-libs/libX11"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${PN}-makefile-gentoo.patch
}

src_install() {
	make DESTDIR="${D}" install || die "Compilation failed."

	dodoc README* INSTALL || die "Installing documentation failed."

	insinto /usr/share/${PN}/examples
	doins examples/* || die "Failed to install example files."

	dodir /usr/share/man/man1
	mv "${ED}"/usr/share/man/manm/xgraph.man \
		"${ED}"/usr/share/man/man1/xgraph.1 || \
		die "Failed to correct man page location."
	rm -Rf "${ED}"/usr/share/man/manm/ || \
		die "Failed to remove bogus manm directory."
}
