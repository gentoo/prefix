# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/lsdvd/lsdvd-0.16-r2.ebuild,v 1.1 2009/07/20 23:13:34 ssuominen Exp $

EAPI=2
inherit autotools eutils

DESCRIPTION="Utility for getting info out of DVDs"
HOMEPAGE="http://untrepid.com/lsdvd/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="media-libs/libdvdread"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/${P}-types.patch \
		"${FILESDIR}"/${P}-usec.patch \
		"${FILESDIR}"/${P}-title.patch
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README
}
