# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/highlight/highlight-2.9.ebuild,v 1.3 2009/05/04 20:24:08 ssuominen Exp $

EAPI=2
inherit eutils toolchain-funcs

DESCRIPTION="converts source code to formatted text ((X)HTML, RTF, (La)TeX, XSL-FO, XML) with syntax highlight"
HOMEPAGE="http://www.andre-simon.de"
SRC_URI="http://www.andre-simon.de/zip/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="qt4"

RDEPEND="qt4? ( x11-libs/qt-gui:4
	x11-libs/qt-core:4 )"
DEPEND="${RDEPEND}"

src_prepare() {
	sed -i -e 's:-O2::' -e 's:CFLAGS:CXXFLAGS:g' \
		-e 's:qmake-qt4:'"${EPREFIX}"'/usr/bin/qmake:' \
		src/makefile || die "sed failed"
}

src_compile() {
	emake -f makefile PREFIX="${EPREFIX}" conf_dir="${EPREFIX}"/etc/highlight/ CXX="$(tc-getCXX)" \
		|| die "emake all failed."

	if use qt4; then
		emake -f makefile PREFIX="${EPREFIX}" conf_dir="${EPREFIX}"/etc/highlight/ CXX="$(tc-getCXX)" all-gui \
			|| die "emake gui failed"
	fi
}

src_install() {
	dodir /usr/bin

	emake -f makefile \
		DESTDIR="${D}" PREFIX="${EPREFIX}" conf_dir="${EPREFIX}"/etc/highlight/ \
		install || die "emake install failed"

	if use qt4; then
		emake -f makefile DESTDIR="${D}" \
			PREFIX="${EPREFIX}" conf_dir="${EPREFIX}"/etc/highlight/ \
			install-gui || die "emake install-gui failed"
		doicon src/gui/${PN}.xpm
		domenu ${PN}.desktop
	fi
}
