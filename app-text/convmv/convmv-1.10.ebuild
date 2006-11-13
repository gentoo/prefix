# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/convmv/convmv-1.10.ebuild,v 1.2 2006/10/02 22:36:05 robbat2 Exp $

EAPI="prefix"

DESCRIPTION="convert filenames to utf8 or any other charset"
HOMEPAGE="http://j3e.de/linux/convmv"
SRC_URI="http://j3e.de/linux/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND="dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "1s|#!/usr/bin/perl|#!${EPREFIX}/usr/bin/perl|" convmv || die
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	einstall DESTDIR="${D}" PREFIX="${EPREFIX}/usr" || die "einstall failed"
	dodoc CREDITS Changes GPL2 TODO VERSION testsuite.tar
}
