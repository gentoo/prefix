# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsvg/libsvg-0.1.4.ebuild,v 1.23 2009/01/04 15:42:10 angelos Exp $

inherit autotools eutils libtool

DESCRIPTION="A parser for SVG content in files or buffers"
HOMEPAGE="http://cairographics.org"
SRC_URI="http://cairographics.org/snapshots/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

RDEPEND="dev-libs/libxml2
	media-libs/jpeg
	media-libs/libpng"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-asneeded.patch
	elibtoolize
	eautoconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
