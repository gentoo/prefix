# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/librsync/librsync-0.9.7-r1.ebuild,v 1.2 2008/01/16 20:56:17 grobian Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="Flexible remote checksum-based differencing"
HOMEPAGE="http://librsync.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Bug #142945
	epatch "${FILESDIR}"/${P}-huge-files.patch

	# Bug #185600
	elibtoolize
	epunt_cxx
}

src_compile() {
	econf --enable-shared || die
	emake || die
}

src_install () {
	emake DESTDIR="${D}" install || die
	dodoc NEWS AUTHORS THANKS README TODO
}
