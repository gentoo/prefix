# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/qhull/qhull-2003.1-r1.ebuild,v 1.1 2007/12/11 02:21:23 markusle Exp $

EAPI="prefix"

inherit eutils flag-o-matic

MY_P="${PN}${PV}"
DESCRIPTION="Geometry library"
HOMEPAGE="http://www.qhull.org"
SRC_URI="${HOMEPAGE}/download/${P}.tar.gz"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64 ~x86 ~x86-macos"
IUSE=""

src_compile() {
	# anything beyond -O1 leads to bad code in libqhull on amd64
	# with gcc-4.2
	if [[ "${ARCH}" == "amd64" ]]; then
		replace-flags -O? -O1
	fi

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	rm -fr "${ED}"/usr/share/doc/${PN}
	dodoc Announce.txt .txt File_id.diz README.txt REGISTER.txt
	cd html
	dohtml *
	dodoc *.txt
}
