# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/qhull/qhull-2003.1-r1.ebuild,v 1.8 2009/09/09 20:47:51 bicatali Exp $

EAPI=2
inherit eutils flag-o-matic

MY_P="${PN}${PV}"
DESCRIPTION="Geometry library"
HOMEPAGE="http://www.qhull.org"
SRC_URI="${HOMEPAGE}/download/${P}.tar.gz"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc"

pkg_setup() {
	# anything beyond -O1 leads to bad code in libqhull on amd64
	# with gcc-4.2
	#use amd64 && replace-flags -O? -O1
	echo
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	rm -fr "${ED}"/usr/share/doc/${PN}
	dodoc Announce.txt File_id.diz README.txt REGISTER.txt
	if use doc; then
		cd html
		dohtml * || die
		dodoc *.txt || die
	fi
}
