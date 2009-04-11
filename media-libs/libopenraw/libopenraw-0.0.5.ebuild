# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libopenraw/libopenraw-0.0.5.ebuild,v 1.9 2008/10/29 08:53:04 remi Exp $

inherit eutils

DESCRIPTION="Decoding library for RAW image formats"
HOMEPAGE="http://libopenraw.freedesktop.org"
SRC_URI="http://${PN}.freedesktop.org/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE="gtk"

RESTRICT="test"

RDEPEND="dev-libs/boost
	media-libs/jpeg
	gtk? ( >=x11-libs/gtk+-2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}/${P}-ljpegdcompressor.patch"
}

src_compile() {
	econf \
	--with-boost=${EPREFIX}/usr \
	--disable-dependency-tracking $(use_enable gtk gnome)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README TODO
}
