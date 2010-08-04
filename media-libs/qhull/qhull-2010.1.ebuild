# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/qhull/qhull-2010.1.ebuild,v 1.1 2010/05/22 09:43:00 jlec Exp $

EAPI=2

inherit cmake-utils eutils flag-o-matic

MY_P="${PN}${PV}"
DESCRIPTION="Geometry library"
HOMEPAGE="http://www.qhull.org"
SRC_URI="${HOMEPAGE}/download/${P}-src.tgz"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc"

pkg_setup() {
	append-flags -fno-strict-aliasing
}

src_install() {
	dobin "${S}"_build/src/{q*,rbox} || die

	dodoc Announce.txt File_id.diz README.txt REGISTER.txt || die

	if use doc; then
		dohtml -r index.htm html || die
	fi
}
