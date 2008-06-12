# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsvg/libsvg-0.1.4.ebuild,v 1.22 2008/02/27 04:20:16 jer Exp $

EAPI="prefix"

inherit libtool

DESCRIPTION="A parser for SVG content in files or buffers"
HOMEPAGE="http://cairographics.org"
SRC_URI="http://cairographics.org/snapshots/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="dev-libs/libxml2
	media-libs/jpeg
	media-libs/libpng"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
