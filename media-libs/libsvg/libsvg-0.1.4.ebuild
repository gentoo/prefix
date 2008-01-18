# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsvg/libsvg-0.1.4.ebuild,v 1.19 2008/01/17 19:37:26 grobian Exp $

EAPI="prefix"

DESCRIPTION="A parser for SVG content in files or buffers"
HOMEPAGE="http://xsvg.org/"
SRC_URI="http://cairographics.org/snapshots/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="dev-libs/libxml2
	media-libs/jpeg
	media-libs/libpng"

DEPEND="dev-util/pkgconfig
	${RDEPEND}"

src_install() {
	make install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README TODO
}
