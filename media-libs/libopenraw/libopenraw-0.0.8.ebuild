# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libopenraw/libopenraw-0.0.8.ebuild,v 1.2 2009/06/18 22:26:24 ssuominen Exp $

EAPI=2

DESCRIPTION="Decoding library for RAW image formats"
HOMEPAGE="http://libopenraw.freedesktop.org"
SRC_URI="http://${PN}.freedesktop.org/download/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="gtk test"

RDEPEND=">=dev-libs/boost-1.35
	media-libs/jpeg
	>=dev-libs/libxml2-2.5
	gtk? ( x11-libs/gtk+:2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	test? ( net-misc/curl )"

src_configure() {
	econf \
		--with-boost=${EPREFIX}/usr \
		--disable-dependency-tracking \
		$(use_enable gtk gnome)
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
