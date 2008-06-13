# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libsvg-cairo/libsvg-cairo-0.1.6.ebuild,v 1.23 2008/02/26 19:33:10 drac Exp $

EAPI="prefix"

DESCRIPTION="Render SVG content using cairo"
HOMEPAGE="http://cairographics.org"
SRC_URI="http://cairographics.org/snapshots/${P}.tar.gz"

LICENSE="X11"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND="x11-libs/cairo
	media-libs/libsvg"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}
