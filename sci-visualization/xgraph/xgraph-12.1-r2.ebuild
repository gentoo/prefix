# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-visualization/xgraph/xgraph-12.1-r2.ebuild,v 1.5 2009/12/26 16:19:05 armin76 Exp $

EAPI=2
inherit eutils autotools

DEB_PR=10
DESCRIPTION="X11 Plotting Utility"
HOMEPAGE="http://www.isi.edu/nsnam/xgraph/"
SRC_URI="http://www.isi.edu/nsnam/dist/${P}.tar.gz
	mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PV}-${DEB_PR}.diff.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="examples"
DEPEND="x11-libs/libSM
		x11-libs/libX11"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${WORKDIR}"/${PN}_${PV}-${DEB_PR}.diff
	epatch "${FILESDIR}"/${P}-glibc-2.10.patch
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "Compilation failed."
	dodoc README*
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples || die "Failed to install example files."
	fi

	dodir /usr/share/man/man1
	mv "${ED}"/usr/share/man/manm/xgraph.man \
		"${ED}"/usr/share/man/man1/xgraph.1 || \
		die "Failed to correct man page location."
	rm -Rf "${ED}"/usr/share/man/manm/ || \
		die "Failed to remove bogus manm directory."
}
