# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/gif2png/gif2png-2.5.1.ebuild,v 1.14 2008/01/26 10:32:00 grobian Exp $

inherit eutils

DESCRIPTION="Converts images from gif format to png format"
HOMEPAGE="http://catb.org/~esr/gif2png/"
SRC_URI="http://catb.org/~esr/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="media-libs/libpng"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# bug 139338 - gif2png won't compile with libpng-1.2.12
	epatch "${FILESDIR}"/${PN}-2.5.1-libpng.patch
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
