# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libopenraw/libopenraw-0.0.9.ebuild,v 1.11 2012/05/30 13:27:58 aballier Exp $

EAPI=4

DESCRIPTION="A decoding library for RAW image formats"
HOMEPAGE="http://libopenraw.freedesktop.org/wiki/"
SRC_URI="http://${PN}.freedesktop.org/download/${P}.tar.bz2"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"
IUSE="gtk static-libs test"

RDEPEND="virtual/jpeg
	dev-libs/libxml2
	gtk? (
		>=dev-libs/glib-2
		>=x11-libs/gdk-pixbuf-2.24.0:2
		)"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.35
	virtual/pkgconfig
	test? ( net-misc/curl )"

DOCS=( AUTHORS ChangeLog NEWS README TODO )

src_configure() {
	econf \
		--with-boost=${EPREFIX}/usr \
		$(use_enable static-libs static) \
		$(use_enable gtk gnome)
}

src_install() {
	default
	find "${ED}"usr -name '*.la' -exec rm -f {} +
}
