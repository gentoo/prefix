# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/exif/exif-0.6.19.ebuild,v 1.1 2009/11/14 20:31:50 maekke Exp $

EAPI=2

DESCRIPTION="Small CLI util to show EXIF infos hidden in JPEG files"
HOMEPAGE="http://libexif.sourceforge.net/"
SRC_URI="mirror://sourceforge/libexif/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="nls"

RDEPEND=">=dev-libs/popt-1.14
	 >=media-libs/libexif-${PV}"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable nls)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
