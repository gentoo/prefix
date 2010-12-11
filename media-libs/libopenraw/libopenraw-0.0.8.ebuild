# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libopenraw/libopenraw-0.0.8.ebuild,v 1.12 2010/11/07 22:32:57 ssuominen Exp $

EAPI=2

inherit eutils

DESCRIPTION="Decoding library for RAW image formats"
HOMEPAGE="http://libopenraw.freedesktop.org"
SRC_URI="http://${PN}.freedesktop.org/download/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"
IUSE="gtk static-libs test"

RDEPEND="virtual/jpeg
	>=dev-libs/libxml2-2.5
	gtk? ( x11-libs/gtk+:2 )"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.35
	dev-util/pkgconfig
	test? ( net-misc/curl )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-ljpegdcompressor.patch
	epatch "${FILESDIR}"/${P}-testsuite.patch
}

src_configure() {
	econf \
		--with-boost=${EPREFIX}/usr \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable gtk gnome)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README TODO
}
